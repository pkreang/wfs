import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/models/clientlevel_model.dart';
import 'package:wfs/services/clientlevel_service.dart';
import 'auth_provider.dart';

final clientLevelProvider = Provider<ClientLevelService>((ref) {
  return ClientLevelService();
});

final clientLevelGetList = FutureProvider<List<ClientLevel>>((ref) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('User is not authenticated.');
  }

  final clientLevelService = ref.watch(clientLevelProvider);

  return clientLevelService.getList(accessToken);
});
