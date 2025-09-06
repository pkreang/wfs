import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';

Future<TimeOfDay?> showCupertinoTimeDialog(BuildContext context, {required String initial}) async {
  final dateTime = DateTime.tryParse(initial) ?? DateTime.now();
  TimeOfDay selected = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);

  return showCupertinoModalPopup<TimeOfDay>(
    context: context,
    builder: (ctx) {
      return SafeArea(
        top: false,
        child: Container(
          color: CupertinoColors.systemBackground.resolveFrom(ctx),
          height: 260,
          child: Column(
            children: [
              _CupertinoDialogHeader(onCancel: () => Navigator.of(ctx).pop(null), onDone: () => Navigator.of(ctx).pop(selected)),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: DateTime(0, 1, 1, selected.hour, selected.minute),
                  onDateTimeChanged: (dt) => selected = TimeOfDay(hour: dt.hour, minute: dt.minute),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _CupertinoDialogHeader extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onDone;

  const _CupertinoDialogHeader({required this.onCancel, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: CupertinoColors.separator, width: 0.0)), color: CupertinoColors.systemGrey6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CupertinoButton(padding: EdgeInsets.zero, onPressed: onCancel, child: AppText(label: 'Cancel')),
          CupertinoButton(padding: EdgeInsets.zero, onPressed: onDone, child: AppText(label: 'Done', textColor: Color(0xFF007AFF))),
        ],
      ),
    );
  }
}
