import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/features/appointment/models/appointment.dart';
import 'package:wfs/features/appointment/models/appointment_detail.dart';
import 'package:wfs/features/appointment/models/appointment_status.dart';
import 'package:wfs/features/appointment/models/appointment_type.dart';
import 'package:wfs/features/appointment/models/outcome.dart';
import 'package:wfs/features/appointment/models/product.dart';
import 'package:wfs/features/appointment/models/purpose.dart';
import 'package:wfs/features/appointment/models/territory.dart';
import 'package:wfs/features/appointment/services/appointment_service.dart';
import 'package:wfs/features/appointment/viewmodels/appointment_create_viewmodel.dart';
import 'package:wfs/features/appointment/viewmodels/appointment_detail_viewmodel.dart';
import 'package:wfs/features/appointment/viewmodels/appointment_edit_viewmodel.dart';
import 'package:wfs/features/appointment/viewmodels/appointment_viewmodel.dart';
import 'package:wfs/features/appointment/viewmodels/appointment_visit_viewmodel.dart';
import 'package:wfs/features/client/models/client.dart';
import 'package:wfs/features/client/models/client_level.dart';
import 'package:wfs/features/client/models/client_status.dart';
import 'package:wfs/features/client/services/client_service.dart';
import 'package:wfs/features/client/viewmodels/client_create_viewmodel.dart';
import 'package:wfs/features/client/viewmodels/client_detail_viewmodel.dart';
import 'package:wfs/features/client/viewmodels/client_edit_viewmodel.dart';
import 'package:wfs/features/client/viewmodels/client_list_viewmodel.dart';
import 'package:wfs/features/company/models/company.dart';
import 'package:wfs/features/company/services/company_service.dart';
import 'package:wfs/features/company/viewmodels/company_create_viewmodel.dart';
import 'package:wfs/features/company/viewmodels/company_edit_viewmodel.dart';
import 'package:wfs/features/company/viewmodels/company_detail_viewmodel.dart';
import 'package:wfs/features/company/viewmodels/company_list_viewmodel.dart';

final appointmentServiceProvider = Provider<AppointmentService>((ref) => AppointmentService());
final appointmentProvider = StateNotifierProvider.autoDispose<AppointmentViewModel, AppointmentState>((ref) => AppointmentViewModel(ref));

final selectedMonthProvider = NotifierProvider<SelectedMonthViewModel, DateTime>(SelectedMonthViewModel.new);
final selectedDateProvider = NotifierProvider<SelectedDateViewModel, DateTime>(SelectedDateViewModel.new);

final appointmentMarkDateProvider = StateNotifierProvider.autoDispose.family<AppointmentMarkDateViewModel, AsyncValue<Map<String, bool>>, DateTime>(
  (ref, date) => AppointmentMarkDateViewModel(ref, date),
);
final appointmentsByDateProvider = StateNotifierProvider.autoDispose.family<AppointmentsByDateViewModel, AsyncValue<List<Appointment>>, String>((ref, date) => AppointmentsByDateViewModel(ref, date));

final companiesOfClentProvider = StateProvider<List<Company>>((ref) => []);

final appointmentCreateProvider = StateNotifierProvider.autoDispose.family<AppointmentCreateViewModel, AppointmentCreateState, String>((ref, id) {
  return AppointmentCreateViewModel(ref, id);
});
final appointmentDetailProvider = StateNotifierProvider.autoDispose.family<AppointmentDetailViewModel, AsyncValue<AppointmentDetail>, String>((ref, id) {
  return AppointmentDetailViewModel(ref, id);
});

final appointmentEditProvider = StateNotifierProvider.autoDispose.family<AppointmentEditViewModel, AppointmentEditState, String>((ref, id) {
  return AppointmentEditViewModel(ref, id);
});

final appointmentVisitProvider = StateNotifierProvider.autoDispose.family<AppointmentVisitViewModel, AppointmentVisitState, String>((ref, id) {
  return AppointmentVisitViewModel(ref, id);
});

// final appointmentMarkDateProvider = FutureProvider.autoDispose.family<Map<String, bool>, DateTime>((ref, date) async {
//   final year = date.year.toString();
//   final month = date.month.toString();

//   final dates = await ref.read(appointmentServiceProvider).fetchAppointmentByMonthYear(ref, month, year);

//   Map<String, bool> map = {};

