import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wfs/features/appointment/widgets/appointment_status_capsule.dart';
import 'package:wfs/features/appointment/widgets/appointment_type_capsule.dart';
import 'package:wfs/features/task/models/task.dart';
import 'package:wfs/features/task/views/task_detail_page.dart';
import 'package:wfs/providers/auth_provider.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';
import 'package:wfs/widgets/capsule_widget.dart';

class TaskInfo extends ConsumerWidget {
  final Task task;
  final VoidCallback onTap;

  const TaskInfo({required this.task, required this.onTap, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeFormat = DateFormat('HH:mm');
    final appointmentDateTimeFrom = timeFormat.format((task.appointmentDateTimeFrom ?? task.scheduledStartDate).toLocal());
    final appointmentDateTimeTo = task.appointmentDateTimeTo == null ? null : timeFormat.format(task.appointmentDateTimeTo!.toLocal());
    final clientAndCompany = [task.clientName, task.companyName].whereType<String>().where((value) => value.isNotEmpty).join(' • ');
    final taskType = task.appointmentTypeName ?? task.taskType.label;
    final status = task.appointmentStatusName ?? '';
    final taskIcon = _iconForLabel(task.iconLabel);

    final authState = ref.watch(authProvider);

    double height = 127;
    if (authState.isSupervisor) {
      height = 155;
    }

    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => TaskDetailPage(taskID: task.taskID ?? ''))),
      child: Container(
        // height: 152,
        height: height,
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
                  Row(
                    spacing: 8,
                    children: [
                      if (taskIcon != null) Icon(taskIcon, size: 18, color: AppUtility.colorPrimary),
                      CapsuleWidget(label: 'Task', capsuleStyle: CapsuleStyle(Color.fromRGBO(144, 112, 213, 0.718), Color.fromRGBO(177, 78, 238, 0.2))),
                      Expanded(child: AppText(label: task.clientName ?? '', fontSize: 17)),
                    ],
                  ),
                  Row(
                    spacing: 6,
                    children: [
                      Row(
                        spacing: 4,
                        children: [
                          Icon(Icons.access_time_outlined, color: AppUtility.textGray, size: 18),
                          AppText(label: appointmentDateTimeTo == null ? appointmentDateTimeFrom : '$appointmentDateTimeFrom - $appointmentDateTimeTo', fontSize: 14, textColor: AppUtility.textLight),
                        ],
                      ),
                      Expanded(
                        child: Row(
                          spacing: 6,
                          children: [
                            AppointmentTypeCapsule(appointmentTypeName: task.appointmentTypeName ?? ''),
                            AppointmentStatusCapsule(appointmentStatusName: task.appointmentStatusName ?? ''),
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
                        child: AppText(label: task.companyName ?? '', fontSize: 14, textColor: AppUtility.textLight),
                      ),
                    ],
                  ),
                  if (authState.isSupervisor)
                    Row(
                      spacing: 4,
                      children: [
                        Icon(Icons.people_alt_rounded, color: AppUtility.textGray, size: 18),
                        Expanded(
                          child: AppText(label: task.saleName ?? '', fontSize: 14, textColor: AppUtility.textLight),
                        ),
                      ],
                    ),
                  Row(
                    spacing: 4,
                    children: [
                      Icon(Icons.access_time_outlined, color: AppUtility.textGray, size: 12),
                      if (task.appointmentDateTimeFrom != null)
                        Expanded(
                          child: AppText(label: DateFormat('dd/MM/yyyy').format(task.appointmentDateTimeFrom!), fontSize: 12, textColor: AppUtility.textLight),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // SizedBox(
            //   width: 100,
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     crossAxisAlignment: CrossAxisAlignment.end,
            //     children: [
            //       isShowCancelButton
            //           ? GestureDetector(
            //               onTap: () => showCancelAppointmentDialog(context: context, ref: ref, appointmentID: appointment.appointmentID ?? '', currentDate: currentDate),
            //               child: Icon(Icons.delete_outline, color: AppUtility.colorGray, size: 24),
            //             )
            //           : const SizedBox.shrink(),
            //       // Icon(Icons.chevron_right, color: AppUtility.colorGray, size: 24),
            //       isShowCompleteButton
            //           ? GestureDetector(
            //               onTap: () => showCompleteConfirmDialog(context: context, ref: ref, currentDate: currentDate, appointmentID: appointment.appointmentID ?? ''),
            //               child: Container(
            //                 padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 14),
            //                 decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12)),
            //                 height: 24,
            //                 child: AppText(label: 'Complete', fontSize: 14, textColor: Colors.blue, lineHeight: 16),
            //               ),
            //             )
            //           : const SizedBox.shrink(),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );

    // return Container(
    //   decoration: const BoxDecoration(border: Border(bottom: AppUtility.borderSide)),
    //   child: Stack(
    //     children: [
    //       ListTile(
    //         title: Row(
    //           spacing: 8,
    //           children: [
    //             if (taskIcon != null) Icon(taskIcon, size: 18, color: AppUtility.colorPrimary),
    //             CapsuleWidget(label: 'Task', capsuleStyle: CapsuleStyle(Color.fromRGBO(255, 153, 26, 0.72), Color.fromRGBO(255, 153, 26, 0.2))),
    //             Expanded(
    //               child: AppText(label: task.title, fontWeight: FontWeight.w500, overflow: TextOverflow.ellipsis),
    //             ),
    //           ],
    //         ),
    //         subtitle: Padding(
    //           padding: const EdgeInsets.only(top: 4),
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               if (clientAndCompany.isNotEmpty) AppText(label: clientAndCompany, fontSize: 12, textColor: AppUtility.textGray),
    //               AppText(label: taskType, fontSize: 12, textColor: AppUtility.textGray),
    //               AppText(label: appointmentDateTimeTo == null ? appointmentDateTimeFrom : '$appointmentDateTimeFrom - $appointmentDateTimeTo', fontSize: 12, textColor: AppUtility.textGray),
    //             ],
    //           ),
    //         ),
    //         trailing: _TaskStatusChip(label: status),
    //         onTap: onTap,
    //       ),
    //       const Positioned(
    //         right: 16,
    //         bottom: 12,
    //         child: IgnorePointer(child: Icon(Icons.chevron_right, size: 20, color: AppUtility.colorGray)),
    //       ),
    //     ],
    //   ),
    // );
  }

  IconData? _iconForLabel(String? label) {
    switch (label?.trim().toLowerCase()) {
      case 'location_on':
        return Icons.location_on;
      case 'phone':
        return Icons.phone;
      case 'email':
        return Icons.email;
      case 'calendar_today':
        return Icons.calendar_today;
      case 'videocam':
        return Icons.videocam;
      default:
        return null;
    }
  }
}

class _TaskStatusChip extends StatelessWidget {
  final String label;

  const _TaskStatusChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final (textColor, backgroundColor) = switch (label.trim().toLowerCase()) {
      'scheduled' => (const Color.fromRGBO(255, 153, 26, 0.72), const Color.fromRGBO(255, 153, 26, 0.2)),
      'completed' => (const Color(0xFF219653), const Color.fromRGBO(36, 151, 86, 0.2)),
      'cancel' || 'canceled' || 'cancelled' => (const Color.fromRGBO(255, 106, 84, 0.72), const Color.fromRGBO(255, 106, 84, 0.2)),
      _ => (AppUtility.colorPrimary, AppUtility.colorPrimary.withValues(alpha: 0.12)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(999)),
      child: AppText(label: label, fontSize: 11, textColor: textColor, fontWeight: FontWeight.w500),
    );
  }
}
