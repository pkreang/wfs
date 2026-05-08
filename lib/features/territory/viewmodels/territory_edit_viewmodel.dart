import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/core/http/api_client.dart';
import 'package:wfs/features/territory/models/territory_model.dart';
import 'package:wfs/features/territory/services/territory_service.dart';

@immutable
class TerritoryEditState {
  final AsyncValue<TerritoryModel> data;
  final bool isDirty;
  final bool isLoading;
  final String? errorMessage;

  const TerritoryEditState({required this.data, this.isDirty = false, this.isLoading = false, this.errorMessage});

  TerritoryEditState copyWith({AsyncValue<TerritoryModel>? data, bool? isDirty, bool? isLoading, String? errorMessage, bool clearErrorMessage = false}) {
    return TerritoryEditState(
      data: data ?? this.data,
      isDirty: isDirty ?? this.isDirty,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class TerritoryEditViewModel extends StateNotifier<TerritoryEditState> {
  TerritoryEditViewModel(this.ref, this.id) : super(const TerritoryEditState(data: AsyncValue.loading())) {
    fetch();
  }

  final Ref ref;
  final String id;

  TerritoryService get _territoryService => ref.read(territoryServiceProvider);

  Future<void> fetch() async {
    final territoryAsync = await AsyncValue.guard(() => _territoryService.getById(ref, id));
    territoryAsync.whenData((territory) {
      state = state.copyWith(data: AsyncValue.data(territory), isDirty: false);
    });
    if (territoryAsync.hasError) {
      state = state.copyWith(data: territoryAsync);
    }
  }

  void setName(String name) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(salesTerritoryName: name)), isDirty: true, clearErrorMessage: true);
  }

  void setDescription(String description) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(salesTerritoryDescription: description)), isDirty: true, clearErrorMessage: true);
  }

  void setIsActive(bool isActive) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(isActive: isActive)), isDirty: true, clearErrorMessage: true);
  }

  Future<bool> updateTerritory() async {
    final detail = state.data.value;
    if (!state.isDirty || detail == null) return false;

    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final result = await _territoryService.updateTerritory(detail, ref);
      if (!result) return result;

      ref.invalidate(territoryListProvider);
      ref.invalidate(territoryDetailProvider(id));
      return result;
    } catch (e) {
      state = state.copyWith(errorMessage: e is ApiException ? e.message : 'Request failed');
    } finally {
      state = state.copyWith(isLoading: false);
    }

    return false;
  }
}
