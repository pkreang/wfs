import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/http/api_client.dart';
import 'package:wfs/features/leaddashboard2/models/lead_dashboard2_metric.dart';
import 'package:wfs/providers/auth_provider.dart';

class LeadDashboard2Service {
  final apiClient = ApiClient('https://sfe-api-test.appnormalthink.com');

  Future<LeadDashboard2Response> fetchDashboard(
    Ref ref, {
    String? startDate,
    String? endDate,
  }) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    return apiClient.getOnly(
      path: '/lead/conversion-report',
      query: startDate != null && endDate != null
          ? {'DateFrom': startDate, 'DateTo': endDate}
          : null,
      decode: (json) {
        final map = json as Map<String, dynamic>;
        final data = map['data'] ?? map['Data'] ?? map;
        return LeadDashboard2Response.fromJson(
          Map<String, dynamic>.from(data as Map),
        );
      },
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }
}
