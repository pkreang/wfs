import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/models/productcategory_model.dart';
import 'package:wfs/services/productcategory_service.dart';
import 'auth_provider.dart';

final productCategoryProvider = Provider<ProductCategoryService>((ref) {
  return ProductCategoryService();
});

final productCategoryGetList = FutureProvider<List<ProductCategory>>((
  ref,
) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('User is not authenticated.');
  }

  final ProductCategoryGetList = ref.watch(productCategoryProvider);

  return ProductCategoryGetList.getList(accessToken);
});
