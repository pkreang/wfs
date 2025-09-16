import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/models/appointment_detail.dart';
import 'package:wfs/features/appointment/services/appointment_service.dart';

class AppointmentDetailViewModel extends StateNotifier<AsyncValue<AppointmentDetail>> {
  AppointmentDetailViewModel(this.ref, this.id) : super(const AsyncValue.loading()) {
    fetch();
  }

  final Ref ref;
  final String id;

  AppointmentService get _appointmentService => ref.read(appointmentServiceProvider);

  Future<void> fetch() async {
    state = const AsyncLoading();
    final res = await AsyncValue.guard(() => _appointmentService.fetchAppointmentById(ref, id));
    state = res;
  }

  Future<void> refresh() => fetch();

  Future<void> updateAppointmentStatus({required String appointmentID, required String appointmentStatusID}) async {
    state = const AsyncLoading();

    try {
      final result = await _appointmentService.updateAppointmentStatus(ref, appointmentID, appointmentStatusID, null);
      if (result) refresh();
    } catch (e) {
      print('updateAppointmentStatus catch: $e');
    } finally {}
  }
}
