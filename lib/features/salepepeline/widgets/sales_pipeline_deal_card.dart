import 'package:flutter/material.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/features/lead/models/lead.dart';
import 'package:wfs/features/lead/widgets/lead_status_capsule.dart';
import 'package:wfs/utility/app_utility.dart';

class SalesPipelineDealCard extends StatelessWidget {
  final Lead lead;
  final VoidCallback? onTap;

  const SalesPipelineDealCard({super.key, required this.lead, this.onTap});

  @override
  Widget build(BuildContext context) {
    final title = '${lead.leadName}';
    final leadStatus = lead.leadStatus ?? lead.leadStatusName ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: const Color(0xFFEFEFEF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppText(label: title, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Icon(Icons.chevron_right, size: 18, color: AppUtility.colorGray),
              ],
            ),
            if ((lead.companyName ?? '').isNotEmpty) _InfoRow(icon: Icons.business_center_outlined, label: lead.companyName ?? ''),
            if ((lead.ownerName ?? '').isNotEmpty) _InfoRow(icon: Icons.person_outline, label: lead.ownerName ?? ''),
            Row(
              spacing: 8,
              children: [
                if (lead.closeProbability != null) _SmallValue(icon: Icons.percent, label: '${lead.closeProbability}%'),
                if (lead.budget != null) _SmallValue(icon: Icons.payments_outlined, label: _formatBudget(lead.budget)),
              ],
            ),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // LeadStatusCapsule(leadStatusName: lead.leadStatus ?? ''),
                if (leadStatus.toLowerCase() != "closed") LeadStatusCapsule(leadStatusName: leadStatus),
                if (leadStatus.toLowerCase() == "closed" && lead.closeLostReason == null) LeadStatusCapsule(leadStatusName: "ClosedWon"),
                if (leadStatus.toLowerCase() == "closed" && lead.closeLostReason != null) LeadStatusCapsule(leadStatusName: "ClosedLost"),
                // if (lead.isQualified != null) _QualifiedPill(isQualified: lead.isQualified == true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatBudget(double? value) {
    if (value == null) return '';
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, color: AppUtility.textGray, size: 18),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: AppText(label: label, fontSize: 13, textColor: AppUtility.textLight),
        ),
      ],
    );
  }
}

class _SmallValue extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SmallValue({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppUtility.textGray, size: 16),
        const SizedBox(width: 4),
        AppText(label: label, fontSize: 13, textColor: AppUtility.textLight),
      ],
    );
  }
}

class _QualifiedPill extends StatelessWidget {
  final bool isQualified;

  const _QualifiedPill({required this.isQualified});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: isQualified ? const Color.fromRGBO(36, 151, 86, 0.2) : const Color(0xFFEFEFEF), borderRadius: BorderRadius.circular(10)),
      child: AppText(label: isQualified ? 'Qualified' : 'Unqualified', fontSize: 12, textColor: isQualified ? const Color(0xFF219653) : AppUtility.textGray),
    );
  }
}
