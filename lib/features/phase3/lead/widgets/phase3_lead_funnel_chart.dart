import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wfs/features/phase3/lead/models/phase3_lead_funnel_model.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';

class Phase3LeadFunnelChart extends StatelessWidget {
  final List<Phase3LeadFunnelModel> items;
  final ValueChanged<Phase3LeadFunnelModel>? onTapItem;

  const Phase3LeadFunnelChart({required this.items, this.onTapItem, super.key});

  @override
  Widget build(BuildContext context) {
    final maxLeadCount = items.fold<int>(
      0,
      (max, item) => item.leadCount > max ? item.leadCount : max,
    );
    final totalLeads = items.fold<int>(0, (sum, item) => sum + item.leadCount);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            label: 'Lead Funnel',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: items.map((item) {
                  final percent = totalLeads == 0
                      ? 0.0
                      : item.leadCount / totalLeads * 100;
                  final widthFactor = maxLeadCount == 0
                      ? 0.18
                      : (item.leadCount / maxLeadCount).clamp(0.18, 1.0);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        // TODO: Navigate to a filtered Phase 3 lead list for this workflow stage.
                        onTapItem?.call(item);
                      },
                      child: SizedBox(
                        height: 70,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: FractionallySizedBox(
                                widthFactor: widthFactor,
                                child: ClipPath(
                                  clipper: _FunnelBarClipper(),
                                  child: ColoredBox(
                                    color: _itemColor(item),
                                    child: const SizedBox.expand(),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AppText(
                                    label: item.stageName,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    textColor: Colors.white,
                                    lineHeight: 17,
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 2),
                                  AppText(
                                    label:
                                        '${item.leadCount} leads • ${NumberFormat('#,##0.##').format(item.totalDealValue)} THB • ${percent.toStringAsFixed(1)}%',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    textColor: Colors.white,
                                    lineHeight: 15,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
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

class _FunnelBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final inset = size.width * 0.06;
    return Path()
      ..moveTo(inset, 0)
      ..lineTo(size.width - inset, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant _FunnelBarClipper oldClipper) => false;
}
