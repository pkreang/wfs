import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/models/Country_model.dart';
import 'package:wfs/services/country_service.dart';
import 'auth_provider.dart';

final countryProvider = Provider<CountryService>((ref) {
  return CountryService();
});

final countryGetList = FutureProvider<List<Country>>((ref) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('User is not authenticated.');
  }

  final CountryGetList = ref.watch(countryProvider);

  return CountryGetList.getList(accessToken);
});
