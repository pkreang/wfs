import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/core/http/api_client.dart';
import 'package:wfs/features/appointment/models/sales_territory.dart';
import 'package:wfs/features/appointment/models/territory.dart';
import 'package:wfs/features/client/models/client.dart';
import 'package:wfs/features/client/models/client_company.dart';
import 'package:wfs/features/client/models/client_level.dart';
import 'package:wfs/features/client/models/client_status.dart';
import 'package:wfs/features/client/services/client_service.dart';
import 'package:wfs/features/company/models/company.dart';
import 'package:wfs/providers/client_provider.dart' show clientProvider;

DateTime get roundedNow {
  final now = DateTime.now();
  final minute = ((now.minute + 4) ~/ 5) * 5;

  return DateTime(now.year, now.month, now.day, now.hour, minute >= 60 ? 55 : minute);
}

@immutable
class ClientCreateState {
  final AsyncValue<Client> data;
  final List<Company> companies;
  final bool isDirty;
  final bool isLoading;
  final String? errorMessage;

  const ClientCreateState({required this.data, this.companies = const [], this.isDirty = false, this.isLoading = false, this.errorMessage});

  ClientCreateState copyWith({AsyncValue<Client>? data, List<Company>? companies, bool? isDirty, bool? isLoading, String? errorMessage, bool clearErrorMessage = false}) => ClientCreateState(
    data: data ?? this.data,
    companies: companies ?? this.companies,
    isDirty: isDirty ?? this.isDirty,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
  );
}

class ClientCreateViewModel extends StateNotifier<ClientCreateState> {
  ClientCreateViewModel(this.ref) : super(const ClientCreateState(data: AsyncValue.loading())) {
    state = state.copyWith(
      data: AsyncValue.data(Client(availableTimeStart: DateFormat('HH:mm').format(roundedNow), availableTimeEnd: DateFormat('HH:mm').format(roundedNow))),
      isDirty: false,
    );
  }

  final Ref ref;

  ClientService get _clientService => ref.read(clientServiceProvider);

  // Future<void> fetch() async {
  //   final clientAsync = await AsyncValue.guard(() => _clientService.getById(ref, id));
  //   clientAsync.whenData((client) {
  //     final res = AsyncValue.data(client);
  //     state = state.copyWith(data: res, isDirty: false);

  //     final List<Company> companies = client.companies
  //         .map((cc) => cc.company)
  //         .where((c) => (c?.companyID ?? '').isNotEmpty)
  //         .map((c) => Company(companyID: c!.companyID, companyName: c.companyName))
  //         .toList();

  //     state = state.copyWith(data: res, companies: companies, isDirty: false);
  //   });
  // }

  void setFirstName(String firstName) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(firstName: firstName)), isDirty: true, clearErrorMessage: true);
  }

  void setLastName(String lastName) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(lastName: lastName)), isDirty: true, clearErrorMessage: true);
  }

  void setMobile(String mobile) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(phone: mobile)), isDirty: true, clearErrorMessage: true);
  }

  void setEmail(String email) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(email: email)), isDirty: true, clearErrorMessage: true);
  }

  void setClientStatus(ClientStatus status) {
    state = state.copyWith(
      data: state.data.whenData((v) => v.copyWith(clientStatusID: status.clientStatusID, clientStatus: status)),
      isDirty: true,
    );
  }

  void setClientLevel(ClientLevel status) {
    state = state.copyWith(
      data: state.data.whenData((v) => v.copyWith(clientLevelID: status.clientLevelID, clientLevel: status)),
      isDirty: true,
    );
  }

  void setTerritory(Territory status) {
    final newSalesTerritory = SalesTerritory(salesTerritoryID: status.salesTerritoryID, salesTerritoryName: status.salesTerritoryName);

    state = state.copyWith(
      data: state.data.whenData((v) => v.copyWith(salesTerritoryID: status.salesTerritoryID, salesTerritoryName: status.salesTerritoryName, salesTerritory: newSalesTerritory)),
      isDirty: true,
    );
  }

  void setAvailableTimeStart(TimeOfDay time) {
    final now = DateTime.now();
    final updated = DateTime(now.year, now.month, now.day, time.hour, time.minute);

    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(availableTimeStart: DateFormat('HH:mm').format(updated))), isDirty: true, clearErrorMessage: true);
  }

  void setAvailableTimeEnd(TimeOfDay time) {
    final now = DateTime.now();
    final updated = DateTime(now.year, now.month, now.day, time.hour, time.minute);

    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(availableTimeEnd: DateFormat('HH:mm').format(updated))), isDirty: true, clearErrorMessage: true);
  }

  void setCompany(Company company) {
    state = state.copyWith(
      data: state.data.whenData((v) {
        return v.copyWith(
          companies: [ClientCompany(companyID: company.companyID ?? '', createdBy: company.createdBy, modifiedBy: company.modifiedBy, company: company)],
        );
      }),
      isDirty: true,
    );
  }

  void removeCompany(String companyID) {
    state = state.copyWith(
      data: state.data.whenData((v) {
        return v.copyWith(companies: []);
      }),
      isDirty: true,
    );
  }

  Future<bool> createClient() async {
    final detail = state.data.value;
    if (!state.isDirty || detail == null) return false;

    state = state.copyWith(isLoading: true);

    try {
      final result = await _clientService.createClient(detail, ref);
      if (!result) return result;

      ref.invalidate(clientListProvider);
      ref.invalidate(clientProvider);

      return result;
    } catch (e, st) {
      state = state.copyWith(errorMessage: e is ApiException ? e.message : 'Request failed');
    } finally {
      state = state.copyWith(isLoading: false);
    }

    return false;
  }
}
