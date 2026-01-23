import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/core/http/api_client.dart';
import 'package:wfs/features/sales/services/sales_service.dart';
import 'package:wfs/features/sales/models/sales_model.dart';
import 'package:wfs/models/user_model.dart';
import 'package:wfs/models/userrole_model.dart';

@immutable
class SalesCreateState {
  final AsyncValue<User> data;
  final bool isDirty;
  final bool isLoading;
  final String? errorMessage;

  const SalesCreateState({required this.data, this.isDirty = false, this.isLoading = false, this.errorMessage});

  SalesCreateState copyWith({AsyncValue<User>? data, bool? isDirty, bool? isLoading, String? errorMessage, bool clearErrorMessage = false}) =>
      SalesCreateState(data: data ?? this.data, isDirty: isDirty ?? this.isDirty, isLoading: isLoading ?? this.isLoading, errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage));
}

class SalesCreateViewModel extends StateNotifier<SalesCreateState> {
  SalesCreateViewModel(this.ref) : super(const SalesCreateState(data: AsyncValue.loading())) {
    state = state.copyWith(data: AsyncValue.data(User()), isDirty: false);
  }

  final Ref ref;

  SalesService get _salesService => ref.read(salesServiceProvider);

  void setFirstName(String firstName) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(firstName: firstName)), isDirty: true);
  }

  void setLastName(String lastName) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(lastName: lastName)), isDirty: true);
  }

  void setPhoneNumber(String phoneNumber) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(phoneNumber: phoneNumber)), isDirty: true);
  }

  void setUserRoleID(String userRoleID) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(userRoleID: userRoleID)), isDirty: true);
  }

  void setEmail(String email) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(email: email)), isDirty: true);
  }

  void setManagerID(String managerID) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(managerID: managerID)), isDirty: true);
  }

  void setUserRole(UserRole userRole) {
    state = state.copyWith(
      data: state.data.whenData((v) => v.copyWith(userRole: userRole, userRoleID: userRole.userRoleID)),
      isDirty: true,
    );
  }

  void setManager(User user) {
    state = state.copyWith(
      data: state.data.whenData((v) => v.copyWith(managerID: user.userID, managerName: user.fullname)),
      isDirty: true,
    );
  }

  Future<bool> createSales() async {
    final detail = state.data.value;
    if (!state.isDirty || detail == null) return false;

    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final result = await _salesService.createSales(detail, ref);
      if (!result) return result;

      ref.invalidate(salesListProvider);
      return result;
    } catch (e) {
      state = state.copyWith(errorMessage: e is ApiException ? e.message : 'Request failed');
    } finally {
      state = state.copyWith(isLoading: false);
    }

    return false;
  }
}
