import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wfs/config/api_config.dart';
import 'package:wfs/models/saleterritorie_model.dart';
import 'package:wfs/models/territory_model.dart';

import '../http/api_client.dart';

class SaleterritorieService {
  final apiClient = ApiClient(ApiConfig.baseUrl);
  Future<List<SaleTerritorie>> GetLists(String accessToken) async {
    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }
    final uri = Uri.parse(ApiConfig.getSaleTerritorieUrl);
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> saleTerritorieListJson = data['sale_territorie'];
      return saleTerritorieListJson
          .map((json) => SaleTerritorie.fromJson(json))
          .toList();
    } else {
      throw Exception(
        'Failed to load Clients. Status code: ${response.statusCode}',
      );
    }
  }

  Future<List<Territory>> GetList(String accessToken) async {
    final territories = await apiClient.get(
      path: "/sale/territory/?IsActive=true",
      decode: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['sale_territorie'] as List? ?? const [];

        return Territory.listFromJson(list);
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );

    return territories;
  }
}
