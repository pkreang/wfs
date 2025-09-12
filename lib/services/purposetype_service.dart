import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wfs/config/api_config.dart';
import 'package:wfs/models/purposetype_model.dart';

class PurposetypeService {
  Future<List<PurposeType>> getList(String accessToken) async {
    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }
    final uri = Uri.parse(ApiConfig.getPurposeTypeUrl);
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> purposeTypeListJson = data['purpose_types'];
      return purposeTypeListJson
          .map((json) => PurposeType.fromJson(json))
          .toList();
    } else {
      throw Exception(
        'Failed to load Clients. Status code: ${response.statusCode}',
      );
    }
  }

  Future<PurposeType> Add(String accessToken, PurposeType purposeType) async {
    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.addProductUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(purposeType),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final dynamic ProductListJson = data['product_type'];
        return PurposeType.fromJson(ProductListJson);
      } else {
        throw Exception(
          'Failed to load Clients. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to load Clients. Status code: ');
    }
  }
}
