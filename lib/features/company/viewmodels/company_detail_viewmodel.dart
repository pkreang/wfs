import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/company/models/company.dart';
import 'package:wfs/features/company/services/company_service.dart';

class CompanyDetailViewModel extends StateNotifier<AsyncValue<Company>> {
  CompanyDetailViewModel(this.ref, this.id) : super(const AsyncValue.loading()) {
    fetch();
  }

  final Ref ref;
  final String id;

  CompanyService get _companyService => ref.read(companyServiceProvider);

  Future<void> fetch() async {
    state = const AsyncLoading();
    final res = await AsyncValue.guard(() => _companyService.getById(ref, id));
    state = res;
  }

  Future<void> refresh() => fetch();
}
