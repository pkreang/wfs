import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/models/address.dart';
import 'package:wfs/features/appointment/models/appointment.dart';
import 'package:wfs/features/appointment/models/appointment_status.dart';
import 'package:wfs/features/appointment/models/appointment_type.dart';
import 'package:wfs/features/appointment/models/purpose.dart';
import 'package:wfs/features/appointment/services/appointment_service.dart';
import 'package:wfs/features/company/models/company.dart';
import 'package:wfs/features/tag/models/tag.dart';
import 'package:wfs/providers/appointment_provider.dart';
import 'package:wfs/providers/auth_provider.dart';
import 'package:wfs/services/client_service.dart';
import 'package:wfs/features/client/services/client_service.dart' as client_service;

DateTime get roundedNow {
  final now = DateTime.now();
  final minute = ((now.minute + 4) ~/ 5) * 5;

  return DateTime(now.year, now.month, now.day, now.hour, minute >= 60 ? 55 : minute);
}

@immutable
class AppointmentCreateState {
  final AsyncValue<Appointment> appointment;
  final List<Company> companies;
  final bool isChangeTag;
  final bool isDirty;
  final bool isLoading;

  const AppointmentCreateState({required this.appointment, this.companies = const [], this.isChangeTag = false, this.isDirty = false, this.isLoading = false});

  AppointmentCreateState copyWith({AsyncValue<Appointment>? appointment, List<Company>? companies, bool? isChangeTag, bool? isDirty, bool? isLoading}) => AppointmentCreateState(
    appointment: appointment ?? this.appointment,
    companies: companies ?? this.companies,
    isChangeTag: isChangeTag ?? this.isChangeTag,
    isDirty: isDirty ?? this.isDirty,
    isLoading: isLoading ?? this.isLoading,
  );
}

class AppointmentCreateViewModel extends StateNotifier<AppointmentCreateState> {
  AppointmentCreateViewModel(this.ref, this.id) : super(AppointmentCreateState(appointment: AsyncValue.loading())) {
    fetchClientById();
  }

  final Ref ref;
  final String id;

  ClientService get _cleintService => ClientService();
  client_service.ClientService get _clientService => client_service.ClientService();
  AppointmentService get _appointmentService => ref.read(appointmentServiceProvider);

  Future<void> fetchClientById() async {
    final res = await AsyncValue.guard(() => _cleintService.getById(ref, id));
    res.whenData((client) {
      final salesTerritory = client.salesTerritory;
      final now = roundedNow;

      List<Company> companies = (client.companies ?? [])
          .map((cc) => cc.company)
          .where((c) => (c?.companyID ?? '').isNotEmpty)
          .map((c) => Company(companyID: c!.companyID, companyName: c.companyName, addresses: c.addresses))
          .toList();

      state = state.copyWith(
        appointment: AsyncValue.data(
          Appointment(
            appointmentTitle: 'นัดพบลูกค้า',
            appointmentStatusID: '4E2DC36E-53E6-4E9B-BAC2-1F2629BD745B',
            appointmentStatusName: 'Scheduled',
            clientID: client.clientID,
            clientName: client.clientName,
            tags: client.tags,
            phone: client.phone,
            email: client.email,
            salesTerritoryID: salesTerritory?.salesTerritoryID,
            salesTerritoryName: salesTerritory?.salesTerritoryName,
            appointmentDateTimeFrom: now,
            appointmentDateTimeTo: now.add(const Duration(minutes: 30)),
            isActive: true,
          ),
        ),
        isDirty: false,
        companies: companies,
      );
    });
  }

  void setTags(List<Tag> tags) {
    state = state.copyWith(appointment: state.appointment.whenData((value) => value.copyWith(tags: tags)), isChangeTag: true, isDirty: true);
  }

  void setAppointmentType(AppointmentType status) {
    state = state.copyWith(
      appointment: state.appointment.whenData((value) => value.copyWith(appointmentTypeID: status.appointmentTypeID, appointmentTypeName: status.appointmentTypeName)),
      isDirty: true,
    );
  }

  void setAppointmentStatus(AppointmentStatus status) {
    state = state.copyWith(
      appointment: state.appointment.whenData((value) => value.copyWith(appointmentStatusID: status.appointmentStatusID, appointmentStatusName: status.appointmentStatusName)),
      isDirty: true,
    );
  }

  void setPurpose(Purpose status) {
    state = state.copyWith(
      appointment: state.appointment.whenData(
        (value) => value.copyWith(purposeTypeID: status.purposeTypeID, purposeTypeName: status.purposeTypeName, isClearPurposeOther: status.purposeTypeName == 'Other'),
      ),
      isDirty: true,
    );
  }

  void setPurposeOther(String purposeOther) {
    state = state.copyWith(appointment: state.appointment.whenData((value) => value.copyWith(purposeOther: purposeOther)), isDirty: true);
  }

