import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/team/models/team_member.dart';
import 'package:wfs/features/team/services/team_service.dart';
import 'package:wfs/models/user_model.dart';

@immutable
class TeamListState {
  final AsyncValue<List<User>> teamMembers;
  final bool isLoading;

  const TeamListState({required this.teamMembers, this.isLoading = false});

  TeamListState copyWith({AsyncValue<List<User>>? teamMembers, Map<String, List<TeamMember>>? sections, bool? isEdit, bool? isDirty, bool? isLoading}) =>
      TeamListState(teamMembers: teamMembers ?? this.teamMembers, isLoading: isLoading ?? this.isLoading);
}

class TeamListViewModel extends StateNotifier<TeamListState> {
  TeamListViewModel(this.ref) : super(const TeamListState(teamMembers: AsyncValue.loading())) {
    fetch();
  }

  final Ref ref;

  TeamService get _teamService => ref.read(teamServiceProvider);

  Future<void> fetch() async {
    final teamMembersAsync = await AsyncValue.guard(() => _teamService.fetchTeamMembers(ref));
    state = state.copyWith(teamMembers: teamMembersAsync);
  }
}
