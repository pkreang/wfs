import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/survey/models/survey_dashboard_analytics.dart';
import 'package:wfs/features/survey/pages/survey_dashboard_page.dart';
import 'package:wfs/features/survey/services/survey_dashboard_service.dart';
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

class _DashboardService extends SurveyDashboardService {
  final requestedIDs = <String>[];
  Future<SurveyDashboardAnalytics> Function() load = () async => SurveyDashboardAnalytics.fromJson({'TotalSent': 5, 'TotalResponded': 0, 'ResponseRate': 0.0, 'AverageOverallScore': 0.0});

  @override
  Future<SurveyDashboardAnalytics> fetchAnalytics(Ref ref, String surveyTemplateID) async {
    requestedIDs.add(surveyTemplateID);
    return load();
  }
}

void main() {
  test('requests dashboard analytics using the selected template and token', () async {
    const templateID = 'template & feedback+?';
    final result = await http.runWithClient(
      () => SurveyDashboardService().fetchAnalytics(_SurveyRef(), templateID),
      () => MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.origin, 'https://sfe-api.appnormalthink.com');
        expect(request.url.path, '/survey/admin/dashboard-analytics');
        expect(request.url.queryParameters, {'surveyTemplateID': templateID});
        expect(request.headers['Authorization'], 'Bearer test-access-token');
        return http.Response(jsonEncode({'TotalSent': 5, 'TotalResponded': 0, 'ResponseRate': 0.0, 'AverageOverallScore': 0.0}), 200);
      }),
    );

    expect(result.totalSent, 5);
    expect(result.totalResponded, 0);
    expect(result.responseRate, 0);
    expect(result.averageOverallScore, 0);
  });

  Future<void> showPage(WidgetTester tester, _DashboardService service) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [surveyDashboardServiceProvider.overrideWithValue(service)],
        child: const MaterialApp(
          home: SurveyDashboardPage(surveyID: 'template-id', title: 'Customer feedback'),
        ),
      ),
    );
  }

  testWidgets('displays the sample analytics including zero values on mobile', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final service = _DashboardService();
    await showPage(tester, service);
    await tester.pumpAndSettle();

    expect(service.requestedIDs, ['template-id']);
    expect(find.text('Customer feedback'), findsOneWidget);
    expect(find.text('Total sent'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Total responded'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('Response rate'), findsOneWidget);
    expect(find.text('0.0%'), findsOneWidget);
    expect(find.text('Average overall score'), findsOneWidget);
    expect(find.text('0.0'), findsOneWidget);
    expect(find.textContaining('Last submitted'), findsNothing);
    expect(find.text('Survey Score Summary'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('displays API rate and score directly on a wide layout', (tester) async {
    final service = _DashboardService()..load = () async => SurveyDashboardAnalytics.fromJson({'TotalSent': 20, 'TotalResponded': 7, 'ResponseRate': 35.0, 'AverageOverallScore': 8.5});
    await showPage(tester, service);
    await tester.pumpAndSettle();

    expect(find.text('20'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('35.0%'), findsOneWidget);
    expect(find.text('8.5'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Total sent')).dy, tester.getTopLeft(find.text('Total responded')).dy);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows loading and retries failed analytics requests', (tester) async {
    final pending = Completer<SurveyDashboardAnalytics>();
    final service = _DashboardService()..load = () => pending.future;
    await showPage(tester, service);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    pending.completeError(Exception('Request failed'));
    await tester.pumpAndSettle();
    expect(find.text('ไม่สามารถโหลดข้อมูล Survey Dashboard ได้'), findsOneWidget);

    service.load = () async => const SurveyDashboardAnalytics(totalSent: 10, totalResponded: 4, responseRate: 40, averageOverallScore: 8);
    await tester.tap(find.text('ลองใหม่'));
    await tester.pumpAndSettle();
    expect(service.requestedIDs, ['template-id', 'template-id']);
    expect(find.text('40.0%'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