  void setAppointmentFromDate(DateTime newDateTime) {
    final currentDateTime = state.appointment.value?.appointmentDateTimeFrom;
    if (currentDateTime == null) return;

    final updated = DateTime(newDateTime.year, newDateTime.month, newDateTime.day, currentDateTime.hour, currentDateTime.minute);
    state = state.copyWith(appointment: state.appointment.whenData((v) => v.copyWith(appointmentDateTimeFrom: updated)), isDirty: true);
  }

  void setAppointmentFromTime(TimeOfDay time) {
    final currentDateTime = state.appointment.value?.appointmentDateTimeFrom;
    if (currentDateTime == null) return;

    final updated = DateTime(currentDateTime.year, currentDateTime.month, currentDateTime.day, time.hour, time.minute);
    state = state.copyWith(appointment: state.appointment.whenData((v) => v.copyWith(appointmentDateTimeFrom: updated)), isDirty: true);
  }

  void setAppointmentToDate(DateTime newDateTime) {
    final currentDateTime = state.appointment.value?.appointmentDateTimeTo;
    if (currentDateTime == null) return;

    final updated = DateTime(newDateTime.year, newDateTime.month, newDateTime.day, currentDateTime.hour, currentDateTime.minute);
    state = state.copyWith(appointment: state.appointment.whenData((v) => v.copyWith(appointmentDateTimeTo: updated)), isDirty: true);
  }

  void setAppointmentToTime(TimeOfDay time) {
    final currentDateTime = state.appointment.value?.appointmentDateTimeTo;
    if (currentDateTime == null) return;

    final updated = DateTime(currentDateTime.year, currentDateTime.month, currentDateTime.day, time.hour, time.minute);
    state = state.copyWith(appointment: state.appointment.whenData((v) => v.copyWith(appointmentDateTimeTo: updated)), isDirty: true);
  }

  void setMobile(String mobile) {
    state = state.copyWith(appointment: state.appointment.whenData((value) => value.copyWith(phone: mobile)), isDirty: true);
  }

  void setEmail(String email) {
    state = state.copyWith(appointment: state.appointment.whenData((value) => value.copyWith(email: email)), isDirty: true);
  }

  void setCompany(Company company) {
    state = state.copyWith(
      appointment: state.appointment.whenData((value) => value.copyWith(companyID: company.companyID, companyName: company.companyName)),
      isDirty: true,
    );

    final companyAddress = company.addresses.isNotEmpty ? company.addresses.first : null;
    if (companyAddress != null) {
      setAddress(
        address: Address(
          address: companyAddress.address,
          subDistrictID: companyAddress.subDistrictID,
          subDistrictName: companyAddress.subDistrictName,
          districtID: companyAddress.districtID,
          districtName: companyAddress.districtName,
          provinceID: companyAddress.provinceID,
          provinceName: companyAddress.provinceName,
          postCode: companyAddress.postCode,
          countryID: 1,
        ),
      );
    }
  }

  void removeCompany() {
    state = state.copyWith(appointment: state.appointment.whenData((value) => value.copyWith(isRemoveCompany: true, isRemoveAddress: true)), isDirty: true);
  }

  void setAddress({required Address address}) {
    state = state.copyWith(appointment: state.appointment.whenData((value) => value.copyWith(appointmentAddress: address)), isDirty: true);
  }

  void setNoted(String noted) {
    state = state.copyWith(appointment: state.appointment.whenData((value) => value.copyWith(noted: noted)), isDirty: true);
  }

  Future<bool> saveAppointment() async {
    final authState = ref.read(authProvider);

    final appointment = state.appointment.value?.copyWith(userID: authState.userID, createdBy: authState.userID, modifiedBy: authState.userID);
    if (!state.isDirty || appointment == null) return false;

    state = state.copyWith(isLoading: true);

    try {
      final result = await _appointmentService.createAppointment(appointment, ref);
      if (!result) return result;

      final tagNames = appointment.tags?.map((t) => t.tagName).toList() ?? [];
      if (tagNames.isNotEmpty) {
        await _clientService.updateTags(appointment.clientID ?? '', tagNames, ref);
      }

      final filter = state.appointment.value?.appointmentDateTimeFrom ?? DateTime.now();
      ref.read(selectedMonthProvider.notifier).setMonth(filter);
      ref.read(selectedDateProvider.notifier).setDate(filter);

      ref.read(appointmentMarkDateProvider(DateTime(filter.year, filter.month, 1)).notifier).refresh();
      ref.read(appointmentsByDateProvider(DateFormat("yyyy-MM-dd").format(filter)).notifier).refresh();

      final now = DateTime.now();
      final bool isSameDate = filter.year == now.year && filter.month == now.month && filter.day == now.day;

      if (isSameDate) {
        ref.invalidate(appointmentsProvider(DateTime(filter.year, filter.month, filter.day)));
        ref.invalidate(appointmentSummaryProvider(DateTime(filter.year, filter.month, filter.day)));
      }

      return result;
    } catch (e, st) {
      state = state.copyWith(appointment: AsyncError(e, st));
    } finally {
      state = state.copyWith(isLoading: false);
    }

    return true;
  }
}
