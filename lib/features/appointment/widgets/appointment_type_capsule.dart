import 'package:flutter/material.dart';
import 'package:wfs/widgets/capsule_widget.dart';

class AppointmentTypeCapsule extends StatelessWidget {
  final String appointmentTypeName;

  const AppointmentTypeCapsule({required this.appointmentTypeName, super.key});

  @override
  Widget build(BuildContext context) {
    const capsuleStyles = <String, CapsuleStyle>{
      'Online': CapsuleStyle(Color(0xFF2F80ED), Color.fromRGBO(47, 128, 237, 0.2)),
      'Visit': CapsuleStyle(Color(0xFF2F80ED), Color.fromRGBO(47, 128, 237, 0.2)),
      'On Call': CapsuleStyle(Color(0xFF2F80ED), Color.fromRGBO(47, 128, 237, 0.2)),
    };

    final capsuleStyle = capsuleStyles[appointmentTypeName] ?? CapsuleStyle(Color(0xFFEEEEEE), Color(0xFFFFFFFF));

    return CapsuleWidget(label: appointmentTypeName, capsuleStyle: capsuleStyle);
  }
}
