// import 'package:flutter/material.dart';
// import 'package:wfs/features/phase3/lead/models/phase3_lead_model.dart';
// import 'package:wfs/features/phase3/lead/repositories/phase3_lead_repository.dart';
// import 'package:wfs/features/phase3/lead/services/phase3_lead_service.dart';
// import 'package:wfs/features/phase3/lead/views/phase3_lead_create_page.dart';
// import 'package:wfs/features/phase3/lead/views/phase3_lead_detail_page.dart';
// import 'package:wfs/features/phase3/lead/widgets/phase3_lead_card.dart';
// import 'package:wfs/features/phase3/lead/widgets/phase3_lead_empty_state.dart';
// import 'package:wfs/features/phase3/lead_workflow/models/lead_workflow_stage_model.dart';
// import 'package:wfs/features/phase3/lead_workflow/services/lead_workflow_service.dart';
// import 'package:wfs/utility/app_utility.dart';
// import 'package:wfs/widgets/app_text.dart';

// class Phase3LeadListPage extends StatefulWidget {
//   const Phase3LeadListPage({super.key});

//   @override
//   State<Phase3LeadListPage> createState() => _Phase3LeadListPageState();
// }

// class _Phase3LeadListPageState extends State<Phase3LeadListPage> {
//   final Phase3LeadRepository _leadRepository = Phase3LeadRepository(
//     service: Phase3LeadService(),
//   );
//   final LeadWorkflowService _workflowService = LeadWorkflowService();
//   late Future<_LeadListData> _future;

//   @override
//   void initState() {
//     super.initState();
//     _future = _load();
//   }

//   Future<_LeadListData> _load() async {
//     final leads = await _leadRepository.getLeads();
//     final workflow = await _workflowService.getDefaultWorkflow();
//     return _LeadListData(leads: leads, stages: workflow.stages);
//   }

//   Future<void> _refresh() async {
//     setState(() => _future = _load());
//     await _future;
//   }

//   Future<void> _openCreate() async {
//     final created = await Navigator.of(context).push<Phase3LeadModel>(
//       MaterialPageRoute(
//         builder: (context) => const Phase3LeadCreatePage(),
//         fullscreenDialog: true,
//       ),
//     );
//     if (created != null) await _refresh();
//   }

//   Future<void> _openDetail(Phase3LeadModel lead) async {
//     await Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => Phase3LeadDetailPage(leadId: lead.id),
//       ),
//     );
//     await _refresh();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF6F6F6),
//       appBar: AppBar(
//         centerTitle: true,
//         leadingWidth: 98,
//         leading: GestureDetector(
//           onTap: _openCreate,
//           child: Row(
//             children: [
//               IconButton(
//                 icon: Row(
//                   children: [
//                     const Icon(Icons.add),
//                     AppText(
//                       label: 'Create',
//                       textColor: AppUtility.colorPrimary,
//                       fontSize: 17,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ],
//                 ),
//                 onPressed: null,
//                 style: ButtonStyle(
//                   iconColor: WidgetStateProperty.all(AppUtility.colorPrimary),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         title: FutureBuilder<_LeadListData>(
//           future: _future,
//           builder: (context, snapshot) {
//             final countText = snapshot.hasData
//                 ? '${snapshot.data!.leads.length} Entry'
//                 : 'Loading...';
//             return Column(
//               children: [
//                 const AppText(
//                   label: 'Phase 3 Lead',
//                   fontSize: 17,
//                   fontWeight: FontWeight.w600,
//                 ),
//                 AppText(label: countText, fontSize: 12, textColor: Colors.grey),
//               ],
//             );
//           },
//         ),
//         shape: const Border(
//           bottom: BorderSide(
//             color: Color.fromRGBO(60, 60, 67, 0.36),
//             width: 0.5,
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: RefreshIndicator(
//           onRefresh: _refresh,
//           child: FutureBuilder<_LeadListData>(
//             future: _future,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting &&
//                   !snapshot.hasData) {
//                 return const Center(
//                   child: CircularProgressIndicator(
//                     color: AppUtility.colorPrimary,
//                   ),
//                 );
//               }
//               if (snapshot.hasError) {
//                 return Center(
//                   child: AppText(
//                     label: snapshot.error.toString(),
//                     textColor: AppUtility.colorRed,
//                   ),
//                 );
//               }
//               final data = snapshot.data;
//               if (data == null || data.leads.isEmpty) {
//                 return const Phase3LeadEmptyState();
//               }

//               return ListView.separated(
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 itemCount: data.leads.length,
//                 separatorBuilder: (context, index) => const Divider(
//                   height: 1,
//                   thickness: AppUtility.borderWidth,
//                   color: AppUtility.colorGray,
//                 ),
//                 itemBuilder: (context, index) {
//                   final lead = data.leads[index];
//                   return Phase3LeadCard(
//                     lead: lead,
//                     stage: data.stageById(lead.currentStageId),
//                     onTap: () => _openDetail(lead),
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _LeadListData {
//   final List<Phase3LeadModel> leads;
//   final List<LeadWorkflowStageModel> stages;

//   const _LeadListData({required this.leads, required this.stages});

//   LeadWorkflowStageModel? stageById(int id) {
//     return stages.where((stage) => stage.id == id).firstOrNull;
//   }
// }
