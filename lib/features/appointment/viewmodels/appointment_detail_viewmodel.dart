import 'package:flutter/widgets.dart';
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
  final Ref ref;
    final res = await AsyncValue.guard(() => _appointmentService.fetchAppointmentById(this.ref,id));
    state = res;
  }

  Future<void> refresh() => fetch();
}
