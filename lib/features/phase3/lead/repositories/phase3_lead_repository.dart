// import 'package:wfs/features/phase3/lead/models/phase3_lead_create_request.dart';
// import 'package:wfs/features/phase3/lead/models/phase3_lead_funnel_model.dart';
// import 'package:wfs/features/phase3/lead/models/phase3_lead_model.dart';
// import 'package:wfs/features/phase3/lead/services/phase3_lead_service.dart';

// class Phase3LeadRepository {
//   final Phase3LeadService service;

//   const Phase3LeadRepository({required this.service});

//   Future<List<Phase3LeadModel>> getLeads() => service.getLeads();

//   Future<List<Phase3LeadFunnelModel>> getLeadFunnel() =>
//       service.getLeadFunnel();

//   Future<Phase3LeadModel?> getLeadById(int id) => service.getLeadById(id);

//   Future<Phase3LeadModel> createLead(Phase3LeadCreateRequest request) =>
//       service.createLead(request);

//   Future<void> updateLead(Phase3LeadModel lead) => service.updateLead(lead);

//   Future<void> moveLeadToStage(int leadId, int toStageId, {String? note}) =>
//       service.moveLeadToStage(leadId, toStageId, note: note);

//   Future<void> moveLeadToNextStage(int leadId) =>
//       service.moveLeadToNextStage(leadId);

//   Future<void> closeLeadWon(int leadId) => service.closeLeadWon(leadId);

//   Future<void> closeLeadLost(int leadId, String reason) =>
//       service.closeLeadLost(leadId, reason);
// }
