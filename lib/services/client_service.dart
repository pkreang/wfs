import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wfs/config/api_config.dart';
import 'package:wfs/models/client_model.dart';

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

  Future<List<Client>> GetList(String accessToken) async {
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
    String jsonString = '''
    {
        "FirstName": "TestName999"  ,
    "LastName" : "TestLastName"    ,
    "Address"  : "123 Bangkok"  ,
    "Phone"  : "0896-525665588"  ,
    "Email"  : "abc3@mail.com"  ,
    "SalesTerritoryID"  : "570C655E-B5F4-4FCD-A5FF-693E85E6274B" ,
    "ClientStatusID" : "593A6DDC-27B0-472C-BC9C-53747FBB3185"  ,
    "ClientLevelID" : "3EDA2919-C815-4078-923F-18652F4EF689"  ,
    "Noted"  : "xxxxxxxxxxxxxxx"  ,
    "AvailableTimeStart"  : "09:00"  ,
    "AvailableTimeEnd"  : "16:00",
    "IsActive" : true  ,
    "CreatedBy"   : "9E0DC5F7-1FD6-41F3-9137-14711FC510F6" ,      
    "ModifiedBy"   : "9E0DC5F7-1FD6-41F3-9137-14711FC510F6",
    "ClientAddresses"  : [{
        "Address":"123/4 Sukhumvit Road",
        "CountryID":1,
        "ProvinceID":1,
        "DistrictID":13,
        "SubDistrictID":2583,
        "Latitude": null,
        "Longitude":null,
        "IsPrimary": true  ,
        "IsActive": true    
    }] ,
    "ClientProducts":[
        "C948FD64-E522-43FD-907E-0EDB3D5C0893"
    ],
    "ClientCompanies"  : [{       
        "CompanyID": "FD5964B8-5C9B-40CC-A2A6-D9CEEE8F523E",    
        "Position": "Staff",
        "Noted": null,
        "AvailableTimeStart" : null,
        "AvailableTimeEnd": null,
        "CreatedBy"   : "9E0DC5F7-1FD6-41F3-9137-14711FC510F6" ,      
        "ModifiedBy"   : "9E0DC5F7-1FD6-41F3-9137-14711FC510F6"
    }] 
    }
    ''';
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
        body: jsonString, //json.encode(client),
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
}
