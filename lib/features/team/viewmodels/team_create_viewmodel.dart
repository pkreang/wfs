import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/core/http/api_client.dart';
import 'package:wfs/features/team/models/team_member.dart';
import 'package:wfs/features/team/services/team_service.dart';
import 'package:wfs/models/userrole_model.dart';

@immutable
class TeamCreateState {
  final AsyncValue<TeamMember> data;
  final bool isDirty;
  final bool isLoading;
  final String? errorMessage;

  const TeamCreateState({required this.data, this.isDirty = false, this.isLoading = false, this.errorMessage});

  TeamCreateState copyWith({AsyncValue<TeamMember>? data, bool? isDirty, bool? isLoading, String? errorMessage, bool clearErrorMessage = false}) =>
      TeamCreateState(data: data ?? this.data, isDirty: isDirty ?? this.isDirty, isLoading: isLoading ?? this.isLoading, errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage));
}

class TeamCreateViewModel extends StateNotifier<TeamCreateState> {
  TeamCreateViewModel(this.ref) : super(const TeamCreateState(data: AsyncValue.loading())) {
    state = state.copyWith(data: AsyncValue.data(TeamMember(isActive: true)), isDirty: false);
  }

  final Ref ref;

  TeamService get _teamService => ref.read(teamServiceProvider);

  void setFirstName(String firstName) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(firstName: firstName)), isDirty: true, clearErrorMessage: true);
  }

  void setLastName(String lastName) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(lastName: lastName)), isDirty: true, clearErrorMessage: true);
  }

  void setEmail(String email) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(email: email)), isDirty: true, clearErrorMessage: true);
  }

  void setPhoneNumber(String phoneNumber) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(phoneNumber: phoneNumber)), isDirty: true, clearErrorMessage: true);
  }

  void setUserRole(UserRole userRole) {
    state = state.copyWith(
      data: state.data.whenData((v) => v.copyWith(userRoleID: userRole.userRoleID, userRoleName: userRole.userRoleName)),
      isDirty: true,
      clearErrorMessage: true,
    );
  }

  void setManagerID(String managerID) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(managerID: managerID)), isDirty: true, clearErrorMessage: true);
  }

  void setIsActive(bool isActive) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(isActive: isActive)), isDirty: true, clearErrorMessage: true);
  }

  Future<bool> createTeamMember() async {
    final detail = state.data.value;
    if (!state.isDirty || detail == null) return false;

    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final result = await _teamService.createTeamMember(detail, ref);
      if (!result) return result;

      ref.invalidate(teamListProvider);
      return result;
    } catch (e) {
      state = state.copyWith(errorMessage: e is ApiException ? e.message : 'Request failed');
    } finally {
      state = state.copyWith(isLoading: false);
    }

    return false;
  }
}
