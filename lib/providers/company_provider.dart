import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/models/clientcompanies_model.dart';
import 'package:wfs/models/companyaddress.dart';
import 'package:wfs/models/territory_model.dart';
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
  //final shouldLoad = ref.watch(companyLoadTriggerProvider);

  // if (!shouldLoad) {
  //   return [];
  // }

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
        return company.companyName!.toLowerCase().contains(query) ||
            company.taxID!.toLowerCase().contains(query) ||
            company.noted!.toLowerCase().contains(query);
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
        final firstLetter = company.companyName!.isNotEmpty
            ? company.companyName!.toUpperCase()
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

  return companyService.getList(accessToken);
});
final companyGetListClientCompanyProvider =
    FutureProvider<List<ClientCompanies>>((ref) async {
      final authState = ref.watch(authProvider);
      final accessToken = authState.accessToken;

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('User is not authenticated.');
      }

      final companyService = ref.watch(companyServiceProvider);

      return companyService.GetListClientCompany(accessToken);
    });
final companyEditProvider = StateNotifierProvider.autoDispose
    .family<CompanyEditViewModel, CompanyEditState, String>((ref, id) {
      return CompanyEditViewModel(ref, id);
    });

@immutable
class CompanyEditState {
  final AsyncValue<Company> data;
  final bool isDirty;
  final bool isLoading;

  const CompanyEditState({
    required this.data,
    this.isDirty = false,
    this.isLoading = false,
  });

  CompanyEditState copyWith({
    AsyncValue<Company>? data,
    bool? isDirty,
    bool? isLoading,
  }) => CompanyEditState(
    data: data ?? this.data,
    isDirty: isDirty ?? this.isDirty,
    isLoading: isLoading ?? this.isLoading,
  );
}

class CompanyEditViewModel extends StateNotifier<CompanyEditState> {
  CompanyEditViewModel(this.ref, this.id)
    : super(const CompanyEditState(data: AsyncValue.loading())) {
    fetch();
  }

  final Ref ref;
  final String id;

  CompanyService get _CompanyService => ref.read(companyServiceProvider);

  Future<void> fetch() async {
    final authState = ref.watch(authProvider);
    final res = await AsyncValue.guard(
      () => _CompanyService.GetById(authState.accessToken.toString(), id),
    );
    state = state.copyWith(data: res, isDirty: false);
  }

  void setName(String name) {
    state = state.copyWith(
      data: state.data.whenData((v) => v.copyWith(companyName: name)),
      isDirty: true,
    );
  }

  void setTaxID(String taxID) {
    state = state.copyWith(
      data: state.data.whenData((v) => v.copyWith(taxID: taxID)),
      isDirty: true,
    );
  }

  void setAddress(List<CompanyAddress> listCompanyAddress) {
    state = state.copyWith(
      data: state.data.whenData(
        (v) => v.copyWith(CompanyAddresses: listCompanyAddress),
      ),
      isDirty: true,
    );
  }

  // void setLastName(String lastName) {
  //   state = state.copyWith(
  //     data: state.data.whenData((v) => v.copyWith(lastName: lastName)),
  //     isDirty: true,
  //   );
  // }

  void setTerritory(Territory territory) {
    state = state.copyWith(
      data: state.data.whenData(
        (v) => v.copyWith(
          salesTerritoryID: territory.salesTerritoryID,
          salesTerritoryName: territory.salesTerritoryName,
        ),
      ),
      isDirty: true,
    );
  }

  Future<bool> editCompany() async {
    final company = state.data.valueOrNull;
    if (!state.isDirty || company == null) return false;

    state = state.copyWith(isLoading: true);

    try {
      final authState = ref.watch(authProvider);
      CompanyService companyService = CompanyService();
      await companyService.Edit(
        authState.accessToken.toString(),
        company.companyID.toString(),
        company,
      );
      return true;
    } catch (e, st) {
      state = state.copyWith(data: AsyncError(e, st));
    } finally {
      state = state.copyWith(isLoading: false);
    }

    return false;
  }

  // void setLevel(ClientLevel clientLevel) {
  //   state = state.copyWith(
  //     data: state.data.whenData(
  //       (v) => v.copyWith(
  //         clientLevel: clientLevel,
  //         clientLevelID: clientLevel.clientLevelID,
  //       ),
  //     ),
  //     isDirty: true,
  //   );
  // }

  // void setEmail(String email) {
  //   state = state.copyWith(
  //     data: state.data.whenData((v) => v.copyWith(email: email)),
  //     isDirty: true,
  //   );
  // }

  // void setPhone(String phone) {
  //   state = state.copyWith(
  //     data: state.data.whenData((v) => v.copyWith(phone: phone)),
  //     isDirty: true,
  //   );
  // }

  // void setTerritory(SalesTerritory territory) {
  //   state = state.copyWith(
  //     data: state.data.whenData(
  //       (v) => v.copyWith(
  //         salesTerritory: territory,
  //         salesTerritoryID: territory.salesTerritoryID,
  //       ),
  //     ),
  //     isDirty: true,
  //   );
  // }

