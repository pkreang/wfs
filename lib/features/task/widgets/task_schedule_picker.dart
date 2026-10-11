import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wfs/core/utils/date_picker_helper.dart';
import 'package:wfs/widgets/app_text.dart';
import 'package:wfs/widgets/form_info_tile.dart';

class TaskSchedulePicker extends StatelessWidget {
  final String label;
  final DateTime datetime;
  final bool isShowBorderBottom;
  final bool preventPast;
  final ValueChanged<DateTime>? onChanged;

  const TaskSchedulePicker({
    required this.label,
    required this.datetime,
    this.isShowBorderBottom = false,
    this.preventPast = true,
    this.onChanged,
    super.key,
  });

  Future<void> _openDatePicker(BuildContext context) async {
    final safeInitialDate = preventPast ? _clampToNow(datetime) : datetime;
    final picked = await DatePickerHelper.pickDate(
      context,
      initialDate: safeInitialDate,
      limitFirstDate: preventPast ? DateTime.now() : null,
    );
    if (picked == null) return;

    final nextDateTime = DateTime(
      picked.year,
      picked.month,
      picked.day,
      datetime.hour,
      datetime.minute,
    );
    onChanged?.call(preventPast ? _clampToNow(nextDateTime) : nextDateTime);
  }

  Future<void> _openTimePicker(BuildContext context) async {
    final picked = await _showTaskTimeDialog(context);
    if (picked == null) return;

    final nextDateTime = DateTime(
      datetime.year,
      datetime.month,
      datetime.day,
      picked.hour,
      picked.minute,
    );
    onChanged?.call(preventPast ? _clampToNow(nextDateTime) : nextDateTime);
  }

  Future<TimeOfDay?> _showTaskTimeDialog(BuildContext context) async {
    final initialDateTime = preventPast ? _clampToNow(datetime) : datetime;
    TimeOfDay selected = TimeOfDay(
      hour: initialDateTime.hour,
      minute: initialDateTime.minute,
    );
    final minimumDate =
        preventPast && DateUtils.isSameDay(initialDateTime, DateTime.now())
        ? _clampToNow(DateTime.now())
        : null;

    return showCupertinoModalPopup<TimeOfDay>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Container(
            height: 260,
            color: CupertinoColors.systemBackground.resolveFrom(ctx),
            child: Column(
              children: [
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: CupertinoColors.separator,
                        width: 0,
                      ),
                    ),
                    color: CupertinoColors.systemGrey6,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(ctx).pop(null),
                        child: AppText(label: 'Cancel'),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          final selectedDateTime = DateTime(
                            datetime.year,
                            datetime.month,
                            datetime.day,
                            selected.hour,
                            selected.minute,
                          );
                          final safeDateTime = preventPast
                              ? _clampToNow(selectedDateTime)
                              : selectedDateTime;
                          Navigator.of(ctx).pop(
                            TimeOfDay(
                              hour: safeDateTime.hour,
                              minute: safeDateTime.minute,
                            ),
                          );
                        },
                        child: AppText(
                          label: 'Done',
                          textColor: Color(0xFF007AFF),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    use24hFormat: true,
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: initialDateTime,
                    minimumDate: minimumDate,
                    minuteInterval: 1,
                    onDateTimeChanged: (value) {
                      selected = TimeOfDay(
                        hour: value.hour,
                        minute: value.minute,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  DateTime _clampToNow(DateTime value) {
    final now = DateTime.now();
    final minDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );
    final valueDateTime = DateTime(
      value.year,
      value.month,
      value.day,
      value.hour,
      value.minute,
    );

    return valueDateTime.isBefore(minDateTime) ? minDateTime : valueDateTime;
  }

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('MMM d, yyyy').format(datetime);
    final timeText = DateFormat('HH:mm').format(datetime);

    return FormInfoTile(
      label: label,
      value: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: 4,
          children: [
            _datetimeField(
              value: dateText,
              onTap: () => _openDatePicker(context),
            ),
            _datetimeField(
              value: timeText,
              onTap: () => _openTimePicker(context),
            ),
          ],
        ),
      ),
      isShowBorderMiddle: false,
      isShowBorderBottom: isShowBorderBottom,
      isHideIcon: true,
    );
  }

  Widget _datetimeField({required String value, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: IntrinsicWidth(
        child: Container(
          height: 35,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color.fromRGBO(118, 118, 128, 0.12),
            borderRadius: BorderRadius.all(Radius.circular(7)),
          ),
          child: AppText(label: value, fontSize: 17),
        ),
      ),
    );
  }
}
