import 'package:flutter/material.dart';
import 'package:wfs/widgets/capsule_widget.dart';

class AppointmentType extends StatelessWidget {
  final String appointmentTypeName;

  const AppointmentType({required this.appointmentTypeName, super.key});

  @override
  Widget build(BuildContext context) {
    return CapsuleWidget(label: appointmentTypeName, capsuleStyle: CapsuleStyle(Color(0xFF2F80ED), Color.fromRGBO(47, 128, 237, 0.2)));
  }
}