  // void setClientAddress(List<ClientAddresses>? listClientAddresses) {
  //   state = state.copyWith(
  //     data: state.data.whenData(
  //       (v) => v.copyWith(clientAddresses: listClientAddresses),
  //     ),
  //     isDirty: true,
  //   );
  // }

  // void setavailableTimeStart(TimeOfDay? availableTimeStart) {
  //   state = state.copyWith(
  //     data: state.data.whenData(
  //       (v) => v.copyWith(
  //         availableTimeStart:
  //             availableTimeStart!.hour.toString() +
  //             ":" +
  //             availableTimeStart.minute.toString(),
  //       ),
  //     ),
  //     isDirty: true,
  //   );
  // }

  // void setavailableTimeEnd(TimeOfDay? availableTimeEnd) {
  //   state = state.copyWith(
  //     data: state.data.whenData(
  //       (v) => v.copyWith(
  //         availableTimeEnd:
  //             availableTimeEnd!.hour.toString() +
  //             ":" +
  //             availableTimeEnd.minute.toString(),
  //       ),
  //     ),
  //     isDirty: true,
  //   );
  // }

  // Future<bool> editClient() async {
  //   final client = state.data.valueOrNull;
  //   if (!state.isDirty || client == null) return false;

  //   state = state.copyWith(isLoading: true);

  //   try {
  //     final authState = ref.watch(authProvider);
  //     ClientService clientService = ClientService();
  //     await clientService.Edit(
  //       authState.accessToken.toString(),
  //       client.clientID.toString(),
  //       client,
  //     );
  //     return true;
  //   } catch (e, st) {
  //     state = state.copyWith(data: AsyncError(e, st));
  //   } finally {
  //     state = state.copyWith(isLoading: false);
  //   }

  //   return false;
  // }

  // // void setClientStatus(ClientStatus status) {
  // //   state = state.copyWith(
  // //     data: state.data.whenData(
  // //       (v) => v.copyWith(
  // //         ClientStatusId: status.ClientStatusID,
  // //         ClientStatusName: status.ClientStatusName,
  // //       ),
  // //     ),
  // //     isDirty: true,
  // //   );
  // // }

  // // void setPurpose(Purpose status) {
  // //   state = state.copyWith(
  // //     data: state.data.whenData(
  // //       (v) => v.copyWith(
  // //         purposeTypeId: status.purposeTypeID,
  // //         purposeTypeName: status.purposeTypeName,
  // //       ),
  // //     ),
  // //     isDirty: true,
  // //   );
  // // }

  // // void setClient(Client status) {
  // //   final newSalesClient = SalesClient(
  // //     salesClientID: status.salesClientID,
  // //     salesClientName: status.salesClientName,
  // //   );

  // //   state = state.copyWith(
  // //     data: state.data.whenData(
  // //       (v) => v.copyWith(
  // //         client: v.client.copyWith(
  // //           salesClient: newSalesClient,
  // //         ),
  // //       ),
  // //     ),
  // //     isDirty: true,
  // //   );
  // // }

  // void addCompany(ClientCompanies clientCompanies) {
  //   state = state.copyWith(
  //     data: state.data.whenData(
  //       (v) => v.copyWith(
  //         clientCompanies: [...v.clientCompanies!, clientCompanies],
  //       ),
  //     ),
  //     isDirty: true,
  //   );
  // }

  // // void updateClient(Client Client) {
  // //   state = state.copyWith(
  // //     data: state.data.whenData(
  // //       (v) => v.copyWith(
  // //         Clients: v.Clients.map(
  // //           (p) => p.ClientId == Client.ClientId
  // //               ? Client
  // //               : p,
  // //         ).toList(),
  // //       ),
  // //     ),
  // //     isDirty: true,
  // //   );
  // // }

  // void removeCompany(String companyID) {
  //   state = state.copyWith(
  //     data: state.data.whenData((v) {
  //       List<ClientCompanies> listClientCompanies = List.from(
  //         v.clientCompanies ?? [],
  //       );
  //       listClientCompanies.removeWhere(
  //         (p) => p.company?.companyID == companyID,
  //       );
  //       return v.copyWith(clientCompanies: listClientCompanies);
  //     }),
  //     isDirty: true,
  //   );
  // }

  // // Future<bool> updateClient({String? noted}) async {
  // //   final detail = state.data.valueOrNull;
  // //   if (!state.isDirty || detail == null) return false;

  // //   state = state.copyWith(isLoading: true);

  // //   try {
  // //     return await _ClientService.updateClient(detail);
  // //   } catch (e, st) {
  // //     state = state.copyWith(data: AsyncError(e, st));
  // //   } finally {
  // //     state = state.copyWith(isLoading: false);
  // //   }

  // //   return false;
  // // }

  // // Future<bool> deleteClient() async {
  // //   state = state.copyWith(isLoading: true);

  // //   try {
  // //     return await _ClientService.deleteClient(id);
  // //   } catch (e, st) {
  // //     state = state.copyWith(data: AsyncError(e, st));
  // //   } finally {
  // //     state = state.copyWith(isLoading: false);
  // //   }

  // //   return false;
  // // }
}
