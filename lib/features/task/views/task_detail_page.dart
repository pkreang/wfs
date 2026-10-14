import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/models/address.dart';
import 'package:wfs/features/client/models/client.dart';
import 'package:wfs/features/task/models/task.dart';
import 'package:wfs/features/task/views/task_edit_page.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/utility/appdialogs.dart';
import 'package:wfs/widgets/app_action_tile.dart';
import 'package:wfs/widgets/app_detail_section_card.dart';
import 'package:wfs/widgets/app_text.dart';

class TaskDetailPage extends ConsumerWidget {
  final String taskID;

  const TaskDetailPage({required this.taskID, super.key});

  Future<void> _callPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> onDelete(BuildContext context, WidgetRef ref) async {
    await showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('Delete Task', textScaler: TextScaler.noScaling),
          content: const Text('Are you sure you want to delete this task?', textScaler: TextScaler.noScaling),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: AppText(label: 'Cancel', textColor: AppUtility.textGray),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final result = await ref.read(taskDetailProvider(taskID).notifier).deleteTask();
                if (!context.mounted) return;

                if (!result) {
                  final errMsg = ref.read(taskDetailProvider(taskID)).errorMessage;
                  AppDialogs.alert(context, title: 'ไม่สามารถดำเนินการได้', message: errMsg ?? 'Request failed');
                  return;
                }

                AppDialogs.success(context, title: "SUCCESS", message: "Data saved successfully", btnOkOnPress: () => Navigator.pop(context));
              },
              child: const AppText(label: 'Delete', textColor: AppUtility.colorRed),
            ),
          ],
        );
      },
    );
  }

  Future<void> showCompleteConfirmDialog({required BuildContext context, required WidgetRef ref, required String taskID}) async {
    return showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: const Text("Complete Task", textScaler: TextScaler.noScaling),
          content: const Text("Are you sure you want to complete this task?", textScaler: TextScaler.noScaling),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const AppText(label: 'Cancel', textColor: Color(0xFF007BFE)),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => confirmCompleteTask(context: dialogContext, ref: ref, taskID: taskID),
              child: const AppText(label: 'Complete', textColor: Color(0xFF007BFE)),
            ),
          ],
        );
      },
    );
  }

  Future<void> confirmCompleteTask({required BuildContext context, required WidgetRef ref, required String taskID}) async {
    Navigator.pop(context);

    if (taskID.isEmpty) {
      return;
    }

    await ref.read(taskDetailProvider(taskID).notifier).updateTaskStatus(appointmentStatusID: "C9B78060-8F8C-46FA-92A6-65D932701EB7​");
  }

  Future<void> showCancelConfirmDialog({required BuildContext context, required WidgetRef ref, required String taskID}) async {
    return showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: const Text("Cancel Task", textScaler: TextScaler.noScaling),
          content: const Text("Are you sure you want to cancel this task?", textScaler: TextScaler.noScaling),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const AppText(label: 'Cancel', textColor: Color(0xFF007BFE)),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => confirmCancelTask(context: dialogContext, ref: ref, taskID: taskID),
              child: const AppText(label: 'Comfirm', textColor: Color(0xFF007BFE)),
            ),
          ],
        );
      },
    );
  }

  Future<void> confirmCancelTask({required BuildContext context, required WidgetRef ref, required String taskID}) async {
    Navigator.pop(context);

    if (taskID.isEmpty) {
      return;
    }

    await ref.read(taskDetailProvider(taskID).notifier).updateTaskStatus(appointmentStatusID: "16CBDB62-30BB-4679-A1ED-CB935E11B7E2​");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(taskDetailProvider(taskID));
    final notifier = ref.read(taskDetailProvider(taskID).notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFEEEEEE),
        leading: IconButton(icon: const Icon(Icons.chevron_left), color: AppUtility.colorPrimary, tooltip: 'Back', onPressed: () => Navigator.pop(context)),
        title: const AppText(label: 'Task Info', fontSize: 17, fontWeight: FontWeight.w600),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => TaskEditPage(taskID: taskID))),
            child: AppText(label: 'Edit', textColor: AppUtility.colorPrimary),
          ),
        ],
      ),
      body: Stack(
        children: [
          state.task.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary)),
            error: (_, _) => _TaskNotFound(onRetry: notifier.fetch),
            data: (task) => RefreshIndicator(
              color: AppUtility.colorPrimary,
              onRefresh: notifier.fetch,
              child: _TaskDetailContent(
                task: task,
                onCall: _callPhone,
                onEmail: _sendEmail,
                onDelete: () => onDelete(context, ref),
                onComplete: () => showCompleteConfirmDialog(context: context, ref: ref, taskID: task.taskID ?? taskID),
                onCancel: () => showCancelConfirmDialog(context: context, ref: ref, taskID: task.taskID ?? taskID),
              ),
            ),
          ),
          if (state.isLoading) ...[const ModalBarrier(color: Color(0x66000000), dismissible: false), const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary))],
        ],
      ),
    );
  }
}

class _TaskDetailContent extends ConsumerWidget {
  final Task task;
  final Future<void> Function(String phone) onCall;
  final Future<void> Function(String email) onEmail;
  final Future<void> Function() onDelete;
  final Future<void> Function() onComplete;
  final Future<void> Function() onCancel;

