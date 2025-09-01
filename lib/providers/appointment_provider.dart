import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/models/appointment_model.dart';
import 'package:wfs/models/appointments_model.dart';
import 'package:wfs/providers/auth_provider.dart';
import '../services/appointment_service.dart';

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

// final appointmentGetByIdProvider = FutureProvider.family<Appointments, String>((
//   ref,
//   guid,
// ) async {
//   final authState = ref.watch(authProvider);
//   final accessToken = authState.accessToken;

//   if (accessToken == null || accessToken.isEmpty) {
//     throw Exception('User is not authenticated.');
//   }

//   final appointmentService = ref.watch(appointmentServiceProvider);

//   return appointmentService.GetById(accessToken, guid);
// });
// final appointmentGetByDateProvider =
//     FutureProvider.family<List<Appointments>, String>((ref, date) async {
//       final authState = ref.watch(authProvider);
//       final accessToken = authState.accessToken;

//       if (accessToken == null || accessToken.isEmpty) {
//         throw Exception('User is not authenticated.');
//       }

//       final appointmentService = ref.watch(appointmentServiceProvider);

//       return appointmentService.GetByDate(accessToken, date);
//     });
// final appointmentGetSummaryProvider =
//     FutureProvider.family<List<Appointments>, String>((ref, date) async {
//       final authState = ref.watch(authProvider);
//       final accessToken = authState.accessToken;

//       if (accessToken == null || accessToken.isEmpty) {
//         throw Exception('User is not authenticated.');
//       }

//       final appointmentService = ref.watch(appointmentServiceProvider);

//       return appointmentService.GetSummary(accessToken, date);
//     });
// final appointmentEditProvider =
//     FutureProvider.family<
//       Appointments,
//       ({String guid, Appointments appointment})
//     >((ref, params) async {
//       final authState = ref.watch(authProvider);
//       final accessToken = authState.accessToken;

//       if (accessToken == null || accessToken.isEmpty) {
//         throw Exception('User is not authenticated.');
//       }

//       final appointmentService = ref.watch(appointmentServiceProvider);

//       return appointmentService.Edit(
//         accessToken,
//         params.guid,
//         params.appointment,
//       );
//       //final result = ref.watch(myProvider((guid: 5, appointment: 'active')));วิธีเรียกใช้ที่ ui
//     });

// final appointmentDeleteProvider = FutureProvider.family<String, String>((
//   ref,
//   guid,
// ) async {
//   final authState = ref.watch(authProvider);
//   final accessToken = authState.accessToken;

//   if (accessToken == null || accessToken.isEmpty) {
//     throw Exception('User is not authenticated.');
//   }

//   final appointmentService = ref.watch(appointmentServiceProvider);

//   return appointmentService.Delete(accessToken, guid);
// });

final appointmentEditProvider = StateNotifierProvider.autoDispose
    .family<AppointmentEditViewModel, AppointmentEditState, String>((ref, id) {
      return AppointmentEditViewModel(ref, id);
    });

@immutable
class AppointmentEditState {
  final AsyncValue<Appointments> data;
  final bool isDirty;
  final bool isLoading;

  const AppointmentEditState({
    required this.data,
    this.isDirty = false,
    this.isLoading = false,
  });

  AppointmentEditState copyWith({
    AsyncValue<Appointments>? data,
    bool? isDirty,
    bool? isLoading,
  }) => AppointmentEditState(
    data: data ?? this.data,
    isDirty: isDirty ?? this.isDirty,
    isLoading: isLoading ?? this.isLoading,
  );
}

class AppointmentEditViewModel extends StateNotifier<AppointmentEditState> {
  AppointmentEditViewModel(this.ref, this.id)
    : super(const AppointmentEditState(data: AsyncValue.loading())) {
    fetch();
  }

  final Ref ref;
  final String id;

  AppointmentService get _AppointmentService =>
      ref.read(appointmentServiceProvider);

  Future<void> fetch() async {
    final authState = ref.watch(authProvider);
    final res = await AsyncValue.guard(
      () => _AppointmentService.GetById(authState.accessToken.toString(), id),
    );
    state = state.copyWith(data: res, isDirty: false);
  }

  // void setAppointmentType(AppointmentType status) {
  //   state = state.copyWith(
  //     data: state.data.whenData(
  //       (v) => v.copyWith(
  //         AppointmentTypeId: status.AppointmentTypeID,
  //         AppointmentTypeName: status.AppointmentTypeName,
  //       ),
  //     ),
  //     isDirty: true,
  //   );
  // }

  // void setAppointmentStatus(AppointmentStatus status) {
  //   state = state.copyWith(
  //     data: state.data.whenData(
  //       (v) => v.copyWith(
  //         AppointmentStatusId: status.AppointmentStatusID,
  //         AppointmentStatusName: status.AppointmentStatusName,
  //       ),
  //     ),
  //     isDirty: true,
  //   );
  // }

  // void setPurpose(Purpose status) {
  //   state = state.copyWith(
  //     data: state.data.whenData(
  //       (v) => v.copyWith(
  //         purposeTypeId: status.purposeTypeID,
  //         purposeTypeName: status.purposeTypeName,
  //       ),
  //     ),
  //     isDirty: true,
  //   );
  // }

  // void setAppointment(Appointment status) {
  //   final newSalesAppointment = SalesAppointment(
  //     salesAppointmentID: status.salesAppointmentID,
  //     salesAppointmentName: status.salesAppointmentName,
  //   );

  //   state = state.copyWith(
  //     data: state.data.whenData(
  //       (v) => v.copyWith(
  //         client: v.client.copyWith(
  //           salesAppointment: newSalesAppointment,
  //         ),
  //       ),
  //     ),
  //     isDirty: true,
  //   );
  // }

  // void addAppointment(Appointment Appointment) {
  //   state = state.copyWith(
  //     data: state.data.whenData(
  //       (v) =>
  //           v.copyWith(Appointments: [...v.Appointments, Appointment]),
  //     ),
  //     isDirty: true,
  //   );
  // }

  // void updateAppointment(Appointment Appointment) {
  //   state = state.copyWith(
  //     data: state.data.whenData(
  //       (v) => v.copyWith(
  //         Appointments: v.Appointments.map(
  //           (p) => p.AppointmentId == Appointment.AppointmentId
  //               ? Appointment
  //               : p,
  //         ).toList(),
  //       ),
  //     ),
  //     isDirty: true,
  //   );
  // }

  // void removeAppointment(String AppointmentId) {
  //   state = state.copyWith(
  //     data: state.data.whenData(
  //       (v) => v.copyWith(
  //         Appointments: v.Appointments.where(
  //           (p) => p.AppointmentId != AppointmentId,
  //         ).toList(),
  //       ),
  //     ),
  //     isDirty: true,
  //   );
  // }

  // Future<bool> updateAppointment({String? noted}) async {
  //   final detail = state.data.valueOrNull;
  //   if (!state.isDirty || detail == null) return false;

  //   state = state.copyWith(isLoading: true);

  //   try {
  //     return await _AppointmentService.updateAppointment(detail);
  //   } catch (e, st) {
  //     state = state.copyWith(data: AsyncError(e, st));
  //   } finally {
  //     state = state.copyWith(isLoading: false);
  //   }

  //   return false;
  // }

  // Future<bool> deleteAppointment() async {
  //   state = state.copyWith(isLoading: true);

  //   try {
  //     return await _AppointmentService.deleteAppointment(id);
  //   } catch (e, st) {
  //     state = state.copyWith(data: AsyncError(e, st));
  //   } finally {
  //     state = state.copyWith(isLoading: false);
  //   }

  //   return false;
  // }
}
