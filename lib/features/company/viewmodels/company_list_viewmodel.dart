import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/company/models/company.dart';
import 'package:wfs/features/company/services/company_service.dart';

@immutable
class CompanyListState {
  final AsyncValue<List<Company>> companies;
  final Map<String, List<Company>> sections;
  final bool isEdit;
  final bool isDirty;
  final bool isLoading;

  const CompanyListState({required this.companies, this.sections = const {}, this.isEdit = false, this.isDirty = false, this.isLoading = false});

  CompanyListState copyWith({AsyncValue<List<Company>>? companies, Map<String, List<Company>>? sections, bool? isEdit, bool? isDirty, bool? isLoading}) => CompanyListState(
    companies: companies ?? this.companies,
    sections: sections ?? this.sections,
    isEdit: isEdit ?? this.isEdit,
    isDirty: isDirty ?? this.isDirty,
    isLoading: isLoading ?? this.isLoading,
  );
}

class CompanyListViewModel extends StateNotifier<CompanyListState> {
  CompanyListViewModel(this.ref) : super(const CompanyListState(companies: AsyncValue.loading())) {
    fetch();
  }

  final Ref ref;

  CompanyService get _companyService => ref.read(companyServiceProvider);

  Future<void> fetch() async {
    final companiesAsync = await AsyncValue.guard(() => _companyService.fetchCompanies(ref));
    companiesAsync.whenData((companies) {
      final Map<String, List<Company>> sections = {};
      for (var company in companies) {
        if (company.companyName != null && company.companyName!.isNotEmpty) {
          final firstChar = company.companyName?[0].toUpperCase();
          sections.putIfAbsent(firstChar ?? '', () => []).add(company);
        }
      }

      state = state.copyWith(companies: companiesAsync, sections: sections);
    });
  }

  void setEditMode() {
    state = state.copyWith(isEdit: !state.isEdit);
  }

  void onRemoveCompany(String companyID) async {
    state = state.copyWith(isLoading: true);

    try {
      await _companyService.deleteCompany(companyID, ref);
    } catch (e, st) {
      state = state.copyWith(companies: AsyncError(e, st));
    } finally {
      state = state.copyWith(isLoading: false);
      fetch();
    }
  }
}
