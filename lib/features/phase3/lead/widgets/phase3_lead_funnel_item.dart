import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wfs/features/phase3/lead/models/phase3_lead_funnel_model.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';

class Phase3LeadFunnelItem extends StatelessWidget {
  final Phase3LeadFunnelModel item;
  final int totalLeads;
  final VoidCallback? onTap;

  const Phase3LeadFunnelItem({
    required this.item,
    required this.totalLeads,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final percent = totalLeads == 0 ? 0.0 : item.leadCount / totalLeads * 100;
    final color = _itemColor(item);

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 42,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      label: item.stageName,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      lineHeight: 19,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 3),
                    AppText(
                      label:
                          '${item.leadCount} leads • ${percent.toStringAsFixed(1)}%',
                      fontSize: 12,
                      textColor: AppUtility.textGray,
                      lineHeight: 16,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AppText(
                label:
                    '${NumberFormat('#,##0.##').format(item.totalDealValue)} THB',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                textColor: AppUtility.colorPrimary,
                lineHeight: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _itemColor(Phase3LeadFunnelModel item) {
    if (item.closeStatus == 'LOST') return AppUtility.colorRed;
    if (item.closeStatus == 'WON') return const Color(0xFF34C759);
    if (item.systemStage == 'prospecting') return AppUtility.colorPrimary;
    if (item.systemStage == 'qualification') return const Color(0xFF7B61FF);
    if (item.systemStage == 'proposal') return const Color(0xFFFF9500);
    if (item.systemStage == 'closed') return const Color(0xFF34C759);
    return const Color(0xFF6E6E73);
  }
}
