import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/models/subdistrict_model.dart';
import 'package:wfs/services/subdistrict_service.dart';
import 'auth_provider.dart';

final SubDistrictProvider = Provider<SubDistrictService>((ref) {
  return SubDistrictService();
});

final selectedSubdistrictProvider = StateProvider<String?>((ref) => null);

final subDistrictGetList = FutureProvider<List<Subdistrict>>((ref) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('User is not authenticated.');
  }

  final SubDistrictGetList = ref.watch(SubDistrictProvider);

  return SubDistrictGetList.GetList(accessToken);
});
