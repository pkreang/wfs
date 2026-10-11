// import 'package:wfs/features/phase3/lead/models/phase3_lead_create_request.dart';
// import 'package:wfs/features/phase3/lead/models/phase3_lead_funnel_model.dart';
// import 'package:wfs/features/phase3/lead/models/phase3_lead_model.dart';
// import 'package:wfs/features/phase3/lead_workflow/models/lead_workflow_stage_model.dart';
// import 'package:wfs/features/phase3/lead_workflow/services/lead_workflow_service.dart';

// class Phase3LeadService {
//   Phase3LeadService({LeadWorkflowService? workflowService}) : _workflowService = workflowService ?? LeadWorkflowService();

//   final LeadWorkflowService _workflowService;

//   static final List<Phase3LeadModel> _leads = [];
//   static bool _seeded = false;
//   static int _nextLeadId = 7;

//   Future<List<Phase3LeadModel>> getLeads() async {
//     await _ensureSeeded();
//     return [..._leads]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
//   }

//   Future<Phase3LeadModel?> getLeadById(int id) async {
//     await _ensureSeeded();
//     return _leads.where((lead) => lead.id == id).firstOrNull;
//   }

//   Future<List<Phase3LeadFunnelModel>> getLeadFunnel() async {
//     // TODO: Replace with GET /api/v1/phase3/leads/funnel.
//     // Backend should aggregate lead count and total deal value by workflow stage.
//     // Backend should split Closed into WON and LOST using closeStatus.
//     // Backend should return items sorted by workflow stage sortOrder.
//     final stages = await _workflowService.getWorkflowStagesForFunnel();
//     final leads = await getLeads();
//     final closedStage = stages.where((stage) => stage.systemStage == SystemLeadStage.closed).firstOrNull;
//     final items = <Phase3LeadFunnelModel>[];

//     for (final stage in stages) {
//       final stageLeads = leads.where((lead) => lead.currentStageId == stage.id).toList();

//       if (stage.systemStage == SystemLeadStage.closed) {
//         final wonLeads = stageLeads.where((lead) => lead.closeStatus == 'WON').toList();
//         final lostLeads = stageLeads.where((lead) => lead.closeStatus == 'LOST').toList();
//         final openClosedLeads = stageLeads.where((lead) => lead.closeStatus == 'OPEN').toList();

//         if (wonLeads.isNotEmpty || lostLeads.isNotEmpty) {
//           items.add(_buildFunnelItem(stage: stage, stageName: 'Closed Won', leads: wonLeads, closeStatus: 'WON'));
//           items.add(_buildFunnelItem(stage: stage, stageName: 'Closed Lost', leads: lostLeads, closeStatus: 'LOST', sortOrderOffset: 1));
//         }

//         if (openClosedLeads.isNotEmpty || (wonLeads.isEmpty && lostLeads.isEmpty)) {
//           // TODO: Backend should validate whether OPEN leads are allowed to remain in Closed.
//           items.add(_buildFunnelItem(stage: stage, stageName: stage.displayName, leads: openClosedLeads, closeStatus: 'OPEN', sortOrderOffset: 2));
//         }
//         continue;
//       }

//       items.add(_buildFunnelItem(stage: stage, leads: stageLeads));
//     }

//     final activeStageIds = stages.map((stage) => stage.id).toSet();
//     final legacyLeads = leads.where((lead) => !activeStageIds.contains(lead.currentStageId)).toList();
//     if (legacyLeads.isNotEmpty && closedStage != null) {
//       // TODO: Backend should migrate leads that are in inactive/deleted workflow stages or return legacy display metadata.
//     }

//     return items..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
//   }

//   Future<Phase3LeadModel> createLead(Phase3LeadCreateRequest request) async {
//     await _ensureSeeded();
//     final workflow = await _workflowService.getDefaultWorkflow();
//     final initialStage = await _initialStage();
//     final now = DateTime.now();
//     final lead = Phase3LeadModel(
//       id: _nextLeadId++,
//       leadName: request.leadName,
//       companyName: request.companyName,
//       phone: request.phone,
//       email: request.email,
//       source: request.source,
//       interestedProduct: request.interestedProduct,
//       dealValue: request.dealValue,
//       note: request.note,
//       workflowId: workflow.id,
//       currentStageId: initialStage.id,
//       closeStatus: 'OPEN',
//       createdAt: now,
//       updatedAt: now,
//     );

