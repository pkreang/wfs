import 'package:flutter/material.dart';

class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    super.key,
    this.hint,
    this.controller,
    this.onChanged,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.enabled = true,
    this.autovalidateMode,
    this.textStyle,
  });

  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;
  final bool enabled;
  final AutovalidateMode? autovalidateMode;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      enabled: enabled,
      autovalidateMode: autovalidateMode,
      cursorColor: const Color(0xFF007AFF),
      decoration: const InputDecoration(
        isDense: true,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
      ),
      style: textStyle ?? const TextStyle(fontSize: 14, height: 22 / 14),
    );
  }
}
