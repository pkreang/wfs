import 'package:flutter/material.dart';
import 'package:wfs/features/leaddashboard/models/lead_dashboard_metric.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';

class LeadConversionRateCard extends StatelessWidget {
  final LeadDashboardRateMetric metric;

  const LeadConversionRateCard({required this.metric, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.lerp(metric.color, Colors.white, 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color.lerp(metric.color, Colors.white, 0.62) ?? metric.color,
          width: AppUtility.borderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: metric.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(metric.icon, color: metric.color, size: 25),
              ),
              const Spacer(),
              AppText(
                label: _formatPercent(metric.value),
                fontSize: 28,
                fontWeight: FontWeight.w800,
                textColor: metric.color,
                lineHeight: 32,
              ),
            ],
          ),
          const SizedBox(height: 14),
          AppText(
            label: metric.title,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            lineHeight: 20,
          ),
          const SizedBox(height: 3),
          AppText(
            label: metric.description,
            fontSize: 13,
            textColor: AppUtility.textGray,
            lineHeight: 18,
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: AppUtility.borderWidth,
              ),
            ),
            child: AppText(
              label: metric.formula,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              textColor: metric.color,
              lineHeight: 16,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPercent(double value) => '${value.toStringAsFixed(1)}%';
}
