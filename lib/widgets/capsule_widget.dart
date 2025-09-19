import 'package:flutter/material.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';

class CapsuleStyle {
  final Color textColor, bgColor;
  const CapsuleStyle(this.textColor, this.bgColor);
}

class CapsuleWidget extends StatelessWidget {
  final String label;
  final CapsuleStyle capsuleStyle;

  const CapsuleWidget({required this.label, required this.capsuleStyle, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 14),
      decoration: BoxDecoration(color: capsuleStyle.bgColor, borderRadius: BorderRadius.circular(18)),
      height: 24,
      child: AppText(label: label, textColor: capsuleStyle.textColor, fontSize: 12, fontWeight: FontWeight.w500, lineHeight: 16),
    );
  }
}
