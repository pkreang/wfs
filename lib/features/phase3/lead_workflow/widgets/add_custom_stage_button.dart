import 'package:flutter/material.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';

class AddCustomStageButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddCustomStageButton({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add, size: 18),
      label: const AppText(label: 'Add Workflow', textColor: AppUtility.colorPrimary),
      style: TextButton.styleFrom(
        foregroundColor: AppUtility.colorPrimary,
        backgroundColor: const Color(0xFFE3F2FD),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
