import 'package:flutter/material.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';

class Phase3LeadEmptyState extends StatelessWidget {
  const Phase3LeadEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: AppText(label: 'No leads found.', textColor: AppUtility.textGray),
    );
  }
}
