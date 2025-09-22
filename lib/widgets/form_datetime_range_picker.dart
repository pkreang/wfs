import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wfs/core/utils/date_picker_helper.dart';
import 'package:wfs/core/utils/time_picker_helper.dart';
import 'package:wfs/widgets/form_info_tile.dart';
import 'package:wfs/widgets/app_text.dart';

class FormDatetimeRangePicker extends StatelessWidget {
  final DateTime start;
  final DateTime end;
  final String startLabel;
  final String endLabel;
  final bool isDateOnly;
  final bool isTimeOnly;
  final bool isShowBorderBottom;

  final ValueChanged<DateTime>? onStartDateSelected;
  final ValueChanged<TimeOfDay>? onStartTimeSelected;
  final ValueChanged<DateTime>? onEndDateSelected;
  final ValueChanged<TimeOfDay>? onEndTimeSelected;

  static const Duration _minGap = Duration(minutes: 30);

  const FormDatetimeRangePicker({
    super.key,
    required this.start,
    required this.end,
    this.startLabel = 'Starts',
    this.endLabel = 'Ends',
    this.isDateOnly = false,
    this.isTimeOnly = false,
    this.isShowBorderBottom = false,
    this.onStartDateSelected,
    this.onStartTimeSelected,
    this.onEndDateSelected,
    this.onEndTimeSelected,
  }) : assert(!(isDateOnly && isTimeOnly), 'isDateOnly and isTimeOnly cannot both be true.');

  bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime _withTime(DateTime d, TimeOfDay t) => DateTime(d.year, d.month, d.day, t.hour, t.minute, d.second, d.millisecond, d.microsecond);

  DateTime? _bumpIfNeeded({required DateTime candidateStart, required DateTime currentEnd}) {
    if (!currentEnd.isAfter(candidateStart)) {
      return candidateStart.add(_minGap);
    }
    return null;
  }

  void _applyEnd(DateTime newEnd) {
    onEndDateSelected?.call(newEnd);
    onEndTimeSelected?.call(TimeOfDay(hour: newEnd.hour, minute: newEnd.minute));
  }

  Future<void> _openStartDatePicker(BuildContext context) async {
    final picked = await DatePickerHelper.pickDate(context, initialDate: start, limitFirstDate: null);
    if (picked == null) return;

    onStartDateSelected?.call(picked);

    DateTime adjustedEnd = end;
    if (DateTime(end.year, end.month, end.day).isBefore(DateTime(picked.year, picked.month, picked.day))) {
      adjustedEnd = DateTime(picked.year, picked.month, picked.day, end.hour, end.minute);
      onEndDateSelected?.call(adjustedEnd);
    }

    final candidateStart = DateTime(picked.year, picked.month, picked.day, start.hour, start.minute);
    if (isSameDay(candidateStart, adjustedEnd)) {
      final bumped = _bumpIfNeeded(candidateStart: candidateStart, currentEnd: adjustedEnd);
      if (bumped != null) _applyEnd(bumped);
    }
  }

  Future<void> _openStartTimePicker(BuildContext context) async {
    final picked = await showCupertinoTimeDialog(initial: start.toIso8601String(), context);
    if (picked == null) return;

    onStartTimeSelected?.call(picked);

    final candidateStart = _withTime(start, picked);

    if (isSameDay(candidateStart, end)) {
      final bumped = _bumpIfNeeded(candidateStart: candidateStart, currentEnd: end);
      if (bumped != null) _applyEnd(bumped);
    }
  }

  Future<void> _openEndDatePicker(BuildContext context) async {
    final picked = await DatePickerHelper.pickDate(context, initialDate: end, limitFirstDate: start);
    if (picked == null) return;

    DateTime fixedEndDate = picked;
    if (DateTime(picked.year, picked.month, picked.day).isBefore(DateTime(start.year, start.month, start.day))) {
      fixedEndDate = DateTime(start.year, start.month, start.day);
    }

    final tentativeEnd = DateTime(fixedEndDate.year, fixedEndDate.month, fixedEndDate.day, end.hour, end.minute);
    onEndDateSelected?.call(tentativeEnd);

    final candidateStart = DateTime(start.year, start.month, start.day, start.hour, start.minute);
    if (isSameDay(candidateStart, tentativeEnd)) {
      final bumped = _bumpIfNeeded(candidateStart: candidateStart, currentEnd: tentativeEnd);
      if (bumped != null) _applyEnd(bumped);
    }
  }

  Future<void> _openEndTimePicker(BuildContext context) async {
    final picked = await showCupertinoTimeDialog(initial: end.toIso8601String(), context);
    if (picked == null) return;

    final tentativeEnd = _withTime(end, picked);

    final candidateStart = DateTime(start.year, start.month, start.day, start.hour, start.minute);
    if (isSameDay(candidateStart, tentativeEnd)) {
      final bumped = _bumpIfNeeded(candidateStart: candidateStart, currentEnd: tentativeEnd);
      if (bumped != null) {
        _applyEnd(bumped);
        return;
      }
    }

    onEndTimeSelected?.call(picked);
  }

  @override
  Widget build(BuildContext context) {
    final startDateStr = DateFormat("MMM d, yyyy").format(start);
    final startTimeStr = DateFormat("HH:mm").format(start);
    final endDateStr = DateFormat("MMM d, yyyy").format(end);
    final endTimeStr = DateFormat("HH:mm").format(end);

    return Column(
      children: [
        FormInfoTile(
          label: startLabel,
          value: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 4,
              children: [
                if (!isTimeOnly) _datetimeField(value: startDateStr, onTap: () => _openStartDatePicker(context)),
                if (!isDateOnly) _datetimeField(value: startTimeStr, onTap: () => _openStartTimePicker(context)),
              ],
            ),
          ),
          isShowBorderMiddle: false,
          isShowBorderBottom: false,
          isHideIcon: true,
        ),
        FormInfoTile(
          label: endLabel,
          value: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 4,
              children: [
                if (!isTimeOnly) _datetimeField(value: endDateStr, onTap: () => _openEndDatePicker(context)),
                if (!isDateOnly) _datetimeField(value: endTimeStr, onTap: () => _openEndTimePicker(context)),
              ],
            ),
          ),
          isShowBorderMiddle: false,
          isShowBorderBottom: isShowBorderBottom,
          isHideIcon: true,
        ),
      ],
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
          decoration: const BoxDecoration(color: Color.fromRGBO(118, 118, 128, 0.12), borderRadius: BorderRadius.all(Radius.circular(7))),
          child: AppText(label: value, fontSize: 17),
        ),
      ),
    );
  }
}
