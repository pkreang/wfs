import 'package:flutter/material.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';

class AppDetailSectionCard extends StatelessWidget {
  final String title;
  final Widget descWidget;
  final bool fullWidth;

  const AppDetailSectionCard({required this.title, required this.descWidget, this.fullWidth = false, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(11)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(label: title, fontSize: 12),
          descWidget,
        ],
      ),
    );
  }
}
