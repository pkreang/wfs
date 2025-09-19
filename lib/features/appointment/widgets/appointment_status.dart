import 'package:flutter/material.dart';
import 'package:wfs/widgets/capsule_widget.dart';

class AppointmentStatus extends StatelessWidget {
  final String appointmentStatusName;

  const AppointmentStatus({required this.appointmentStatusName, super.key});

  @override
  Widget build(BuildContext context) {
    const capsuleStyles = <String, CapsuleStyle>{
      'Scheduled': CapsuleStyle(Color.fromRGBO(255, 153, 26, 0.72), Color.fromRGBO(255, 153, 26, 0.2)),
      'Postpone': CapsuleStyle(Color.fromRGBO(27, 31, 38, 0.72), Color.fromRGBO(142, 142, 147, 0.2)),
      'Canceled': CapsuleStyle(Color.fromRGBO(255, 106, 84, 0.72), Color.fromRGBO(255, 106, 84, 0.2)),
      'Completed': CapsuleStyle(Color(0xFF219653), Color.fromRGBO(36, 151, 86, 0.2)),
    };

    final capsuleStyle = capsuleStyles[appointmentStatusName] ?? CapsuleStyle(Color(0xFFEEEEEE), Color(0xFFEEEEEE));
    return CapsuleWidget(label: appointmentStatusName, capsuleStyle: capsuleStyle);
  }
}
