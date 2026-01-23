import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wfs/config/api_config.dart';
import 'package:wfs/models/user_model.dart';
import 'package:wfs/models/userprofile_model.dart';
import 'package:wfs/models/userrole_model.dart';
import 'package:wfs/providers/auth_provider.dart';

class UserService {
  Future<List<User>> getList(String accessToken) async {
    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }
    final uri = Uri.parse(ApiConfig.getListUserUrl);
    final response = await http.get(uri, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'});
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> UserListJson = data['users'];
      return UserListJson.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load Users. Status code: ${response.statusCode}');
    }
  }

  Future<void> Add(String accessToken, User user) async {
    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.addUser),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $accessToken'},
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

  Future<UserProfile> GetUserProfile(String accessToken) async {
    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }

    final uri = Uri.parse(ApiConfig.userProfileUrl);

    final response = await http.get(uri, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final dynamic userProfileJson = data['user_profile'];
      return UserProfile.fromJson(userProfileJson);
    } else {
      throw Exception('Failed to load UserProfiles. Status code: ${response.statusCode}');
    }
  }

  Future<List<User>> GetSales(Ref ref) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }

    final uri = Uri.parse(ApiConfig.getListSaleUrl);

    final response = await http.get(uri, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final dynamic userJson = data['users'];
      if (userJson is List) {
        return userJson.map((json) => User.fromJson(json)).toList();
      }
      if (userJson is Map<String, dynamic>) {
        return [User.fromJson(userJson)];
      }
      throw Exception('Unexpected user_profile format.');
    } else {
      throw Exception('Failed to load UserProfiles. Status code: ${response.statusCode}');
    }
  }

  Future<List<User>> GetSupervisors(Ref ref) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }

    final uri = Uri.parse(ApiConfig.getListSupervisorUrl);

    final response = await http.get(uri, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final dynamic userJson = data['users'];
      if (userJson is List) {
        return userJson.map((json) => User.fromJson(json)).toList();
      }
      if (userJson is Map<String, dynamic>) {
        return [User.fromJson(userJson)];
      }
      throw Exception('Unexpected user_profile format.');
    } else {
      throw Exception('Failed to load UserProfiles. Status code: ${response.statusCode}');
    }
  }

  Future<List<UserRole>> fetchUserRoles(Ref ref) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }

    final uri = Uri.parse(ApiConfig.getUserRoleUrl);

    final response = await http.get(uri, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final dynamic userRolesJson = data['user_roles'];
      if (userRolesJson is List) {
        return userRolesJson.map((json) => UserRole.fromJson(json)).toList();
      }
      throw Exception('Unexpected user_roles format.');
    } else {
      throw Exception('Failed to load UserRoles. Status code: ${response.statusCode}');
    }
  }

  Future<User> getByID(String accessToken, String userID) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/user/?UserID=$userID');

    final response = await http.get(uri, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final dynamic usersJson = data['users'];

      if (usersJson is List && usersJson.isNotEmpty) {
        return User.fromJson(usersJson.first);
      } else if (usersJson is Map<String, dynamic>) {
        return User.fromJson(usersJson);
      }

      throw Exception('User not found');
    } else {
      throw Exception('Failed to load User. Status code: ${response.statusCode}');
    }
  }

  Future<File?> getProfileImage(WidgetRef ref, String userId) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/user/profile_image?user_id=$userId');

      final response = await http.get(uri, headers: {'Authorization': 'Bearer $accessToken'});

      if (response.statusCode == 200) {
        // Response is binary image data
        final bytes = response.bodyBytes;

        // Save to temporary file
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/profile_$userId.jpg');
        await file.writeAsBytes(bytes);

        return file;
      } else {
        print('Failed to get profile image. Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting profile image: $e');
      return null;
    }
  }

  Future<File?> _compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(file.absolute.path, targetPath, quality: 70, minWidth: 1024, minHeight: 1024, format: CompressFormat.jpeg);

      if (result != null) {
        final compressedFile = File(result.path);
        print('Original size: ${await file.length()} bytes');
        print('Compressed size: ${await compressedFile.length()} bytes');
        return compressedFile;
      }
      return null;
    } catch (e) {
      print('Error compressing image: $e');
      return file; // Return original file if compression fails
    }
  }

  Future<bool> uploadProfileImage(WidgetRef ref, File imageFile) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }

    try {
      // Compress image before uploading
      final compressedFile = await _compressImage(imageFile);
      final fileToUpload = compressedFile ?? imageFile;

      // Check file size (10MB = 10 * 1024 * 1024 bytes)
      final fileSize = await fileToUpload.length();
      const maxSize = 10 * 1024 * 1024; // 10MB

      if (fileSize > maxSize) {
        throw Exception('FILE_TOO_LARGE'); // Special error code for size check
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/user/upload_profile_image?user_id=${authState.userID.toString()}');

      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $accessToken';

      var stream = http.ByteStream(fileToUpload.openRead());
      var length = await fileToUpload.length();

      var multipartFile = http.MultipartFile('profile_image', stream, length, filename: fileToUpload.path.split('/').last);

      request.files.add(multipartFile);

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = json.decode(responseData);
        return (data['status'] as String?)?.toLowerCase() == 'success';
      } else {
        final responseData = await response.stream.bytesToString();
        print('Upload failed with status: ${response.statusCode}');
        print('Response body: $responseData');
        throw Exception('Failed to upload profile image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading profile image: $e');
      rethrow; // Rethrow to let widget handle the error
    }
  }

  Future<bool> updatePincode(WidgetRef ref, String pincode) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/user/update_pincode?pincode=$pincode');

      final response = await http.post(uri, headers: {'Authorization': 'Bearer $accessToken'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final isSuccess = (data['status'] as String?)?.toLowerCase() == 'success';

        if (isSuccess) {
          // Update auth state with new pincode
          final currentAuth = ref.read(authProvider);

          ref.read(authProvider.notifier).state = currentAuth.copyWith(pincode: pincode);
        }

        return isSuccess;
      } else {
        print('Update pincode failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to update pincode. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating pincode: $e');
      throw Exception('Failed to update pincode: $e');
    }
  }

  Future<bool> validatePincode(WidgetRef ref, String accessToken, String pincode) async {
    try {
      final uri = Uri.parse('${ApiConfig.validatePincodeUrl}?pincode=$pincode');

      final response = await http.post(uri, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['status'] as String?)?.toLowerCase() == 'success' || (data['valid'] as bool?) == true;
      } else {
        print('Validate pincode failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error validating pincode: $e');
      throw Exception('Failed to validate pincode: $e');
    }
  }
}
