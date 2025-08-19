import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:wfs/config/api_config.dart';
import 'package:wfs/models/district_model.dart';
import 'package:wfs/models/province_model.dart';
import 'package:wfs/models/subdistrict_model.dart';
import 'package:wfs/providers/auth_provider.dart';

final provincesProvider = FutureProvider<List<Province>>((ref) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;
  if (accessToken == null) {
    throw Exception('Authentication token is not available.');
  }
  final uri = Uri.parse(ApiConfig.getListProvinceUrl);
  final response = await http.get(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final List<dynamic> ProvinceListJson = data['provinces'];
    return ProvinceListJson.map((json) => Province.fromJson(json)).toList();
  } else {
    throw Exception(
      'Failed to load Clients. Status code: ${response.statusCode}',
    );
  }
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
