import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/models/appointment.dart';
import 'package:wfs/features/appointment/views/appointment_detail_page.dart';
import 'package:wfs/features/appointment/widgets/appointment_status_capsule.dart';
import 'package:wfs/features/appointment/widgets/appointment_type_capsule.dart';
import 'package:wfs/features/appointment/widgets/cancel_appointment_dialog.dart';
import 'package:wfs/providers/appointment_provider.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';

class AppointmentInfo extends ConsumerWidget {
  final Appointment appointment;
  final DateTime currentDate;

  const AppointmentInfo({required this.appointment, required this.currentDate, super.key});

  Future<void> showCompleteConfirmDialog({required BuildContext context, required WidgetRef ref, required DateTime currentDate, required String appointmentID}) async {
    return showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: const Text("Complete Appointment", textScaler: TextScaler.noScaling),
          content: const Text("Are you sure you want to complete this appointment?", textScaler: TextScaler.noScaling),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: AppText(label: 'Cancel', textColor: Color(0xFF007BFE)),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => confirmCompleteAppointment(context: dialogContext, ref: ref, currentDate: currentDate, appointmentID: appointmentID),
              child: AppText(label: 'Complete', textColor: Color(0xFF007BFE)),
            ),
          ],
        );
      },
    );
  }

  void confirmCompleteAppointment({required BuildContext context, required WidgetRef ref, required DateTime currentDate, required String appointmentID}) async {
    Navigator.pop(context);

    if (appointmentID.isEmpty) {
      return;
    }

    await ref
        .read(appointmentProvider.notifier)
        .updateAppointmentStatus(
          appointmentID: appointmentID,
          appointmentStatusID: "C9B78060-8F8C-46FA-92A6-65D932701EB7",
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
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isShowCompleteButton = false;
    bool isShowCancelButton = false;

    bool isOnline = appointment.appointmentTypeName == "Online";
    bool isOnCall = appointment.appointmentTypeName == "On Call";
    if (isOnline || isOnCall) isShowCompleteButton = true;

    bool isCancel = appointment.appointmentStatusName == "Canceled";
    bool isComplete = appointment.appointmentStatusName == "Completed";

    if (isComplete || isCancel) isShowCompleteButton = false;
    if (!isComplete && !isCancel) isShowCancelButton = true;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => AppointmentDetailPage(appointmentID: appointment.appointmentID ?? ''))),
      child: Container(
        // height: 152,
        height: 97,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(border: Border(bottom: AppUtility.borderSide)),
        child: Row(
          // crossAxisAlignment: CrossAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [
                  Expanded(child: AppText(label: appointment.clientName ?? '', fontSize: 17)),
                  Row(
                    spacing: 6,
                    children: [
                      Row(
                        spacing: 4,
                        children: [
                          Icon(Icons.access_time_outlined, color: AppUtility.textGray, size: 18),
                          AppText(label: '${appointment.appointmentTimeFrom}-${appointment.appointmentTimeTo.toString()}', fontSize: 14, textColor: AppUtility.textLight),
                        ],
                      ),
                      Expanded(
                        child: Row(
                          spacing: 6,
                          children: [
                            AppointmentTypeCapsule(appointmentTypeName: appointment.appointmentTypeName ?? ''),
                            AppointmentStatusCapsule(appointmentStatusName: appointment.appointmentStatusName ?? ''),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 4,
                    children: [
                      Icon(Icons.business_center_outlined, color: AppUtility.textGray, size: 18),
                      Expanded(
                        child: AppText(label: appointment.companyName ?? '', fontSize: 14, textColor: AppUtility.textLight),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  isShowCancelButton
                      ? GestureDetector(
                          onTap: () => showCancelAppointmentDialog(context: context, ref: ref, appointmentID: appointment.appointmentID ?? '', currentDate: currentDate),
                          child: Icon(Icons.delete_outline, color: AppUtility.colorGray, size: 24),
                        )
                      : const SizedBox.shrink(),
                  // Icon(Icons.chevron_right, color: AppUtility.colorGray, size: 24),
                  isShowCompleteButton
                      ? GestureDetector(
                          onTap: () => showCompleteConfirmDialog(context: context, ref: ref, currentDate: currentDate, appointmentID: appointment.appointmentID ?? ''),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 14),
                            decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12)),
                            height: 24,
                            child: AppText(label: 'Complete', fontSize: 14, textColor: Colors.blue, lineHeight: 16),
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
