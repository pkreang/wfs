import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/survey/models/survey_model.dart';
import 'package:wfs/features/survey/models/survey_question_type_model.dart';
import 'package:wfs/features/survey/pages/survey_list_page.dart';
import 'package:wfs/features/survey/services/survey_service.dart';
import 'package:wfs/widgets/app_filter_sheet.dart';

class _SurveyService extends SurveyService {
  final queries = <String>[];
  final statusFilters = <bool?>[];
  final requests = <Completer<List<Survey>>>[];

  @override
  Future<List<Survey>> fetchSurveys(Ref ref, {String sText = '', bool? isActive}) {
    queries.add(sText);
    statusFilters.add(isActive);
    final request = Completer<List<Survey>>();
    requests.add(request);
    return request.future;
  }

  @override
  Future<List<SurveyQuestionType>> getQuestionTypes(Ref ref) async => [];
}

void main() {
  setUpAll(() async {
    // Use real font metrics so the existing Create button fits its toolbar slot.
    final configFile = File('.dart_tool/package_config.json');
    final packages = jsonDecode(await configFile.readAsString())['packages'] as List;
    final flutterPackage = packages.firstWhere((package) => package['name'] == 'flutter');
    final flutterRoot = Directory.fromUri(configFile.uri.resolve(flutterPackage['rootUri'] as String)).parent.parent;
    final font = File('${flutterRoot.path}/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf');
    final loader = FontLoader('Roboto')..addFont(font.readAsBytes().then((bytes) => ByteData.sublistView(bytes)));
    await loader.load();
  });

  Future<void> showPage(WidgetTester tester, _SurveyService service) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [surveyServiceProvider.overrideWithValue(service)],
        child: MaterialApp(
          theme: ThemeData(fontFamily: 'Roboto'),
          home: const SurveyListPage(),
        ),
      ),
    );
    service.requests.single.complete([const Survey(title: 'All surveys')]);
    await tester.pumpAndSettle();
  }

  testWidgets('searches only on keyboard Done, keeps submitted query on refresh and clears it', (tester) async {
    final service = _SurveyService();
    await showPage(tester, service);
    expect(tester.widget<TextField>(find.byType(TextField)).textInputAction, TextInputAction.done);

    await tester.enterText(find.byType(TextField), 'cus');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.enterText(find.byType(TextField), '  customer  ');
    await tester.pump(const Duration(milliseconds: 500));
    expect(service.queries, ['']);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(service.queries, ['', 'customer']);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    service.requests.last.complete([const Survey(title: 'Customer satisfaction')]);
    await tester.pumpAndSettle();
    expect(find.text('Customer satisfaction'), findsOneWidget);
    expect(find.text('All surveys'), findsNothing);

    await tester.enterText(find.byType(TextField), 'unsubmitted draft');
    await tester.pump(const Duration(milliseconds: 500));
    expect(service.queries, ['', 'customer']);
    final refresh = tester.widget<RefreshIndicator>(find.byType(RefreshIndicator)).onRefresh();
    expect(service.queries.last, 'customer');
    service.requests.last.complete([const Survey(title: 'Updated customer survey')]);
    await refresh;
    await tester.pumpAndSettle();
    expect(find.text('Updated customer survey'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '');
    await tester.pump(const Duration(milliseconds: 500));
    expect(service.queries, ['', 'customer', 'customer']);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(service.queries, ['', 'customer', 'customer', '']);
    service.requests.last.complete([const Survey(title: 'All surveys')]);
    await tester.pumpAndSettle();
    expect(find.text('All surveys'), findsOneWidget);
  });

  testWidgets('ignores older submitted searches after newer results', (tester) async {
    final service = _SurveyService();
    await showPage(tester, service);

    await tester.enterText(find.byType(TextField), 'old');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.enterText(find.byType(TextField), 'new');
    await tester.testTextInput.receiveAction(TextInputAction.done);

    await tester.enterText(find.byType(TextField), 'latest');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    service.requests[3].complete([const Survey(title: 'Latest result')]);
    await tester.pumpAndSettle();
    service.requests[1].complete([const Survey(title: 'Old result')]);
    service.requests[2].completeError(Exception('Stale failure'));
    await tester.pumpAndSettle();
    expect(find.text('Latest result'), findsOneWidget);
    expect(find.text('Old result'), findsNothing);
    expect(find.textContaining('Stale failure'), findsNothing);
  });

  testWidgets('shows empty results and allows resubmitting the same query after API errors', (tester) async {
    final service = _SurveyService();
    await showPage(tester, service);
    await tester.enterText(find.byType(TextField), 'missing');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    service.requests.last.complete([]);
    await tester.pumpAndSettle();
    expect(find.text('No surveys found.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'failure');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    service.requests.last.completeError(Exception('Search failed'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Search failed'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'failure');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(service.queries, ['', 'missing', 'failure', 'failure']);
    service.requests.last.complete([const Survey(title: 'Retry result')]);
    await tester.pumpAndSettle();
    expect(find.text('Retry result'), findsOneWidget);
  });

  testWidgets('leaves draft text unsubmitted and ignores results after disposal', (tester) async {
    final service = _SurveyService();
    await showPage(tester, service);
    await tester.enterText(find.byType(TextField), 'active');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.enterText(find.byType(TextField), 'pending');

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 300));
    service.requests.last.complete([const Survey(title: 'Disposed result')]);
    await tester.pump();
    expect(service.queries, ['', 'active']);
    expect(tester.takeException(), isNull);
  });

  for (final status in [('Active', true), ('InActive', false)]) {
    testWidgets('applies ${status.$1} only on Search and retains it for Done and refresh', (tester) async {
      final service = _SurveyService();
      await showPage(tester, service);
      await tester.enterText(find.byType(TextField), 'customer');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      service.requests.last.complete([const Survey(title: 'Customer survey')]);
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Filter'));
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(of: find.byType(AppFilterSheet), matching: find.text(status.$1)));
      await tester.pumpAndSettle();
      expect(service.statusFilters, [null, null]);
      await tester.tap(find.text('ค้นหา'));
      expect(service.queries.last, 'customer');
      expect(service.statusFilters.last, status.$2);
      service.requests.last.complete([const Survey(title: 'Filtered customer survey')]);
      await tester.pumpAndSettle();
      expect(find.byType(AppFilterSheet), findsNothing);

      await tester.enterText(find.byType(TextField), 'updated');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      expect(service.queries.last, 'updated');
      expect(service.statusFilters.last, status.$2);
      service.requests.last.complete([const Survey(title: 'Updated survey')]);
      await tester.pumpAndSettle();
      final refresh = tester.widget<RefreshIndicator>(find.byType(RefreshIndicator)).onRefresh();
      expect(service.queries.last, 'updated');
      expect(service.statusFilters.last, status.$2);
      service.requests.last.complete([const Survey(title: 'Refreshed survey')]);
      await refresh;
      await tester.pumpAndSettle();
      expect(service.statusFilters, [null, null, status.$2, status.$2, status.$2]);
    });
  }

  testWidgets('discards closed filter edits and clears status only after Search', (tester) async {
    final service = _SurveyService();
    await showPage(tester, service);
    final filterState = ProviderScope.containerOf(tester.element(find.byType(SurveyListPage)));

    await tester.tap(find.byTooltip('Filter'));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(AppFilterSheet), matching: find.text('InActive')));
    await tester.tap(find.text('ค้นหา'));
    service.requests.last.complete([const Survey(title: 'Inactive survey')]);
    await tester.pumpAndSettle();
    expect(filterState.read(surveyListProvider).isActive, isFalse);

    await tester.tap(find.byTooltip('Filter'));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(AppFilterSheet), matching: find.text('Active')));
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(service.statusFilters, [null, false]);
    expect(filterState.read(surveyListProvider).isActive, isFalse);

    await tester.tap(find.byTooltip('Filter'));
    await tester.pumpAndSettle();
    final selectedLabel = tester.widget<Text>(find.descendant(of: find.byType(AppFilterSheet), matching: find.text('InActive')));
    expect(selectedLabel.style?.color, const Color(0xFF0689FF));
    await tester.tap(find.text('ล้างค่า'));
    await tester.pumpAndSettle();
    expect(service.statusFilters, [null, false]);
    expect(filterState.read(surveyListProvider).isActive, isFalse);
    await tester.tap(find.text('ค้นหา'));
    expect(service.statusFilters, [null, false, null]);
    service.requests.last.complete([const Survey(title: 'All surveys')]);
    await tester.pumpAndSettle();
    expect(filterState.read(surveyListProvider).isActive, isNull);
  });
}
