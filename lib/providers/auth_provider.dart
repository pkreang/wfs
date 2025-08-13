
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_model.dart';
import '../services/auth_service.dart';


final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  
  AuthNotifier(this._authService) : super(AuthState());
  
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

      if (accessToken == null || tokenType == null) {
        throw Exception('Invalid login response - missing token information');
      }


      final user = await _authService.getUserId(accessToken, tokenType);

      final List<dynamic> users = user['users'];
      final Map<String, dynamic> userMap = {
        for (var user in users) 
          user['UserID']: user 
      };
      
      String? foundUserId;
      for (var user in userMap.values) {
        if (user['Email'] == username) {
          foundUserId = user['UserID'];
          break; 
        }
      }

      if (foundUserId == null) {
        throw Exception('User details not found for the logged-in user.');
      }



      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        accessToken: accessToken,
        tokenType: tokenType,
        userID: foundUserId,
      );
      

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

  void logout() {
    state = AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}