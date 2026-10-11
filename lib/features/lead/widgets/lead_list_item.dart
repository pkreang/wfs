import 'package:flutter/material.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/features/lead/models/lead.dart';
import 'package:wfs/features/lead/widgets/lead_status_capsule.dart';

class LeadListItem extends StatelessWidget {
  final Lead lead;
  final VoidCallback? onTap;

  const LeadListItem({super.key, required this.lead, this.onTap});

  @override
  Widget build(BuildContext context) {
    final leadName = (lead.leadName ?? '').trim();
    final fallbackTitle = [lead.firstName, lead.lastName].where((value) => (value ?? '').trim().isNotEmpty).join(' ').trim();
    final title = leadName.isNotEmpty ? leadName : fallbackTitle;
    final leadStatus = lead.leadStatus ?? '';

    return Container(
      color: const Color(0xFFFFFFFF),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          spacing: 8,
                          children: [
                            Flexible(child: AppText(label: title.isEmpty ? '-' : title, fontSize: 17)),
                            if (leadStatus.toLowerCase() != "closed") LeadStatusCapsule(leadStatusName: leadStatus),
                            if (leadStatus.toLowerCase() == "closed" && lead.closeLostReason == null) LeadStatusCapsule(leadStatusName: "ClosedWon"),
                            if (leadStatus.toLowerCase() == "closed" && lead.closeLostReason != null) LeadStatusCapsule(leadStatusName: "ClosedLost"),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if ((lead.companyName ?? '').isNotEmpty) _InfoRow(icon: Icons.business_center_outlined, label: lead.companyName ?? ''),
                        if ((lead.ownerName ?? '').isNotEmpty) _InfoRow(icon: Icons.person_outline, label: lead.ownerName ?? ''),
                        if (lead.closeProbability != null) _InfoRow(icon: Icons.percent, label: '${lead.closeProbability}%'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade300),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, indent: 16, color: Color(0xFFEFEFEF)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Icon(icon, color: Colors.grey.shade600, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AppText(label: label, fontSize: 14, textColor: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
