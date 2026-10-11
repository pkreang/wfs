import 'package:flutter/material.dart';
import 'package:wfs/features/leaddashboard2/models/lead_dashboard2_metric.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';

class LeadDashboard2ConversionRateCard extends StatelessWidget {
  final LeadDashboard2RateMetric metric;

  const LeadDashboard2ConversionRateCard({required this.metric, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(metric.icon, color: metric.color, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: AppText(label: metric.title, fontSize: 15, fontWeight: FontWeight.w600, lineHeight: 19),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AppText(label: metric.description, fontSize: 12, textColor: AppUtility.textGray, lineHeight: 16, maxLines: 2),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(14)),
            child: AppText(label: metric.formula, fontSize: 12, textColor: AppUtility.textGray, lineHeight: 16, maxLines: 1),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: AppText(label: '${metric.value.toStringAsFixed(1)}%', fontSize: 28, fontWeight: FontWeight.w600, textColor: metric.color, lineHeight: 32),
          ),
        ],
      ),
    );
  }
}
