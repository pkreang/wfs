import 'package:flutter/material.dart';
import 'package:wfs/widgets/capsule_widget.dart';

class ClientLevelCapsule extends StatelessWidget {
  final String clientLevelName;

  const ClientLevelCapsule({required this.clientLevelName, super.key});

  @override
  Widget build(BuildContext context) {
    final capsuleStyle = clientLevelName == "" ? CapsuleStyle(Color(0xFFFFFFFF), Color(0xFFFFFFFF)) : CapsuleStyle(Color(0xFF0689FF), Color.fromRGBO(47, 128, 237, 0.2));

    return CapsuleWidget(label: clientLevelName, capsuleStyle: capsuleStyle);
  }
}
