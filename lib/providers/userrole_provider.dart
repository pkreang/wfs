import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/models/userrole_model.dart';
import 'package:wfs/services/userrole_service.dart';
import 'auth_provider.dart';

final userRoleProvider = Provider<UserRoleService>((ref) {
  return UserRoleService();
});

final GetListUserRole = FutureProvider<List<UserRole>>((ref) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('User is not authenticated.');
  }

  final userRoleService = ref.watch(userRoleProvider);

  return userRoleService.GetList(accessToken);
});
