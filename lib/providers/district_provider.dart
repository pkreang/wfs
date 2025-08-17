import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/models/district_model.dart';
import 'package:wfs/services/district_service.dart';
import 'auth_provider.dart';

final DistrictProvider = Provider<DistrictService>((ref) {
  return DistrictService();
});

final districtGetList = FutureProvider<List<District>>((ref) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('User is not authenticated.');
  }

  final DistrictGetList = ref.watch(DistrictProvider);

  return DistrictGetList.GetList(accessToken);
});
