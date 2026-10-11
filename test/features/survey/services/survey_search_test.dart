import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wfs/features/survey/services/survey_service.dart';
import 'package:wfs/features/survey/models/survey_recipient_filter.dart';
import 'package:wfs/models/auth_model.dart';
import 'package:wfs/providers/auth_provider.dart';

class _SurveyRef implements Ref {
  @override
  T read<T>(ProviderListenable<T> provider) {
    expect(provider, authProvider);
    return AuthState(accessToken: 'test-access-token') as T;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  for (final status in ['Pending', 'Responded']) {
    for (final type in ['Client', 'Lead']) {
      test('fetches recipients with responStatus=$status and type=$type', () async {
        final SurveyRecipientFilter filter = (responStatus: status, type: type, sendDateFrom: null, sendDateTo: null);
        await http.runWithClient(
          () => SurveyService().searchAnswers(_SurveyRef(), 'template-id', sText: 'customer', filter: filter),
          () => MockClient((request) async {
            expect(request.url.queryParameters, {'SurveyTemplateID': 'template-id', 'sText': 'customer', 'ResponseStatus': status, 'type': type});
            return http.Response('[]', 200);
          }),
        );
      });
    }
  }

  for (final sendDateFrom in <DateTime?>[null, DateTime(2026, 10, 1, 9, 30)]) {
    for (final sendDateTo in <DateTime?>[null, DateTime(2026, 10, 6, 18, 45)]) {
      test('fetches recipients with sendDateFrom=$sendDateFrom and sendDateTo=$sendDateTo', () async {
        final SurveyRecipientFilter filter = (responStatus: 'Pending', type: 'Client', sendDateFrom: sendDateFrom, sendDateTo: sendDateTo);
        await http.runWithClient(
          () => SurveyService().searchAnswers(_SurveyRef(), 'template-id', sText: 'customer', filter: filter),
          () => MockClient((request) async {
            expect(request.url.queryParameters, {'SurveyTemplateID': 'template-id', 'sText': 'customer', 'ResponseStatus': 'Pending', 'type': 'Client', if (sendDateFrom != null) 'SentDateFrom': '2026-10-01', if (sendDateTo != null) 'SentDateTo': '2026-10-06'});
            return http.Response('[]', 200);
          }),
        );
      });
    }
  }

  for (final query in ['', 'ลูกค้า & customer + feedback?']) {
    test('fetches recipients with template ID and encoded sText "$query"', () async {
      final recipients = await http.runWithClient(
        () => SurveyService().searchAnswers(_SurveyRef(), 'template-id', sText: query),
        () => MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/survey/admin/search');
          expect(request.url.queryParameters, {'SurveyTemplateID': 'template-id', if (query.isNotEmpty) 'sText': query});
          expect(request.headers['Authorization'], 'Bearer test-access-token');
          return http.Response(
            jsonEncode([
              {'SurveyResponseID': 'response-id', 'ClientName': 'Customer'},
            ]),
            200,
          );
        }),
      );
      expect(recipients.single.surveyResponseID, 'response-id');
    });
  }

  for (final query in ['', 'แบบสอบถาม & customer + feedback?']) {
    for (final isActive in <bool?>[null, true, false]) {
      test('fetches surveys with correctly encoded query "$query" and IsActive=$isActive', () async {
        final surveys = await http.runWithClient(
          () => SurveyService().fetchSurveys(_SurveyRef(), sText: query, isActive: isActive),
          () => MockClient((request) async {
            expect(request.method, 'GET');
            expect(request.url.path, '/survey/admin/templates');
            expect(request.url.hasQuery, query.isNotEmpty || isActive != null);
            expect(request.url.queryParameters, {if (query.isNotEmpty) 'sText': query, if (isActive != null) 'IsActive': isActive.toString()});
            expect(request.headers['Authorization'], 'Bearer test-access-token');
            return http.Response(
              jsonEncode([
                {'SurveyTemplateID': 'survey-id', 'TemplateName': 'Customer feedback'},
              ]),
              200,
            );
          }),
        );
        expect(surveys.single.surveyID, 'survey-id');
        expect(surveys.single.title, 'Customer feedback');
      });
    }
  }
}
