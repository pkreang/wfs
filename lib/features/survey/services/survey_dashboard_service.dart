import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/http/api_client.dart';
import 'package:wfs/features/survey/models/survey_dashboard_analytics.dart';
import 'package:wfs/providers/auth_provider.dart';

class SurveyDashboardService {
  SurveyDashboardService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient(_baseUrl);

  static const _baseUrl = 'https://sfe-api.appnormalthink.com';

  final ApiClient _apiClient;

  Future<SurveyDashboardAnalytics> fetchAnalytics(Ref ref, String surveyTemplateID) async {
    return _apiClient.getOnly(
      path: '/survey/admin/dashboard-analytics',
      query: {'surveyTemplateID': surveyTemplateID},
      headers: {'Authorization': 'Bearer ${ref.read(authProvider).accessToken}'},
      decode: (json) => SurveyDashboardAnalytics.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }
}
