import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/client/models/client.dart';
import 'package:wfs/features/client/services/client_service.dart';

@immutable
class ClientEditState {
  final AsyncValue<Client> data;
  final bool isDirty;
  final bool isLoading;

  const ClientEditState({required this.data, this.isDirty = false, this.isLoading = false});

  ClientEditState copyWith({AsyncValue<Client>? data, bool? isDirty, bool? isLoading}) =>
      ClientEditState(data: data ?? this.data, isDirty: isDirty ?? this.isDirty, isLoading: isLoading ?? this.isLoading);
}

class ClientEditViewModel extends StateNotifier<ClientEditState> {
  ClientEditViewModel(this.ref, this.id) : super(const ClientEditState(data: AsyncValue.loading())) {
    fetch();
  }

  final Ref ref;
  final String id;

  ClientService get _clientService => ref.read(clientServiceProvider);

  void setIsLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }

  Future<void> fetch() async {
    // final res = await AsyncValue.guard(() => _clientService.fetchAppointmentById(ref, id));
    // state = state.copyWith(data: res, isDirty: false);
  }

  void setMobile(String mobile) {}

  void setEmail(String email) {}

  // void setAppointmentType(AppointmentType status) {
  //   state = state.copyWith(
  //     data: state.data.whenData((v) => v.copyWith(appointmentTypeID: status.appointmentTypeID, appointmentTypeName: status.appointmentTypeName)),
  //     isDirty: true,
  //   );
  // }

  // void setAppointmentStatus(AppointmentStatus status) {
  //   state = state.copyWith(
  //     data: state.data.whenData((v) => v.copyWith(appointmentStatusID: status.appointmentStatusID, appointmentStatusName: status.appointmentStatusName)),
  //     isDirty: true,
  //   );
  // }

  // void setPurpose(Purpose status) {
  //   state = state.copyWith(
  //     data: state.data.whenData((v) => v.copyWith(purposeTypeID: status.purposeTypeID, purposeTypeName: status.purposeTypeName)),
  //     isDirty: true,
  //   );
  // }

  // void setTerritory(Territory status) {
  //   final newSalesTerritory = SalesTerritory(salesTerritoryID: status.salesTerritoryID, salesTerritoryName: status.salesTerritoryName);

  //   state = state.copyWith(
  //     data: state.data.whenData((v) => v.copyWith(client: v.client.copyWith(salesTerritory: newSalesTerritory))),
  //     isDirty: true,
  //   );
  // }

  // void setAppointmentFromDate(DateTime newDateTime) {
  //   final currentDateTime = state.data.value?.appointmentDateTimeFrom;
  //   if (currentDateTime == null) return;

  //   final oldDateTime = DateTime.parse(currentDateTime);
  //   final updated = DateTime(newDateTime.year, newDateTime.month, newDateTime.day, oldDateTime.hour, oldDateTime.minute);

  //   state = state.copyWith(data: state.data.whenData((v) => v.copyWith(appointmentDateTimeFrom: updated.toIso8601String())), isDirty: true);
  // }

  // void setAppointmentFromTime(TimeOfDay time) {
  //   final currentDateTime = state.data.value?.appointmentDateTimeFrom;
  //   if (currentDateTime == null) return;

  //   final dateTime = DateTime.parse(currentDateTime);
  //   final updated = DateTime(dateTime.year, dateTime.month, dateTime.day, time.hour, time.minute);

  //   state = state.copyWith(data: state.data.whenData((v) => v.copyWith(appointmentDateTimeFrom: updated.toIso8601String())), isDirty: true);
  // }

  // void setAppointmentToDate(DateTime newDateTime) {
  //   final currentDateTime = state.data.value?.appointmentDateTimeTo;
  //   if (currentDateTime == null) return;

  //   final oldDateTime = DateTime.parse(currentDateTime);
  //   final updated = DateTime(newDateTime.year, newDateTime.month, newDateTime.day, oldDateTime.hour, oldDateTime.minute);

  //   state = state.copyWith(data: state.data.whenData((v) => v.copyWith(appointmentDateTimeTo: updated.toIso8601String())), isDirty: true);
  // }

  // void setAppointmentToTime(TimeOfDay time) {
  //   final currentDateTime = state.data.value?.appointmentDateTimeTo;
  //   if (currentDateTime == null) return;

  //   final dateTime = DateTime.parse(currentDateTime);
  //   final updated = DateTime(dateTime.year, dateTime.month, dateTime.day, time.hour, time.minute);

  //   state = state.copyWith(data: state.data.whenData((v) => v.copyWith(appointmentDateTimeTo: updated.toIso8601String())), isDirty: true);
  // }

  // void setNoted(String noted) {
  //   state = state.copyWith(data: state.data.whenData((v) => v.copyWith(noted: noted)), isDirty: true);
  // }

  // void addProduct(Product product) {
  //   state = state.copyWith(data: state.data.whenData((v) => v.copyWith(products: [...v.products, product])), isDirty: true);
  // }

  // void updateProduct(Product product) {
  //   state = state.copyWith(data: state.data.whenData((v) => v.copyWith(products: v.products.map((p) => p.productId == product.productId ? product : p).toList())), isDirty: true);
  // }

  // void removeProduct(String productId) {
  //   state = state.copyWith(data: state.data.whenData((v) => v.copyWith(products: v.products.where((p) => p.productId != productId).toList())), isDirty: true);
  // }

  // Future<bool> updateAppointment({String? noted}) async {
  //   final detail = state.data.value;
  //   if (!state.isDirty || detail == null) return false;

  //   state = state.copyWith(isLoading: true);

  //   try {
  //     final result = await _appointmentService.updateAppointment(detail, ref);
  //     if (!result) return result;

  //     final filter = DateTime.tryParse(detail.appointmentDateTimeFrom) ?? DateTime.now();
  //     ref.read(appointmentsByDateProvider(DateFormat("yyyy-MM-dd").format(filter)).notifier).refresh();

  //     return result;
  //   } catch (e, st) {
  //     state = state.copyWith(data: AsyncError(e, st));
  //   } finally {
  //     state = state.copyWith(isLoading: false);
  //   }

  //   return false;
  // }

  // Future<bool> deleteAppointment() async {
  //   final detail = state.data.value;
  //   if (detail == null) return false;

  //   state = state.copyWith(isLoading: true);

  //   try {
  //     final result = await _appointmentService.deleteAppointment(id, ref);
  //     if (!result) return result;

  //     final filter = DateTime.tryParse(detail.appointmentDateTimeFrom) ?? DateTime.now();
  //     ref.read(appointmentMarkDateProvider(DateTime(filter.year, filter.month, 1)).notifier).refresh();
  //     ref.read(appointmentsByDateProvider(DateFormat("yyyy-MM-dd").format(filter)).notifier).refresh();

  //     return result;
  //   } catch (e, st) {
  //     state = state.copyWith(data: AsyncError(e, st));
  //   } finally {
  //     state = state.copyWith(isLoading: false);
  //   }

  //   return false;
  // }
}
