import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/company_model.dart';

class CompanyService {
  Future<CompanyResponse> getCompanies(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.companyUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return CompanyResponse.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 403) {
        throw Exception('Access forbidden - CORS issue or server error');
      } else {
        throw Exception(
          'Failed to get companies: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception(
          'Network error - Please check your internet connection',
        );
      }
      rethrow;
    }
  }

  Future<Company> Add(String accessToken, Company company) async {
    // String jsonString = '''
    //   {
    //   "CompanyName": "CompanyTest Tessdfast asdf9999"  ,
    // "TaxID" : "123457890"    ,
    // "SalesTerritoryID"  : "09A69122-4BE0-4201-8B53-3AEF1C24EBDC" ,
    // "Noted"  : "xxxxxxxxxxxxxxx"  ,
    // "IsActive" : true  ,
    // "CreatedBy"   : "9E0DC5F7-1FD6-41F3-9137-14711FC510F6" ,
    // "ModifiedBy"   : "9E0DC5F7-1FD6-41F3-9137-14711FC510F6",
    // "CompanyAddresses":[
    //      {
    //                 "Address": "123 ABC Rd.",
    //                 "ProvinceID": 1,
    //                 "DistrictID": 13,
    //                 "Latitude": null,
    //                 "IsPrimary": true,
    //                 "CreatedBy": "9E0DC5F7-1FD6-41F3-9137-14711FC510F6",
    //                 "ModifiedBy": "9E0DC5F7-1FD6-41F3-9137-14711FC510F6",
    //                 "CountryID": 1,
    //                 "SubDistrictID": 2583,
    //                 "Longitude": null,
    //                 "IsActive": true
    //             }
    // ]
    //   }
    //   ''';
    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.addCompanyUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(company),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final dynamic companyTypeJson = data['companies'];
        return Company.fromJson(companyTypeJson);
      } else {
        throw Exception(
          'Failed to load Clients. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to load Clients. Status code: ');
    }
  }

  Future<List<Company>> GetList(String accessToken) async {
    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }
    final uri = Uri.parse(ApiConfig.companyUrl);
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> companyTypeListJson = data['companies'];
      return companyTypeListJson.map((json) => Company.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to load Clients. Status code: ${response.statusCode}',
      );
    }
  }
}
