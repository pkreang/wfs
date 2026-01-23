import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/http/api_client.dart';
import 'package:wfs/features/client/models/client.dart';
import 'package:wfs/features/team/models/team_member.dart';
import 'package:wfs/models/user_model.dart';
import 'package:wfs/providers/auth_provider.dart';

class TeamService {
  final apiClient = ApiClient('https://sfe-api.appnormalthink.com');

  Future<List<User>> fetchTeamMembers(Ref ref) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    var path = "/user/?ManagerID=${authState.userID.toString()}";
    if (authState.isSuperAdmin) {
      path = "/user/?UserRoleID=8CFBD382-FA8B-459C-9BCF-6A3FDF66A8D6";
    }

    final teamMembers = await apiClient.get(
      path: path,
      decode: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['users'] as List? ?? const [];

        return list.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );

    return teamMembers;
  }

  Future<Client> getClientById(Ref ref, String clientID) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    final client = await apiClient.get(
      path: "/client/id/${clientID.toString()}/",
      decode: (json) => Client.fromJson((json as Map<String, dynamic>)["client"]),
      headers: {"Authorization": "Bearer $accessToken"},
    );

    return client;
  }

  Future<List<User>> getUserByManagerID(Ref ref, String managerID) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    final users = await apiClient.get<List<User>>(
      path: "/user/?ManagerID=${managerID.toString()}/",
      decode: (json) {
        final map = json as Map<String, dynamic>;
        final usersList = map["users"] as List;
        return usersList.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );

    return users;
  }

  Future<bool> createTeamMember(TeamMember teamMember, Ref ref) async {
    final authState = ref.watch(authProvider);
    final accessToken = authState.accessToken;
    final userID = authState.userID ?? '';

    return await apiClient.post(
      path: "/user/",
      body: {...teamMember.toJson(), 'CreatedBy': userID, 'ModifiedBy': userID, 'CreatedDate': DateTime.now().toIso8601String(), 'ModifiedDate': DateTime.now().toIso8601String()},
      decode: (json) {
        final map = json as Map<String, dynamic>;
        return (map['status'] as String?)?.toLowerCase() == "success";
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );
  }

  Future<bool> updateTeamMember(TeamMember teamMember, Ref ref) async {
    final authState = ref.watch(authProvider);
    final accessToken = authState.accessToken;

    try {
      return await apiClient.put(
        path: "/user/${teamMember.userID.toString()}",
        body: {...teamMember.toJson(), 'ModifiedBy': authState.userID ?? '', 'ModifiedDate': DateTime.now().toIso8601String()},
        headers: {"Authorization": "Bearer $accessToken"},
      );
    } catch (e) {
      print('updateTeamMember catch: $e');
    }

    return false;
  }

  Future<bool> deleteTeamMember(String userID, Ref ref) async {
    final authState = ref.watch(authProvider);
    final accessToken = authState.accessToken;

    try {
      return await apiClient.delete(path: "/user/${userID.toString()}", headers: {"Authorization": "Bearer $accessToken"});
    } catch (e) {
      print('deleteTeamMember catch: $e');
      return false;
    }
  }
}
