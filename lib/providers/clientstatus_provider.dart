import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/models/clientstatus_model.dart';
import 'package:wfs/services/clientstatus_service.dart';
import 'auth_provider.dart';

final ClientStatusProvider = Provider<ClientStatusService>((ref) {
  return ClientStatusService();
});

final ClientStatusGetList = FutureProvider<List<ClientStatus>>((ref) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('User is not authenticated.');
  }

  final ClientStatusService = ref.watch(ClientStatusProvider);

  return ClientStatusService.GetList(accessToken);
});
