import 'package:flutter/material.dart';
import 'package:wfs/features/leaddashboard/models/lead_dashboard_metric.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';

class LeadSummaryCard extends StatelessWidget {
  final LeadDashboardMetric metric;

  const LeadSummaryCard({required this.metric, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Color.lerp(metric.color, Colors.white, 0.88),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color.lerp(metric.color, Colors.white, 0.62) ?? metric.color,
          width: AppUtility.borderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: metric.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(metric.icon, color: metric.color, size: 24),
          ),
          const Spacer(),
          AppText(
            label: metric.title,
            fontSize: 13,
            textColor: AppUtility.textGray,
            lineHeight: 17,
            maxLines: 2,
          ),
          const SizedBox(height: 4),
          AppText(
            label: metric.value.toString(),
            fontSize: 28,
            fontWeight: FontWeight.w800,
            lineHeight: 32,
          ),
        ],
      ),
    );
  }
}
