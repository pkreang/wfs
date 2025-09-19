import 'package:flutter/material.dart';
import 'package:wfs/widgets/capsule_widget.dart';

class ClientStatus extends StatelessWidget {
  final String clientStatusName;

  const ClientStatus({required this.clientStatusName, super.key});

  @override
  Widget build(BuildContext context) {
    const capsuleStyles = <String, CapsuleStyle>{
      'Active': CapsuleStyle(Color(0xFF219653), Color.fromRGBO(36, 151, 86, 0.2)),
      'Inactive': CapsuleStyle(Color.fromRGBO(27, 31, 38, 0.72), Color.fromRGBO(142, 142, 147, 0.2)),
      'Lead': CapsuleStyle(Color.fromRGBO(255, 153, 26, 0.72), Color.fromRGBO(255, 153, 26, 0.2)),
    };

    final capsuleStyle = capsuleStyles[clientStatusName] ?? CapsuleStyle(Color(0xFFEEEEEE), Color(0xFFEEEEEE));
    return CapsuleWidget(label: clientStatusName, capsuleStyle: capsuleStyle);
  }
}
