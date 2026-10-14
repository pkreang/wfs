import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:wfs/features/lead/models/lead_status.dart';
import 'package:wfs/features/lead/services/lead_service.dart';
import 'package:wfs/features/lead/viewmodels/lead_create_viewmodel.dart';
import 'package:wfs/features/lead/viewmodels/lead_detail_viewmodel.dart';
import 'package:wfs/features/lead/viewmodels/lead_edit_viewmodel.dart';
import 'package:wfs/features/lead/viewmodels/lead_list_viewmodel.dart';
import 'package:wfs/features/leaddashboard2/services/lead_dashboard2_service.dart';
import 'package:wfs/features/leaddashboard2/providers/lead_dashboard2_date_range_provider.dart';
import 'package:wfs/features/leaddashboard2/viewmodels/lead_dashboard2_viewmodel.dart';
import 'package:wfs/features/phase3/lead_workflow/models/lead_workflow_model.dart';
import 'package:wfs/features/phase3/lead_workflow/repositories/lead_workflow_repository.dart';
import 'package:wfs/features/phase3/lead_workflow/services/lead_workflow_service.dart';
import 'package:wfs/features/salepepeline/viewmodels/sales_pipeline_viewmodel.dart';
import 'package:wfs/features/salesconversionfunnel/services/sales_conversion_funnel_service.dart';
import 'package:wfs/features/salesconversionfunnel/viewmodels/sales_conversion_funnel_viewmodel.dart';
import 'package:wfs/features/tag/services/tag_service.dart';
import 'package:wfs/features/sales/services/sales_service.dart';
import 'package:wfs/features/sales/viewmodels/sales_list_viewmodel.dart';
import 'package:wfs/features/sales/viewmodels/sales_create_viewmodel.dart';
import 'package:wfs/features/sales/viewmodels/sales_detail_viewmodel.dart';
import 'package:wfs/features/sales/viewmodels/sales_edit_viewmodel.dart';
import 'package:wfs/features/survey/models/survey_model.dart';
import 'package:wfs/features/survey/models/survey_recipient.dart';
import 'package:wfs/features/survey/models/survey_recipient_filter.dart';
import 'package:wfs/features/survey/models/survey_dashboard_model.dart';
import 'package:wfs/features/survey/services/survey_dashboard_service.dart';
import 'package:wfs/features/survey/services/survey_service.dart';
import 'package:wfs/features/survey/viewmodels/survey_dashboard_viewmodel.dart';
import 'package:wfs/features/survey/viewmodels/survey_list_viewmodel.dart';
import 'package:wfs/features/task/services/task_service.dart';
import 'package:wfs/features/task/models/task_appointment_type.dart';
import 'package:wfs/features/task/models/task_purpose.dart';
import 'package:wfs/features/task/viewmodels/task_create_viewmodel.dart';
import 'package:wfs/features/task/viewmodels/task_detail_viewmodel.dart';
import 'package:wfs/features/task/viewmodels/task_list_viewmodel.dart';
import 'package:wfs/features/territory/models/territory_model.dart';
import 'package:wfs/features/territory/services/territory_service.dart';
import 'package:wfs/features/territory/viewmodels/territory_create_viewmodel.dart';
import 'package:wfs/features/territory/viewmodels/territory_detail_viewmodel.dart';
import 'package:wfs/features/territory/viewmodels/territory_edit_viewmodel.dart';
import 'package:wfs/features/territory/viewmodels/territory_list_viewmodel.dart';
import 'package:wfs/features/team/services/team_service.dart';
import 'package:wfs/features/team/viewmodels/team_list_viewmodel.dart';
import 'package:wfs/features/team/viewmodels/team_create_viewmodel.dart';
import 'package:wfs/features/team/viewmodels/team_client_detail_viewmodel.dart';
import 'package:wfs/features/tag/viewmodels/tag_create_viewmodel.dart';
import 'package:wfs/features/tag/viewmodels/tag_list_viewmodel.dart';
import 'package:wfs/features/pin/services/pin_service.dart';
import 'package:wfs/features/pin/viewmodels/pin_viewmodel.dart';
import 'package:wfs/features/team/viewmodels/team_sales_detail_viewmodel.dart';
import 'package:wfs/models/user_model.dart';
import 'package:wfs/models/userrole_model.dart';
import 'package:wfs/providers/auth_provider.dart';
import 'package:wfs/services/user_service.dart';

