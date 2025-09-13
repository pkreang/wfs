import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';
import '../models/appointment_model.dart';
import '../services/appointment_service.dart';
import 'auth_provider.dart'; 
import '../models/appointment_summary_model.dart';

final appointmentServiceProvider = Provider<AppointmentService>((ref) {
  return AppointmentService();
});

final appointmentsProvider = FutureProvider.autoDispose.family<List<Appointment>, DateTime>((ref, date) async {
 
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;
  final formattedDate = DateFormat('yyyy-MM-dd').format(date);

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('User is not authenticated.');
  }

  final appointmentService = ref.read(appointmentServiceProvider); 


  return appointmentService.fetchAppointments(accessToken, authState.userID!, formattedDate);
});



final appointmentGetByIdProvider = FutureProvider.autoDispose.family<Appointment, String>((ref,guid,) async {

  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('User is not authenticated.');
  }

  final appointmentService = ref.watch(appointmentServiceProvider);

  return appointmentService.GetById(accessToken, guid);
});

final appointmentGetByDateProvider = FutureProvider.autoDispose.family<List<Appointment>, DateTime>((ref, date) async {
      final authState = ref.watch(authProvider);
      final accessToken = authState.accessToken;
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('User is not authenticated.');
      }

      final appointmentService = ref.watch(appointmentServiceProvider);

      return appointmentService.GetByDate(accessToken, formattedDate);
    });

  final appointmentSummaryProvider = FutureProvider.autoDispose.family<AppointmentSummary, DateTime>((ref, date) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;

  // ไม่ต้อง watch currentDateProvider ข้างในนี้อีกแล้ว
  // final date = ref.watch(currentDateProvider); // <--- ลบบรรทัดนี้

  final formattedDate = DateFormat('yyyy-MM-dd').format(date);

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('User is not authenticated.');
  }
  
  final summaryAppointmentService = ref.read(appointmentServiceProvider); // เปลี่ยนเป็น read
  

  return summaryAppointmentService.fetchAppointmentSummary(accessToken, authState.userID!,formattedDate);
});


// currentDateProvider ยังคงเหมือนเดิม
final currentDateProvider = StateProvider <DateTime>((ref) => DateTime.now()); 


final appointmentEditProvider =
    FutureProvider.autoDispose.family<Appointment,({String guid, Appointment appointment})>((ref, params) async {
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

final appointmentDeleteProvider = FutureProvider.family<String, String>((ref,guid,
) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('User is not authenticated.');
  }

  final appointmentService = ref.watch(appointmentServiceProvider);

  return appointmentService.Delete(accessToken, guid);
});