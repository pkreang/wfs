import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wfs/features/leaddashboard2/models/lead_dashboard2_metric.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';

class LeadDashboard2FilterSection extends StatelessWidget {
  final List<LeadDashboard2FilterItem> filters;
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;
  final VoidCallback? onDateRangeTap;

  const LeadDashboard2FilterSection({
    required this.filters,
    this.selectedStartDate,
    this.selectedEndDate,
    this.onDateRangeTap,
    super.key,
  });

  String _dateRangeLabel(LeadDashboard2FilterItem item) {
    if (item.title != 'ช่วงวันที่' ||
        selectedStartDate == null ||
        selectedEndDate == null) {
      return item.value;
    }

    final format = DateFormat('dd/MM/yyyy');
    return '${format.format(selectedStartDate!)} - ${format.format(selectedEndDate!)}';
  }

  @override
  Widget build(BuildContext context) {
    return _DashboardSectionCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth >= 720
              ? 3
              : constraints.maxWidth >= 520
              ? 2
              : 1;

          return GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filters.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, mainAxisExtent: 58, crossAxisSpacing: 0, mainAxisSpacing: 0),
            itemBuilder: (context, index) {
              final item = filters[index];
              return _FilterTile(
                item: item,
                value: _dateRangeLabel(item),
                onTap: item.title == 'ช่วงวันที่' ? onDateRangeTap : null,
                showTopBorder: index >= crossAxisCount,
                showTrailingBorder: (index + 1) % crossAxisCount != 0 && index != filters.length - 1,
              );
            },
          );
        },
      ),
    );
  }
}

class _FilterTile extends StatelessWidget {
  final LeadDashboard2FilterItem item;
  final String value;
  final VoidCallback? onTap;
  final bool showTopBorder;
  final bool showTrailingBorder;

  const _FilterTile({
    required this.item,
    required this.value,
    this.onTap,
    required this.showTopBorder,
    required this.showTrailingBorder,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: showTopBorder ? AppUtility.borderSide : BorderSide.none, right: showTrailingBorder ? AppUtility.borderSide : BorderSide.none),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(item.icon, color: AppUtility.colorPrimary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(label: item.title, fontSize: 12, textColor: AppUtility.textGray, lineHeight: 16),
                  AppText(label: value, fontSize: 14, fontWeight: FontWeight.w500, lineHeight: 18, maxLines: 1),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 22, color: AppUtility.colorGray),
          ],
        ),
      ),
    );
  }
}

class _DashboardSectionCard extends StatelessWidget {
  final Widget child;

  const _DashboardSectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11)),
      child: child,
    );
  }
}
