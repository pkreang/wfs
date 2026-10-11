import 'package:flutter/material.dart';

class AppMultilineText extends StatelessWidget {
  final String label;

  const AppMultilineText({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    final text = label
        .replaceAll(r'\r\n', '\n')
        .replaceAll(r'\n', '\n')
        .replaceAll(r'\r', '\n');

    return DefaultTextStyle(
      style: const TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 22 / 14,
        decoration: TextDecoration.none,
      ),
      softWrap: true,
      overflow: TextOverflow.visible,
      child: Text(
        text,
        textAlign: TextAlign.left,
        textScaler: TextScaler.noScaling,
      ),
    );
  }
}
