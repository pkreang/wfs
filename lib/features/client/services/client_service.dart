import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:wfs/core/http/api_client.dart';
import 'package:wfs/features/client/models/client.dart';
import 'package:wfs/features/client/models/client_level.dart';
import 'package:wfs/features/client/models/client_status.dart';
import 'package:wfs/providers/auth_provider.dart';

class ClientService {
  final apiClient = ApiClient('https://sfe-api.appnormalthink.com');

  Future<List<Client>> fetchClients(Ref ref) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    final clients = await apiClient.get(
      path: "/client/?IsActive=true",
      decode: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['clients'] as List? ?? const [];

        return list.map((e) => Client.fromJson(e as Map<String, dynamic>)).toList();
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );

    return clients;
  }

  Future<Client> getById(Ref ref, String clientId) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    final client = await apiClient.get(
      path: "/client/id/$clientId",
      decode: (json) {
        final map = json as Map<String, dynamic>;

        return Client.fromJson(map['client']);
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );

    return client;
  }

  Future<List<ClientStatus>> fetchClientStatus(Ref ref) async {
    final authState = ref.watch(authProvider);
    final accessToken = authState.accessToken;

    final clientStatus = await apiClient.get(
      path: "/client/status/?IsActive=true",
      decode: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['client_status'] as List? ?? const [];

        return ClientStatus.listFromJson(list);
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );

    return clientStatus;
  }

  Future<List<ClientLevel>> fetchClientLevel(Ref ref) async {
    final authState = ref.watch(authProvider);
    final accessToken = authState.accessToken;

    final clientLevel = await apiClient.get(
      path: "/client/level/?IsActive=true",
      decode: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['client_level'] as List? ?? const [];

        return ClientLevel.listFromJson(list);
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );

    return clientLevel;
  }

  Future<(bool, String)> createClient(Client client, Ref ref) async {
    final authState = ref.watch(authProvider);
    final accessToken = authState.accessToken;
    final userID = authState.userID ?? '';

    return await apiClient.post(
      path: "/client/",
      body: client.toJsonCreate(userID),
      decode: (json) {
        final map = json as Map<String, dynamic>;
        return ((map['status'] as String?)?.toLowerCase() == "success", map['client']['ClientID'] as String? ?? '');
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );
  }

  Future<bool> updateClient(Client client, Ref ref) async {
    final authState = ref.watch(authProvider);
    final accessToken = authState.accessToken;
    final userID = authState.userID ?? '';

    return await apiClient.put(path: "/client/${client.clientID}", body: client.toJsonUpdate(userID), headers: {"Authorization": "Bearer $accessToken"});
  }

  Future<bool> deleteClient(String clientID, Ref ref) async {
    final authState = ref.watch(authProvider);
    final accessToken = authState.accessToken;

    return await apiClient.delete(path: "/client/${clientID.toString()}", headers: {"Authorization": "Bearer $accessToken"});
  }

  Future<bool> updateTags(String clientID, List<String?> tagNames, Ref ref) async {
    final authState = ref.watch(authProvider);
    final accessToken = authState.accessToken;
    final userID = authState.userID ?? '';

    return await apiClient.put(path: "/client/tags/${clientID.toString()}", body: {"TagNames": tagNames, "ModifiedBy": userID}, headers: {"Authorization": "Bearer $accessToken"});
  }

  Future<List<Client>> getNotifications(WidgetRef ref) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    final clients = await apiClient.get(
      path: "/client/notification",
      decode: (json) {
        print('json: $json');
        final map = json as Map<String, dynamic>;
        final list = map['clients'] as List? ?? const [];

        print('list: $list');

        return list.map((e) => Client.fromJson(e as Map<String, dynamic>)).toList();
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );

    return clients;
  }

  Future<void> markNotification({required String clientID, required WidgetRef ref}) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    final url = Uri.parse('https://sfe-api.appnormalthink.com/notification/');

    await http.post(url, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'}, body: json.encode({'RefID': clientID, 'NotificationType': 'Client'}));
  }
}
