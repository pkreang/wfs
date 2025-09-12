import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wfs/config/api_config.dart';
import 'package:wfs/models/client_model.dart';
import 'package:wfs/utility/json_helper.dart';

class ClientService {
  Future<Client> GetById(String accessToken, String guid) async {
    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }
    final uri = Uri.parse(ApiConfig.getByIdClientUrl + guid);
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final dynamic ClientListJson = data['client'];
      return Client.fromJson(ClientListJson);
    } else {
      throw Exception(
        'Failed to load Clients. Status code: ${response.statusCode}',
      );
    }
  }

  Future<List<Client>> getList(String accessToken) async {
    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }
    final uri = Uri.parse(ApiConfig.clientUrl);
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> ClientListJson = data['clients'];
      return ClientListJson.map((json) => Client.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to load Clients. Status code: ${response.statusCode}',
      );
    }
  }

  Future<List<Client>> fetchClients(String accessToken) async {
    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }
    final uri = Uri.parse(ApiConfig.clientUrl);
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> ClientListJson = data['clients'];
      return ClientListJson.map((json) => Client.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to load Clients. Status code: ${response.statusCode}',
      );
    }
  }

  Future<Client> Add(String accessToken, Client client) async {
    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.addClientUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(client),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final dynamic ClientJson = data['client'];
        return Client.fromJson(ClientJson);
      } else {
        throw Exception(
          'Failed to load Clients. Status code: ${response.statusCode}',
        );
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
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(clientEdit),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final dynamic clientJson = data['client'];
        return Client.fromJson(clientJson);
      } else {
        throw Exception(
          'Failed to load appointments. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to load appointments. Status code:');
    }
  }
}
