import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/models/clientaddresses_model.dart';
import 'package:wfs/models/clientcompanies_model.dart';
import 'package:wfs/models/clientlevel_model.dart';
import 'package:wfs/models/clientstatus_model.dart';
import 'package:wfs/models/sales_territory.dart';
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

final clienAddProvider = FutureProvider.family<Client, Client>((
  ref,
  client,
) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('User is not authenticated.');
  }

  final clientService = ref.watch(clientServiceProvider);

  return clientService.Add(accessToken, client);
});

final clientEditProvider = StateNotifierProvider.autoDispose
    .family<ClientEditViewModel, ClientEditState, String>((ref, id) {
      return ClientEditViewModel(ref, id);
    });

@immutable
class ClientEditState {
  final AsyncValue<Client> data;
  final bool isDirty;
  final bool isLoading;

  const ClientEditState({
    required this.data,
    this.isDirty = false,
    this.isLoading = false,
  });

  ClientEditState copyWith({
    AsyncValue<Client>? data,
    bool? isDirty,
    bool? isLoading,
  }) => ClientEditState(
    data: data ?? this.data,
    isDirty: isDirty ?? this.isDirty,
    isLoading: isLoading ?? this.isLoading,
  );
}

class ClientEditViewModel extends StateNotifier<ClientEditState> {
  ClientEditViewModel(this.ref, this.id)
    : super(const ClientEditState(data: AsyncValue.loading())) {
    fetch();
  }

  final Ref ref;
  final String id;

  ClientService get _ClientService => ref.read(clientServiceProvider);

  Future<void> fetch() async {
    final authState = ref.watch(authProvider);
    final res = await AsyncValue.guard(
      () => _ClientService.GetById(authState.accessToken.toString(), id),
    );
    state = state.copyWith(data: res, isDirty: false);
  }

  void setFirstName(String firstName) {
    state = state.copyWith(
      data: state.data.whenData((v) => v.copyWith(firstName: firstName)),
      isDirty: true,
    );
  }

  void setLastName(String lastName) {
    state = state.copyWith(
      data: state.data.whenData((v) => v.copyWith(lastName: lastName)),
      isDirty: true,
    );
  }

  void setStatus(ClientStatus clientStatus) {
    state = state.copyWith(
      data: state.data.whenData(
        (v) => v.copyWith(
          clientStatus: clientStatus,
          clientStatusID: clientStatus.clientStatusID,
        ),
      ),
      isDirty: true,
    );
  }

  void setLevel(ClientLevel clientLevel) {
    state = state.copyWith(
      data: state.data.whenData(
        (v) => v.copyWith(
          clientLevel: clientLevel,
          clientLevelID: clientLevel.clientLevelID,
        ),
      ),
      isDirty: true,
    );
  }

  void setEmail(String email) {
    state = state.copyWith(
      data: state.data.whenData((v) => v.copyWith(email: email)),
      isDirty: true,
    );
  }

  void setPhone(String phone) {
    state = state.copyWith(
      data: state.data.whenData((v) => v.copyWith(phone: phone)),
      isDirty: true,
    );
  }

  void setTerritory(SalesTerritory territory) {
    state = state.copyWith(
      data: state.data.whenData(
        (v) => v.copyWith(
          salesTerritory: territory,
          salesTerritoryID: territory.salesTerritoryID,
        ),
      ),
      isDirty: true,
    );
  }

  void setClientAddress(List<ClientAddresses>? listClientAddresses) {
    state = state.copyWith(
      data: state.data.whenData(
        (v) => v.copyWith(clientAddresses: listClientAddresses),
      ),
      isDirty: true,
    );
  }

  void setavailableTimeStart(TimeOfDay? availableTimeStart) {
    state = state.copyWith(
      data: state.data.whenData(
        (v) => v.copyWith(
          availableTimeStart:
              availableTimeStart!.hour.toString() +
              ":" +
              availableTimeStart.minute.toString(),
        ),
      ),
      isDirty: true,
    );
  }

