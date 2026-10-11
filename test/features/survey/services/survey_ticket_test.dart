import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wfs/core/http/api_client.dart';
import 'package:wfs/features/survey/services/survey_service.dart';
import 'package:wfs/models/auth_model.dart';
import 'package:wfs/providers/auth_provider.dart';

class _TicketRef implements WidgetRef {
  @override
  T read<T>(ProviderListenable<T> provider) {
    expect(provider, authProvider);
    return AuthState(accessToken: 'test-access-token') as T;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const link = 'https://sfe-survey.appnormalthink.com?token=test-token';

  for (final appointmentID in <String?>['appointment-id', null]) {
    test('creates a ticket with AppointmentID=$appointmentID', () async {
      final result = await http.runWithClient(
        () => SurveyService().createTicket(
          _TicketRef(),
          surveyTemplateID: 'template-id',
          clientID: 'client-id',
          appointmentID: appointmentID,
        ),
        () => MockClient((request) async {
          expect(request.method, 'POST');
          expect(
            request.url.toString(),
            'https://sfe-api-test.appnormalthink.com/survey/admin/tickets',
          );
          expect(request.headers['Authorization'], 'Bearer test-access-token');
          expect(jsonDecode(request.body), {
            'SurveyTemplateID': 'template-id',
            'ClientID': 'client-id',
            'AppointmentID': appointmentID,
          });
          return http.Response(
            jsonEncode({
              'SurveyResponseID': 'response-id',
              'SurveyToken': 'test-token',
              'SurveyLink': link,
            }),
            201,
          );
        }),
      );
      expect(result, link);
    });
  }

  for (final response in [
    http.Response('{"message":"Ticket creation failed"}', 500),
    http.Response('{"Status":"error","message":"Ticket creation failed"}', 200),
    http.Response('{}', 201),
    http.Response('{"SurveyLink":"/relative-link"}', 201),
  ]) {
    test(
      'rejects failed or invalid ticket response ${response.body}',
      () async {
        await expectLater(
          http.runWithClient(
            () => SurveyService().createTicket(
              _TicketRef(),
              surveyTemplateID: 'template-id',
              clientID: 'client-id',
            ),
            () => MockClient((_) async => response),
          ),
          throwsA(isA<Exception>()),
        );
      },
    );
  }

  test('existing POST calls still require success status by default', () async {
    await expectLater(
      http.runWithClient(
        () => ApiClient(
          'https://example.com',
        ).post(path: '/test', body: {}, decode: (json) => json),
        () => MockClient((_) async => http.Response('{}', 200)),
      ),
      throwsA(isA<ApiException>()),
    );
  });
}
