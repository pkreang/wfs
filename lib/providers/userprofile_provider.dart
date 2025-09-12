import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/models/userprofile_model.dart';
import 'package:wfs/services/userprofile_service.dart';
import 'auth_provider.dart';

final userProfileProvider = Provider<UserProfileService>((ref) {
  return UserProfileService();
});

final getUserProfile = FutureProvider<UserProfile>((ref) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('User is not authenticated.');
  }

  final userProfileService = ref.watch(userProfileProvider);

  return userProfileService.GetUserProfile(accessToken);
});
