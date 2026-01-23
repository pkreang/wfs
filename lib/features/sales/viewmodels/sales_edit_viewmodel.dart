import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/core/http/api_client.dart';
import 'package:wfs/features/sales/services/sales_service.dart';
import 'package:wfs/models/user_model.dart';
import 'package:wfs/models/userrole_model.dart';

@immutable
class SalesEditState {
  final AsyncValue<User> data;
  final bool isDirty;
  final bool isLoading;
  final String? errorMessage;

  const SalesEditState({required this.data, this.isDirty = false, this.isLoading = false, this.errorMessage});

  SalesEditState copyWith({AsyncValue<User>? data, bool? isDirty, bool? isLoading, String? errorMessage, bool clearErrorMessage = false}) =>
      SalesEditState(data: data ?? this.data, isDirty: isDirty ?? this.isDirty, isLoading: isLoading ?? this.isLoading, errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage));
}

class SalesEditViewModel extends StateNotifier<SalesEditState> {
  SalesEditViewModel(this.ref, this.id) : super(const SalesEditState(data: AsyncValue.loading())) {
    fetch();
  }

  final Ref ref;
  final String id;

  SalesService get _salesService => ref.read(salesServiceProvider);

  void setIsLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }

  Future<void> fetch() async {
    final userAsync = await AsyncValue.guard(() => _salesService.getById(ref, id));
    userAsync.whenData((user) {
      final res = AsyncValue.data(user);
      state = state.copyWith(data: res, isDirty: false);
    });
  }

  void setFirstName(String firstName) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(firstName: firstName)), isDirty: true, clearErrorMessage: true);
  }

  void setLastName(String lastName) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(lastName: lastName)), isDirty: true, clearErrorMessage: true);
  }

  void setPhoneNumber(String phoneNumber) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(phoneNumber: phoneNumber)), isDirty: true, clearErrorMessage: true);
  }

  void setUserRoleID(String userRoleID) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(userRoleID: userRoleID)), isDirty: true, clearErrorMessage: true);
  }

  void setEmail(String email) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(email: email)), isDirty: true, clearErrorMessage: true);
  }

  void setManagerID(String managerID) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(managerID: managerID)), isDirty: true, clearErrorMessage: true);
  }

  void setUserRole(UserRole userRole) {
    state = state.copyWith(
      data: state.data.whenData((v) => v.copyWith(userRole: userRole, userRoleID: userRole.userRoleID)),
      isDirty: true,
      clearErrorMessage: true,
    );
  }

  void setManager(User user) {
    state = state.copyWith(
      data: state.data.whenData((v) => v.copyWith(managerID: user.userID, managerName: user.fullname)),
      isDirty: true,
      clearErrorMessage: true,
    );
  }

  Future<bool> updateSales() async {
    final detail = state.data.value;
    if (!state.isDirty || detail == null) return false;

    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final result = await _salesService.updateSales(detail, ref);
      if (!result) return result;

      ref.invalidate(salesListProvider);
      ref.invalidate(salesDetailProvider(id));
      return result;
    } catch (e) {
      state = state.copyWith(errorMessage: e is ApiException ? e.message : 'Request failed');
    } finally {
      state = state.copyWith(isLoading: false);
    }

    return false;
  }
}
