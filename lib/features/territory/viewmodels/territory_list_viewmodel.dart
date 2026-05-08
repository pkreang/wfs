import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/territory/models/territory_model.dart';
import 'package:wfs/features/territory/services/territory_service.dart';

@immutable
class TerritoryListState {
  final AsyncValue<List<TerritoryModel>> territories;
  final bool isEdit;
  final bool isLoading;

  const TerritoryListState({required this.territories, this.isEdit = false, this.isLoading = false});

  TerritoryListState copyWith({AsyncValue<List<TerritoryModel>>? territories, bool? isEdit, bool? isLoading}) {
    return TerritoryListState(
      territories: territories ?? this.territories,
      isEdit: isEdit ?? this.isEdit,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class TerritoryListViewModel extends StateNotifier<TerritoryListState> {
  TerritoryListViewModel(this.ref) : super(const TerritoryListState(territories: AsyncValue.loading())) {
    fetch();
  }

  final Ref ref;

  TerritoryService get _territoryService => ref.read(territoryServiceProvider);

  Future<void> fetch() async {
    final territoriesAsync = await AsyncValue.guard(() => _territoryService.fetchTerritories(ref));
    state = state.copyWith(territories: territoriesAsync);
  }

  void setEditMode() {
    state = state.copyWith(isEdit: !state.isEdit);
  }

  Future<void> onRemoveTerritory(String territoryID) async {
    state = state.copyWith(isLoading: true);

    try {
      await _territoryService.deleteTerritory(territoryID, ref);
      ref.invalidate(territoryListProvider);
    } catch (e, st) {
      state = state.copyWith(territories: AsyncError(e, st));
    } finally {
      state = state.copyWith(isLoading: false);
      fetch();
    }
  }
}
