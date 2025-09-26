import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/core/http/api_client.dart';
import 'package:wfs/features/client/models/client.dart';
import 'package:wfs/features/client/services/client_service.dart';

@immutable
class ClientListState {
  final AsyncValue<List<Client>> clients;
  final Map<String, List<Client>> sections;
  final bool isEdit;
  final bool isDirty;
  final bool isLoading;
  final String? errorMessage;
  final String? statusNameFilter;

  const ClientListState({required this.clients, this.sections = const {}, this.isEdit = false, this.isDirty = false, this.isLoading = false, this.errorMessage, this.statusNameFilter});

  ClientListState copyWith({
    AsyncValue<List<Client>>? clients,
    Map<String, List<Client>>? sections,
    bool? isEdit,
    bool? isDirty,
    bool? isLoading,
    String? errorMessage,
    String? statusNameFilter,
    bool clearErrorMessage = false,
  }) => ClientListState(
    clients: clients ?? this.clients,
    sections: sections ?? this.sections,
    isEdit: isEdit ?? this.isEdit,
    isDirty: isDirty ?? this.isDirty,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    statusNameFilter: statusNameFilter ?? this.statusNameFilter,
  );
}

class ClientListViewModel extends StateNotifier<ClientListState> {
  ClientListViewModel(this.ref, {String? initialStatus}) : super(ClientListState(clients: const AsyncValue.loading(), statusNameFilter: initialStatus)) {
    fetch();
  }

  final Ref ref;

  ClientService get _clientService => ref.read(clientServiceProvider);

  Future<void> fetch() async {
    final clientsAsync = await AsyncValue.guard(() => _clientService.fetchClients(ref));
    clientsAsync.whenData((clients) {
      List<Client> filtered = clients;
      final status = state.statusNameFilter?.trim();
      if (status != null && status.isNotEmpty) {
        final target = status.toLowerCase();
        filtered = clients.where((c) => (c.clientStatus?.clientStatusName ?? '').toLowerCase() == target).toList();
      }

      final Map<String, List<Client>> sections = {};
      for (var client in filtered) {
        final firstChar = client.clientName[0].toUpperCase();
        sections.putIfAbsent(firstChar, () => []).add(client);
      }

      const levelOrder = {'A': 0, 'B': 1, 'C': 2, 'D': 3, 'E': 4, 'F': 5};
      int levelRank(String? level) => levelOrder[level?.toUpperCase()] ?? 999;
      int nameCompare(Client a, Client b) => ('${a.firstName ?? ''} ${a.lastName ?? ''}').compareTo('${b.firstName ?? ''} ${b.lastName ?? ''}');

      for (final entry in sections.entries) {
        entry.value.sort((a, b) {
          final ra = levelRank(a.clientLevel?.clientLevelName);
          final rb = levelRank(b.clientLevel?.clientLevelName);
          final cmp = ra.compareTo(rb);
          if (cmp != 0) return cmp;
          return nameCompare(a, b);
        });
      }

      state = state.copyWith(clients: AsyncValue.data(filtered), sections: sections);
    });
  }

  void setEditMode() {
    state = state.copyWith(isEdit: !state.isEdit);
  }

  void onRemoveClient(String clientID) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      await _clientService.deleteClient(clientID, ref);
    } catch (e, st) {
      state = state.copyWith(errorMessage: e is ApiException ? e.message : 'Request failed');
    } finally {
      state = state.copyWith(isLoading: false);
      fetch();
    }
  }
}
