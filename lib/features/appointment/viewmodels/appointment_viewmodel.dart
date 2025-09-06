import 'package:wfs/features/appointment/models/appointment.dart';
import 'package:wfs/features/appointment/services/appointment_service.dart';

class AppointmentViewModel {
  final AppointmentService _appointmentService = AppointmentService();

  Future<List<Appointment>> fetchAppointments() async => await _appointmentService.fetchAppointments();
}
