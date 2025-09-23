import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wfs/features/appointment/models/address.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/models/appointment_detail.dart';
import 'package:wfs/features/appointment/models/appointment_status.dart';
import 'package:wfs/features/appointment/models/appointment_type.dart';
import 'package:wfs/features/appointment/models/product.dart';
import 'package:wfs/features/appointment/models/purpose.dart';
import 'package:wfs/features/appointment/models/sales_territory.dart';
import 'package:wfs/features/appointment/models/territory.dart';
import 'package:wfs/features/appointment/services/appointment_service.dart';
import 'package:wfs/features/company/models/company.dart';
import 'package:wfs/providers/appointment_provider.dart';

@immutable
class AppointmentEditState {
  final AsyncValue<AppointmentDetail> data;
  final List<Company> companies;
  final bool isDirty;
  final bool isLoading;

  const AppointmentEditState({required this.data, this.companies = const [], this.isDirty = false, this.isLoading = false});

  AppointmentEditState copyWith({AsyncValue<AppointmentDetail>? data, List<Company>? companies, bool? isDirty, bool? isLoading}) =>
      AppointmentEditState(data: data ?? this.data, companies: companies ?? this.companies, isDirty: isDirty ?? this.isDirty, isLoading: isLoading ?? this.isLoading);
}

class AppointmentEditViewModel extends StateNotifier<AppointmentEditState> {
  AppointmentEditViewModel(this.ref, this.id) : super(const AppointmentEditState(data: AsyncValue.loading())) {
    fetch();
  }

  final Ref ref;
  final String id;

  AppointmentService get _appointmentService => ref.read(appointmentServiceProvider);

