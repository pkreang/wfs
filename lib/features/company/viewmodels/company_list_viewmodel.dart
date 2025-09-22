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

  // void loadCompanies(WidgetRef ref) {
  //   ref.read(companyLoadTriggerProvider.notifier).state = false;

  //   ref.read(companyLoadTriggerProvider.notifier).state = true;
  // }

  // final companySectionsProvider = Provider<Map<String, List<Company>>>((ref) {
  //   final companiesAsync = ref.watch(filteredCompaniesProvider);

  //   return companiesAsync.when(
  //     data: (companies) {
  //       final Map<String, List<Company>> sections = {};
  //       for (var company in companies) {
  //         if (company.companyName != null && company.companyName!.isNotEmpty) {
  //           final firstChar = company.companyName![0].toUpperCase();
  //           // sections.putIfAbsent(firstChar, () => []).add(company);
  //         }
  //       }
  //       return sections;
  //     },
  //     loading: () => {},
  //     error: (error, stack) => {},
  //   );
  // });

  // Future<Map<String, List<Company>>> fetchSections({String searchQuery = ''}) async {
  //   final companies = await _companyService.fetchCompanies(ref);
  //   state = state.copyWith(companies: AsyncValue.data(companies));
  //   final filtered = _filterCompanies(companies, searchQuery);
  //   return _buildSections(filtered);
  // }

  // // Build sections from current state (no network). Useful if data already fetched.
  // Map<String, List<Company>> sections({String searchQuery = ''}) {
  //   final companies = state.companies.value ?? const <Company>[];
  //   final filtered = _filterCompanies(companies, searchQuery);
  //   return _buildSections(filtered);
  // }

  // List<Company> _filterCompanies(List<Company> companies, String searchQuery) {
  //   final q = searchQuery.trim().toLowerCase();
  //   if (q.isEmpty) return companies;

  //   return companies.where((company) {
  //     final name = (company.companyName).toLowerCase();
  //     final nameMatch = name.contains(q);

  //     bool addressMatch = false;
  //     if (q.startsWith('status:')) {
  //       final statusQuery = q.substring(7).trim();
  //       final isActive = company.isActive ?? false;
  //       if (statusQuery == 'active' && isActive) return true;
  //       if (statusQuery == 'inactive' && !isActive) return true;
  //       return false;
  //     } else if (q.startsWith('name:')) {
  //       final nameQuery = q.substring(5).trim();
  //       return name.contains(nameQuery.toLowerCase());
  //     }

  //     if (company.addresses.isNotEmpty) {
  //       addressMatch = company.addresses.any((addr) => (addr.address ?? '').toLowerCase().contains(q));
  //     }

  //     return nameMatch || addressMatch;
  //   }).toList();
  // }

  // Map<String, List<Company>> _buildSections(List<Company> companies) {
  //   final Map<String, List<Company>> sections = {};
  //   for (final company in companies) {
  //     final name = company.companyName;
  //     if (name.isEmpty) continue;
  //     final firstChar = name[0].toUpperCase();
  //     sections.putIfAbsent(firstChar, () => []).add(company);
  //   }
  //   // Optionally sort companies in each section by name
  //   for (final e in sections.entries) {
  //     e.value.sort((a, b) => a.companyName.compareTo(b.companyName));
  //   }
  //   return sections;
  // }

  //   final companySectionsProvider = Provider<Map<String, List<Company>>>((ref) {
  //   final companiesAsync = ref.watch(filteredCompaniesProvider);

  //   return companiesAsync.when(
  //     data: (companies) {
  //       final Map<String, List<Company>> sections = {};
  //       for (var company in companies) {
  //         if (company.companyName != null && company.companyName!.isNotEmpty) {
  //           final firstChar = company.companyName![0].toUpperCase();
  //           // sections.putIfAbsent(firstChar, () => []).add(company);
  //         }
  //       }
  //       return sections;
  //     },
  //     loading: () => {},
  //     error: (error, stack) => {},
  //   );
  // });
}
