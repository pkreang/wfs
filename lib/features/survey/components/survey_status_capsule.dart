import 'package:flutter/material.dart';
import 'package:wfs/widgets/capsule_widget.dart';

class SurveyStatusCapsule extends StatelessWidget {
  final String isActive;

  const SurveyStatusCapsule({required this.isActive, super.key});

  @override
  Widget build(BuildContext context) {
    const capsuleStyles = <String, CapsuleStyle>{
      'Active': CapsuleStyle(Color(0xFF2F80ED), Color.fromRGBO(47, 128, 237, 0.2)),
      'inactive': CapsuleStyle(Color.fromRGBO(255, 106, 84, 0.72), Color.fromRGBO(255, 106, 84, 0.2)),
    };

    final capsuleStyle = capsuleStyles[isActive] ?? CapsuleStyle(Color(0xFFEEEEEE), Color(0xFFFFFFFF));

    return CapsuleWidget(label: isActive, capsuleStyle: capsuleStyle);
  }
}
