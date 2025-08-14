import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wfs/config/api_config.dart';
import 'package:wfs/models/userprofile_model.dart';

class UserProfileService {
  Future<UserProfile> GetUserProfile(String accessToken) async {
    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }

    final uri = Uri.parse(ApiConfig.userProfileUrl);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final dynamic userProfileJson = data['user_profile'];
      return UserProfile.fromJson(userProfileJson);
    } else {
      throw Exception(
        'Failed to load UserProfiles. Status code: ${response.statusCode}',
      );
    }
  }
}
