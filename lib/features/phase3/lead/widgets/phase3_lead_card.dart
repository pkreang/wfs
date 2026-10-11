import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wfs/features/phase3/lead/models/phase3_lead_model.dart';
import 'package:wfs/features/phase3/lead/widgets/phase3_lead_stage_badge.dart';
import 'package:wfs/features/phase3/lead_workflow/models/lead_workflow_stage_model.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';

class Phase3LeadCard extends StatelessWidget {
  final Phase3LeadModel lead;
  final LeadWorkflowStageModel? stage;
  final VoidCallback onTap;

  const Phase3LeadCard({
    required this.lead,
    required this.stage,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final contact =
        (lead.phone?.trim().isNotEmpty == true ? lead.phone : lead.email) ??
        '-';

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppText(
                      label: lead.leadName,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      lineHeight: 20,
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Phase3LeadStageBadge.fromLead(lead: lead, stage: stage),
                ],
              ),
              const SizedBox(height: 6),
              AppText(
                label: lead.companyName?.trim().isNotEmpty == true
                    ? lead.companyName!
                    : 'No company',
                fontSize: 13,
                textColor: AppUtility.textGray,
                lineHeight: 18,
                maxLines: 1,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 15,
                    color: AppUtility.textGray,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: AppText(
                      label: contact,
                      fontSize: 12,
                      textColor: AppUtility.textGray,
                      lineHeight: 16,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppText(
                    label: _formatDealValue(lead.dealValue),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    textColor: AppUtility.colorPrimary,
                    lineHeight: 16,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              AppText(
                label:
                    'Updated ${DateFormat('dd/MM/yyyy HH:mm').format(lead.updatedAt)}',
                fontSize: 12,
                textColor: AppUtility.textLight,
                lineHeight: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDealValue(double? value) {
    if (value == null) return 'No deal value';
    final formatter = NumberFormat('#,##0.##');
    return '${formatter.format(value)} THB';
  }
}
