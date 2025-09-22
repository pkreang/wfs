import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wfs/core/utils/date_picker_helper.dart';
import 'package:wfs/core/utils/time_picker_helper.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/widgets/form_info_tile.dart';

class FormDatetimePicker extends StatelessWidget {
  final String label;
  final DateTime datetime;
  final bool isDateOnly;
  final bool isShowBorderBottom;
  final ValueChanged<DateTime>? onDateSelected;
  final ValueChanged<TimeOfDay>? onTimeSelected;

  const FormDatetimePicker({required this.label, required this.datetime, this.isDateOnly = false, this.isShowBorderBottom = false, this.onDateSelected, this.onTimeSelected, super.key});

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void openDatePicker({required BuildContext context, required String datetime, required Function(DateTime) onSelected, String? limitFirstDate}) async {
    final picked = await DatePickerHelper.pickDate(context, initialDate: DateTime.parse(datetime), limitFirstDate: limitFirstDate == null ? null : DateTime.parse(limitFirstDate));
    if (picked != null) onSelected(picked);
  }

  void openTimePicker({required BuildContext context, required String datetime, required Function(TimeOfDay) onSelected, String? limitFirstDate}) async {
    final picked = await showCupertinoTimeDialog(initial: datetime, context);

    if (picked != null) {
      if (limitFirstDate != null) {
        final current = DateTime.parse(datetime);
        final limit = DateTime.parse(limitFirstDate);
        final limitTime = TimeOfDay(hour: limit.hour, minute: limit.minute);

        if (isSameDay(limit, current) && picked.isBefore(limitTime)) {
          // if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: AppText(label: 'Please select a time after the appointment start time.', textColor: Colors.white, maxLines: 2),
            ),
          );
          return;
        }
      }

      onSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = DateFormat("MMM d, yyyy").format(datetime);
    final time = DateFormat("h:mm a").format(datetime);

    return FormInfoTile(
      label: label,
      value: Container(
        margin: const EdgeInsets.only(right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: 4,
          children: [
            datetimeField(
              value: date,
              onTap: () => openDatePicker(context: context, datetime: datetime.toIso8601String(), onSelected: (value) => onDateSelected?.call(value)),
            ),

            if (!isDateOnly)
              datetimeField(
                value: time,
                onTap: () => openTimePicker(context: context, datetime: datetime.toIso8601String(), onSelected: (value) => onTimeSelected?.call(value)),
              ),
          ],
        ),
      ),
      isShowBorderMiddle: false,
      isShowBorderBottom: isShowBorderBottom,
      isHideIcon: true,
    );
  }

  Widget datetimeField({required String value, VoidCallback? onTap}) {
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
