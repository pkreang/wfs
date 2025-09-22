import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/models/address.dart';
import 'package:wfs/features/appointment/models/territory.dart';
import 'package:wfs/features/company/models/company.dart';
import 'package:wfs/core/http/api_client.dart';
import 'package:wfs/features/company/models/company_address.dart';
import 'package:wfs/features/company/models/company_status.dart';
import 'package:wfs/features/company/services/company_service.dart';

@immutable
class CompanyCreateState {
  final AsyncValue<Company> data;
  final bool isDirty;
  final bool isLoading;
  final String? errorMessage;

  const CompanyCreateState({required this.data, this.isDirty = false, this.isLoading = false, this.errorMessage});

  CompanyCreateState copyWith({AsyncValue<Company>? data, bool? isDirty, bool? isLoading, String? errorMessage, bool clearErrorMessage = false}) => CompanyCreateState(
    data: data ?? this.data,
    isDirty: isDirty ?? this.isDirty,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
  );
}

class CompanyCreateViewModel extends StateNotifier<CompanyCreateState> {
  CompanyCreateViewModel(this.ref) : super(const CompanyCreateState(data: AsyncValue.loading())) {
    state = state.copyWith(data: AsyncValue.data(Company(isActive: true, addresses: [CompanyAddress()])), isDirty: false);
  }

  final Ref ref;

  CompanyService get _companyService => ref.read(companyServiceProvider);

  void setCompanyName(String companyName) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(companyName: companyName)), isDirty: true, clearErrorMessage: true);
  }

  void setTaxID(String taxID) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(taxID: taxID)), isDirty: true, clearErrorMessage: true);
  }

  void setIsActive(CompanyStatus value) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(isActive: value.isActive)), isDirty: true, clearErrorMessage: true);
  }

  void setTerritory(Territory status) {
    state = state.copyWith(
      data: state.data.whenData((v) => v.copyWith(salesTerritoryID: status.salesTerritoryID, salesTerritoryName: status.salesTerritoryName)),
      isDirty: true,
      clearErrorMessage: true,
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
      clearErrorMessage: true,
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
      clearErrorMessage: true,
    );
  }

  void setAddress(Address address) {
    state = state.copyWith(
      data: state.data.whenData((v) {
        if (v.addresses.isEmpty) return v;

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
      clearErrorMessage: true,
    );
  }

  Future<bool> createCompany() async {
    final detail = state.data.value;
    if (!state.isDirty || detail == null) return false;

    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final result = await _companyService.createCompany(detail, ref);
      if (!result) return result;

      ref.invalidate(companyListProvider);
      return result;
    } catch (e) {
      state = state.copyWith(errorMessage: e is ApiException ? e.message : 'Request failed');
    } finally {
      state = state.copyWith(isLoading: false);
    }

    return false;
  }
}
