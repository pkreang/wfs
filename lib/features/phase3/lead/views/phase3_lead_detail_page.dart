// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:wfs/features/phase3/lead/models/phase3_lead_model.dart';
// import 'package:wfs/features/phase3/lead/repositories/phase3_lead_repository.dart';
// import 'package:wfs/features/phase3/lead/services/phase3_lead_service.dart';
// import 'package:wfs/features/phase3/lead/widgets/phase3_lead_action_tile.dart';
// import 'package:wfs/features/phase3/lead/widgets/phase3_lead_stage_badge.dart';
// import 'package:wfs/features/phase3/lead/widgets/phase3_lead_stage_selector.dart';
// import 'package:wfs/features/phase3/lead_workflow/models/lead_workflow_stage_model.dart';
// import 'package:wfs/features/phase3/lead_workflow/services/lead_workflow_service.dart';
// import 'package:wfs/utility/app_utility.dart';
// import 'package:wfs/widgets/app_detail_section_card.dart';
// import 'package:wfs/widgets/app_text.dart';
// import 'package:wfs/widgets/app_text_form_field.dart';

// class Phase3LeadDetailPage extends StatefulWidget {
//   final int leadId;

//   const Phase3LeadDetailPage({required this.leadId, super.key});

//   @override
//   State<Phase3LeadDetailPage> createState() => _Phase3LeadDetailPageState();
// }

// class _Phase3LeadDetailPageState extends State<Phase3LeadDetailPage> {
//   final Phase3LeadRepository _leadRepository = Phase3LeadRepository(
//     service: Phase3LeadService(),
//   );
//   final LeadWorkflowService _workflowService = LeadWorkflowService();
//   late Future<_LeadDetailData> _future;
//   bool _isUpdating = false;

//   @override
//   void initState() {
//     super.initState();
//     _future = _load();
//   }

//   Future<_LeadDetailData> _load() async {
//     final lead = await _leadRepository.getLeadById(widget.leadId);
//     final stages = await _workflowService.getWorkflowStagesForFunnel();
//     if (lead == null) throw StateError('Lead not found');
//     return _LeadDetailData(lead: lead, stages: stages);
//   }

//   Future<void> _refresh() async {
//     setState(() => _future = _load());
//     await _future;
//   }

//   Future<void> _runUpdate(Future<void> Function() action) async {
//     setState(() => _isUpdating = true);
//     try {
//       await action();
//       await _refresh();
//     } finally {
//       if (mounted) setState(() => _isUpdating = false);
//     }
//   }

//   Future<void> _moveNext(Phase3LeadModel lead) async {
//     await _runUpdate(() => _leadRepository.moveLeadToNextStage(lead.id));
//   }

//   Future<void> _changeStage(_LeadDetailData data) async {
//     final selected = await Phase3LeadStageSelector.show(
//       context: context,
//       stages: data.stages,
//       currentStageId: data.lead.currentStageId,
//     );
//     if (selected == null || selected.id == data.lead.currentStageId) return;
//     await _runUpdate(
//       () => _leadRepository.moveLeadToStage(data.lead.id, selected.id),
//     );
//   }

//   Future<void> _closeWon(Phase3LeadModel lead) async {
//     await _runUpdate(() => _leadRepository.closeLeadWon(lead.id));
//   }

//   Future<void> _closeLost(Phase3LeadModel lead) async {
//     final reason = await _showLostReasonDialog();
//     if (reason == null) return;
//     await _runUpdate(() => _leadRepository.closeLeadLost(lead.id, reason));
//   }