//     _leads.insert(0, lead);
//     return lead;
//   }

//   Future<void> updateLead(Phase3LeadModel lead) async {
//     await _ensureSeeded();
//     final index = _leads.indexWhere((item) => item.id == lead.id);
//     if (index < 0) return;
//     _leads[index] = lead.copyWith(updatedAt: DateTime.now());
//   }

//   Future<void> moveLeadToStage(int leadId, int toStageId, {String? note}) async {
//     await _ensureSeeded();
//     final stages = await _workflowService.getWorkflowStagesForFunnel();
//     if (!stages.any((stage) => stage.id == toStageId)) {
//       throw StateError('Target stage is inactive, deleted, or not part of this workflow.');
//     }

//     final lead = await getLeadById(leadId);
//     if (lead == null) return;
//     await updateLead(lead.copyWith(currentStageId: toStageId, closeStatus: 'OPEN', note: note ?? lead.note, clearLostReason: true));
//   }

//   Future<void> moveLeadToNextStage(int leadId) async {
//     await _ensureSeeded();
//     final lead = await getLeadById(leadId);
//     if (lead == null || lead.isClosed) return;

//     final stages = await _workflowService.getWorkflowStagesForFunnel();
//     final currentIndex = stages.indexWhere((stage) => stage.id == lead.currentStageId);
//     if (currentIndex < 0 || currentIndex >= stages.length - 1) return;

//     await moveLeadToStage(leadId, stages[currentIndex + 1].id);
//   }

//   Future<void> closeLeadWon(int leadId) async {
//     await _ensureSeeded();
//     final lead = await getLeadById(leadId);
//     if (lead == null) return;

//     final closedStage = await _closedStage();
//     // TODO: Convert-to-client logic should run here when backend support is ready.
//     await updateLead(lead.copyWith(currentStageId: closedStage.id, closeStatus: 'WON', clearLostReason: true));
//   }

//   Future<void> closeLeadLost(int leadId, String reason) async {
//     await _ensureSeeded();
//     final trimmedReason = reason.trim();
//     if (trimmedReason.isEmpty) {
//       throw StateError('Lost reason is required.');
//     }

//     final lead = await getLeadById(leadId);
//     if (lead == null) return;

//     final closedStage = await _closedStage();
//     await updateLead(lead.copyWith(currentStageId: closedStage.id, closeStatus: 'LOST', lostReason: trimmedReason));
//   }

//   Phase3LeadFunnelModel _buildFunnelItem({required LeadWorkflowStageModel stage, required List<Phase3LeadModel> leads, String? stageName, String? closeStatus, int sortOrderOffset = 0}) {
//     return Phase3LeadFunnelModel(
//       stageId: stage.id,
//       stageName: stageName ?? stage.displayName,
//       sortOrder: stage.sortOrder + sortOrderOffset,
//       leadCount: leads.length,
//       totalDealValue: leads.fold<double>(0, (sum, lead) => sum + (lead.dealValue ?? 0)),
//       systemStage: stage.systemStage?.name,
//       stageType: stage.stageType.name,
//       closeStatus: closeStatus,
//     );
//   }

//   Future<void> _ensureSeeded() async {
//     if (_seeded) return;

//     final workflow = await _workflowService.getDefaultWorkflow();
//     final stages = await _workflowService.getWorkflowStagesForFunnel();
//     final prospecting = _stageBySystemStage(stages, SystemLeadStage.prospecting) ?? stages.first;
//     final qualification = _stageBySystemStage(stages, SystemLeadStage.qualification) ?? prospecting;
//     final firstCustom = stages.where((stage) => stage.isCustom).firstOrNull ?? qualification;
//     final proposal = _stageBySystemStage(stages, SystemLeadStage.proposal) ?? stages.last;
//     final closed = _stageBySystemStage(stages, SystemLeadStage.closed) ?? stages.last;
//     final now = DateTime.now();

