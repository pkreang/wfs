import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/survey/models/survey_dashboard_model.dart';
import 'package:wfs/features/survey/models/survey_recipient.dart';
import 'package:wfs/features/survey/models/survey_recipient_filter.dart';
import 'package:wfs/features/appointment/widgets/app_datepicker.dart';
import 'package:wfs/widgets/app_filter_sheet.dart';
import 'package:wfs/features/survey/pages/survey_recipient_answer.dart';
import 'package:wfs/features/survey/pages/survey_recipient_list_page.dart';
import 'package:wfs/features/survey/services/survey_service.dart';
import 'package:wfs/providers/auth_provider.dart';

const _responseID = '3F10BB04-2775-4588-8ACE-883D7E0A89C6';
const _payload = {
  'SurveyResponseID': _responseID,
  'SurveyTemplateID': 'template-id',
  'ClientID': 'client-id',
  'ClientName': 'Phone001 Mail001',
  'AppointmentID': null,
  'SentDate': '2026-09-29T07:25:56.153000',
  'ResponseStatus': 'Responded',
  'RespondedDate': '2026-09-29T07:26:51.417000',
  'OverallScore': 6.5,
  'IsAnswered': true,
  'details': [
    {
      'QuestionID': 'question-1',
      'QuestionText': 'เจ้าหน้าที่ขายและช่างเทคนิคให้คำแนะนำและบริการด้วยความสุภาพเรียบร้อยเพียงใด xxx?',
      'TypeCode': 'SCORE_0_10',
      'Score': 7,
      'FreeText': 'Do not use this for a score answer',
    },
    {'QuestionID': 'question-2', 'QuestionText': 'ข้อเสนอแนะเพิ่มเติมเกี่ยวกับการให้บริการในครั้งนี้', 'TypeCode': 'FREE_TEXT', 'Score': 9, 'FreeText': 'Test\nรายละเอียดเพิ่มเติม'},
    {'QuestionID': 'question-3', 'QuestionText': 'ระดับความพึงพอใจต่อประสิทธิภาพและความเร็วในการติดตั้งอุปกรณ์ในภาพรวม YYY', 'TypeCode': 'SCORE_0_10', 'Score': 6, 'FreeText': null},
  ],
};

class _SurveyService extends SurveyService {
  final requestedIDs = <String>[];
  final recipientQueries = <({String surveyTemplateID, String sText})>[];
  final recipientFilters = <SurveyRecipientFilter>[];
  Future<SurveyResponse> Function()? load;
  Future<List<SurveyRecipient>> Function()? loadRecipients;

  @override
  Future<SurveyResponse> getResponseById(Ref ref, String surveyResponseID) async {
    requestedIDs.add(surveyResponseID);
    return load == null ? SurveyResponse.fromJson(_payload) : await load!();
  }

  @override
  Future<List<SurveyRecipient>> searchAnswers(Ref ref, String surveyTemplateID, {String sText = '', SurveyRecipientFilter filter = emptySurveyRecipientFilter}) async {
    recipientQueries.add((surveyTemplateID: surveyTemplateID, sText: sText));
    recipientFilters.add(filter);
    if (loadRecipients != null) return loadRecipients!();
    return const [
      SurveyRecipient(surveyResponseID: 'other-response', clientName: 'Other recipient', email: '', sentDate: null),
      SurveyRecipient(surveyResponseID: _responseID, clientName: 'Selected recipient', email: '', sentDate: null),
    ];
  }
}

