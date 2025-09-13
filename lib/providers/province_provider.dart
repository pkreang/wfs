import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:http/http.dart' as http;
import 'package:wfs/config/api_config.dart';
import 'package:wfs/models/province_model.dart';
import 'package:wfs/services/province_service.dart';
import 'auth_provider.dart';

final provinceProvider = Provider<ProvinceService>((ref) {
  return ProvinceService();
});

final selectedProvinceProvider = StateProvider<String?>((ref) => null);

final provinceGetList = FutureProvider<List<Province>>((ref) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('User is not authenticated.');
  }

  final ProvinceGetList = ref.watch(provinceProvider);

  return ProvinceGetList.getList(accessToken);
});

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
