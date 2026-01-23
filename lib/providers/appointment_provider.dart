import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';
import 'package:wfs/features/appointment/models/appointment.dart';
import 'package:wfs/providers/date_picker_provider.dart';
import '../services/appointment_service.dart';
import 'auth_provider.dart';
import '../models/appointment_summary_model.dart';

final appointmentServiceProvider2 = Provider<AppointmentService>((ref) {
  return AppointmentService();
});

final appointmentsProvider = FutureProvider.autoDispose.family<List<Appointment>, DateTime>((ref, date) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;

  // ใช้ watch แทน read เพื่อให้ฟังการเปลี่ยนแปลง
  final selectedRange = ref.watch(selectedDateRangeProvider);

  final formattedStartDate = DateFormat('yyyy-MM-dd').format(selectedRange.start);
  final formattedEndDate = selectedRange.end != null ? DateFormat('yyyy-MM-dd').format(selectedRange.end!) : formattedStartDate;

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('User is not authenticated.');
  }

  final appointmentService = ref.read(appointmentServiceProvider2);

  const statusOrder = <String, int>{'Scheduled': 0, 'Completed': 1, 'Canceled': 2};

  final appointments = await appointmentService.fetchAppointments(accessToken, authState.userID!, formattedStartDate, formattedEndDate);

  final sorted = [...appointments];
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

// final appointmentGetByIdProvider = FutureProvider.autoDispose.family<Appointment, String>((ref, guid) async {
//   final authState = ref.watch(authProvider);
//   final accessToken = authState.accessToken;

//   if (accessToken == null || accessToken.isEmpty) {
//     throw Exception('User is not authenticated.');
//   }

//   final appointmentService = ref.watch(appointmentServiceProvider);

//   return appointmentService.GetById(accessToken, guid);
// });

// final appointmentGetByDateProvider = FutureProvider.autoDispose.family<List<Appointment>, DateTime>((ref, date) async {
//   final authState = ref.watch(authProvider);
//   final accessToken = authState.accessToken;
//   final formattedDate = DateFormat('yyyy-MM-dd').format(date);

//   if (accessToken == null || accessToken.isEmpty) {
//     throw Exception('User is not authenticated.');
//   }

//   final appointmentService = ref.watch(appointmentServiceProvider);

//   return appointmentService.GetByDate(accessToken, formattedDate);
// });

final appointmentSummaryProvider = FutureProvider.autoDispose.family<AppointmentSummary, DateTime>((ref, date) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;

  final selectedRange = ref.watch(selectedDateRangeProvider);

  final formattedStartDate = DateFormat('yyyy-MM-dd').format(selectedRange.start);
  final formattedEndDate = selectedRange.end != null ? DateFormat('yyyy-MM-dd').format(selectedRange.end!) : formattedStartDate;

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('User is not authenticated.');
  }

  final summaryAppointmentService = ref.read(appointmentServiceProvider2); // เปลี่ยนเป็น read

  return summaryAppointmentService.fetchAppointmentSummary(accessToken, authState.userID!, formattedStartDate, formattedEndDate);
});

// // currentDateProvider ยังคงเหมือนเดิม
// final currentDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// final appointmentEditProvider = FutureProvider.autoDispose.family<Appointment, ({String guid, Appointment appointment})>((ref, params) async {
//   final authState = ref.watch(authProvider);
//   final accessToken = authState.accessToken;

//   if (accessToken == null || accessToken.isEmpty) {
//     throw Exception('User is not authenticated.');
//   }

//   final appointmentService = ref.watch(appointmentServiceProvider);

//   return appointmentService.Edit(accessToken, params.guid, params.appointment);
//   //final result = ref.watch(myProvider((guid: 5, appointment: 'active')));วิธีเรียกใช้ที่ ui
// });

// final appointmentDeleteProvider = FutureProvider.family<String, String>((ref, guid) async {
//   final authState = ref.watch(authProvider);
//   final accessToken = authState.accessToken;

//   if (accessToken == null || accessToken.isEmpty) {
//     throw Exception('User is not authenticated.');
//   }

//   final appointmentService = ref.watch(appointmentServiceProvider);

//   return appointmentService.Delete(accessToken, guid);
// });
