import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/models/purposetype_model.dart';
import 'package:wfs/services/purposetype_service.dart';
import 'auth_provider.dart';

final purposetypeProvider = Provider<PurposetypeService>((ref) {
  return PurposetypeService();
});

final perposeTypeGetList = FutureProvider<List<PurposeType>>((ref) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('User is not authenticated.');
  }

  final purposetypeService = ref.watch(purposetypeProvider);

  return purposetypeService.GetList(accessToken);
});
