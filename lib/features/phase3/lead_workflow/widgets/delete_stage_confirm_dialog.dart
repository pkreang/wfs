import 'package:flutter/cupertino.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';

class DeleteStageConfirmDialog {
  static Future<bool> show({
    required BuildContext context,
    required String stageName,
  }) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: const Text(
            'Delete custom stage',
            textScaler: TextScaler.noScaling,
          ),
          content: Text(
            'Delete "$stageName" from this workflow?',
            textScaler: TextScaler.noScaling,
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: AppText(label: 'Cancel', textColor: AppUtility.textGray),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: AppText(label: 'Delete', textColor: AppUtility.colorRed),
            ),
          ],
        );
      },
    );

    return result == true;
  }
}
