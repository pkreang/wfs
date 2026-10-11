import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wfs/features/appointment/widgets/app_datepicker.dart';
import 'package:wfs/features/survey/models/survey_recipient_filter.dart';
import 'package:wfs/widgets/app_filter_sheet.dart';
import 'package:wfs/widgets/app_text.dart';

Future<SurveyRecipientFilter?> showFilterSheet({required BuildContext context, required SurveyRecipientFilter initialFilter}) async {
  FocusScope.of(context).unfocus();
  var responStatus = initialFilter.responStatus;
  var type = initialFilter.type;
  var sendDateFrom = initialFilter.sendDateFrom;
  var sendDateTo = initialFilter.sendDateTo;
  SurveyRecipientFilter? appliedFilter;
  late StateSetter updateDraft;

  await AppFilterSheet.show<void>(
    context: context,
    child: StatefulBuilder(
      builder: (context, setDraftState) {
        updateDraft = setDraftState;

        Widget buildChip({required String label, required bool selected, required VoidCallback onTap}) {
          return GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: selected ? const Color(0xFF0689FF) : Colors.grey.shade400, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: AppText(label: label, fontSize: 14, textColor: selected ? const Color(0xFF0689FF) : Colors.grey),
            ),
          );
        }

        Widget buildDateField({required String label, required DateTime? date, required ValueChanged<DateTime> onSelected}) {
          return GestureDetector(
            onTap: () => showDialog<DateTime>(
              context: context,
              builder: (pickerContext) => Dialog(
                child: AppDatePicker(
                  appointmentMarkDate: const {},
                  currentMonth: date ?? sendDateFrom ?? sendDateTo ?? DateTime.now(),
                  selectedDate: date,
                  onConfirm: (selectedDate) => setDraftState(() => onSelected(selectedDate)),
                  onClose: () => Navigator.of(pickerContext).pop(),
                ),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AppText(label: label, fontSize: 14, textColor: Colors.grey),
                  // const SizedBox(height: 4),
                  AppText(label: date == null ? label : DateFormat('dd/MM/yyyy').format(date), fontSize: 14, textColor: date == null ? Colors.grey : Colors.black),
                ],
              ),
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            buildDateField(
              label: 'เลือกวันที่เริ่มต้น',
              date: sendDateFrom,
              onSelected: (date) {
                sendDateFrom = date;
                if (sendDateTo != null && date.isAfter(sendDateTo!)) {
                  sendDateTo = date;
                }
              },
            ),
            buildDateField(
              label: 'เลือกวันที่สิ้นสุด',
              date: sendDateTo,
              onSelected: (date) {
                sendDateTo = date;
                if (sendDateFrom != null && date.isBefore(sendDateFrom!)) {
                  sendDateFrom = date;
                }
              },
            ),
            Wrap(
              spacing: 8,
              children: [
                for (final status in ['Pending', 'Responded'])
                  buildChip(label: status, selected: responStatus == status, onTap: () => setDraftState(() => responStatus = responStatus == status ? null : status)),
              ],
            ),
          ],
        );
      },
    ),
    onClear: () => updateDraft(() {
      responStatus = null;
      type = null;
      sendDateFrom = null;
      sendDateTo = null;
    }),
    onSearch: () => appliedFilter = (responStatus: responStatus, type: type, sendDateFrom: sendDateFrom, sendDateTo: sendDateTo),
  );

  return appliedFilter;
}
