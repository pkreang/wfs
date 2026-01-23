import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/client/models/client.dart';
import 'package:wfs/features/team/services/team_service.dart';

class TeamClientDetailViewModel extends StateNotifier<AsyncValue<List<Client>>> {
  TeamClientDetailViewModel(this.ref, this.ids) : super(const AsyncValue.loading()) {
    fetch();
  }

  final Ref ref;
  final List<String> ids;

  TeamService get _teamService => ref.read(teamServiceProvider);

  Future<void> fetch() async {
    List<Client> clients = [];
    state = const AsyncLoading();

    try {
      for (final id in ids) {
        final client = await _teamService.getClientById(ref, id);
        clients.add(client);
      }
      state = AsyncValue.data(clients);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() => fetch();
}
