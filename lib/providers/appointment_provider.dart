import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';
import 'package:wfs/features/appointment/models/appointment.dart';
import 'package:wfs/features/task/models/task.dart';
import 'package:wfs/providers/dashboard_filter_provider.dart';
import '../services/appointment_service.dart';
import 'auth_provider.dart';
import '../models/appointment_summary_model.dart';

final appointmentServiceProvider2 = Provider<AppointmentService>((ref) {
  return AppointmentService();
});

final appointmentsProvider = FutureProvider.autoDispose.family<List<dynamic>, DateTime>((ref, date) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;

  final filter = ref.watch(dashboardAppliedFilterProvider);

  final formattedStartDate = DateFormat('yyyy-MM-dd').format(filter.startDate);
  final formattedEndDate = filter.endDate != null ? DateFormat('yyyy-MM-dd').format(filter.endDate!) : formattedStartDate;

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('User is not authenticated.');
  }

  final appointmentService = ref.read(appointmentServiceProvider2);

  final appointments = await appointmentService.fetchAppointments(
    accessToken,
    formattedStartDate,
    appointmentDateTo: formattedEndDate,
    appointmentStatusName: filter.status == 'all' ? null : filter.status,
  );

  const statusOrder = <String, int>{'Scheduled': 0, 'Completed': 1, 'Canceled': 2};
  final rows = [...appointments];
  rows.sort((a, b) {
    final ra = statusOrder[_statusNameOf(a).trim()] ?? 999;
    final rb = statusOrder[_statusNameOf(b).trim()] ?? 999;
    if (ra != rb) return ra - rb;

    return _startDateOf(a).compareTo(_startDateOf(b));
  });

  return rows;
});

String _statusNameOf(Object row) {
  if (row is Appointment) return row.appointmentStatusName ?? '';
  if (row is Task) return row.appointmentStatusName ?? '';
  return '';
}

DateTime _startDateOf(Object row) {
  if (row is Appointment) return row.appointmentDateTimeFrom;
  if (row is Task) return row.appointmentDateTimeFrom ?? row.scheduledStartDate;
  return DateTime.fromMillisecondsSinceEpoch(0);
}

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

  final selectedRange = ref.watch(dashboardAppliedFilterProvider);

  final formattedStartDate = DateFormat('yyyy-MM-dd').format(selectedRange.startDate);
  final formattedEndDate = selectedRange.endDate != null ? DateFormat('yyyy-MM-dd').format(selectedRange.endDate!) : formattedStartDate;

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
