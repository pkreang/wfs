import 'package:flutter/material.dart';
import 'package:wfs/widgets/capsule_widget.dart';

class LeadStatusCapsule extends StatelessWidget {
  final String leadStatusName;

  const LeadStatusCapsule({required this.leadStatusName, super.key});

  @override
  Widget build(BuildContext context) {
    const capsuleStyles = <String, CapsuleStyle>{
      // 'New': CapsuleStyle(Color(0xFF0689FF), Color.fromRGBO(47, 128, 237, 0.2)),
      // 'Contacted': CapsuleStyle(Color(0xFF9B51E0), Color.fromRGBO(155, 81, 224, 0.18)),
      // 'Qualified': CapsuleStyle(Color(0xFF219653), Color.fromRGBO(36, 151, 86, 0.2)),
      // 'qualified': CapsuleStyle(Color(0xFF219653), Color.fromRGBO(36, 151, 86, 0.2)),
      // 'Qualify': CapsuleStyle(Color(0xFF219653), Color.fromRGBO(36, 151, 86, 0.2)),
      // 'Unqualified': CapsuleStyle(Color(0xFFFF382B), Color.fromRGBO(255, 56, 43, 0.16)),
      // 'UnQualified': CapsuleStyle(Color(0xFFFF382B), Color.fromRGBO(255, 56, 43, 0.16)),
      // 'UnQualify': CapsuleStyle(Color(0xFFFF382B), Color.fromRGBO(255, 56, 43, 0.16)),
      // 'Converted': CapsuleStyle(Color(0xFF0F766E), Color.fromRGBO(15, 118, 110, 0.18)),
      // 'Prospecting': CapsuleStyle(Color(0xFF0689FF), Color.fromRGBO(47, 128, 237, 0.2)),
      // 'Qualification': CapsuleStyle(Color(0xFF9B51E0), Color.fromRGBO(155, 81, 224, 0.18)),
      // 'Proposal': CapsuleStyle(Color.fromRGBO(255, 153, 26, 0.72), Color.fromRGBO(255, 153, 26, 0.2)),
      // 'proposal': CapsuleStyle(Color.fromRGBO(255, 153, 26, 0.72), Color.fromRGBO(255, 153, 26, 0.2)),
      // 'Closed': CapsuleStyle(Color(0xFF219653), Color.fromRGBO(36, 151, 86, 0.2)),
      // 'closed': CapsuleStyle(Color(0xFF219653), Color.fromRGBO(36, 151, 86, 0.2)),
      'Closed': CapsuleStyle(Color(0xFFFF382B), Color.fromRGBO(255, 56, 43, 0.16)),
      'ClosedWon': CapsuleStyle(Color(0xFF219653), Color.fromRGBO(36, 151, 86, 0.2)),
      'ClosedLost': CapsuleStyle(Color(0xFFFF382B), Color.fromRGBO(255, 56, 43, 0.16)),
    };

    final capsuleStyle = capsuleStyles[leadStatusName] ?? CapsuleStyle(Color(0xFF0689FF), Color.fromRGBO(47, 128, 237, 0.2));
    return CapsuleWidget(label: leadStatusName, capsuleStyle: capsuleStyle);
  }
}
