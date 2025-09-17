import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/utility/appdialogs.dart';
import 'package:wfs/utility/validator.dart';
import 'package:wfs/widgets/app_text_form_field.dart';

Future<bool> showCancelAppointmentDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String appointmentID,
  required DateTime currentDate,
  // String canceledStatusID = "16CBDB62-30BB-4679-A1ED-CB935E11B7E2",
  // String title = 'Cancel Appointment',
  // String noteLabel = 'Canceled note',
  // String confirmText = 'Confirm',
  // String closeText = 'Close',
  // String? initialNote,
}) async {
  if (appointmentID.isEmpty) return false;

  final completer = Completer<bool>();
  final TextEditingController notedController = TextEditingController();

  void handleConfirm() async {
    if (Validator.required(notedController.text) != null) {
      AppDialogs.error(context, message: "กรุณากรอก canceled note");
      return;
    }

    Navigator.pop(context);

    try {
      final result = await ref
          .read(appointmentProvider.notifier)
          .updateAppointmentStatus(
            appointmentID: appointmentID,
            appointmentStatusID: "16CBDB62-30BB-4679-A1ED-CB935E11B7E2",
            onSuccess: () {
              // ref.invalidate(appointmentMarkDateProvider(currentDate));
              // ref.invalidate(appointmentsByDateProvider(DateFormat("yyyy-MM-dd").format(currentDate)));

              ref.read(appointmentMarkDateProvider(DateTime(currentDate.year, currentDate.month, 1)).notifier).refresh();
              ref.read(appointmentsByDateProvider(DateFormat("yyyy-MM-dd").format(currentDate)).notifier).refresh();
            },
            cancelNoted: notedController.text,
          );

      if (!completer.isCompleted) completer.complete(result);
    } catch (_) {
      if (!completer.isCompleted) completer.complete(false);
    } finally {
      notedController.dispose();
    }
  }

  Widget dialogCancelAppointment() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(label: 'Cancel Appointment', fontSize: 17, fontWeight: FontWeight.bold),
          const SizedBox(height: 24),
          AppText(label: 'canceled note'),
          const SizedBox(height: 4),
          AppTextFormField(controller: notedController, hintText: 'canceled note', isShowBorder: true),
          const SizedBox(height: 24),
          Row(
            spacing: 24,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    decoration: BoxDecoration(color: AppUtility.colorRed, borderRadius: BorderRadius.circular(12)),
                    child: AppText(label: 'Cancel', fontSize: 14, fontWeight: FontWeight.bold, textColor: Colors.white),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => handleConfirm(),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    decoration: BoxDecoration(color: AppUtility.colorRed, borderRadius: BorderRadius.circular(12)),
                    child: AppText(label: 'Confirm', fontSize: 14, fontWeight: FontWeight.bold, textColor: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  AppDialogs.custom(context, widget: dialogCancelAppointment());

  return completer.future;
}
