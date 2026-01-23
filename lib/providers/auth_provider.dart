import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wfs/core/http/api_client.dart';
import 'package:wfs/models/user_model.dart';

import '../models/auth_model.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _userKey = 'user_data';

  AuthNotifier(this._authService) : super(AuthState());

  void updateAuthState({required String accessToken, required String foundUserId, String? userRoleID, String? userRoleName, String? email, String? pincode}) {
    state = state.copyWith(isLoading: false, isAuthenticated: true, accessToken: accessToken, userID: foundUserId, userRoleID: userRoleID, userRoleName: userRoleName, email: email, pincode: pincode);
  }

  Future<void> login(String username, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final loginData = await _authService.login(username, password);

      if (loginData['status'] == "success") {
      } else {
        throw Exception('Login failed: ${loginData['message'] ?? 'Unknown error'}');
      }

      final accessToken = loginData['access_token'];
      final tokenType = loginData['token_type'];
      final tokentExp = loginData['token_expires'];

      if (accessToken == null || tokenType == null) {
        throw Exception('Invalid login response - missing token information');
      }

      final user = await _authService.getUserId(accessToken);
      // if (user["status"] == "failed") {
      //   throw Exception('Failed to get user ID: ${user["message"] ?? 'Unknown error'}');
      // }

      final List<dynamic> users = user['users'];
      final Map<String, dynamic> userMap = {for (var user in users) user['UserID']: user};

      String? foundUserId;
      String? userRoleID;
      String? userRoleName;
      String? email;
      String? pincode;
      for (var user in userMap.values) {
        if (user['Email'] == username) {
          foundUserId = user['UserID'];
          final userRole = user['UserRole'];
          userRoleID = userRole['UserRoleID'];
          userRoleName = userRole['UserRoleName'];
          email = user['Email'];
          pincode = user['Pincode'];
          break;
        }
      }

      if (foundUserId == null) {
        throw Exception('User details not found for the logged-in user.');
      }

      // Save token and expiry date to secure storage
      await _storage.write(key: 'access_token', value: accessToken);
      await _storage.write(key: 'user_id', value: foundUserId);
      await _storage.write(key: 'token_type', value: tokenType);
      await _storage.write(key: 'token_expiry', value: tokentExp.toString());
      await _storage.write(key: _userKey, value: json.encode(userMap[foundUserId]));

      updateAuthState(accessToken: accessToken, foundUserId: foundUserId, userRoleID: userRoleID, userRoleName: userRoleName, email: email, pincode: pincode);
    } catch (e) {
      String errorMessage = e.toString();

      if (errorMessage.contains('XMLHttpRequest')) {
        errorMessage = 'Network error - Please check your internet connection';
      } else if (errorMessage.contains('CORS')) {
        errorMessage = 'Server configuration issue - Please contact administrator';
      } else if (errorMessage.contains('401')) {
        errorMessage = 'Invalid username or password';
      } else if (errorMessage.contains('403')) {
        errorMessage = 'Access forbidden - Please try again later';
      }

      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'user_id');
    await _storage.delete(key: 'token_type');
    await _storage.delete(key: 'token_expiry');
    await _storage.delete(key: _userKey);
    await _storage.delete(key: 'user_pin_hash'); // Clear PIN hash as well

    print('logout');

    state = AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<bool> forgotPassword(String email) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      return await _authService.forgotPassword(email);
    } catch (e, st) {
      state = state.copyWith(errorMessage: e is ApiException ? e.message : 'Request failed');

      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> changePassword(WidgetRef ref, String oldPassword, String newPassword) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      return await _authService.changePassword(ref, oldPassword, newPassword);
    } catch (e, st) {
      state = state.copyWith(errorMessage: e is ApiException ? e.message : 'Request failed');

      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> saveUser(User user) async {
    try {
      final userJson = json.encode(user.toJson());
      await _storage.write(key: _userKey, value: userJson);
      print('User saved to secure storage');
    } catch (e) {
      print('Error saving user to secure storage: $e');
    }
  }

  Future<User?> getUser() async {
    try {
      final userJson = await _storage.read(key: _userKey);
      if (userJson == null) return null;

      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    } catch (e) {
      print('Error getting user from secure storage: $e');
      return null;
    }
  }

  // Remove User from secure storage
  Future<void> removeUser() async {
    await _storage.delete(key: _userKey);
  }
}
