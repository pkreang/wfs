import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/models/clients_model.dart';
import 'package:wfs/services/client_service.dart';
import 'auth_provider.dart';

final clientServiceProvider = Provider<ClientService>((ref) {
  return ClientService();
});

final clientsProvider = FutureProvider<List<Clients>>((ref) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('User is not authenticated.');
  }

  final clientService = ref.watch(clientServiceProvider);

  return clientService.fetchClients(accessToken);
});
