import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/models/user_model.dart';
import 'package:wfs/services/userservice.dart';
import 'auth_provider.dart';

final userProvider = Provider<UserService>((ref) {
  return UserService();
});

final GetListUser = FutureProvider<List<User>>((ref) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('User is not authenticated.');
  }

  final userService = ref.watch(userProvider);

  return userService.GetList(accessToken);
});