void main() {
  setUpAll(() async {
    // Match the app's font metrics when testing the shared calendar on a phone.
    final configFile = File('.dart_tool/package_config.json');
    final packages = jsonDecode(await configFile.readAsString())['packages'] as List;
    final flutterPackage = packages.firstWhere((package) => package['name'] == 'flutter');
    final flutterRoot = Directory.fromUri(configFile.uri.resolve(flutterPackage['rootUri'] as String)).parent.parent;
    final font = File('${flutterRoot.path}/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf');
    final loader = FontLoader('Roboto')..addFont(font.readAsBytes().then((bytes) => ByteData.sublistView(bytes)));
    await loader.load();
  });

  Future<void> showPage(WidgetTester tester, _SurveyService service, {Widget? page}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [surveyServiceProvider.overrideWithValue(service)],
        child: MaterialApp(
          theme: ThemeData(fontFamily: 'Roboto'),
          home: page ?? const SurveyRecipientAnswerPage(surveyResponseID: _responseID),
        ),
      ),
    );
  }

  test('fetches the selected response with authorization and decodes details', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(authProvider.notifier).updateAuthState(accessToken: 'test-access-token', foundUserId: 'user-id', firstName: '', lastName: '');

    final response = await http.runWithClient(
      () => container.read(surveyRecipientAnswerProvider(_responseID).future),
      () => MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), 'https://sfe-api.appnormalthink.com/survey/admin/responses/$_responseID');
        expect(request.headers['Authorization'], 'Bearer test-access-token');
        return http.Response(jsonEncode(_payload), 200, headers: {'content-type': 'application/json; charset=utf-8'});
      }),
    );

    expect(response.surveyResponseID, _responseID);
    expect(response.details.map((detail) => detail.score), [7, 9, 6]);
    expect(response.details[1].freeText, 'Test\nรายละเอียดเพิ่มเติม');
  });

  testWidgets('shows only questions and their typed answers on a narrow screen', (tester) async {
    tester.view.physicalSize = const Size(320, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await showPage(tester, _SurveyService());
    await tester.pumpAndSettle();

    expect(find.text('7 / 10'), findsOneWidget);
    expect(find.text('6 / 10'), findsOneWidget);
    expect(find.text('Test\nรายละเอียดเพิ่มเติม'), findsOneWidget);
    expect(find.text('9 / 10'), findsNothing);
    expect(find.text('Do not use this for a score answer'), findsNothing);
    expect(find.text('Phone001 Mail001'), findsNothing);
    expect(find.text(_responseID), findsNothing);
    expect(find.text('6.5'), findsNothing);
    for (final detail in _payload['details']! as List<Map<String, Object?>>) {
      expect(find.text(detail['QuestionText']! as String), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('passes the tapped recipient response ID to the answer page', (tester) async {
    final service = _SurveyService();
    await showPage(
      tester,
      service,
      page: const SurveyRecipientListPage(surveyTemplateID: 'template-id', title: 'Survey'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Selected recipient'));
    await tester.pumpAndSettle();

    expect(service.requestedIDs, [_responseID]);
    expect(find.text('7 / 10'), findsOneWidget);
  });

  testWidgets('searches recipients on Done and refreshes only the submitted query', (tester) async {
    final service = _SurveyService();
    await showPage(
      tester,
      service,
      page: const SurveyRecipientListPage(surveyTemplateID: 'template-id', title: 'Survey'),
    );
    await tester.pumpAndSettle();
    final field = find.byType(TextField);
    expect(tester.widget<TextField>(field).textInputAction, TextInputAction.done);

    await tester.enterText(field, '  customer  ');
    await tester.pump(const Duration(milliseconds: 500));
    expect(service.recipientQueries, [(surveyTemplateID: 'template-id', sText: '')]);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(service.recipientQueries.last, (surveyTemplateID: 'template-id', sText: 'customer'));

    await tester.enterText(field, 'unsubmitted draft');
    await tester.pump(const Duration(milliseconds: 500));
    expect(service.recipientQueries.length, 2);
    await tester.widget<RefreshIndicator>(find.byType(RefreshIndicator)).onRefresh();
    await tester.pumpAndSettle();
    expect(service.recipientQueries.last.sText, 'customer');

    await tester.enterText(field, '');
    await tester.pump(const Duration(milliseconds: 500));
    expect(service.recipientQueries.length, 3);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(service.recipientQueries.map((query) => query.sText), ['', 'customer', 'customer', '']);
  });

  testWidgets('keeps search visible during errors and resubmits the same query', (tester) async {
    final service = _SurveyService();
    await showPage(
      tester,
      service,
      page: const SurveyRecipientListPage(surveyTemplateID: 'template-id', title: 'Survey'),
    );
    await tester.pumpAndSettle();
    service.loadRecipients = () async => throw Exception('Search failed');
    await tester.enterText(find.byType(TextField), 'customer');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Unable to load'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    service.loadRecipients = () async => [];
    await tester.enterText(find.byType(TextField), 'customer');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(service.recipientQueries.map((query) => query.sText), ['', 'customer', 'customer']);
    expect(find.text('No Recipient found'), findsOneWidget);
  });

  testWidgets('ignores an older recipient search after the latest results', (tester) async {
    final service = _SurveyService();
    await showPage(
      tester,
      service,
      page: const SurveyRecipientListPage(surveyTemplateID: 'template-id', title: 'Survey'),
    );
    await tester.pumpAndSettle();
    final older = Completer<List<SurveyRecipient>>();
    final latest = Completer<List<SurveyRecipient>>();
    service.loadRecipients = () => older.future;
    await tester.enterText(find.byType(TextField), 'older');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    service.loadRecipients = () => latest.future;
    await tester.enterText(find.byType(TextField), 'latest');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    latest.complete([]);
    await tester.pumpAndSettle();
    older.completeError(Exception('Stale search error'));
    await tester.pumpAndSettle();
    expect(find.text('No Recipient found'), findsOneWidget);
    expect(find.text('Unable to load'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('applies recipient filters on Search and retains them for Done and refresh', (tester) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final service = _SurveyService();
    await showPage(
      tester,
      service,
      page: const SurveyRecipientListPage(surveyTemplateID: 'template-id', title: 'Survey'),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'customer');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'unsubmitted');
    await tester.tap(find.byTooltip('Filter'));
    await tester.pumpAndSettle();

    final statusY = tester.getTopLeft(find.text('Pending')).dy;
    final typeY = tester.getTopLeft(find.text('Client')).dy;
    final dateY = tester.getTopLeft(find.text('SendDateFrom')).dy;
    final endDateY = tester.getTopLeft(find.text('SendDateTo')).dy;
    expect(dateY, lessThan(endDateY));
    expect(endDateY, lessThan(statusY));
    expect(statusY, lessThan(typeY));
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Responded'));
    await tester.tap(find.text('Lead'));
    final from = DateTime(2026, 10, 1);
    final to = DateTime(2026, 10, 31);
    await tester.tap(find.text('SendDateFrom'));
    await tester.pumpAndSettle();
    tester.widget<AppDatePicker>(find.byType(AppDatePicker)).onConfirm!(from);
    Navigator.of(tester.element(find.byType(AppDatePicker))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('SendDateTo'));
    await tester.pumpAndSettle();
    tester.widget<AppDatePicker>(find.byType(AppDatePicker)).onConfirm!(to);
    Navigator.of(tester.element(find.byType(AppDatePicker))).pop();
    await tester.pumpAndSettle();
    expect(service.recipientFilters.length, 2);
    expect(find.text('01/10/2026'), findsOneWidget);
    expect(find.text('31/10/2026'), findsOneWidget);

    await tester.tap(find.text('ค้นหา'));
    await tester.pumpAndSettle();
    final SurveyRecipientFilter expectedFilter = (responStatus: 'Responded', type: 'Lead', sendDateFrom: from, sendDateTo: to);
    expect(service.recipientFilters.last, expectedFilter);
    expect(service.recipientQueries.last.sText, 'customer');
    await tester.enterText(find.byType(TextField), 'updated');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(service.recipientFilters.last, expectedFilter);
    await tester.widget<RefreshIndicator>(find.byType(RefreshIndicator)).onRefresh();
    await tester.pumpAndSettle();
    expect(service.recipientFilters.last, expectedFilter);
    expect(service.recipientQueries.last.sText, 'updated');
    expect(tester.takeException(), isNull);
  });

  testWidgets('discards recipient filter edits on Close and clears only on Search', (tester) async {
    final service = _SurveyService();
    await showPage(
      tester,
      service,
      page: const SurveyRecipientListPage(surveyTemplateID: 'template-id', title: 'Survey'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Filter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pending'));
    await tester.tap(find.text('Client'));
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(service.recipientFilters, [emptySurveyRecipientFilter]);

    await tester.tap(find.byTooltip('Filter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pending'));
    await tester.tap(find.text('Client'));
    await tester.tap(find.text('ค้นหา'));
    await tester.pumpAndSettle();
    expect(service.recipientFilters.last.responStatus, 'Pending');
    expect(service.recipientFilters.last.type, 'Client');

    await tester.tap(find.byTooltip('Filter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ล้างค่า'));
    await tester.pumpAndSettle();
    expect(service.recipientFilters.length, 2);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Filter'));
    await tester.pumpAndSettle();
    final selectedStatus = tester.widget<Text>(find.descendant(of: find.byType(AppFilterSheet), matching: find.text('Pending')));
    expect(selectedStatus.style?.color, const Color(0xFF0689FF));
    await tester.tap(find.text('ล้างค่า'));
    await tester.tap(find.text('ค้นหา'));
    await tester.pumpAndSettle();
    expect(service.recipientFilters.last, emptySurveyRecipientFilter);
  });

  testWidgets('shows loading, retries errors and handles empty details', (tester) async {
    final pending = Completer<SurveyResponse>();
    final service = _SurveyService()..load = () => pending.future;
    await showPage(tester, service);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    pending.completeError(Exception('Request failed'));
    await tester.pumpAndSettle();
    expect(find.text('ไม่สามารถโหลดคำตอบได้'), findsOneWidget);
    service.load = () async => SurveyResponse.fromJson({..._payload, 'details': []});
    await tester.tap(find.text('ลองใหม่'));
    await tester.pumpAndSettle();

    expect(service.requestedIDs, [_responseID, _responseID]);
    expect(find.text('ยังไม่ได้ตอบแบบสอบถาม'), findsOneWidget);
  });

  testWidgets('refreshes answers and displays refresh errors without throwing', (tester) async {
    final service = _SurveyService();
    await showPage(tester, service);
    await tester.pumpAndSettle();
    final refresh = tester.widget<RefreshIndicator>(find.byType(RefreshIndicator));
    service.load = () async => throw Exception('Refresh failed');
    await refresh.onRefresh();
    await tester.pumpAndSettle();

    expect(service.requestedIDs, [_responseID, _responseID]);
    expect(find.text('ไม่สามารถโหลดคำตอบได้'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
