import 'package:flutter/material.dart';
import 'package:wfs/widgets/capsule_widget.dart';

class ClientLevelCapsule extends StatelessWidget {
  final String clientLevelName;

  const ClientLevelCapsule({required this.clientLevelName, super.key});

  @override
  Widget build(BuildContext context) {
    const capsuleStyles = <String, CapsuleStyle>{
      'Online': CapsuleStyle(Color(0xFF2F80ED), Color.fromRGBO(47, 128, 237, 0.2)),
      'Visit': CapsuleStyle(Color(0xFF2F80ED), Color.fromRGBO(47, 128, 237, 0.2)),
      'On Call': CapsuleStyle(Color(0xFF2F80ED), Color.fromRGBO(47, 128, 237, 0.2)),
    };

    if (capsuleStyles[clientLevelName] == null) return SizedBox.shrink();
    final capsuleStyle = capsuleStyles[clientLevelName] ?? CapsuleStyle(Color(0xFFFFFFFF), Color(0xFFFFFFFF));

    return CapsuleWidget(label: clientLevelName, capsuleStyle: capsuleStyle);
  }
}