//   for (var appointmentDate in dates) {
//     map[appointmentDate] = true;
//   }

//   return map;
// });

// final appointmentsByDateProvider = FutureProvider.autoDispose.family<List<Appointment>, DateTime>((ref, date) async {
//   return ref.read(appointmentServiceProvider).fetchAppointmentsByDate(ref, date.toIso8601String());
// });

final productsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  return await ref.read(appointmentServiceProvider).fetchProducts(ref);
});

final appointmentTypeProvider = FutureProvider.autoDispose<List<AppointmentType>>((ref) async {
  return await ref.read(appointmentServiceProvider).fetchAppointmentTypd(ref);
});

final appointmentStatusProvider = FutureProvider.autoDispose<List<AppointmentStatus>>((ref) async {
  return await ref.read(appointmentServiceProvider).fetchAppointmentStatus(ref);
});

final purposesProvider = FutureProvider.autoDispose<List<Purpose>>((ref) async {
  return await ref.read(appointmentServiceProvider).fetchPurposes(ref);
});

final territoryProvider = FutureProvider.autoDispose<List<Territory>>((ref) async {
  return await ref.read(appointmentServiceProvider).fetchTerritories(ref);
});

final outcomeProvider = FutureProvider.autoDispose<List<Outcome>>((ref) async {
  return await ref.read(appointmentServiceProvider).fetchOutcomes();
});

final companyProvider = FutureProvider.autoDispose<List<Company>>((ref) async {
  return await ref.read(companyServiceProvider).fetchCompanies(ref);
});

//* Client
final clientServiceProvider = Provider<ClientService>((ref) => ClientService());

final clientListProvider = StateNotifierProvider.autoDispose<ClientListViewModel, ClientListState>((ref) {
  return ClientListViewModel(ref);
});

final clientCreateProvider = StateNotifierProvider.autoDispose<ClientCreateViewModel, ClientCreateState>((ref) {
  return ClientCreateViewModel(ref);
});

final clientDetailProvider = StateNotifierProvider.autoDispose.family<ClientDetailViewModel, AsyncValue<Client>, String>((ref, id) {
  return ClientDetailViewModel(ref, id);
});

final clientEditProvider = StateNotifierProvider.autoDispose.family<ClientEditViewModel, ClientEditState, String>((ref, id) {
  return ClientEditViewModel(ref, id);
});

final clientStatusProvider = FutureProvider.autoDispose<List<ClientStatus>>((ref) async {
  return await ref.read(clientServiceProvider).fetchClientStatus(ref);
});

final clientLevelProvider = FutureProvider.autoDispose<List<ClientLevel>>((ref) async {
  return await ref.read(clientServiceProvider).fetchClientLevel(ref);
});

//* Company
final companyServiceProvider = Provider<CompanyService>((ref) => CompanyService());

final companyListProvider = StateNotifierProvider.autoDispose<CompanyListViewModel, CompanyListState>((ref) {
  return CompanyListViewModel(ref);
});

final companyCreateProvider = StateNotifierProvider.autoDispose<CompanyCreateViewModel, CompanyCreateState>((ref) {
  return CompanyCreateViewModel(ref);
});

final companyDetailProvider = StateNotifierProvider.autoDispose.family<CompanyDetailViewModel, AsyncValue<Company>, String>((ref, id) {
  return CompanyDetailViewModel(ref, id);
});

final companyEditProvider = StateNotifierProvider.autoDispose.family<CompanyEditViewModel, CompanyEditState, String>((ref, id) {
  return CompanyEditViewModel(ref, id);
});

// final clientGetByIdProvider = FutureProvider.autoDispose.family<Client, String>((ref, clientId) async {
//   return await ref.read(clientServiceProvider).getById(ref, clientId);
// });

// final clientGetByIdProvider = FutureProvider.autoDispose.family<Client, String>((ref, clientId) async {
//   // Fetches client by id using the service, leveraging Ref for auth headers
//   return await ref.read(clientServiceProvider).getById(ref, clientId);
// });

// final clientGetByIdProvider = FutureProvider.family<Client, String>((ref, guid) async {
//   final authState = ref.watch(authProvider);
//   final accessToken = authState.accessToken;

//   if (accessToken == null || accessToken.isEmpty) {
//     throw Exception('User is not authenticated.');
//   }

//   final clientService = ref.watch(clientServiceProvider);

//   return clientService.GetById(accessToken, guid);
// });
