import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class AuthService {
  
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // สำหรับ web ใช้ application/json แทน x-www-form-urlencoded
      final headers = kIsWeb 
          ? {'Content-Type': 'application/json'}
          : {'Content-Type': 'application/x-www-form-urlencoded'};

      final body = kIsWeb 
          ? json.encode({'username': username, 'password': password})
          : {'username': username, 'password': password};

      final response = await http.post(
        Uri.parse(ApiConfig.loginUrl),
        headers: headers,
        body: body,
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Invalid username or password');
      } else if (response.statusCode == 403) {
        throw Exception('Access forbidden - CORS issue or server error');
      } else {
        throw Exception('Failed to login: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Login error: $e');
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception('Network error - Please check your internet connection');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUserRole(String accessToken, String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.userRoleUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
      );

      print('Get user role response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get user role: ${response.statusCode}');
      }
    } catch (e) {
      print('Get user role error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUserId(String accessToken, String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.userIdUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
      );

      print('Get user ID response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get user ID: ${response.statusCode}');
      }
    } catch (e) {

      rethrow;
    }
  }

  Future<Map<String, dynamic>> getAppointment(String accessToken, String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.appointmentUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
      );



      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get appointment: ${response.statusCode}');
      }
    } catch (e) {

      rethrow;
    }
  }
}