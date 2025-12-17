import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/core/http/api_client.dart';
import 'package:wfs/features/appointment/models/address.dart';
import 'package:wfs/features/appointment/models/territory.dart';
import 'package:wfs/features/company/models/company.dart';
import 'package:wfs/features/company/models/company_address.dart';
import 'package:wfs/features/company/models/company_status.dart';
import 'package:wfs/features/company/services/company_service.dart';

@immutable
class CompanyEditState {
  final AsyncValue<Company> data;
  final List<Company> companies;
  final bool isDirty;
  final bool isLoading;
  final String? errorMessage;

  const CompanyEditState({required this.data, this.companies = const [], this.isDirty = false, this.isLoading = false, this.errorMessage});

  CompanyEditState copyWith({AsyncValue<Company>? data, List<Company>? companies, bool? isDirty, bool? isLoading, String? errorMessage, bool clearErrorMessage = false}) => CompanyEditState(
    data: data ?? this.data,
    companies: companies ?? this.companies,
    isDirty: isDirty ?? this.isDirty,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
  );
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
      state = state.copyWith(data: res, isDirty: false, clearErrorMessage: true);
    });
  }

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
        final hasAddress = v.addresses.isNotEmpty;
        final initial = hasAddress ? v.addresses.first : const CompanyAddress();

        final first = initial.copyWith(latitude: latitude);
        final updated = hasAddress ? [first, ...v.addresses.skip(1)] : [first];
        return v.copyWith(addresses: updated);
      }),
      isDirty: true,
      clearErrorMessage: true,
    );
  }

  void setLongitude(double? longitude) {
    state = state.copyWith(
      data: state.data.whenData((v) {
        final hasAddress = v.addresses.isNotEmpty;
        final initial = hasAddress ? v.addresses.first : const CompanyAddress();

        final first = initial.copyWith(longitude: longitude);
        final updated = hasAddress ? [first, ...v.addresses.skip(1)] : [first];
        return v.copyWith(addresses: updated);
      }),
      isDirty: true,
      clearErrorMessage: true,
    );
  }

  void setAddress(Address address) {
    state = state.copyWith(
      data: state.data.whenData((v) {
        final hasAddress = v.addresses.isNotEmpty;
        final initial = hasAddress ? v.addresses.first : const CompanyAddress();

        final merged = address.copyWith(
          latitude: address.latitude ?? initial.latitude,
          longitude: address.longitude ?? initial.longitude,
          countryID: address.countryID ?? initial.countryID,
          countryName: address.countryName ?? initial.countryName,
        );

        final first = initial.copyWith(
          address: merged.address,
          subDistrictID: merged.subDistrictID,
          subDistrictName: merged.subDistrictName,
          districtID: merged.districtID,
          districtName: merged.districtName,
          provinceID: merged.provinceID,
          provinceName: merged.provinceName,
          countryID: merged.countryID,
          countryName: merged.countryName,
          latitude: merged.latitude,
          longitude: merged.longitude,
          postCode: merged.postCode,
        );
        final updated = hasAddress ? [first, ...v.addresses.skip(1)] : [first];

        return v.copyWith(addresses: updated);
      }),
      isDirty: true,
      clearErrorMessage: true,
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
      ref.invalidate(companyListProvider);

      return result;
    } catch (e, st) {
      state = state.copyWith(errorMessage: e is ApiException ? e.message : 'Request failed');
    } finally {
      state = state.copyWith(isLoading: false);
    }

    return false;
  }
}
