import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/sales/services/sales_service.dart';
import 'package:wfs/models/user_model.dart';

class SalesDetailViewModel extends StateNotifier<AsyncValue<User>> {
  SalesDetailViewModel(this.ref, this.id) : super(const AsyncValue.loading()) {
    fetch();
  }

  final Ref ref;
  final String id;

  SalesService get _salesService => ref.read(salesServiceProvider);

  Future<void> fetch() async {
    state = const AsyncLoading();
    final res = await AsyncValue.guard(() => _salesService.getById(ref, id));
    state = res;
  }

  Future<void> refresh() => fetch();
}
