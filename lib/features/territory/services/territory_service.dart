import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/http/api_client.dart';
import 'package:wfs/features/territory/models/territory_model.dart';
import 'package:wfs/providers/auth_provider.dart';

class TerritoryService {
  final apiClient = ApiClient('https://sfe-api.appnormalthink.com');

  Future<List<TerritoryModel>> fetchTerritories(Ref ref) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    final territories = await apiClient.get(
      path: '/sale/territory',
      decode: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['sale_territorie'] as List? ?? const [];

        return TerritoryModel.listFromJson(list);
      },
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    return territories;
  }

  Future<TerritoryModel> getById(Ref ref, String territoryID) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    final territory = await apiClient.get(
      path: '/sale/territory/?SalesTerritoryID=$territoryID',
      decode: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['sale_territorie'] as List? ?? const [];
        if (list.isEmpty) {
          throw Exception('Territory not found');
        }

        return TerritoryModel.fromJson(list.first as Map<String, dynamic>);
      },
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    return territory;
  }

  Future<bool> createTerritory(TerritoryModel territory, Ref ref) async {
    final authState = ref.watch(authProvider);
    final accessToken = authState.accessToken;
    final userID = authState.userID ?? '';

    return await apiClient.post(
      path: '/sale/territory',
      body: territory.toJsonCreate(userID),
      decode: (json) {
        final map = json as Map<String, dynamic>;
        return (map['status'] as String?)?.toLowerCase() == 'success';
      },
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }

  Future<bool> updateTerritory(TerritoryModel territory, Ref ref) async {
    final authState = ref.watch(authProvider);
    final accessToken = authState.accessToken;
    final territoryID = territory.salesTerritoryID;

    if ((territoryID ?? '').isEmpty) {
      throw Exception('Territory ID is required');
    }

    return await apiClient.put(path: '/sale/territory/$territoryID', body: territory.toJsonUpdate(authState.userID ?? ''), headers: {'Authorization': 'Bearer $accessToken'});
  }

  Future<bool> deleteTerritory(String territoryID, Ref ref) async {
    final authState = ref.watch(authProvider);
    final accessToken = authState.accessToken;

    return await apiClient.delete(path: '/sale/territory/$territoryID', headers: {'Authorization': 'Bearer $accessToken'});
  }
}
