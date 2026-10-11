import 'package:flutter/material.dart';
import 'package:wfs/features/leaddashboard/models/lead_dashboard_metric.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';

class LeadDashboardFilterSection extends StatelessWidget {
  final List<LeadDashboardFilterItem> filters;

  const LeadDashboardFilterSection({required this.filters, super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 720
            ? 3
            : constraints.maxWidth >= 460
            ? 2
            : 1;

        return GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filters.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: 74,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            return _FilterCard(item: filters[index]);
          },
        );
      },
    );
  }
}

class _FilterCard extends StatelessWidget {
  final LeadDashboardFilterItem item;

  const _FilterCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: AppUtility.borderWidth,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppUtility.colorPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: AppUtility.colorPrimary, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    label: item.title,
                    fontSize: 12,
                    textColor: AppUtility.textGray,
                    lineHeight: 16,
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    label: item.value,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    lineHeight: 18,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            if (item.hasDropdown)
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppUtility.textGray,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
