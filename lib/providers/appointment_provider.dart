import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/appointment_model.dart';
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

final appointmentGetByIdProvider = FutureProvider.family<Appointment, String>((
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
    FutureProvider.family<List<Appointment>, String>((ref, date) async {
      final authState = ref.watch(authProvider);
      final accessToken = authState.accessToken;

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('User is not authenticated.');
      }

      final appointmentService = ref.watch(appointmentServiceProvider);

      return appointmentService.GetByDate(accessToken, date);
    });
final appointmentGetSummaryProvider =
    FutureProvider.family<List<Appointment>, String>((ref, date) async {
      final authState = ref.watch(authProvider);
      final accessToken = authState.accessToken;

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('User is not authenticated.');
      }

      final appointmentService = ref.watch(appointmentServiceProvider);

      return appointmentService.GetSummary(accessToken, date);
    });