//   Future<String?> _showLostReasonDialog() async {
//     final controller = TextEditingController();
//     String? validationError;
//     final result = await showCupertinoDialog<String>(
//       context: context,
//       builder: (dialogContext) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return CupertinoAlertDialog(
//               title: const Text(
//                 'Close Lost Reason',
//                 textScaler: TextScaler.noScaling,
//               ),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const SizedBox(height: 12),
//                   Material(
//                     color: Colors.transparent,
//                     child: AppTextFormField(
//                       controller: controller,
//                       hintText: 'Reason',
//                       isShowBorder: true,
//                       maxLines: 3,
//                     ),
//                   ),
//                   if (validationError != null) ...[
//                     const SizedBox(height: 8),
//                     Text(
//                       validationError!,
//                       style: const TextStyle(color: Colors.red, fontSize: 12),
//                       textScaler: TextScaler.noScaling,
//                     ),
//                   ],
//                 ],
//               ),
//               actions: [
//                 CupertinoDialogAction(
//                   onPressed: () => Navigator.of(dialogContext).pop(),
//                   child: AppText(
//                     label: 'Cancel',
//                     textColor: AppUtility.textGray,
//                   ),
//                 ),
//                 CupertinoDialogAction(
//                   isDestructiveAction: true,
//                   onPressed: () {
//                     final reason = controller.text.trim();
//                     if (reason.isEmpty) {
//                       setState(() => validationError = 'Reason is required');
//                       return;
//                     }
//                     Navigator.of(dialogContext).pop(reason);
//                   },
//                   child: AppText(
//                     label: 'Close Lost',
//                     textColor: AppUtility.colorRed,
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//     controller.dispose();
//     return result;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Scaffold(
//           backgroundColor: const Color(0xFFF6F6F6),
//           appBar: AppBar(
//             centerTitle: true,
//             title: const AppText(
//               label: 'Lead Detail',
//               fontSize: 17,
//               fontWeight: FontWeight.w600,
//             ),
//             shape: const Border(
//               bottom: BorderSide(
//                 color: Color.fromRGBO(60, 60, 67, 0.36),
//                 width: 0.5,
//               ),
//             ),
//           ),
//           body: SafeArea(
//             child: FutureBuilder<_LeadDetailData>(
//               future: _future,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting &&
//                     !snapshot.hasData) {
//                   return const Center(
//                     child: CircularProgressIndicator(
//                       color: AppUtility.colorPrimary,
//                     ),
//                   );
//                 }
//                 if (snapshot.hasError) {
//                   return Center(
//                     child: AppText(
//                       label: snapshot.error.toString(),
//                       textColor: AppUtility.colorRed,
//                     ),
//                   );
//                 }
//                 final data = snapshot.data;
//                 if (data == null) {
//                   return const Center(child: AppText(label: 'Lead not found.'));
//                 }
//                 return _buildContent(data);
//               },
//             ),
//           ),
//         ),
//         if (_isUpdating) ...[
//           const ModalBarrier(color: Color(0x33000000), dismissible: false),
//           const Center(
//             child: CircularProgressIndicator(color: AppUtility.colorPrimary),
//           ),
//         ],
//       ],
//     );
//   }

//   Widget _buildContent(_LeadDetailData data) {
//     final lead = data.lead;
//     final currentStage = data.stageById(lead.currentStageId);
//     final isClosed = lead.isClosed;

//     return SingleChildScrollView(
//       padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: AppText(
//                   label: lead.leadName,
//                   fontSize: 26,
//                   fontWeight: FontWeight.w600,
//                   lineHeight: 32,
//                   maxLines: 2,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Phase3LeadStageBadge.fromLead(lead: lead, stage: currentStage),
//             ],
//           ),
//           const SizedBox(height: 16),
//           _StageProgress(
//             stages: data.stages,
//             currentStageId: lead.currentStageId,
//             closeStatus: lead.closeStatus,
//           ),
//           const SizedBox(height: 16),
//           AppDetailSectionCard(
//             title: 'Lead information',
//             fullWidth: true,
//             descWidget: _InfoList(lead: lead, currentStage: currentStage),
//           ),
//           const SizedBox(height: 16),
//           const AppText(
//             label: 'Actions',
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//           const SizedBox(height: 8),
//           Phase3LeadActionTile(
//             icon: Icons.arrow_forward_rounded,
//             title: 'Move to next stage',
//             onTap: isClosed ? null : () => _moveNext(lead),
//           ),
//           const SizedBox(height: 8),
//           Phase3LeadActionTile(
//             icon: Icons.swap_horiz_rounded,
//             title: 'Change stage manually',
//             onTap: isClosed ? null : () => _changeStage(data),
//           ),
//           const SizedBox(height: 8),
//           Phase3LeadActionTile(
//             icon: Icons.check_circle_outline,
//             title: 'Close Won',
//             color: const Color(0xFF34C759),
//             onTap: isClosed ? null : () => _closeWon(lead),
//           ),
//           const SizedBox(height: 8),
//           Phase3LeadActionTile(
//             icon: Icons.cancel_outlined,
//             title: 'Close Lost',
//             color: AppUtility.colorRed,
//             onTap: isClosed ? null : () => _closeLost(lead),
//           ),
//           if (isClosed) ...[
//             const SizedBox(height: 12),
//             const AppText(
//               label: 'This lead is closed. Reopen logic can be added later.',
//               fontSize: 12,
//               textColor: AppUtility.textGray,
//               maxLines: 2,
//             ),
//             // TODO: Add reopen lead logic if business rules allow closed leads to return to active workflow.
//           ],
//         ],
//       ),
//     );
//   }
// }

