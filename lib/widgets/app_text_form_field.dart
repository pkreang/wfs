import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wfs/widgets/app_text.dart';

class AppTextFormField extends StatelessWidget {
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool isValidate;
  final String? Function(String?)? validator;
  final String? requiredMessage;
  final int maxLines;
  final bool enabled;
  final AutovalidateMode? autovalidateMode;
  final TextStyle? textStyle;
  final bool isDisabled;
  final String? hintText;
  final bool isShowBorder;
  final bool isNumberOnly;
  final bool allowDecimal;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextAlignVertical? textAlignVertical;
  final EdgeInsetsGeometry? contentPadding;
  final ValueChanged<String>? onFieldSubmitted;
  final List<TextInputFormatter>? inputFormatters;

  const AppTextFormField({
    super.key,
    this.focusNode,
    this.controller,
    this.onChanged,
    this.isValidate = false,
    this.validator,
    this.requiredMessage,
    this.maxLines = 1,
    this.enabled = true,
    this.autovalidateMode,
    this.textStyle,
    this.isDisabled = false,
    this.hintText,
    this.isShowBorder = false,
    this.isNumberOnly = false,
    this.allowDecimal = false,
    this.obscureText = false,
    this.suffixIcon,
    this.textAlignVertical,
    this.contentPadding,
    this.onFieldSubmitted,
    this.inputFormatters,
  });

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: color, width: 1),
  );

  @override
  Widget build(BuildContext context) {
    String? Function(String?)? effectiveValidator;
    if (validator != null || isValidate) {
      effectiveValidator = (v) {
        if (isDisabled) return null;
        if (validator != null) return validator!(v);

        if (isValidate) {
          if (v == null || v.trim().isEmpty) {
            return requiredMessage ?? '';
          }
        }

        return null;
      };
    }

    return TextFormField(
      focusNode: isDisabled ? AlwaysDisabledFocusNode() : focusNode,
      controller: controller,
      onChanged: isDisabled ? null : onChanged,
      onFieldSubmitted: onFieldSubmitted,
      textAlignVertical: textAlignVertical,
      obscureText: obscureText,
      validator: effectiveValidator,
      maxLines: maxLines,
      enabled: enabled,
      autovalidateMode: autovalidateMode,
      keyboardType: isNumberOnly ? (allowDecimal ? const TextInputType.numberWithOptions(decimal: true, signed: false) : TextInputType.number) : TextInputType.text,
      inputFormatters: inputFormatters ?? (isNumberOnly ? [allowDecimal ? _SingleDotDecimalTextInputFormatter() : FilteringTextInputFormatter.digitsOnly] : null),
      cursorColor: const Color(0xFF007AFF),
      decoration: InputDecoration(
        hint: AppText(label: hintText ?? '', textColor: Colors.grey.shade400),
        isDense: true,
        suffixIcon: suffixIcon,
        contentPadding: contentPadding,
        border: isShowBorder ? _border(Colors.grey.shade400) : InputBorder.none,
        enabledBorder: isShowBorder ? _border(Colors.grey.shade400) : InputBorder.none,
        focusedBorder: isShowBorder ? _border(Colors.grey.shade400) : InputBorder.none,
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

class _SingleDotDecimalTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    if (!RegExp(r'^[0-9.]*$').hasMatch(text)) {
      return oldValue;
    }
    if ('.'.allMatches(text).length > 1) {
      return oldValue;
    }
    return newValue;
  }
}
