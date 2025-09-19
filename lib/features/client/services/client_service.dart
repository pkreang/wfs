import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/http/api_client.dart';
import 'package:wfs/features/client/models/client.dart';
import 'package:wfs/providers/auth_provider.dart';

class ClientService {
  final apiClient = ApiClient('https://sfe-api.appnormalthink.com');

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
}
