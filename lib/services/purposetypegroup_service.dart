import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wfs/config/api_config.dart';
import 'package:wfs/models/PurposeTypeGroup_model.dart';

class PurposeTypeGroupService {
  Future<List<PurposeTypeGroup>> getList(String accessToken) async {
    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }
    final uri = Uri.parse(ApiConfig.getPurposeTypeGroupUrl);
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> PurposeTypeGroupListJson =
          data['purpose_type_groups'];
      return PurposeTypeGroupListJson.map(
        (json) => PurposeTypeGroup.fromJson(json),
      ).toList();
    } else {
      throw Exception(
        'Failed to load Clients. Status code: ${response.statusCode}',
      );
    }
  }
}
