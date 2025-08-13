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
          'Authorization': 'Bearer $accessToken'
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
        throw Exception('Failed to get companies: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {

      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception('Network error - Please check your internet connection');
      }
      rethrow;
    }
  }
} 