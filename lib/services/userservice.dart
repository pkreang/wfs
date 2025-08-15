import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wfs/config/api_config.dart';
import 'package:wfs/models/user_model.dart';

class UserService {
  Future<List<User>> GetList(String accessToken) async {
    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }
    final uri = Uri.parse(ApiConfig.getListUserUrl);
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> UserListJson = data['users'];
      return UserListJson.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to load Users. Status code: ${response.statusCode}',
      );
    }
  }

  Future<void> Add(String accessToken, User user) async {
    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.addUser),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(user),
      );
      //jsonEncode(user)
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('สำเร็จ: $data');
      } else {
        print('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('เกิดข้อผิดพลาด: $e');
    }
  }
}
