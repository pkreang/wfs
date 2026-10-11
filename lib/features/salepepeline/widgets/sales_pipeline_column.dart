import 'package:flutter/material.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/features/lead/models/lead.dart';
import 'package:wfs/features/phase3/lead_workflow/models/lead_workflow_stage_model.dart';
import 'package:wfs/features/salepepeline/widgets/sales_pipeline_deal_card.dart';
import 'package:wfs/utility/app_utility.dart';

class SalesPipelineColumn extends StatelessWidget {
  final LeadWorkflowStageModel stage;
  final List<Lead> leads;
  final bool isDragEnabled;
  final void Function(Lead lead)? onTapLead;
  final Future<bool> Function(Lead lead, LeadWorkflowStageModel stage)? onMoveLead;
  final VoidCallback? onDragStarted;
  final void Function(DragUpdateDetails details)? onDragUpdate;
  final VoidCallback? onDragEnd;

  const SalesPipelineColumn({super.key, required this.stage, required this.leads, this.isDragEnabled = true, this.onTapLead, this.onMoveLead, this.onDragStarted, this.onDragUpdate, this.onDragEnd});

  @override
  Widget build(BuildContext context) {
    final totalBudget = leads.fold<double>(0, (sum, lead) => sum + (lead.budget ?? 0));

    return DragTarget<Lead>(
      onWillAcceptWithDetails: (details) => details.data.leadStatusID != _stageId,
      onAcceptWithDetails: (details) => onMoveLead?.call(details.data, stage),
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        return SizedBox(
          width: 292,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: isHovering ? const Color(0xFFEAF4FF) : const Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: isHovering ? AppUtility.colorPrimary : const Color(0xFFEFEFEF)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 6,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: AppUtility.colorPrimary, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppText(label: stage.displayName, fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          AppText(label: '${leads.length}', fontSize: 13, textColor: AppUtility.textLight),
                        ],
                      ),
                      // AppText(label: 'Total ${_formatBudget(totalBudget)}', fontSize: 12, textColor: AppUtility.textLight),
                    ],
                  ),
                ),
                Expanded(
                  child: leads.isEmpty
                      ? const Center(
                          child: AppText(label: 'No deals found.', fontSize: 13, textColor: AppUtility.textLight),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(10),
                          itemCount: leads.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final lead = leads[index];
                            final card = SalesPipelineDealCard(lead: lead, onTap: () => onTapLead?.call(lead));
                            if (!isDragEnabled) return card;

                            return LongPressDraggable<Lead>(
                              data: lead,
                              delay: const Duration(milliseconds: 100),
                              onDragStarted: onDragStarted,
                              onDragUpdate: onDragUpdate,
                              onDragEnd: (_) => onDragEnd?.call(),
                              onDragCompleted: onDragEnd,
                              onDraggableCanceled: (_, _) => onDragEnd?.call(),
                              feedback: SizedBox(
                                width: 272,
                                child: Material(
                                  color: Colors.transparent,
                                  child: Opacity(opacity: 0.92, child: SalesPipelineDealCard(lead: lead)),
                                ),
                              ),
                              childWhenDragging: Opacity(opacity: 0.35, child: SalesPipelineDealCard(lead: lead)),
                              child: card,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatBudget(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  String get _stageId {
    final stageId = stage.stageId.trim();
    if (stageId.isNotEmpty) return stageId;
    return stage.id.toString();
  }
}
