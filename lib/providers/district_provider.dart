import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:http/http.dart' as http;
import 'package:wfs/config/api_config.dart';
import 'package:wfs/models/district_model.dart';
import 'package:wfs/services/district_service.dart';
import 'auth_provider.dart';

final districtProvider = Provider<DistrictService>((ref) {
  return DistrictService();
});

final selectedDistrictProvider = StateProvider <String?>((ref) => null);

final districtGetList = FutureProvider<List<District>>((ref) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('User is not authenticated.');
  }

  final DistrictGetList = ref.watch(districtProvider);

  return DistrictGetList.getList(accessToken);
});

final districtsProvider = FutureProvider.family<List<District>, String>((
  ref,
  provinceCode,
) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;
  if (accessToken == null) {
    throw Exception('Authentication token is not available.');
  }
  final uri = Uri.parse(
    ApiConfig.baseUrl +
        "/address/district/?IsActive=true&ProvinceID=$provinceCode",
  );
  final response = await http.get(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final List<dynamic> districtListJson = data['districts'];
    return districtListJson.map((json) => District.fromJson(json)).toList();
  } else {
    throw Exception(
      'Failed to load Clients. Status code: ${response.statusCode}',
    );
  }
});
