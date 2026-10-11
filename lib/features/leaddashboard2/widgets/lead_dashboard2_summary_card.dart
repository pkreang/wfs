import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/leaddashboard2/models/lead_dashboard2_metric.dart';
import 'package:wfs/features/leaddashboard2/providers/lead_dashboard2_date_range_provider.dart';
import 'package:wfs/providers/lead_filter_provider.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';

class LeadDashboard2SummaryCard extends ConsumerWidget {
  final LeadDashboard2Metric metric;
  final VoidCallback onOpenLeads;

  const LeadDashboard2SummaryCard({required this.metric, required this.onOpenLeads, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        if (metric.statusSearch.isEmpty) return;

        final range = ref.read(leadDashboard2SelectedDateRangeProvider);
        ref.read(leadFilterProvider.notifier).applyDashboardFilter(startDate: range.start, endDate: range.end, status: metric.statusSearch);
        ref.invalidate(leadListProvider);
        onOpenLeads();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 16,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(color: Color.lerp(metric.color, Colors.white, 0.86), borderRadius: BorderRadius.circular(8)),
                  child: Icon(metric.icon, color: metric.color, size: 19),
                ),
                // const Spacer(),
                // Container(
                //   width: 7,
                //   height: 7,
                //   decoration: BoxDecoration(color: metric.color, shape: BoxShape.circle),
                // ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(label: metric.title, fontSize: 12, textColor: AppUtility.textGray, lineHeight: 16, maxLines: 2),
                    const SizedBox(height: 4),
                    AppText(label: metric.displayValue, fontSize: 24, fontWeight: FontWeight.w600, lineHeight: 28),
                  ],
                ),
              ],
            ),
            // const Spacer(),
            // AppText(label: metric.title, fontSize: 12, textColor: AppUtility.textGray, lineHeight: 16, maxLines: 2),
            // const SizedBox(height: 4),
            // AppText(label: metric.value.toString(), fontSize: 24, fontWeight: FontWeight.w600, lineHeight: 28),
          ],
        ),
      ),
    );
  }
}
