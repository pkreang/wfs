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
    if (!mounted) return;

    if (res.hasError) {
      print('appointmentDetail fetch error: ${res.error}');
    }

    final appointment = res.asData?.value;
    if (appointment == null) {
      state = res;
      return;
    }

    final clientAsync = await AsyncValue.guard(
      () => _clientService.findById(ref, appointment.clientID),
    );
    if (!mounted) return;
    final client = clientAsync.asData?.value;
    state = AsyncValue.data(
      appointment.copyWith(
        tags: client != null ? client.tags ?? [] : appointment.tags,
        isLeadClient: !clientAsync.hasError && client == null,
      ),
    );
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
