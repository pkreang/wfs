import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/models/saleterritorie_model.dart';
import 'package:wfs/services/saleterritorie_service.dart';
import 'auth_provider.dart';

final saleterritorieProvider = Provider<SaleterritorieService>((ref) {
  return SaleterritorieService();
});

final saleTerritorieGetList = FutureProvider<List<SaleTerritorie>>((ref) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('User is not authenticated.');
  }

  final saleterritorService = ref.watch(saleterritorieProvider);

  return saleterritorService.GetList(accessToken);
});
