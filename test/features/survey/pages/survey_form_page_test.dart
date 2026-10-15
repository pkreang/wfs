import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/core/http/api_client.dart';
import 'package:wfs/features/survey/models/survey_model.dart';
import 'package:wfs/features/survey/models/survey_question_type_model.dart';
import 'package:wfs/features/survey/pages/survey_form_page.dart';
import 'package:wfs/features/survey/services/survey_service.dart';

class _FailingSurveyService extends SurveyService {
  _FailingSurveyService(this.error);

  final Object error;
  int creates = 0;
  int updates = 0;

  @override
  Future<List<Survey>> fetchSurveys(
    Ref ref, {
    String sText = '',
    bool? isActive,
  }) async => [];

  @override
  Future<List<SurveyQuestionType>> getQuestionTypes(Ref ref) async => [];

  @override
  Future<bool> createSurvey(WidgetRef ref, Survey survey) async {
    creates++;
    throw error;
  }

  @override
  Future<bool> updateSurvey(WidgetRef ref, Survey survey) async {
    updates++;
    throw error;
  }
}

void main() {
  setUpAll(() async {
    // Match real font metrics for the existing fixed-width Back toolbar.
    final configFile = File('.dart_tool/package_config.json');
    final packages =
        jsonDecode(await configFile.readAsString())['packages'] as List;
    final flutterPackage = packages.firstWhere(
      (package) => package['name'] == 'flutter',
    );
    final flutterRoot = Directory.fromUri(
      configFile.uri.resolve(flutterPackage['rootUri'] as String),
    ).parent.parent;
    final font = File(
      '${flutterRoot.path}/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf',
    );
    final loader = FontLoader(
      'Roboto',
    )..addFont(font.readAsBytes().then((bytes) => ByteData.sublistView(bytes)));
    await loader.load();
  });

  Future<void> save(
    WidgetTester tester,
    _FailingSurveyService service, {
    bool editing = false,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [surveyServiceProvider.overrideWithValue(service)],
        child: MaterialApp(
          theme: ThemeData(fontFamily: 'Roboto'),
          home: SurveyFormPage(
            survey: editing ? const Survey(surveyID: 'survey-1') : null,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'a');
    await tester.enterText(fields.at(1), 'Description');
    await tester.enterText(fields.at(2), 'a');
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
  }

  for (final editing in [false, true]) {
    testWidgets(
      'shows 422 field errors on ${editing ? 'update' : 'create'} and allows retry',
      (tester) async {
        final service = _FailingSurveyService(
          ApiException(
            message: 'HTTP 422',
            httpStatus: 422,
            body: jsonEncode({
              'detail': [
                {
                  'loc': ['body', 'TemplateName'],
                  'msg': 'String should have at least 3 characters',
                },
                {
                  'loc': ['body', 'Questions', 0, 'QuestionText'],
                  'msg': 'String should have at least 5 characters',
                },
              ],
            }),
          ),
        );
        await save(tester, service, editing: editing);
        expect(find.text('ไม่สามารถดำเนินการได้'), findsOneWidget);
        expect(
          find.text(
            'Title: String should have at least 3 characters\nQuestion 1: String should have at least 5 characters',
          ),
          findsOneWidget,
        );
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(SurveyFormPage), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('Ok'));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<TextField>(find.byType(TextField).first)
              .controller!
              .text,
          'a',
        );
        await tester.tap(find.text('Done'));
        await tester.pumpAndSettle();
        expect(editing ? service.updates : service.creates, 2);
        expect(tester.takeException(), isNull);
      },
    );
  }

  final cases = <String, (Object, String)>{
    'plain detail': (
      ApiException(
        message: 'HTTP 400',
        body: {'detail': 'Template already exists'},
      ),
      'Template already exists',
    ),
    'non-JSON response': (
      ApiException(message: 'HTTP 500', body: '<html>Server error</html>'),
      'HTTP 500',
    ),
    'network error': (
      Exception('Connection failed'),
      'ไม่สามารถบันทึกข้อมูลได้ กรุณาลองใหม่อีกครั้ง',
    ),
  };
  for (final entry in cases.entries) {
    testWidgets('shows dialog for ${entry.key}', (tester) async {
      await save(tester, _FailingSurveyService(entry.value.$1));
      expect(find.text(entry.value.$2), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