//     _leads.addAll([
//       Phase3LeadModel(
//         id: 1,
//         leadName: 'Lead A',
//         companyName: 'Acme Co., Ltd.',
//         phone: '081-111-1111',
//         source: 'Website',
//         interestedProduct: 'CRM Package',
//         dealValue: 120000,
//         workflowId: workflow.id,
//         currentStageId: prospecting.id,
//         closeStatus: 'OPEN',
//         createdAt: now.subtract(const Duration(days: 6)),
//         updatedAt: now.subtract(const Duration(hours: 4)),
//       ),
//       Phase3LeadModel(
//         id: 2,
//         leadName: 'Lead B',
//         companyName: 'Northwind',
//         phone: '082-222-2222',
//         email: 'buyer@northwind.test',
//         source: 'Referral',
//         interestedProduct: 'Service Plan',
//         dealValue: 85000,
//         workflowId: workflow.id,
//         currentStageId: qualification.id,
//         closeStatus: 'OPEN',
//         createdAt: now.subtract(const Duration(days: 5)),
//         updatedAt: now.subtract(const Duration(hours: 9)),
//       ),
//       Phase3LeadModel(
//         id: 3,
//         leadName: 'Lead C',
//         companyName: 'Demo Group',
//         phone: '083-333-3333',
//         source: 'Event',
//         interestedProduct: 'Demo',
//         dealValue: 56000,
//         workflowId: workflow.id,
//         currentStageId: firstCustom.id,
//         closeStatus: 'OPEN',
//         createdAt: now.subtract(const Duration(days: 4)),
//         updatedAt: now.subtract(const Duration(days: 1)),
//       ),
//       Phase3LeadModel(
//         id: 4,
//         leadName: 'Lead D',
//         companyName: 'Proposal Partner',
//         email: 'contact@proposal.test',
//         source: 'Sales',
//         interestedProduct: 'Enterprise Plan',
//         dealValue: 180000,
//         workflowId: workflow.id,
//         currentStageId: proposal.id,
//         closeStatus: 'OPEN',
//         createdAt: now.subtract(const Duration(days: 3)),
//         updatedAt: now.subtract(const Duration(days: 1, hours: 6)),
//       ),
//       Phase3LeadModel(
//         id: 5,
//         leadName: 'Lead E',
//         companyName: 'Won Client',
//         phone: '085-555-5555',
//         source: 'Referral',
//         interestedProduct: 'Annual Contract',
//         dealValue: 250000,
//         workflowId: workflow.id,
//         currentStageId: closed.id,
//         closeStatus: 'WON',
//         createdAt: now.subtract(const Duration(days: 12)),
//         updatedAt: now.subtract(const Duration(days: 2)),
//       ),
//       Phase3LeadModel(
//         id: 6,
//         leadName: 'Lead F',
//         companyName: 'Lost Prospect',
//         email: 'lost@example.test',
//         source: 'Website',
//         interestedProduct: 'Consulting',
//         dealValue: 45000,
//         workflowId: workflow.id,
//         currentStageId: closed.id,
//         closeStatus: 'LOST',
//         lostReason: 'Budget not approved',
//         createdAt: now.subtract(const Duration(days: 10)),
//         updatedAt: now.subtract(const Duration(days: 3)),
//       ),
//     ]);
//     _seeded = true;
//   }

//   Future<LeadWorkflowStageModel> _initialStage() async {
//     final stages = await _workflowService.getWorkflowStagesForFunnel();
//     return _stageBySystemStage(stages, SystemLeadStage.prospecting) ?? stages.first;
//   }

//   Future<LeadWorkflowStageModel> _closedStage() async {
//     final workflow = await _workflowService.getDefaultWorkflow();
//     return workflow.stages.firstWhere((stage) => stage.systemStage == SystemLeadStage.closed);
//   }

//   LeadWorkflowStageModel? _stageBySystemStage(List<LeadWorkflowStageModel> stages, SystemLeadStage systemStage) {
//     return stages.where((stage) => stage.systemStage == systemStage).firstOrNull;
//   }
// }
