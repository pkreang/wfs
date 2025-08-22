import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/models/appointment_model.dart';
import 'package:wfs/models/appointments_model.dart';
import '../services/appointment_service.dart';
import 'auth_provider.dart';

final appointmentServiceProvider = Provider<AppointmentService>((ref) {
  return AppointmentService();
});

final appointmentsProvider = FutureProvider<List<Appointment>>((ref) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('User is not authenticated.');
  }

  final appointmentService = ref.watch(appointmentServiceProvider);

  return appointmentService.fetchAppointments(accessToken, authState.userID!);
});

final appointmentGetByIdProvider = FutureProvider.family<Appointments, String>((
  ref,
  guid,
) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('User is not authenticated.');
  }

  final appointmentService = ref.watch(appointmentServiceProvider);

  return appointmentService.GetById(accessToken, guid);
});
final appointmentGetByDateProvider =
    FutureProvider.family<List<Appointments>, String>((ref, date) async {
      final authState = ref.watch(authProvider);
      final accessToken = authState.accessToken;

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('User is not authenticated.');
      }

      final appointmentService = ref.watch(appointmentServiceProvider);

      return appointmentService.GetByDate(accessToken, date);
    });
final appointmentGetSummaryProvider =
    FutureProvider.family<List<Appointments>, String>((ref, date) async {
      final authState = ref.watch(authProvider);
      final accessToken = authState.accessToken;

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('User is not authenticated.');
      }

      final appointmentService = ref.watch(appointmentServiceProvider);

      return appointmentService.GetSummary(accessToken, date);
    });
final appointmentEditProvider =
    FutureProvider.family<
      Appointments,
      ({String guid, Appointments appointment})
    >((ref, params) async {
      final authState = ref.watch(authProvider);
      final accessToken = authState.accessToken;

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('User is not authenticated.');
      }

      final appointmentService = ref.watch(appointmentServiceProvider);

      return appointmentService.Edit(
        accessToken,
        params.guid,
        params.appointment,
      );
      //final result = ref.watch(myProvider((guid: 5, appointment: 'active')));วิธีเรียกใช้ที่ ui
    });

final appointmentDeleteProvider = FutureProvider.family<String, String>((
  ref,
  guid,
) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('User is not authenticated.');
  }

  final appointmentService = ref.watch(appointmentServiceProvider);

  return appointmentService.Delete(accessToken, guid);
});
