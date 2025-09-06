import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/models/appointmentstatus_model.dart';
import 'package:wfs/services/AppointmentStatus_service.dart';
import 'auth_provider.dart';

final appointmentStatusProvider = Provider<AppointmentStatusService>((ref) {
  return AppointmentStatusService();
});

final appointmentStatusGetList = FutureProvider<List<AppointmentStatus>>((
  ref,
) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('User is not authenticated.');
  }

  final appointmentStatusService = ref.watch(appointmentStatusProvider);

  return appointmentStatusService.getList(accessToken);
});
