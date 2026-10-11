import 'package:flutter/material.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/utility/app_utility.dart';

class SalesPipelineSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const SalesPipelineSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Icon(icon, color: AppUtility.colorPrimary, size: 20),
          AppText(label: title, fontSize: 12, textColor: AppUtility.textLight),
          AppText(label: value, fontSize: 18, fontWeight: FontWeight.w600),
        ],
      ),
    );
  }
}
