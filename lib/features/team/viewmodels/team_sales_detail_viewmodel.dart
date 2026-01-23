import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/team/services/team_service.dart';
import 'package:wfs/models/user_model.dart';

class TeamSalesDetailViewModel extends StateNotifier<AsyncValue<List<User>>> {
  TeamSalesDetailViewModel(this.ref, this.id) : super(const AsyncValue.loading()) {
    fetch();
  }

  final Ref ref;
  final String id;

  TeamService get _teamService => ref.read(teamServiceProvider);

  Future<void> fetch() async {
    state = const AsyncLoading();

    try {
      final users = await _teamService.getUserByManagerID(ref, id);
      state = AsyncValue.data(users);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() => fetch();
}
