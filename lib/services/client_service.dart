import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' as apiClient;
import 'package:wfs/config/api_config.dart';
import 'package:wfs/core/http/api_client.dart';
import 'package:wfs/models/client_model.dart';
import 'package:wfs/features/client/models/client.dart' as client_model;
import 'package:wfs/providers/auth_provider.dart';
import 'package:wfs/utility/json_helper.dart';

class ClientService {
  final apiClient = ApiClient(ApiConfig.baseUrl);

  Future<client_model.Client> getById(Ref ref, String clientId) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    print('something;');

    final client = await apiClient.get(
      path: "/client/id/" + clientId,
      decode: (json) {
        print('json: $json');
        final map = json as Map<String, dynamic>;

        return client_model.Client.fromJson(map['client']);
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );

    return client;
  }

  Future<Client> GetById(String accessToken, String guid) async {
    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }
    final uri = Uri.parse(ApiConfig.getByIdClientUrl + guid);
    final response = await http.get(uri, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'});
    if (response.statusCode == 200) {
      print('response: ${response.body}');
      final data = json.decode(response.body);
      final dynamic ClientListJson = data['client'];
      return Client.fromJson(ClientListJson);
    } else {
      throw Exception('Failed to load Clients. Status code: ${response.statusCode}');
    }
  }

  Future<List<Client>> getList(String accessToken) async {
    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }
    final uri = Uri.parse(ApiConfig.clientUrl);
    final response = await http.get(uri, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'});
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> ClientListJson = data['clients'];
      return ClientListJson.map((json) => Client.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load Clients. Status code: ${response.statusCode}');
    }
  }

  Future<List<Client>> fetchClients(String accessToken) async {
    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }
    final uri = Uri.parse(ApiConfig.clientUrl);
    final response = await http.get(uri, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'});
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> ClientListJson = data['clients'];
      return ClientListJson.map((json) => Client.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load Clients. Status code: ${response.statusCode}');
    }
  }

  Future<Client> Add(String accessToken, Client client) async {
    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }
    try {
      print('json.encode(client): ${json.encode(client)}');
      final response = await http.post(
        Uri.parse(ApiConfig.addClientUrl),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $accessToken'},
        body: json.encode(client),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final dynamic ClientJson = data['client'];
        return Client.fromJson(ClientJson);
      } else {
        throw Exception('Failed to load Clients. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load Clients. Status code: ');
    }
  }

  Future<Client> Edit(String accessToken, String guid, Client client) async {
    client.clientAddresses![0].countryID = 1;
    client.clientAddresses![0].countryName = "ไทย";
    client.clientAddresses![0].isActive = true;
    client.clientAddresses![0].isPrimary = true;
    var clientEdit = Client(
      firstName: client.firstName,
      lastName: client.lastName,
      address: client.address,
      phone: client.phone,
      email: client.email,
      salesTerritoryID: client.salesTerritoryID,
      clientStatusID: client.clientStatusID,
      clientLevelID: client.clientLevelID,
      noted: client.noted,
      availableTimeStart: client.availableTimeStart,
      availableTimeEnd: client.availableTimeEnd,
      isActive: client.isActive,
      createdBy: client.createdBy,
      modifiedBy: client.modifiedBy,
      clientAddresses: client.clientAddresses,
      clientProducts: client.clientProducts,
      clientCompanies: client.clientCompanies,
      clientID: client.clientID,
      createdDate: client.createdDate,
      modifiedDate: client.modifiedDate,
      salesTerritory: client.salesTerritory,
    );
    printLongString(jsonEncode(clientEdit));

    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.editClientUrl + guid),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $accessToken'},
        body: jsonEncode(clientEdit),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final dynamic clientJson = data['client'];
        return Client.fromJson(clientJson);
      } else {
        throw Exception('Failed to load appointments. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load appointments. Status code:');
    }
  }
}
