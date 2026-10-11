import 'package:flutter/material.dart';
import 'package:wfs/features/phase3/lead_workflow/models/lead_workflow_stage_model.dart';
import 'package:wfs/features/phase3/lead_workflow/widgets/workflow_stage_tile.dart';

class SystemStageTile extends StatelessWidget {
  final LeadWorkflowStageModel stage;
  final int position;
  final VoidCallback onEdit;

  const SystemStageTile({required this.stage, required this.position, required this.onEdit, super.key});

  @override
  Widget build(BuildContext context) {
    return WorkflowStageTile(stage: stage, position: position, onEdit: onEdit);
  }
}
