import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/sales/services/sales_service.dart';
import 'package:wfs/models/user_model.dart';

@immutable
class SalesListState {
  final AsyncValue<List<User>> users;
  final bool isEdit;
  final bool isDirty;
  final bool isLoading;

  const SalesListState({required this.users, this.isEdit = false, this.isDirty = false, this.isLoading = false});

  SalesListState copyWith({AsyncValue<List<User>>? users, bool? isEdit, bool? isDirty, bool? isLoading}) =>
      SalesListState(users: users ?? this.users, isEdit: isEdit ?? this.isEdit, isDirty: isDirty ?? this.isDirty, isLoading: isLoading ?? this.isLoading);
}

class SalesListViewModel extends StateNotifier<SalesListState> {
  SalesListViewModel(this.ref) : super(const SalesListState(users: AsyncValue.loading())) {
    fetch();
  }

  final Ref ref;

  SalesService get _salesService => ref.read(salesServiceProvider);

  Future<void> fetch() async {
    final usersAsync = await AsyncValue.guard(() => _salesService.fetchSales(ref));
    state = state.copyWith(users: usersAsync);
  }

  void setEditMode() {
    state = state.copyWith(isEdit: !state.isEdit);
  }

  void onRemoveSales(String saleID) async {
    state = state.copyWith(isLoading: true);

    try {
      await _salesService.deleteSales(saleID, ref);
    } catch (e, st) {
      state = state.copyWith(users: AsyncError(e, st));
    } finally {
      state = state.copyWith(isLoading: false);
      fetch();
    }
  }
}
