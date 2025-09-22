import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/models/address.dart';
import 'package:wfs/features/appointment/models/territory.dart';
import 'package:wfs/features/company/models/company.dart';
import 'package:wfs/features/company/models/company_status.dart';
import 'package:wfs/features/company/services/company_service.dart';

@immutable
class CompanyEditState {
  final AsyncValue<Company> data;
  final List<Company> companies;
  final bool isDirty;
  final bool isLoading;

  const CompanyEditState({required this.data, this.companies = const [], this.isDirty = false, this.isLoading = false});

  CompanyEditState copyWith({AsyncValue<Company>? data, List<Company>? companies, bool? isDirty, bool? isLoading}) =>
      CompanyEditState(data: data ?? this.data, companies: companies ?? this.companies, isDirty: isDirty ?? this.isDirty, isLoading: isLoading ?? this.isLoading);
}

class CompanyEditViewModel extends StateNotifier<CompanyEditState> {
  CompanyEditViewModel(this.ref, this.id) : super(const CompanyEditState(data: AsyncValue.loading())) {
    fetch();
  }

  final Ref ref;
  final String id;

  CompanyService get _companyService => ref.read(companyServiceProvider);

  void setIsLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }

  Future<void> fetch() async {
    final clientAsync = await AsyncValue.guard(() => _companyService.getById(ref, id));
    clientAsync.whenData((client) {
      final res = AsyncValue.data(client);
      state = state.copyWith(data: res, isDirty: false);

      // final List<Company> companies = client.companies
      //     .map((cc) => cc.company)
      //     .where((c) => (c?.companyID ?? '').isNotEmpty)
      //     .map((c) => Company(companyID: c!.companyID, companyName: c.companyName))
      //     .toList();

      state = state.copyWith(data: res, isDirty: false);
    });
  }

  void setCompanyName(String companyName) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(companyName: companyName)), isDirty: true);
  }

  void setTaxID(String taxID) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(taxID: taxID)), isDirty: true);
  }

  void setIsActive(CompanyStatus value) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(isActive: value.isActive)), isDirty: true);
  }

  void setTerritory(Territory status) {
    state = state.copyWith(
      data: state.data.whenData((v) => v.copyWith(salesTerritoryID: status.salesTerritoryID, salesTerritoryName: status.salesTerritoryName)),
      isDirty: true,
    );
  }

  void setLatitude(double? latitude) {
    state = state.copyWith(
      data: state.data.whenData((v) {
        if (v.addresses.isEmpty) return v;

        final first = v.addresses.first.copyWith(latitude: latitude);
        final updated = [first, ...v.addresses.skip(1)];
        return v.copyWith(addresses: updated);
      }),
      isDirty: true,
    );
  }

  void setLongitude(double? longitude) {
    state = state.copyWith(
      data: state.data.whenData((v) {
        if (v.addresses.isEmpty) return v;

        final first = v.addresses.first.copyWith(longitude: longitude);
        final updated = [first, ...v.addresses.skip(1)];
        return v.copyWith(addresses: updated);
      }),
      isDirty: true,
    );
  }

  void setAddress(Address address) {
    state = state.copyWith(
      data: state.data.whenData((v) {
        if (v.addresses.isEmpty) return v;

        print('address: ${address.toJson()}');

        final first = v.addresses.first.copyWith(
          address: address.address,
          subDistrictID: address.subDistrictID,
          subDistrictName: address.subDistrictName,
          districtID: address.districtID,
          districtName: address.districtName,
          provinceID: address.provinceID,
          provinceName: address.provinceName,
          postCode: address.postCode,
        );
        final updated = [first, ...v.addresses.skip(1)];

        return v.copyWith(addresses: updated);
      }),
      isDirty: true,
    );
  }

  Future<bool> updateCompany() async {
    final detail = state.data.value;
    if (!state.isDirty || detail == null) return false;

    state = state.copyWith(isLoading: true);

    try {
      final result = await _companyService.updateCompany(detail, ref);
      if (!result) return result;

      ref.invalidate(companyDetailProvider(detail.companyID ?? ''));

      // final filter = DateTime.tryParse(detail.appointmentDateTimeFrom) ?? DateTime.now();
      // ref.read(appointmentsByDateProvider(DateFormat("yyyy-MM-dd").format(filter)).notifier).refresh();

      return result;
    } catch (e, st) {
      state = state.copyWith(data: AsyncError(e, st));
    } finally {
      state = state.copyWith(isLoading: false);
    }

    return false;
  }
}
