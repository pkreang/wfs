import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/models/PurposeTypeGroup_model.dart';
import 'package:wfs/services/PurposeTypeGroup_service.dart';
import 'auth_provider.dart';

final PurposeTypeGroupProvider = Provider<PurposeTypeGroupService>((ref) {
  return PurposeTypeGroupService();
});

final perposeTypeGroupGetList = FutureProvider<List<PurposeTypeGroup>>((
  ref,
) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('User is not authenticated.');
  }

  final PurposeTypeGroupService = ref.watch(PurposeTypeGroupProvider);

  return PurposeTypeGroupService.GetList(accessToken);
});
