import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/models/product_model.dart';
import 'package:wfs/services/product_service.dart';
import 'auth_provider.dart';

final productProvider = Provider<ProductService>((ref) {
  return ProductService();
});

final productGetList = FutureProvider<List<Product>>((ref) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('User is not authenticated.');
  }

  final productGetList = ref.watch(productProvider);

  return productGetList.getList(accessToken);
});
