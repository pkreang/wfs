import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/client_model.dart';
import '../services/client_service.dart';
import 'auth_provider.dart';

final clientServiceProvider = Provider<ClientService>((ref) {
  return ClientService();
});
final clientLoadTriggerProvider = StateProvider<bool>((ref) => false);

final clientDataProvider = StateProvider<AsyncValue<List<Client>>>(
  (ref) => const AsyncValue.loading(),
);

final clientProvider = FutureProvider<List<Client>>((ref) async {
  final authState = ref.watch(authProvider);
  final clientService = ref.read(clientServiceProvider);
  //final shouldLoad = ref.watch(clientLoadTriggerProvider);

  // if (!shouldLoad) {
  //   return [];
  // }

  if (authState.accessToken == null) {
    throw Exception('No access token available');
  }

  return await clientService.GetList(authState.accessToken!);
});

final clientSectionsProvider = Provider<Map<String, List<Client>>>((ref) {
  final companiesAsync = ref.watch(clientCompaniesProvider);

  return companiesAsync.when(
    data: (companies) {
      final sections = <String, List<Client>>{};

      for (final client in companies) {
        final firstLetter = client.firstName.toString().isNotEmpty
            ? client.firstName.toString().toUpperCase()
            : '#';

        if (!sections.containsKey(firstLetter)) {
          sections[firstLetter] = [];
        }
        sections[firstLetter]!.add(client);
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
final clientSearchProvider = StateProvider<String>((ref) => '');
final clientCompaniesProvider = Provider<AsyncValue<List<Client>>>((ref) {
  final companiesAsync = ref.watch(clientProvider);
  final searchQuery = ref.watch(clientSearchProvider);

  return companiesAsync.when(
    data: (companies) {
      if (searchQuery.isEmpty) {
        return AsyncValue.data(companies);
      }

      final client = companies.where((company) {
        final query = searchQuery.toLowerCase();
        return company.firstName.toString().toLowerCase().contains(query);
      }).toList();

      return AsyncValue.data(client);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

final clientGetByIdProvider = FutureProvider.family<Client, String>((
  ref,
  guid,
) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('User is not authenticated.');
  }

  final clientService = ref.watch(clientServiceProvider);

  return clientService.GetById(accessToken, guid);
});
