import 'package:flutter/cupertino.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';

Future<bool> showCloseWonDialog({required BuildContext context}) async {
  final confirmed = await showCupertinoDialog<bool>(
    context: context,
    builder: (dialogContext) => CupertinoAlertDialog(
      title: const Text(
        'Are you sure you want to close won?',
        textScaler: TextScaler.noScaling,
      ),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const AppText(label: 'Cancel', textColor: AppUtility.textGray),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const AppText(
            label: 'Confirm',
            textColor: AppUtility.colorRed,
          ),
        ),
      ],
    ),
  );

  return confirmed ?? false;
}
