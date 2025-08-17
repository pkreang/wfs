import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/models/Province_model.dart';
import 'package:wfs/services/province_service.dart';
import 'auth_provider.dart';

final ProvinceProvider = Provider<ProvinceService>((ref) {
  return ProvinceService();
});

final provinceGetList = FutureProvider<List<Province>>((ref) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('User is not authenticated.');
  }

  final ProvinceGetList = ref.watch(ProvinceProvider);

  return ProvinceGetList.getList(accessToken);
});