final appointmentServiceProvider = Provider<AppointmentService>((ref) => AppointmentService());
final appointmentProvider = StateNotifierProvider.autoDispose<AppointmentViewModel, AppointmentState>((ref) => AppointmentViewModel(ref));

final selectedMonthProvider = NotifierProvider<SelectedMonthViewModel, DateTime>(SelectedMonthViewModel.new);
final selectedDateProvider = NotifierProvider<SelectedDateViewModel, DateTime>(SelectedDateViewModel.new);

final appointmentMarkDateProvider = StateNotifierProvider.autoDispose.family<AppointmentMarkDateViewModel, AsyncValue<Map<String, bool>>, DateTime>(
  (ref, date) => AppointmentMarkDateViewModel(ref, date),
);
final appointmentsByDateProvider = StateNotifierProvider.autoDispose.family<AppointmentsByDateViewModel, AsyncValue<List<dynamic>>, String>((ref, date) => AppointmentsByDateViewModel(ref, date));

final companiesOfClentProvider = StateProvider<List<Company>>((ref) => []);

final appointmentCreateProvider = StateNotifierProvider.autoDispose.family<AppointmentCreateViewModel, AppointmentCreateState, ({String id, String clientType})>((ref, params) {
  return AppointmentCreateViewModel(ref, params.id, params.clientType);
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

final companysProvider = FutureProvider.autoDispose<List<Company>>((ref) async {
  return await ref.read(companyServiceProvider).fetchCompanies(ref);
});

final companyByIDProvider = FutureProvider.autoDispose.family<List<Company>, String>((ref, id) async {
  final company = await ref.read(companyServiceProvider).getById(ref, id);
  return [company];
});

final saleProvider = FutureProvider.autoDispose<List<User>>((ref) async {
  return await ref.read(userServiceProvider).GetSales(ref);
});

final userRoleProvider = FutureProvider.autoDispose<List<UserRole>>((ref) async {
  final authState = ref.watch(authProvider);
  final roles = await ref.read(userServiceProvider).fetchUserRoles(ref);

  if (authState.isSupervisor) {
    return roles.where((role) => role.userRoleID == 'BBCC9574-F8F2-402A-8ED1-784934A04FA0').toList();
  } else if (authState.isAdmin) {
    return roles.where((role) => role.userRoleID == '8CFBD382-FA8B-459C-9BCF-6A3FDF66A8D6' || role.userRoleID == 'BBCC9574-F8F2-402A-8ED1-784934A04FA0').toList();
  } else if (authState.isSystemAdmin) {
    return roles
        .where(
          (role) => role.userRoleID == '91FA9057-F815-456C-8D7E-C8CCCBC2A805' || role.userRoleID == '8CFBD382-FA8B-459C-9BCF-6A3FDF66A8D6' || role.userRoleID == 'BBCC9574-F8F2-402A-8ED1-784934A04FA0',
        )
        .toList();
  }

  return roles;
});

final supervisorProvider = FutureProvider.autoDispose<List<User>>((ref) async {
  return await ref.read(userServiceProvider).GetSupervisors(ref);
});

//* Tag
final tagServiceProvider = Provider<TagService>((ref) => TagService());

final tagListProvider = StateNotifierProvider.autoDispose<TagListViewModel, TagListState>((ref) {
  final service = ref.read(tagServiceProvider);
  return TagListViewModel(ref, service: service);
});

//* Pin
final pinServiceProvider = Provider<PinService>((ref) => PinService());

final pinViewModelProvider = StateNotifierProvider<PinViewModel, PinState>((ref) {
  return PinViewModel(ref.watch(pinServiceProvider), ref);
});

//* Client
final clientServiceProvider = Provider<ClientService>((ref) => ClientService());

final clientListProvider = StateNotifierProvider.autoDispose.family<ClientListViewModel, ClientListState, List<String>?>((ref, statusNames) {
  return ClientListViewModel(ref, initialStatus: statusNames);
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

final clientsProvider = FutureProvider.autoDispose<List<Client>>((ref) async {
  return await ref.read(clientServiceProvider).fetchClients(ref);
});

final clientForLeadProvider = FutureProvider.autoDispose<List<Client>>((ref) async {
  return await ref.read(clientServiceProvider).fetchTaskClients(ref);
});

final clientLevelProvider = FutureProvider.autoDispose<List<ClientLevel>>((ref) async {
  return await ref.read(clientServiceProvider).fetchClientLevel(ref);
});

//* Lead
final leadServiceProvider = Provider<LeadService>((ref) => LeadService());

final leadListProvider = StateNotifierProvider.autoDispose<LeadListViewModel, LeadListState>((ref) {
  final service = ref.read(leadServiceProvider);
  return LeadListViewModel(ref, service: service);
});

final leadCreateProvider = StateNotifierProvider.autoDispose<LeadCreateViewModel, LeadCreateState>((ref) {
  return LeadCreateViewModel(ref);
});

final leadDetailProvider = StateNotifierProvider.autoDispose.family<LeadDetailViewModel, LeadDetailState, String>((ref, id) {
  final workflowService = ref.read(leadWorkflowServiceProvider);
  return LeadDetailViewModel(ref, id, workflowService: workflowService);
});

final leadEditProvider = StateNotifierProvider.autoDispose.family<LeadEditViewModel, LeadEditState, String>((ref, id) {
  return LeadEditViewModel(ref, id);
});

final leadStatusProvider = FutureProvider.autoDispose<List<LeadStatus>>((ref) async {
  return await ref.read(leadServiceProvider).fetchLeadStatus(ref);
});

//* Lead Workflow
final leadWorkflowServiceProvider = Provider<LeadWorkflowService>((ref) => LeadWorkflowService());

final leadWorkflowRepositoryProvider = StateNotifierProvider.autoDispose<LeadWorkflowRepository, LeadWorkflowRepositoryState>((ref) {
  return LeadWorkflowRepository(ref: ref, service: ref.read(leadWorkflowServiceProvider));
});

final leadWorkflowProvider = FutureProvider.autoDispose<LeadWorkflowModel>((ref) async {
  return await ref.read(leadWorkflowServiceProvider).getDefaultWorkflow(ref);
});

//* Sales Pipeline
final salesPipelineProvider = StateNotifierProvider.autoDispose<SalesPipelineViewModel, SalesPipelineState>((ref) {
  final service = ref.read(leadServiceProvider);
  final workflowService = ref.read(leadWorkflowServiceProvider);
  return SalesPipelineViewModel(ref, service: service, workflowService: workflowService);
});

//* Sales Conversion Funnel
final salesConversionFunnelServiceProvider = Provider<SalesConversionFunnelService>((ref) {
  return SalesConversionFunnelService();
});

final salesConversionFunnelProvider = StateNotifierProvider.autoDispose<SalesConversionFunnelViewModel, SalesConversionFunnelState>((ref) {
  return SalesConversionFunnelViewModel(ref, leadService: ref.read(leadServiceProvider), funnelService: ref.read(salesConversionFunnelServiceProvider));
});

//* Task
final taskServiceProvider = Provider<TaskService>((ref) => TaskService());

final taskListProvider = StateNotifierProvider.autoDispose<TaskListViewModel, TaskListState>((ref) {
  final service = ref.read(taskServiceProvider);
  return TaskListViewModel(ref, service: service);
});

final taskCreateProvider = StateNotifierProvider.autoDispose.family<TaskCreateViewModel, TaskCreateState, ({String? clientID, String clientType})>((ref, params) {
  return TaskCreateViewModel(ref, params.clientID, params.clientType);
});

final taskDetailProvider = StateNotifierProvider.autoDispose.family<TaskDetailViewModel, TaskDetailState, String>((ref, id) {
  return TaskDetailViewModel(ref, id);
});

final taskEditProvider = StateNotifierProvider.autoDispose.family<TaskDetailViewModel, TaskDetailState, String>((ref, id) {
  return TaskDetailViewModel(ref, id);
});

final taskTypeProvider = FutureProvider.autoDispose<List<TaskAppointmentType>>((ref) async {
  return ref.read(taskServiceProvider).fetchTaskTypes(ref);
});

final taskPurposeProvider = FutureProvider.autoDispose<List<TaskPurpose>>((ref) async {
  return ref.read(taskServiceProvider).fetchTaskPurposes(ref);
});

//* Survey
final surveyServiceProvider = Provider<SurveyService>((ref) => SurveyService());

final surveyDashboardServiceProvider = Provider<SurveyDashboardService>((ref) => SurveyDashboardService());

final surveyListProvider = StateNotifierProvider.autoDispose<SurveyListViewModel, SurveyListState>((ref) {
  return SurveyListViewModel(ref, service: ref.read(surveyServiceProvider));
});

final surveyDetailProvider = FutureProvider.autoDispose.family<Survey, String>((ref, id) async {
  return ref.read(surveyServiceProvider).getSurveyById(ref, id);
});

final surveyRecipientAnswerProvider = FutureProvider.autoDispose.family<SurveyResponse, String>((ref, surveyResponseID) async {
  return ref.read(surveyServiceProvider).getResponseById(ref, surveyResponseID);
});

final surveyRecipientListProvider = FutureProvider.autoDispose.family<List<SurveyRecipient>, ({String surveyTemplateID, String sText, SurveyRecipientFilter filter})>((ref, params) {
  return ref.watch(surveyServiceProvider).searchAnswers(ref, params.surveyTemplateID, sText: params.sText, filter: params.filter);
});

final surveyByRefCodeProvider = FutureProvider.autoDispose.family<Survey, String>((ref, refCode) async {
  return ref.read(surveyServiceProvider).getSurveyByRefCode(ref, refCode);
});

final surveyDashboardProvider = StateNotifierProvider.autoDispose.family<SurveyDashboardViewModel, SurveyDashboardState, String>((ref, surveyID) {
  return SurveyDashboardViewModel(ref, surveyID, service: ref.read(surveyDashboardServiceProvider));
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

//* Lead Dashboard 2
final leadDashboard2ServiceProvider = Provider<LeadDashboard2Service>((ref) => LeadDashboard2Service());

final leadDashboard2Provider = StateNotifierProvider.autoDispose<LeadDashboard2ViewModel, LeadDashboard2State>((ref) {
  final selectedRange = ref.watch(leadDashboard2SelectedDateRangeProvider);
  return LeadDashboard2ViewModel(ref, selectedRange);
});

//* Sales
final salesServiceProvider = Provider<SalesService>((ref) => SalesService());

final salesListProvider = StateNotifierProvider.autoDispose<SalesListViewModel, SalesListState>((ref) {
  return SalesListViewModel(ref);
});

final salesCreateProvider = StateNotifierProvider.autoDispose<SalesCreateViewModel, SalesCreateState>((ref) {
  return SalesCreateViewModel(ref);
});

final salesDetailProvider = StateNotifierProvider.autoDispose.family<SalesDetailViewModel, AsyncValue<User>, String>((ref, id) {
  return SalesDetailViewModel(ref, id);
});

final salesEditProvider = StateNotifierProvider.autoDispose.family<SalesEditViewModel, SalesEditState, String>((ref, id) {
  return SalesEditViewModel(ref, id);
});

//* Territory
final territoryServiceProvider = Provider<TerritoryService>((ref) => TerritoryService());

final territoryListProvider = StateNotifierProvider.autoDispose<TerritoryListViewModel, TerritoryListState>((ref) {
  return TerritoryListViewModel(ref);
});

final territoryCreateProvider = StateNotifierProvider.autoDispose<TerritoryCreateViewModel, TerritoryCreateState>((ref) {
  return TerritoryCreateViewModel(ref);
});

final territoryDetailProvider = StateNotifierProvider.autoDispose.family<TerritoryDetailViewModel, AsyncValue<TerritoryModel>, String>((ref, id) {
  return TerritoryDetailViewModel(ref, id);
});

final territoryEditProvider = StateNotifierProvider.autoDispose.family<TerritoryEditViewModel, TerritoryEditState, String>((ref, id) {
  return TerritoryEditViewModel(ref, id);
});

//* Team
final teamServiceProvider = Provider<TeamService>((ref) => TeamService());

final teamListProvider = StateNotifierProvider.autoDispose<TeamListViewModel, TeamListState>((ref) {
  return TeamListViewModel(ref);
});

final teamCreateProvider = StateNotifierProvider.autoDispose<TeamCreateViewModel, TeamCreateState>((ref) {
  return TeamCreateViewModel(ref);
});

final teamClientDetailProvider = StateNotifierProvider.autoDispose.family<TeamClientDetailViewModel, AsyncValue<List<Client>>, List<String>>((ref, ids) {
  return TeamClientDetailViewModel(ref, ids);
});

final teamSalesDetailProvider = StateNotifierProvider.autoDispose.family<TeamSalesDetailViewModel, AsyncValue<List<User>>, String>((ref, id) {
  return TeamSalesDetailViewModel(ref, id);
});

final userServiceProvider = Provider<UserService>((ref) => UserService());

final tagCreateProvider = StateNotifierProvider.autoDispose<TagCreateViewModel, TagCreateState>((ref) {
  return TagCreateViewModel(ref);
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
