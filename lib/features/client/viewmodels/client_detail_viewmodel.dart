import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/client/models/client.dart';
import 'package:wfs/features/client/services/client_service.dart';

class ClientDetailViewModel extends StateNotifier<AsyncValue<Client>> {
  ClientDetailViewModel(this.ref, this.id) : super(const AsyncValue.loading()) {
    fetch();
  }

  final Ref ref;
  final String id;

  ClientService get _clientService => ref.read(clientServiceProvider);

  Future<void> fetch() async {
    state = const AsyncLoading();
    final res = await AsyncValue.guard(() => _clientService.getById(ref, id));
    state = res;
  }

  Future<void> refresh() => fetch();
}
