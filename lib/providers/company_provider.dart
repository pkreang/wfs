import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/company_model.dart';
import '../services/company_service.dart';
import 'auth_provider.dart';

final companyServiceProvider = Provider<CompanyService>((ref) {
  return CompanyService();
});
final companyLoadTriggerProvider = StateProvider<bool>((ref) => false);

final companiesDataProvider = StateProvider<AsyncValue<List<Company>>>(
  (ref) => const AsyncValue.loading(),
);

final companiesProvider = FutureProvider<List<Company>>((ref) async {
  final authState = ref.watch(authProvider);
  final companyService = ref.read(companyServiceProvider);
  final shouldLoad = ref.watch(companyLoadTriggerProvider);

  if (!shouldLoad) {
    return [];
  }

  if (authState.accessToken == null) {
    throw Exception('No access token available');
  }

  final response = await companyService.getCompanies(authState.accessToken!);

  return response.companies;
});

final filteredCompaniesProvider = Provider<AsyncValue<List<Company>>>((ref) {
  final companiesAsync = ref.watch(companiesProvider);
  final searchQuery = ref.watch(companySearchProvider);

  return companiesAsync.when(
    data: (companies) {
      if (searchQuery.isEmpty) {
        return AsyncValue.data(companies);
      }

      final filtered = companies.where((company) {
        final query = searchQuery.toLowerCase();
        return company.companyName.toLowerCase().contains(query) ||
            company.taxID.toLowerCase().contains(query) ||
            company.noted.toLowerCase().contains(query);
      }).toList();

      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

final companySearchProvider = StateProvider<String>((ref) => '');

final companySectionsProvider = Provider<Map<String, List<Company>>>((ref) {
  final companiesAsync = ref.watch(filteredCompaniesProvider);

  return companiesAsync.when(
    data: (companies) {
      final sections = <String, List<Company>>{};

      for (final company in companies) {
        final firstLetter = company.companyName.isNotEmpty
            ? company.companyName[0].toUpperCase()
            : '#';

        if (!sections.containsKey(firstLetter)) {
          sections[firstLetter] = [];
        }
        sections[firstLetter]!.add(company);
      }

      // Sort sections alphabetically
      final sortedSections = Map.fromEntries(
        sections.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
      );

      return sortedSections;
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

void loadCompanies(WidgetRef ref) {
  ref.read(companyLoadTriggerProvider.notifier).state = false;

  ref.read(companyLoadTriggerProvider.notifier).state = true;
}

void refreshCompanies(WidgetRef ref) {
  ref.invalidate(companiesProvider);
}

void resetCompanies(WidgetRef ref) {
  ref.read(companyLoadTriggerProvider.notifier).state = false;
  ref.read(companySearchProvider.notifier).state = '';
}

final companyGetListProvider = FutureProvider<List<Company>>((ref) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('User is not authenticated.');
  }

  final companyService = ref.watch(companyServiceProvider);

  return companyService.GetList(accessToken);
});
