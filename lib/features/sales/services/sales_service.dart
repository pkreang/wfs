import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/http/api_client.dart';
import 'package:wfs/models/user_model.dart';
import 'package:wfs/providers/auth_provider.dart';

class SalesService {
  final apiClient = ApiClient('https://sfe-api.appnormalthink.com');

  Future<List<User>> fetchSales(Ref ref) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    var url = "/user/?IsActive=true&UserRoleID=BBCC9574-F8F2-402A-8ED1-784934A04FA0";
    if (authState.isAdmin) {
      url = "/user/?IsActive=true&UserRoleID=8CFBD382-FA8B-459C-9BCF-6A3FDF66A8D6,BBCC9574-F8F2-402A-8ED1-784934A04FA0";
    } else if (authState.isSystemAdmin) {
      url = "/user/?IsActive=true&UserRoleID=91FA9057-F815-456C-8D7E-C8CCCBC2A805,8CFBD382-FA8B-459C-9BCF-6A3FDF66A8D6,BBCC9574-F8F2-402A-8ED1-784934A04FA0";
    }

    final users = await apiClient.get(
      path: url,
      decode: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['users'] as List? ?? const [];

        return list.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );

    return users;
  }

  Future<User> getById(Ref ref, String userID) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    final user = await apiClient.get(
      path: "/user/?UserID=${userID.toString()}",
      decode: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['users'] as List? ?? const [];
        if (list.isEmpty) {
          throw Exception('Sales not found');
        }

        return User.fromJson(list.first as Map<String, dynamic>);
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );

    return user;
  }

  Future<bool> createSales(User user, Ref ref) async {
    final authState = ref.watch(authProvider);
    final accessToken = authState.accessToken;

    return await apiClient.post(
      path: "/user/",
      body: user.toJsonCreate(authState.userID ?? ''),
      decode: (json) {
        final map = json as Map<String, dynamic>;
        return (map['status'] as String?)?.toLowerCase() == "success";
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );
  }

  Future<bool> updateSales(User user, Ref ref) async {
    final authState = ref.watch(authProvider);
    final accessToken = authState.accessToken;

    return await apiClient.put(path: "/user/${user.userID}", body: user.toJsonUpdate(authState.userID ?? ''), headers: {"Authorization": "Bearer $accessToken"});
  }

  Future<bool> deleteSales(String saleID, Ref ref) async {
    final authState = ref.watch(authProvider);
    final accessToken = authState.accessToken;

    try {
      return await apiClient.delete(path: "/sales/${saleID.toString()}", headers: {"Authorization": "Bearer $accessToken"});
    } catch (e) {
      print('deleteSales catch: $e');
      return false;
    }
  }
}
