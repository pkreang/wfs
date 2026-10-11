import 'package:flutter/material.dart';
import 'package:wfs/features/phase3/lead_workflow/models/lead_workflow_stage_model.dart';
import 'package:wfs/features/phase3/lead_workflow/widgets/workflow_stage_tile.dart';

class CustomStageTile extends StatelessWidget {
  final LeadWorkflowStageModel stage;
  final int position;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onActiveChanged;
  final Widget dragHandle;

  const CustomStageTile({required this.stage, required this.position, required this.onEdit, required this.onDelete, required this.onActiveChanged, required this.dragHandle, super.key});

  @override
  Widget build(BuildContext context) {
    return WorkflowStageTile(stage: stage, position: position, onEdit: onEdit, onDelete: onDelete, onActiveChanged: onActiveChanged, dragHandle: dragHandle);
  }
}
