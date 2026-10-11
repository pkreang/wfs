import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/features/phase3/lead_workflow/models/lead_workflow_stage_model.dart';
import 'package:wfs/providers/auth_provider.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';

class WorkflowStageTile extends ConsumerWidget {
  final LeadWorkflowStageModel stage;
  final int position;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final ValueChanged<bool>? onActiveChanged;
  final Widget? dragHandle;

  const WorkflowStageTile({required this.stage, required this.position, required this.onEdit, this.onDelete, this.onActiveChanged, this.dragHandle, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.read(authProvider);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Color.lerp(AppUtility.colorPrimary, Colors.white, 0.86), shape: BoxShape.circle),
            child: AppText(label: position.toString(), fontSize: 13, fontWeight: FontWeight.w600, textColor: AppUtility.colorPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: AppText(label: stage.displayName, fontSize: 15, fontWeight: FontWeight.w600, lineHeight: 19, maxLines: 1),
                    ),
                    const SizedBox(width: 8),
                    _StageBadge(stage: stage),
                  ],
                ),
              ],
            ),
          ),
          if ((auth.isAdmin || auth.isSuperAdmin) && stage.isCustom) ...[dragHandle ?? const Icon(Icons.drag_handle_rounded, color: AppUtility.textGray)],
          if ((auth.isAdmin || auth.isSuperAdmin) && !stage.isSystem)
            IconButton(onPressed: onEdit, icon: const Icon(Icons.settings, size: 20), color: AppUtility.colorPrimary, visualDensity: VisualDensity.compact, tooltip: 'Edit'),
        ],
      ),
    );
  }
}

class _StageBadge extends StatelessWidget {
  final LeadWorkflowStageModel stage;

  const _StageBadge({required this.stage});

  @override
  Widget build(BuildContext context) {
    final isInactive = !stage.isSystem && !stage.isActive;
    final color = isInactive ? const Color(0xFFFF382B) : (stage.isSystem ? AppUtility.colorPrimary : const Color(0xFF34C759));
    final backgroundColor = isInactive ? Color.fromRGBO(255, 56, 43, 0.16) : Color.lerp(color, Colors.white, 0.86);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12)),
      child: AppText(label: stage.isSystem ? 'System' : (stage.isActive ? 'Active' : 'Inactive'), fontSize: 11, fontWeight: FontWeight.w600, textColor: color, lineHeight: 14),
    );
  }
}