  const _TaskDetailContent({required this.task, required this.onCall, required this.onEmail, required this.onDelete, required this.onComplete, required this.onCancel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startDate = task.appointmentDateTimeFrom ?? task.scheduledStartDate;
    final endDate = task.appointmentDateTimeTo ?? task.scheduledEndDate;
    final hasPhone = task.phone?.trim().isNotEmpty ?? false;
    final hasEmail = task.email?.trim().isNotEmpty ?? false;
    final hasPurposeName = task.purposeName?.trim().isNotEmpty ?? false;
    final hasPurposeOther = task.purposeOther?.trim().isNotEmpty ?? false;
    final taskType = task.appointmentType?.appointmentTypeName ?? '';
    final isCompleted = task.appointmentStatusID == "C9B78060-8F8C-46FA-92A6-65D932701EB7";
    final isCancel = task.appointmentStatusID == "16CBDB62-30BB-4679-A1ED-CB935E11B7E2";
    final status = isCompleted
        ? "Completed"
        : isCancel
        ? "Canceled"
        : "Scheduled";
    final List<Client> clients = ref.watch(clientForLeadProvider).maybeWhen(data: (items) => items, orElse: () => const <Client>[]);
    final client = clients.where((client) => task.clientID?.isNotEmpty == true && client.clientID == task.clientID).firstOrNull;
    final clientName = client == null ? task.clientName ?? '' : '${client.firstName ?? ''} ${client.lastName ?? ''}'.trim();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              AppText(label: task.title.isEmpty ? 'Task' : task.title, fontSize: 26, fontWeight: FontWeight.w600, textAlign: TextAlign.center, maxLines: null),
              const SizedBox(height: 8),
              _TaskStatusChip(label: status),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              if (hasPhone) AppActionTile(icon: Icons.phone_outlined, title: 'call', onTap: () => onCall(task.phone!)),
              if (hasEmail) AppActionTile(icon: Icons.mail_outline, title: 'mail', onTap: () => onEmail(task.email!)),
              if (!isCompleted && !isCancel) ...[
                AppActionTile(icon: Icons.check_circle, title: 'complete', onTap: onComplete),
                AppActionTile(icon: Icons.warning_rounded, iconColor: AppUtility.colorRed, textColor: AppUtility.colorRed, title: 'cancel', onTap: onCancel),
              ],
            ],
          ),
          const SizedBox(height: 16),
          AppDetailSectionCard(
            title: 'Client',
            descWidget: AppText(label: clientName, maxLines: null),
            fullWidth: true,
          ),
          const SizedBox(height: 16),
          AppDetailSectionCard(
            title: 'Type',
            descWidget: AppText(label: taskType),
            fullWidth: true,
          ),
          if (hasPurposeName || hasPurposeOther) ...[
            const SizedBox(height: 16),
            AppDetailSectionCard(
              title: 'purpose',
              descWidget: AppText(label: hasPurposeName ? task.purposeName! : task.purposeOther!, maxLines: null),
              fullWidth: true,
            ),
          ],
          if (task.details?.trim().isNotEmpty ?? false) ...[
            const SizedBox(height: 16),
            AppDetailSectionCard(
              title: 'Details',
              descWidget: AppText(label: task.details!, maxLines: null),
              fullWidth: true,
            ),
          ],
          const SizedBox(height: 16),
          AppDetailSectionCard(
            title: 'time',
            descWidget: AppText(label: '${DateFormat('HH:mm').format(startDate.toLocal())} - ${DateFormat('HH:mm').format(endDate.toLocal())}'),
          ),
          // _ScheduleCard(startDate: startDate, endDate: endDate),
          if (task.cancelNoted?.trim().isNotEmpty ?? false) ...[
            const SizedBox(height: 16),
            AppDetailSectionCard(
              title: 'cancel note',
              descWidget: AppText(label: task.cancelNoted!, maxLines: null),
              fullWidth: true,
            ),
          ],
          const SizedBox(height: 16),
          AppDetailSectionCard(
            title: 'Address',
            descWidget: AppText(label: task.taskAddress?.fullAddress ?? '', maxLines: 2),
            fullWidth: true,
          ),
          const SizedBox(height: 16),
          AppDetailSectionCard(
            title: 'Mobile',
            descWidget: AppText(label: task.phone ?? ''),
            fullWidth: true,
          ),
          const SizedBox(height: 16),
          AppDetailSectionCard(
            title: 'Email',
            descWidget: AppText(label: task.email ?? ''),
            fullWidth: true,
          ),
          const SizedBox(height: 16),
          AppDetailSectionCard(
            title: 'Company',
            descWidget: AppText(label: task.companyName ?? ''),
            fullWidth: true,
          ),
          if (task.saleName?.isNotEmpty ?? false) ...[
            const SizedBox(height: 16),
            AppDetailSectionCard(
              title: 'salesperson',
              descWidget: AppText(label: task.saleName!),
              fullWidth: true,
            ),
          ],
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11)),
              alignment: Alignment.center,
              child: const AppText(label: 'Delete Task', textColor: AppUtility.colorRed, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final DateTime startDate;
  final DateTime? endDate;

  const _ScheduleCard({required this.startDate, this.endDate});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd/MM/yyyy').format(startDate.toLocal());
    final startTime = DateFormat('HH:mm').format(startDate.toLocal());
    final endTime = endDate == null ? null : DateFormat('HH:mm').format(endDate!.toLocal());

    return AppDetailSectionCard(
      title: 'scheduled time',
      fullWidth: true,
      descWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(label: date, fontSize: 16, fontWeight: FontWeight.w600),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(Icons.schedule_outlined, size: 16, color: AppUtility.colorPrimary),
              const SizedBox(width: 6),
              AppText(label: endTime == null ? startTime : '$startTime - $endTime', textColor: AppUtility.colorPrimary),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskNotFound extends StatelessWidget {
  final VoidCallback onRetry;

  const _TaskNotFound({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppText(label: 'Task Not Found', textColor: Colors.red),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            child: const AppText(label: 'Try again', textColor: AppUtility.colorPrimary),
          ),
        ],
      ),
    );
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
