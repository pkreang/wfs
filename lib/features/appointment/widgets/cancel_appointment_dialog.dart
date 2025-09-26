import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/providers/appointment_provider.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/utility/validator.dart';
import 'package:wfs/widgets/app_text_form_field.dart';

Future<bool> showCancelAppointmentDialog({required BuildContext context, required WidgetRef ref, required String appointmentID, required DateTime currentDate}) async {
  if (appointmentID.isEmpty) return false;

  var noteValue = '';
  var completed = false;
  String? validationError;

  await showCupertinoDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) => CupertinoAlertDialog(
          title: const Text("Cancel Appointment", textScaler: TextScaler.noScaling),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("Are you sure you want to cancel this appointment?", textScaler: TextScaler.noScaling),
              const SizedBox(height: 12),
              Material(
                color: Colors.transparent,
                child: AppTextFormField(
                  controller: null,
                  hintText: 'Canceled note',
                  isShowBorder: true,
                  onChanged: (v) {
                    noteValue = v;
                    if (validationError != null) setState(() => validationError = null);
                  },
                ),
              ),
              if ((validationError ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'กรุณากรอก canceled note',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                  textScaler: TextScaler.noScaling,
                ),
              ],
            ],
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: AppText(label: 'Cancel', textColor: AppUtility.textGray),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () async {
                final note = noteValue.trim();
                if (Validator.required(note) != null) {
                  setState(() => validationError = 'required');
                  return;
                }

                try {
                  await ref
                      .read(appointmentProvider.notifier)
                      .updateAppointmentStatus(
                        appointmentID: appointmentID,
                        appointmentStatusID: "16CBDB62-30BB-4679-A1ED-CB935E11B7E2",
                        cancelNoted: note,
                        onSuccess: () {
                          final now = DateTime.now();
                          final bool isSameDate = currentDate.year == now.year && currentDate.month == now.month && currentDate.day == now.day;

                          if (isSameDate) {
                            ref.invalidate(appointmentsProvider(DateTime(currentDate.year, currentDate.month, currentDate.day)));
                            ref.invalidate(appointmentSummaryProvider(DateTime(currentDate.year, currentDate.month, currentDate.day)));
                          }

                          ref.read(selectedMonthProvider.notifier).setMonth(currentDate);
                          ref.read(selectedDateProvider.notifier).setDate(currentDate);

                          ref.read(appointmentMarkDateProvider(DateTime(currentDate.year, currentDate.month, 1)).notifier).refresh();
                          ref.read(appointmentsByDateProvider(DateFormat("yyyy-MM-dd").format(currentDate)).notifier).refresh();
                        },
                      );
                  completed = true;
                } finally {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: AppText(label: 'Confirm', textColor: AppUtility.colorRed),
            ),
          ],
        ),
      );
    },
  );

  return completed;
}