  void setavailableTimeEnd(TimeOfDay? availableTimeEnd) {
    state = state.copyWith(
      data: state.data.whenData(
        (v) => v.copyWith(
          availableTimeEnd:
              availableTimeEnd!.hour.toString() +
              ":" +
              availableTimeEnd.minute.toString(),
        ),
      ),
      isDirty: true,
    );
  }

  Future<bool> editClient() async {
    final client = state.data.valueOrNull;
    if (!state.isDirty || client == null) return false;

    state = state.copyWith(isLoading: true);

    try {
      final authState = ref.watch(authProvider);
      ClientService clientService = ClientService();
      await clientService.Edit(
        authState.accessToken.toString(),
        client.clientID.toString(),
        client,
      );
      return true;
    } catch (e, st) {
      state = state.copyWith(data: AsyncError(e, st));
    } finally {
      state = state.copyWith(isLoading: false);
    }

    return false;
  }

  // void setClientStatus(ClientStatus status) {
  //   state = state.copyWith(
  //     data: state.data.whenData(
  //       (v) => v.copyWith(
  //         ClientStatusId: status.ClientStatusID,
  //         ClientStatusName: status.ClientStatusName,
  //       ),
  //     ),
  //     isDirty: true,
  //   );
  // }

  // void setPurpose(Purpose status) {
  //   state = state.copyWith(
  //     data: state.data.whenData(
  //       (v) => v.copyWith(
  //         purposeTypeId: status.purposeTypeID,
  //         purposeTypeName: status.purposeTypeName,
  //       ),
  //     ),
  //     isDirty: true,
  //   );
  // }

  // void setClient(Client status) {
  //   final newSalesClient = SalesClient(
  //     salesClientID: status.salesClientID,
  //     salesClientName: status.salesClientName,
  //   );

  //   state = state.copyWith(
  //     data: state.data.whenData(
  //       (v) => v.copyWith(
  //         client: v.client.copyWith(
  //           salesClient: newSalesClient,
  //         ),
  //       ),
  //     ),
  //     isDirty: true,
  //   );
  // }

  void addCompany(ClientCompanies clientCompanies) {
    state = state.copyWith(
      data: state.data.whenData(
        (v) => v.copyWith(
          clientCompanies: [...v.clientCompanies!, clientCompanies],
        ),
      ),
      isDirty: true,
    );
  }

  // void updateClient(Client Client) {
  //   state = state.copyWith(
  //     data: state.data.whenData(
  //       (v) => v.copyWith(
  //         Clients: v.Clients.map(
  //           (p) => p.ClientId == Client.ClientId
  //               ? Client
  //               : p,
  //         ).toList(),
  //       ),
  //     ),
  //     isDirty: true,
  //   );
  // }

  void removeCompany(String companyID) {
    state = state.copyWith(
      data: state.data.whenData((v) {
        List<ClientCompanies> listClientCompanies = List.from(
          v.clientCompanies ?? [],
        );
        listClientCompanies.removeWhere(
          (p) => p.company?.companyID == companyID,
        );
        return v.copyWith(clientCompanies: listClientCompanies);
      }),
      isDirty: true,
    );
  }

  // Future<bool> updateClient({String? noted}) async {
  //   final detail = state.data.valueOrNull;
  //   if (!state.isDirty || detail == null) return false;

  //   state = state.copyWith(isLoading: true);

  //   try {
  //     return await _ClientService.updateClient(detail);
  //   } catch (e, st) {
  //     state = state.copyWith(data: AsyncError(e, st));
  //   } finally {
  //     state = state.copyWith(isLoading: false);
  //   }

  //   return false;
  // }

  // Future<bool> deleteClient() async {
  //   state = state.copyWith(isLoading: true);

  //   try {
  //     return await _ClientService.deleteClient(id);
  //   } catch (e, st) {
  //     state = state.copyWith(data: AsyncError(e, st));
  //   } finally {
  //     state = state.copyWith(isLoading: false);
  //   }

  //   return false;
  // }
}
