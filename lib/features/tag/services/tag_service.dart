import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/http/api_client.dart';
import 'package:wfs/features/tag/models/tag.dart';
import 'package:wfs/providers/auth_provider.dart';

class TagService {
  final apiClient = ApiClient('https://sfe-api.appnormalthink.com');

  Future<List<Tag>> fetchTags(Ref ref) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    final tags = await apiClient.get(
      path: "/tag/?IsActive=true",
      decode: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['tags'] as List? ?? const [];

        return list.map((e) => Tag.fromJson(e as Map<String, dynamic>)).toList();
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );

    return tags;
  }

  Future<bool> createTag(Ref ref, {required String name}) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    print('createTag');

    return await apiClient.post(
      path: "/tag/",
      body: {"TagName": name},
      decode: (json) {
        final map = json as Map<String, dynamic>;
        print('map: $map');
        return (map['status'] as String?)?.toLowerCase() == "success";
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );
  }
}
