import 'package:flutter/material.dart';
import 'package:wfs/widgets/capsule_widget.dart';

class ClientStatusCapsule extends StatelessWidget {
  final String clientStatusName;

  const ClientStatusCapsule({required this.clientStatusName, super.key});

  @override
  Widget build(BuildContext context) {
    const capsuleStyles = <String, CapsuleStyle>{
      'Scheduled': CapsuleStyle(Color.fromRGBO(255, 153, 26, 0.72), Color.fromRGBO(255, 153, 26, 0.2)),
      'Postpone': CapsuleStyle(Color.fromRGBO(27, 31, 38, 0.72), Color.fromRGBO(142, 142, 147, 0.2)),
      'Canceled': CapsuleStyle(Color.fromRGBO(255, 106, 84, 0.72), Color.fromRGBO(255, 106, 84, 0.2)),
      'Completed': CapsuleStyle(Color(0xFF219653), Color.fromRGBO(36, 151, 86, 0.2)),
    };

    if (capsuleStyles[clientStatusName] == null) return SizedBox.shrink();
    final capsuleStyle = capsuleStyles[clientStatusName] ?? CapsuleStyle(Color(0xFFFFFFFF), Color(0xFFFFFFFF));

    return CapsuleWidget(label: clientStatusName, capsuleStyle: capsuleStyle);
  }
}
