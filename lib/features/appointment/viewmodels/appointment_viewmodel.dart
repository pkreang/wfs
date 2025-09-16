import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/models/appointment.dart';
import 'package:wfs/features/appointment/services/appointment_service.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class AppointmentState {
  final bool isLoading;

  const AppointmentState({this.isLoading = false});

  AppointmentState copyWith({bool? isLoading}) {
    return AppointmentState(isLoading: isLoading ?? this.isLoading);
  }
}

class AppointmentViewModel extends StateNotifier<AppointmentState> {
  AppointmentViewModel(this.ref) : super(const AppointmentState());

  final Ref ref;

  AppointmentService get _appointmentService => ref.read(appointmentServiceProvider);

  Future<void> updateAppointmentStatus({required String appointmentID, required String appointmentStatusID, String? cancelNoted, required DateTime currentDate, VoidCallback? onSuccess}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      final result = await _appointmentService.updateAppointmentStatus(ref, appointmentID, appointmentStatusID, cancelNoted);
      if (result) {
        ref.read(appointmentsByDateProvider(DateFormat("yyyy-MM-dd").format(currentDate)).notifier).refresh();
        onSuccess?.call();
      }
    } catch (e) {
      print('updateAppointmentStatus catch: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

class AppointmentsByDateViewModel extends StateNotifier<AsyncValue<List<Appointment>>> {
  AppointmentsByDateViewModel(this.ref, this.date) : super(const AsyncValue.loading()) {
    fetch();
  }

  final Ref ref;
  final String date;

  AppointmentService get _appointmentService => ref.read(appointmentServiceProvider);

  Future<void> fetch() async {
    print('AppointmentsByDateViewModel feych');
    state = const AsyncValue.loading();
    final res = await AsyncValue.guard(() => _appointmentService.fetchAppointmentsByDate(ref, date));
    state = res;
  }

  Future<void> refresh() => fetch();
}
