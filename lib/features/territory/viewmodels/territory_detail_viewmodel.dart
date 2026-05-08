import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/territory/models/territory_model.dart';
import 'package:wfs/features/territory/services/territory_service.dart';

class TerritoryDetailViewModel extends StateNotifier<AsyncValue<TerritoryModel>> {
  TerritoryDetailViewModel(this.ref, this.id) : super(const AsyncValue.loading()) {
    fetch();
  }

  final Ref ref;
  final String id;

  TerritoryService get _territoryService => ref.read(territoryServiceProvider);

  Future<void> fetch() async {
    state = const AsyncLoading();
    final res = await AsyncValue.guard(() => _territoryService.getById(ref, id));
    state = res;
  }

  Future<void> refresh() => fetch();
}
