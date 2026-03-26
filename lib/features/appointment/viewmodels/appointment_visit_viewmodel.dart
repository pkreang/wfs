import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/models/appointment_detail.dart';
import 'package:wfs/features/appointment/models/outcome.dart';
import 'package:wfs/features/appointment/models/visit_activities.dart';
import 'package:wfs/features/appointment/services/appointment_service.dart';
import 'package:wfs/features/appointment/views/appointment_visit_page.dart';
import 'package:wfs/providers/appointment_provider.dart';
import 'package:wfs/services/location_service.dart';

@immutable
class AppointmentVisitState {
  final AsyncValue<AppointmentDetail> data;
  final AsyncValue<Location?> location;
  final VisitActivity? visitActivity;
  final bool isLoading;

  const AppointmentVisitState({required this.data, required this.location, this.visitActivity, this.isLoading = false});

  AppointmentVisitState copyWith({AsyncValue<AppointmentDetail>? data, AsyncValue<Location?>? location, VisitActivity? visitActivity, bool? isLoading}) {
    return AppointmentVisitState(data: data ?? this.data, location: location ?? this.location, visitActivity: visitActivity ?? this.visitActivity, isLoading: isLoading ?? this.isLoading);
  }
}

class AppointmentVisitViewModel extends StateNotifier<AppointmentVisitState> {
  AppointmentVisitViewModel(this.ref, this.id) : super(const AppointmentVisitState(data: AsyncValue.loading(), location: AsyncValue.loading())) {
    fetch();
  }

  final Ref ref;
  final String id;

  AppointmentService get _appointmentService => ref.read(appointmentServiceProvider);
  final _locationService = LocationService();

  Future<Location?> fetchLocation() async {
    final permission = await _locationService.requestPermission(requestIfDenied: false);
    if (permission != LocationPermissionStatus.granted) return null;

    final pos = await _locationService.getPosition();
    final address = await _locationService.reverseGeocodeGoogle(pos.latitude, pos.longitude);

    return Location(lat: pos.latitude, lng: pos.longitude, address: address);
  }

  Future<void> fetch() async {
    final resAppointment = await AsyncValue.guard(() => _appointmentService.fetchAppointmentById(ref, id));
    resAppointment.whenData((appointmentDetail) async {
      AsyncValue<Location?>? resLocation;

      final outcomID = appointmentDetail.visitActivities.isNotEmpty ? appointmentDetail.visitActivities.first.outcomeID : null;
      if ((outcomID ?? '').isEmpty) {
        resLocation = await AsyncValue.guard(fetchLocation);
      }

      state = state.copyWith(
        data: resAppointment,
        visitActivity: VisitActivity(
          activityID: appointmentDetail.visitActivities.isNotEmpty ? appointmentDetail.visitActivities.first.activityID : null,
          appointmentID: appointmentDetail.appointmentID,
          userID: appointmentDetail.userID,
          clientID: appointmentDetail.clientID,
          outcomeID: outcomID,
          createdBy: appointmentDetail.createdBy,
          modifiedBy: appointmentDetail.modifiedBy,
          isActive: appointmentDetail.isActive,
        ),
        location: resLocation,
      );
    });
  }

  void setNotes(String notes) {
    state = state.copyWith(visitActivity: state.visitActivity?.copyWith(notes: notes));
  }

  void setOutcome(Outcome outcome) {
    state = state.copyWith(
      visitActivity: state.visitActivity?.copyWith(outcomeID: outcome.outcomeID, outcomeName: outcome.outcomeName),
    );
  }

  bool validateOutcome() {
    return state.visitActivity?.outcomeID != null;
  }

  void loading(bool isLoading) => state = state.copyWith(isLoading: isLoading);

  Future<bool> checkIn({required double latitude, required double longitude, required String imgBase64}) async {
    if (state.visitActivity == null) return false;

    final now = DateTime.now();
    final checkInTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(now);

    state = state.copyWith(
      visitActivity: state.visitActivity!.copyWith(checkInTime: checkInTime, checkInLatitude: latitude, checkInLongitude: longitude),
    );

    try {
      final result = await _appointmentService.checkIn(state.visitActivity!, ref);
      if (result.ok) {
        return await _appointmentService.uploadImage(ref: ref, activityId: result.activityId, modifiedBy: result.modifiedBy, imgBase64: imgBase64);
      }
    } catch (e, st) {
      state = state.copyWith(data: AsyncError(e, st));
    } finally {
      loading(false);
    }

    return false;
  }

  Future<bool> checkOut({required double latitude, required double longitude}) async {
    final detail = state.data.value;
    if (detail == null) return false;

    if (state.visitActivity == null) return false;

    final now = DateTime.now();
    final checkOutTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(now);

    state = state.copyWith(
      visitActivity: state.visitActivity!.copyWith(checkOutTime: checkOutTime, checkOutLatitude: latitude, checkOutLongitude: longitude),
      isLoading: true,
    );

    try {
      final result = await _appointmentService.checkOut(state.visitActivity!, ref);
      if (result) {
        final filter = DateTime.tryParse(detail.appointmentDateTimeFrom) ?? DateTime.now();

        final now = DateTime.now();
        final bool isSameDate = filter.year == now.year && filter.month == now.month && filter.day == now.day;

        if (isSameDate) {
          ref.invalidate(appointmentsProvider(DateTime(filter.year, filter.month, filter.day)));
          ref.invalidate(appointmentSummaryProvider(DateTime(filter.year, filter.month, filter.day)));
        }

        ref.read(appointmentMarkDateProvider(DateTime(filter.year, filter.month, 1)).notifier).refresh();
        ref.read(appointmentsByDateProvider(DateFormat("yyyy-MM-dd").format(filter)).notifier).refresh();

        return true;
      }
    } catch (e, st) {
      state = state.copyWith(data: AsyncError(e, st));
    } finally {
      state = state.copyWith(isLoading: false);
    }

    return false;
  }
}
