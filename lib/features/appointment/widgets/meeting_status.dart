import 'package:flutter/material.dart';
import 'package:wfs/features/appointment/widgets/capsule_widget.dart';

class MeetingStatus extends StatelessWidget {
  final String meetingStatusName;

  const MeetingStatus({required this.meetingStatusName, super.key});

  @override
  Widget build(BuildContext context) {
    const capsuleStyles = <String, CapsuleStyle>{
      'Online': CapsuleStyle(Color(0xFF0689FF), Color.fromRGBO(47, 128, 237, 0.2)),
      'Visit': CapsuleStyle(Color(0xFF0689FF), Color.fromRGBO(47, 128, 237, 0.2)),
      'On Call': CapsuleStyle(Color(0xFF0689FF), Color.fromRGBO(47, 128, 237, 0.2)),
    };

    final capsuleStyle = capsuleStyles[meetingStatusName] ?? CapsuleStyle(Color(0xFFEEEEEE), Color(0xFFEEEEEE));

    return CapsuleWidget(label: meetingStatusName, capsuleStyle: capsuleStyle);
  }
}
