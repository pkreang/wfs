import 'package:flutter/material.dart';

class AppTextFormField extends StatelessWidget {
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool isValidate;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool enabled;
  final AutovalidateMode? autovalidateMode;
  final TextStyle? textStyle;
  final isDisabled;

  const AppTextFormField({
    super.key,
    this.focusNode,
    this.controller,
    this.onChanged,
    this.isValidate = false,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
    this.autovalidateMode,
    this.textStyle,
    this.isDisabled = false,
  });

  OutlineInputBorder _border(Color color) => OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: color, width: 1));

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: isDisabled ? AlwaysDisabledFocusNode() : focusNode,
      controller: controller,
      onChanged: isDisabled ? null : onChanged,
      validator: isValidate ? (v) => (v == null || v.trim().isEmpty) ? '' : null : null,
      maxLines: maxLines,
      enabled: enabled,
      autovalidateMode: autovalidateMode,
      cursorColor: const Color(0xFF007AFF),
      decoration: InputDecoration(
        isDense: true,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: _border(Colors.red),
        focusedErrorBorder: _border(Colors.red),
        disabledBorder: InputBorder.none,
      ),
      style: textStyle ?? const TextStyle(fontSize: 14, height: 22 / 14),
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
