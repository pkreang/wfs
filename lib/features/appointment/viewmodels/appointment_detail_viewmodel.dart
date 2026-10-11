import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/models/appointment_detail.dart';
import 'package:wfs/features/appointment/services/appointment_service.dart';
import 'package:wfs/features/client/services/client_service.dart';

class AppointmentDetailViewModel
    extends StateNotifier<AsyncValue<AppointmentDetail>> {
  AppointmentDetailViewModel(this.ref, this.id)
    : super(const AsyncValue.loading()) {
    fetch();
  }

  final Ref ref;
  final String id;

  AppointmentService get _appointmentService =>
      ref.read(appointmentServiceProvider);
  ClientService get _clientService => ref.read(clientServiceProvider);

  Future<void> fetch() async {
    print('appointmentID: $id');
    state = const AsyncLoading();
    final res = await AsyncValue.guard(
      () => _appointmentService.fetchAppointmentById(ref, id),
    );
    state = res;

    if (res.hasError) {
      print('appointmentDetail fetch error: ${res.error}');
    }

    final appointment = res.asData?.value;
    if (appointment == null) return;

    final clientAsync = await AsyncValue.guard(
      () => _clientService.getById(ref, appointment.clientID),
    );
    final client = clientAsync.asData?.value;
    if (client != null) {
      state = AsyncValue.data(appointment.copyWith(tags: client.tags ?? []));
    }
  }

  Future<void> refresh() => fetch();

  Future<void> updateAppointmentStatus({
    required String appointmentID,
    required String appointmentStatusID,
  }) async {
    state = const AsyncLoading();

    try {
      final result = await _appointmentService.updateAppointmentStatus(
        ref,
        appointmentID,
        appointmentStatusID,
        null,
      );
      if (result) refresh();
    } catch (e) {
      print('updateAppointmentStatus catch: $e');
    } finally {}
  }
}
