import 'package:flutter/material.dart';
import 'package:wfs/features/phase3/lead/models/phase3_lead_model.dart';
import 'package:wfs/features/phase3/lead_workflow/models/lead_workflow_stage_model.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';

class Phase3LeadStageBadge extends StatelessWidget {
  final LeadWorkflowStageModel? stage;
  final String closeStatus;

  const Phase3LeadStageBadge({
    required this.stage,
    required this.closeStatus,
    super.key,
  });

  factory Phase3LeadStageBadge.fromLead({
    required Phase3LeadModel lead,
    required LeadWorkflowStageModel? stage,
    Key? key,
  }) {
    return Phase3LeadStageBadge(
      stage: stage,
      closeStatus: lead.closeStatus,
      key: key,
    );
  }

  @override
  Widget build(BuildContext context) {
    final label = closeStatus == 'WON'
        ? 'Closed Won'
        : closeStatus == 'LOST'
        ? 'Closed Lost'
        : stage?.displayName ?? 'Unknown';
    final color = closeStatus == 'LOST'
        ? AppUtility.colorRed
        : closeStatus == 'WON'
        ? const Color(0xFF34C759)
        : _stageColor(stage);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color.lerp(color, Colors.white, 0.84),
        borderRadius: BorderRadius.circular(12),
      ),
      child: AppText(
        label: label,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        textColor: color,
        lineHeight: 15,
        maxLines: 1,
      ),
    );
  }

  Color _stageColor(LeadWorkflowStageModel? stage) {
    switch (stage?.systemStage) {
      case SystemLeadStage.prospecting:
        return AppUtility.colorPrimary;
      case SystemLeadStage.qualification:
        return const Color(0xFF7B61FF);
      case SystemLeadStage.proposal:
        return const Color(0xFFFF9500);
      case SystemLeadStage.closed:
        return const Color(0xFF34C759);
      case null:
        return AppUtility.textGray;
    }
  }
}
