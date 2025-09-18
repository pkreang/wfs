import 'package:flutter/material.dart';
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

  Future<bool> updateAppointmentStatus({required String appointmentID, required String appointmentStatusID, required VoidCallback onSuccess, String? cancelNoted}) async {
    if (state.isLoading) return false;

    state = state.copyWith(isLoading: true);

    try {
      final result = await _appointmentService.updateAppointmentStatus(ref, appointmentID, appointmentStatusID, cancelNoted);
      if (result) {
        onSuccess.call();
      }

      return result;
    } catch (e) {
      print('updateAppointmentStatus catch: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }

    return false;
  }
}

DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

class SelectedMonthViewModel extends Notifier<DateTime> {
  @override
  DateTime build() {
    return _startOfDay(DateTime.now());
  }

  void setMonth(DateTime d) => state = _startOfDay(d);
  void nextMonth() => state = _startOfDay(DateTime(state.year, state.month + 1, 1));
  void prevMonth() => state = _startOfDay(DateTime(state.year, state.month - 1, 1));
}

class SelectedDateViewModel extends Notifier<DateTime> {
  @override
  DateTime build() {
    return _startOfDay(DateTime.now());
  }

  void setDate(DateTime d) => state = _startOfDay(d);
}

class AppointmentMarkDateViewModel extends StateNotifier<AsyncValue<Map<String, bool>>> {
  AppointmentMarkDateViewModel(this.ref, this.date) : super(const AsyncValue.loading()) {
    fetch();
  }

  final Ref ref;
  final DateTime date;

  AppointmentService get _appointmentService => ref.read(appointmentServiceProvider);

  Future<void> fetch() async {
    state = const AsyncValue.loading();

    try {
      final datasAsync = await _appointmentService.fetchAppointmentByMonthYear(ref, date.month.toString(), date.year.toString());
      Map<String, bool> map = {};
      for (var appointmentDate in datasAsync) {
        map[appointmentDate] = true;
      }

      state = AsyncData(map);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() => fetch();
}

class AppointmentsByDateViewModel extends StateNotifier<AsyncValue<List<Appointment>>> {
  AppointmentsByDateViewModel(this.ref, this.date) : super(const AsyncValue.loading()) {
    fetch();
  }

  final Ref ref;
  final String date;

  AppointmentService get _appointmentService => ref.read(appointmentServiceProvider);

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    final res = await AsyncValue.guard(() => _appointmentService.fetchAppointmentsByDate(ref, date));

    const statusOrder = <String, int>{'Scheduled': 0, 'Completed': 1, 'Canceled': 2};

    state = res.whenData((list) {
      final sorted = [...list];
      sorted.sort((a, b) {
        final ra = statusOrder[(a.appointmentStatusName ?? '').trim()] ?? 999;
        final rb = statusOrder[(b.appointmentStatusName ?? '').trim()] ?? 999;
        if (ra != rb) return ra - rb;

        final sa = (a.appointmentTimeFrom ?? a.appointmentDateTimeFrom.toIso8601String()).trim();
        final sb = (b.appointmentTimeFrom ?? b.appointmentDateTimeFrom.toIso8601String()).trim();

        return sa.compareTo(sb);
      });

      return sorted;
    });
  }

  Future<void> refresh() => fetch();
}
