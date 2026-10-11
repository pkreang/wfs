import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/lead/models/lead.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/utility/appdialogs.dart';
import 'package:wfs/widgets/app_text.dart';
import 'package:wfs/widgets/app_text_form_field.dart';

Future<bool> showDealValueDialog({required BuildContext context, required WidgetRef ref, required String leadID, DealValue? initial, isRefresh = true}) async {
  final detailProvider = leadDetailProvider(leadID);
  var hasAddedDealValue = false;
  String? dealValueValidationError;

  final result = await showCupertinoDialog<bool>(
    context: context,
    builder: (dialogContext) => Consumer(
      builder: (context, dialogRef, _) {
        final state = dialogRef.watch(detailProvider);
        final dealValues = state.lead.value?.dealValues ?? const <DealValue>[];

        return StatefulBuilder(
          builder: (context, setState) => CupertinoAlertDialog(
            title: const Text('Deal Value', textScaler: TextScaler.noScaling),
            content: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(11)),
                  child: Column(
                    children: [
                      for (var index = 0; index < dealValues.length; index++) ...[
                        Container(
                          alignment: Alignment.centerLeft,
                          height: 38,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: AppText(label: '${dealValues[index].detail} - ${dealValues[index].saleAmount}', textColor: AppUtility.colorPrimary),
                              ),
                              // GestureDetector(
                              //   onTap: () async {
                              //     final shouldRemove = await _showRemoveDealValueDialog(context);
                              //     if (!shouldRemove) return;

                              //     // final isRemoved = await dialogRef.read(detailProvider.notifier).removeDealValues(dealValues[index].dealValueItemID ?? '');
                              //     if (!context.mounted) return;
                              //     if (!isRemoved) {
                              //       final errorMessage = dialogRef.read(detailProvider).errorMessage;
                              //       AppDialogs.alert(context, title: 'ไม่สามารถดำเนินการได้', message: errorMessage ?? 'Request failed');
                              //     }
                              //   },
                              //   child: const Icon(Icons.remove_circle, color: Color(0xFFFF382B), size: 20),
                              // ),
                            ],
                          ),
                        ),
                        if (index < dealValues.length - 1) const Divider(height: 0, thickness: 0.33, color: Color(0xFFC7C7CC)),
                      ],
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            final dealValue = await _showDealValueFormDialog(context: context, initial: initial);
                            if (dealValue == null) return;

                            final isSaved = await dialogRef.read(detailProvider.notifier).addDealValues(dealValue, isRefresh);
                            if (!context.mounted) return;
                            if (!isSaved) {
                              final errorMessage = dialogRef.read(detailProvider).errorMessage;
                              AppDialogs.alert(context, title: 'ไม่สามารถดำเนินการได้', message: errorMessage ?? 'Request failed');
                              return;
                            }

                            hasAddedDealValue = true;
                            if (dealValueValidationError != null) {
                              setState(() => dealValueValidationError = null);
                            }
                            dialogRef.invalidate(detailProvider);
                          },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 8,
                            children: [
                              Icon(Icons.add_circle, color: Color(0xFF31C859), size: 24),
                              AppText(label: 'Add Deal Value'),
                            ],
                          ),
                        ),
                      ),
                      if (dealValueValidationError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          dealValueValidationError!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                          textScaler: TextScaler.noScaling,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const AppText(label: 'Cancel', textColor: AppUtility.textGray),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  if (dealValues.isEmpty && !hasAddedDealValue) {
                    setState(() => dealValueValidationError = 'กรุณาเพิ่ม Deal Value อย่างน้อย 1 รายการ');
                    return;
                  }

                  Navigator.of(dialogContext).pop(true);
                },
                child: const AppText(label: 'Close Won', textColor: AppUtility.colorPrimary),
              ),
            ],
          ),
        );
      },
    ),
  );

  return result ?? false;
}

Future<DealValue?> _showDealValueFormDialog({required BuildContext context, DealValue? initial}) async {
  final detailController = TextEditingController(text: initial?.detail);
  final saleAmountController = TextEditingController(text: initial?.saleAmount?.toString() ?? '');
  String? validationError;

  final result = await showCupertinoDialog<DealValue>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => CupertinoAlertDialog(
        title: const Text('Deal Value', textScaler: TextScaler.noScaling),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Material(
              color: Colors.transparent,
              child: AppTextFormField(
                controller: detailController,
                hintText: 'ตำแหน่ง',
                isShowBorder: true,
                onChanged: (_) {
                  if (validationError != null) {
                    setState(() => validationError = null);
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            Material(
              color: Colors.transparent,
              child: AppTextFormField(
                controller: saleAmountController,
                hintText: 'ราคา',
                isShowBorder: true,
                isNumberOnly: true,
                allowDecimal: true,
                onChanged: (_) {
                  if (validationError != null) {
                    setState(() => validationError = null);
                  }
                },
              ),
            ),
            if ((validationError ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                validationError!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
                textScaler: TextScaler.noScaling,
              ),
            ],
          ],
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const AppText(label: 'Cancel', textColor: AppUtility.textGray),
          ),
          CupertinoDialogAction(
            onPressed: () {
              final detail = detailController.text.trim();
              final saleAmountText = saleAmountController.text.trim();
              if (detail.isEmpty) {
                setState(() => validationError = 'กรุณากรอกตำแหน่ง');
                return;
              }
              if (saleAmountText.isEmpty) {
                setState(() => validationError = 'กรุณากรอกราคา');
                return;
              }

              Navigator.of(dialogContext).pop(DealValue(detail: detail, saleAmount: num.tryParse(saleAmountText)));
            },
            child: const AppText(label: 'Save', textColor: AppUtility.colorPrimary),
          ),
        ],
      ),
    ),
  );

  await Future<void>.delayed(const Duration(milliseconds: 300));
  detailController.dispose();
  saleAmountController.dispose();
  return result;
}