  void setIsLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }

  Future<void> fetch() async {
    final res = await AsyncValue.guard(() => _appointmentService.fetchAppointmentById(ref, id));
    res.whenData((appointment) {
      List<Company> companies = (appointment.client.companies)
          .map((cc) => cc.company)
          .where((c) => (c?.companyID ?? '').isNotEmpty)
          .map((c) => Company(companyID: c!.companyID, companyName: c.companyName, addresses: c.addresses))
          .toList();
      state = state.copyWith(data: res, companies: companies, isDirty: false);
    });
  }

  void setAppointmentType(AppointmentType status) {
    state = state.copyWith(
      data: state.data.whenData((v) => v.copyWith(appointmentTypeID: status.appointmentTypeID, appointmentTypeName: status.appointmentTypeName)),
      isDirty: true,
    );
  }

  void setAppointmentStatus(AppointmentStatus status) {
    state = state.copyWith(
      data: state.data.whenData((v) => v.copyWith(appointmentStatusID: status.appointmentStatusID, appointmentStatusName: status.appointmentStatusName)),
      isDirty: true,
    );
  }

  void setPurpose(Purpose status) {
    state = state.copyWith(
      data: state.data.whenData((v) {
        return v.copyWith(purposeTypeID: status.purposeTypeID, purposeTypeName: status.purposeTypeName, isClearPurposeOther: status.purposeTypeName == 'Other');
      }),
      isDirty: true,
    );
  }

  void setTerritory(Territory status) {
    final newSalesTerritory = SalesTerritory(salesTerritoryID: status.salesTerritoryID, salesTerritoryName: status.salesTerritoryName);

    state = state.copyWith(
      data: state.data.whenData((v) => v.copyWith(client: v.client.copyWith(salesTerritory: newSalesTerritory))),
      isDirty: true,
    );
  }

  void setPurposeOther(String purposeOther) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(purposeOther: purposeOther)), isDirty: true);
  }

  void setAppointmentFromDate(DateTime newDateTime) {
    final currentDateTime = state.data.value?.appointmentDateTimeFrom;
    if (currentDateTime == null) return;

    final oldDateTime = DateTime.parse(currentDateTime);
    final updated = DateTime(newDateTime.year, newDateTime.month, newDateTime.day, oldDateTime.hour, oldDateTime.minute);

    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(appointmentDateTimeFrom: updated.toIso8601String())), isDirty: true);
  }

  void setAppointmentFromTime(TimeOfDay time) {
    final currentDateTime = state.data.value?.appointmentDateTimeFrom;
    if (currentDateTime == null) return;

    final dateTime = DateTime.parse(currentDateTime);
    final updated = DateTime(dateTime.year, dateTime.month, dateTime.day, time.hour, time.minute);

    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(appointmentDateTimeFrom: updated.toIso8601String())), isDirty: true);
  }

  void setAppointmentToDate(DateTime newDateTime) {
    final currentDateTime = state.data.value?.appointmentDateTimeTo;
    if (currentDateTime == null) return;

    final oldDateTime = DateTime.parse(currentDateTime);
    final updated = DateTime(newDateTime.year, newDateTime.month, newDateTime.day, oldDateTime.hour, oldDateTime.minute);

    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(appointmentDateTimeTo: updated.toIso8601String())), isDirty: true);
  }

  void setAppointmentToTime(TimeOfDay time) {
    final currentDateTime = state.data.value?.appointmentDateTimeTo;
    if (currentDateTime == null) return;

    final dateTime = DateTime.parse(currentDateTime);
    final updated = DateTime(dateTime.year, dateTime.month, dateTime.day, time.hour, time.minute);

    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(appointmentDateTimeTo: updated.toIso8601String())), isDirty: true);
  }

  void setMobile(String mobile) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(phone: mobile)), isDirty: true);
  }

  void setEmail(String email) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(email: email)), isDirty: true);
  }

  void setCompany(Company company) {
    state = state.copyWith(
      data: state.data.whenData((v) => v.copyWith(companyID: company.companyID, companyName: company.companyName)),
      isDirty: true,
    );

    print('company: ${jsonEncode(company.toJson())}');

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
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(isRemoveCompany: true, isRemoveAddress: true)), isDirty: true);
  }

  void setAddress({required Address address}) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(address: address)), isDirty: true);
  }

  void setNoted(String noted) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(noted: noted)), isDirty: true);
  }

  void addProduct(Product product) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(products: [...v.products, product])), isDirty: true);
  }

  void updateProduct(Product product) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(products: v.products.map((p) => p.productId == product.productId ? product : p).toList())), isDirty: true);
  }

  void removeProduct(String productId) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(products: v.products.where((p) => p.productId != productId).toList())), isDirty: true);
  }

  Future<bool> updateAppointment({String? noted}) async {
    final detail = state.data.value;
    if (!state.isDirty || detail == null) return false;

    state = state.copyWith(isLoading: true);

    try {
      final result = await _appointmentService.updateAppointment(detail, ref);
      if (!result) return result;

      final filter = DateTime.tryParse(detail.appointmentDateTimeFrom) ?? DateTime.now();

      final now = DateTime.now();
      final bool isSameDate = filter.year == now.year && filter.month == now.month && filter.day == now.day;

      if (isSameDate) {
        ref.invalidate(appointmentsProvider(DateTime(filter.year, filter.month, filter.day)));
        ref.invalidate(appointmentSummaryProvider(DateTime(filter.year, filter.month, filter.day)));
      }

      ref.read(appointmentsByDateProvider(DateFormat("yyyy-MM-dd").format(filter)).notifier).refresh();

      return result;
    } catch (e, st) {
      state = state.copyWith(data: AsyncError(e, st));
    } finally {
      state = state.copyWith(isLoading: false);
    }

    return false;
  }

  Future<bool> deleteAppointment() async {
    final detail = state.data.value;
    if (detail == null) return false;

    state = state.copyWith(isLoading: true);

    try {
      final result = await _appointmentService.deleteAppointment(id, ref);
      if (!result) return result;

      final filter = DateTime.tryParse(detail.appointmentDateTimeFrom) ?? DateTime.now();

      final now = DateTime.now();
      final bool isSameDate = filter.year == now.year && filter.month == now.month && filter.day == now.day;

      if (isSameDate) {
        ref.invalidate(appointmentsProvider(DateTime(filter.year, filter.month, filter.day)));
        ref.invalidate(appointmentSummaryProvider(DateTime(filter.year, filter.month, filter.day)));
      }

      ref.read(appointmentMarkDateProvider(DateTime(filter.year, filter.month, 1)).notifier).refresh();
      ref.read(appointmentsByDateProvider(DateFormat("yyyy-MM-dd").format(filter)).notifier).refresh();

      return result;
    } catch (e, st) {
      state = state.copyWith(data: AsyncError(e, st));
    } finally {
      state = state.copyWith(isLoading: false);
    }

    return false;
  }
}
