import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wfs/features/phase3/lead_workflow/models/lead_workflow_stage_model.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';

class Phase3LeadStageSelector {
  static Future<LeadWorkflowStageModel?> show({
    required BuildContext context,
    required List<LeadWorkflowStageModel> stages,
    required int currentStageId,
  }) {
    return showCupertinoModalPopup<LeadWorkflowStageModel>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: const Text('Change Stage', textScaler: TextScaler.noScaling),
          actions: stages.map((stage) {
            final isCurrent = stage.id == currentStageId;
            return CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(stage),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText(
                    label: stage.displayName,
                    textColor: isCurrent
                        ? AppUtility.colorPrimary
                        : Colors.black,
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                  ),
                  if (isCurrent)
                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(
                        Icons.check,
                        color: AppUtility.colorPrimary,
                        size: 18,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const AppText(
              label: 'Cancel',
              textColor: AppUtility.textGray,
            ),
          ),
        );
      },
    );
  }
}