// class _InfoList extends StatelessWidget {
//   final Phase3LeadModel lead;
//   final LeadWorkflowStageModel? currentStage;

//   const _InfoList({required this.lead, required this.currentStage});

//   @override
//   Widget build(BuildContext context) {
//     final rows = [
//       ('Company', lead.companyName ?? '-'),
//       ('Phone', lead.phone ?? '-'),
//       ('Email', lead.email ?? '-'),
//       ('Source', lead.source ?? '-'),
//       ('Product', lead.interestedProduct ?? '-'),
//       (
//         'Deal Value',
//         lead.dealValue == null
//             ? '-'
//             : NumberFormat('#,##0.##').format(lead.dealValue),
//       ),
//       ('Current Stage', currentStage?.displayName ?? '-'),
//       ('Close Status', lead.closeStatus),
//       if (lead.lostReason != null) ('Lost Reason', lead.lostReason!),
//       ('Updated', DateFormat('dd/MM/yyyy HH:mm').format(lead.updatedAt)),
//       if (lead.note != null) ('Note', lead.note!),
//     ];

//     return Column(
//       children: rows.map((row) {
//         return Padding(
//           padding: const EdgeInsets.only(top: 8),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(
//                 width: 104,
//                 child: AppText(
//                   label: row.$1,
//                   fontSize: 12,
//                   textColor: AppUtility.textGray,
//                   lineHeight: 16,
//                 ),
//               ),
//               Expanded(
//                 child: AppText(
//                   label: row.$2,
//                   fontSize: 14,
//                   lineHeight: 18,
//                   maxLines: 4,
//                 ),
//               ),
//             ],
//           ),
//         );
//       }).toList(),
//     );
//   }
// }

// class _StageProgress extends StatelessWidget {
//   final List<LeadWorkflowStageModel> stages;
//   final int currentStageId;
//   final String closeStatus;

//   const _StageProgress({
//     required this.stages,
//     required this.currentStageId,
//     required this.closeStatus,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final currentIndex = stages.indexWhere(
//       (stage) => stage.id == currentStageId,
//     );

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(11),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const AppText(
//             label: 'Stage progress',
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//           const SizedBox(height: 12),
//           ...stages.indexed.map((entry) {
//             final index = entry.$1;
//             final stage = entry.$2;
//             final isCurrent = stage.id == currentStageId;
//             final isCompleted = currentIndex >= 0 && index < currentIndex;
//             final color = isCurrent
//                 ? AppUtility.colorPrimary
//                 : isCompleted
//                 ? const Color(0xFF34C759)
//                 : AppUtility.colorGray;

//             return Padding(
//               padding: EdgeInsets.only(
//                 bottom: index == stages.length - 1 ? 0 : 10,
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     isCompleted || isCurrent
//                         ? Icons.check_circle
//                         : Icons.radio_button_unchecked,
//                     color: color,
//                     size: 20,
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: AppText(
//                       label: stage.displayName,
//                       fontSize: 14,
//                       fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
//                       textColor: isCurrent
//                           ? AppUtility.colorPrimary
//                           : Colors.black,
//                       lineHeight: 18,
//                     ),
//                   ),
//                   if (isCurrent &&
//                       (closeStatus == 'WON' || closeStatus == 'LOST'))
//                     AppText(
//                       label: closeStatus == 'WON'
//                           ? 'Closed Won'
//                           : 'Closed Lost',
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       textColor: closeStatus == 'WON'
//                           ? const Color(0xFF34C759)
//                           : AppUtility.colorRed,
//                     ),
//                 ],
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }
// }

// class _LeadDetailData {
//   final Phase3LeadModel lead;
//   final List<LeadWorkflowStageModel> stages;

//   const _LeadDetailData({required this.lead, required this.stages});

//   LeadWorkflowStageModel? stageById(int id) {
//     return stages.where((stage) => stage.id == id).firstOrNull;
//   }
// }
