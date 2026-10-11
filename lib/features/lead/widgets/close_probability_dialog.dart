import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';
import 'package:wfs/widgets/app_text_form_field.dart';

Future<int?> showCloseProbabilityDialog({required BuildContext context, int? initialCloseProbability}) async {
  final closeProbabilityController = TextEditingController(text: initialCloseProbability?.toString() ?? '');
  String? validationError;

  final result = await showCupertinoDialog<int>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => CupertinoAlertDialog(
        title: const Text('Close Probability', textScaler: TextScaler.noScaling),
        content: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(child: AppText(label: closeProbabilityController.text)),
                // AppTextFormField(
                //   controller: closeProbabilityController,
                //   isDisabled: true,
                //   isShowBorder: true,
                //   isNumberOnly: true,
                //   inputFormatters: _closeProbabilityInputFormatters,
                //   textAlignVertical: TextAlignVertical.center,
                //   contentPadding: EdgeInsets.zero,
                //   suffixIcon: Padding(
                //     padding: const EdgeInsets.only(right: 8),
                //     child: Center(
                //       widthFactor: 1,
                //       child: AppText(label: '%', textColor: AppUtility.textGray),
                //     ),
                //   ),
                //   onChanged: (_) {
                //     if (validationError != null) {
                //       setState(() => validationError = null);
                //     }
                //   },
                // ),
                if (validationError != null) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'กรุณากรอก Close Probability เป็น 100',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                    textScaler: TextScaler.noScaling,
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const AppText(label: 'Cancel', textColor: AppUtility.textGray),
          ),
          CupertinoDialogAction(
            onPressed: () {
              final closeProbability = int.tryParse(closeProbabilityController.text);
              if (closeProbability != 100) {
                setState(() => validationError = 'invalid');
                return;
              }

              Navigator.of(dialogContext).pop(closeProbability);
            },
            child: const AppText(label: 'Save', textColor: AppUtility.colorPrimary),
          ),
        ],
      ),
    ),
  );

  await Future<void>.delayed(const Duration(milliseconds: 300));
  closeProbabilityController.dispose();
  return result;
}

final List<TextInputFormatter> _closeProbabilityInputFormatters = [
  FilteringTextInputFormatter.digitsOnly,
  TextInputFormatter.withFunction((oldValue, newValue) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    if (text.length > 1 && text.startsWith('0')) return oldValue;

    final probability = int.tryParse(text);
    if (probability == null || probability > 100) return oldValue;

    return newValue;
  }),
];
