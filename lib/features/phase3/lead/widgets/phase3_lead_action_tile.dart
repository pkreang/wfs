import 'package:flutter/material.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';

class Phase3LeadActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Color color;

  const Phase3LeadActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color = AppUtility.colorPrimary,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(11)),
          child: Row(
            children: [
              Icon(
                icon,
                color: onTap == null ? AppUtility.textGray : color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppText(
                  label: title,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  textColor: onTap == null ? AppUtility.textGray : Colors.black,
                  lineHeight: 18,
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppUtility.colorGray,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
