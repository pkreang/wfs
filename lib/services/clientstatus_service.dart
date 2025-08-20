import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wfs/models/clientstatus_model.dart';
import '../config/api_config.dart';

class ClientStatusService {
  Future<List<ClientStatus>> GetList(String accessToken) async {
    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }
    final uri = Uri.parse(ApiConfig.getListClientStatusUrl);
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> ClientStatusListJson = data['client_status'];
      return ClientStatusListJson.map(
        (json) => ClientStatus.fromJson(json),
      ).toList();
    } else {
      throw Exception(
        'Failed to load Clients. Status code: ${response.statusCode}',
      );
    }
  }
}
