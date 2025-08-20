import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:wfs/config/api_config.dart';
import 'package:wfs/models/subdistrict_model.dart';
import 'package:wfs/services/subdistrict_service.dart';
import 'auth_provider.dart';

final SubDistrictProvider = Provider<SubDistrictService>((ref) {
  return SubDistrictService();
});

final selectedSubdistrictProvider = StateProvider<String?>((ref) => null);

final subDistrictGetList = FutureProvider<List<Subdistrict>>((ref) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('User is not authenticated.');
  }

  final SubDistrictGetList = ref.watch(SubDistrictProvider);

  return SubDistrictGetList.GetList(accessToken);
});

final subdistrictsProvider = FutureProvider.family<List<Subdistrict>, String>((
  ref,
  districtCode,
) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;
  if (accessToken == null) {
    throw Exception('Authentication token is not available.');
  }
  final uri = Uri.parse(
    ApiConfig.baseUrl +
        "/address/subdistrict/?IsActive=true&DistrictID=$districtCode",
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
    final List<dynamic> subDistrictListJson = data['subdistricts'];
    return subDistrictListJson
        .map((json) => Subdistrict.fromJson(json))
        .toList();
  } else {
    throw Exception(
      'Failed to load Clients. Status code: ${response.statusCode}',
    );
  }
});
