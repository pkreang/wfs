import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/models/address.dart';
import 'package:wfs/features/appointment/models/purpose.dart';
import 'package:wfs/features/client/models/client.dart';
import 'package:wfs/features/company/models/company.dart';
import 'package:wfs/features/task/models/task.dart' hide AppointmentType;
import 'package:wfs/features/task/models/task_appointment_type.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/utility/appdialogs.dart';
import 'package:wfs/utility/validator.dart';
import 'package:wfs/widgets/app_sheet.dart';
import 'package:wfs/widgets/app_text.dart';
import 'package:wfs/widgets/app_text_form_field.dart';
import 'package:wfs/widgets/form_address.dart';
import 'package:wfs/widgets/form_company_with_data_tile.dart';
import 'package:wfs/widgets/form_datetime_range_picker.dart';
import 'package:wfs/widgets/form_info_tile.dart';

class TaskEditPage extends ConsumerStatefulWidget {
  final String taskID;

  const TaskEditPage({required this.taskID, super.key});

  @override
  ConsumerState<TaskEditPage> createState() => _TaskEditPageState();
}

class _TaskEditPageState extends ConsumerState<TaskEditPage> {
  final titleController = TextEditingController();
  final detailsController = TextEditingController();
  final purposeOtherController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  bool _didBind = false;

  @override
  void dispose() {
    titleController.dispose();
    detailsController.dispose();
    purposeOtherController.dispose();
    mobileController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _bind(Task task) {
    if (_didBind) return;
    titleController.text = task.title;
    detailsController.text = task.details ?? '';
    purposeOtherController.text = task.purposeOther ?? '';
    mobileController.text = task.phone ?? '';
    emailController.text = task.email ?? '';
    addressController.text = task.taskAddress?.address ?? '';
    _didBind = true;
  }

  Future<void> handleSave() async {
    final task = ref.read(taskEditProvider(widget.taskID)).task.value;
    if (task == null) {
      AppDialogs.error(context, message: 'ไม่พบข้อมูล Task');
      return;
    }

    if (Validator.required(titleController.text) != null) {
      AppDialogs.error(context, message: 'กรุณากรอก Task Title');
      return;
    }

    if (Validator.required(detailsController.text) != null) {
      AppDialogs.error(context, message: 'กรุณากรอก Details');
      return;
    }

    if (Validator.required(task.appointmentTypeID) != null) {
      AppDialogs.error(context, message: 'กรุณาเลือก Type');
      return;
    }

    if (!task.scheduledEndDate.isAfter(task.scheduledStartDate)) {
      AppDialogs.error(context, message: 'Schedule end ต้องมากกว่า Schedule start');
      return;
    }

    if (Validator.required(task.purposeID) != null) {
      AppDialogs.error(context, message: 'กรุณาเลือก Purpose');
      return;
    }

    if (task.purposeName?.toLowerCase() == 'other' && Validator.required(purposeOtherController.text) != null) {
      AppDialogs.error(context, message: 'กรุณากรอก Purpose Other');
      return;
    }

    if (Validator.required(task.clientID) != null) {
      AppDialogs.error(context, message: 'กรุณาเลือก Client');
      return;
    }

    if (Validator.required(mobileController.text) != null) {
      AppDialogs.error(context, message: "กรุณากรอกข้อมูล Mobile");
      return;
    }

    if (Validator.required(emailController.text) != null) {
      AppDialogs.error(context, message: "กรุณากรอกข้อมูล Email");
      return;
    }

    if (Validator.required(task.companyID) != null) {
      AppDialogs.error(context, message: 'กรุณาเลือก Company');
      return;
    }

    if (Validator.required(addressController.text) != null) {
      AppDialogs.error(context, message: 'กรุณากรอกข้อมูล Address');
      return;
    }

    final result = await ref.read(taskEditProvider(widget.taskID).notifier).updateTask();
    if (!mounted) return;
    if (!result) {
      final errMsg = ref.read(taskEditProvider(widget.taskID)).errorMessage;
      if (errMsg != null && errMsg.isNotEmpty) {
        AppDialogs.alert(context, title: 'ไม่สามารถดำเนินการได้', message: errMsg);
      }
      return;
    }

    ref.invalidate(taskDetailProvider(widget.taskID));

    AppDialogs.success(context, title: 'SUCCESS', message: 'Data saved successfully', btnOkOnPress: () => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    final List<Company> companies = ref.watch(companysProvider).maybeWhen(data: (items) => items, orElse: () => const <Company>[]);
    final List<TaskAppointmentType> appointmentTypes = ref.watch(taskTypeProvider).maybeWhen(data: (items) => items, orElse: () => const <TaskAppointmentType>[]);
    final List<Purpose> purposes = ref.watch(purposesProvider).maybeWhen(data: (items) => items, orElse: () => const <Purpose>[]);
    final List<Client> clients = ref.watch(clientForLeadProvider).maybeWhen(data: (items) => items, orElse: () => const <Client>[]);
    final state = ref.watch(taskEditProvider(widget.taskID));

    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            backgroundColor: const Color(0xFFEEEEEE),
            appBar: _TaskEditAppBar(onDone: handleSave),
            body: state.task.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary)),
              error: (_, _) => const Center(
                child: AppText(label: 'Task Not Found', textColor: Colors.red),
              ),
              data: (task) {
                _bind(task);
                return _TaskEditForm(
                  task: task,
                  companies: companies,
                  taskTypeName: _getTaskTypeName(task, appointmentTypes),
                  purposeName: _getPurposeName(task, purposes),
                  clientName: _getClientName(task, clients),
                  companyName: _getCompanyName(task, companies),
                  titleController: titleController,
                  detailsController: detailsController,
                  purposeOtherController: purposeOtherController,
                  mobileController: mobileController,
                  emailController: emailController,
                  addressController: addressController,
                  onTaskTypeTap: () => _openTaskTypeSheet(task.appointmentTypeID ?? ''),
                  onScheduleStartChanged: (value) {
                    final notifier = ref.read(taskEditProvider(widget.taskID).notifier);
                    notifier.setScheduledStartDate(value);
                    if (task.scheduledEndDate.isBefore(value)) {
                      notifier.setScheduledEndDate(value);
                    }
                  },
                  onScheduleEndChanged: (value) => ref.read(taskEditProvider(widget.taskID).notifier).setScheduledEndDate(value),
                  onScheduleStartTimeChanged: (value) => ref.read(taskEditProvider(widget.taskID).notifier).setScheduledStartTime(value),
                  onScheduleEndTimeChanged: (value) => ref.read(taskEditProvider(widget.taskID).notifier).setScheduledEndTime(value),
                  onTitleChanged: (value) => ref.read(taskEditProvider(widget.taskID).notifier).setTitle(value),
                  onDetailsChanged: (value) => ref.read(taskEditProvider(widget.taskID).notifier).setDetails(value),
                  onPurposeChanged: (value) => ref.read(taskEditProvider(widget.taskID).notifier).setPurpose(value),
                  onPurposeOtherChanged: (value) => ref.read(taskEditProvider(widget.taskID).notifier).setPurposeOther(value),
                  onMobileChanged: (value) => ref.read(taskEditProvider(widget.taskID).notifier).setMobile(value),
                  onEmailChanged: (value) => ref.read(taskEditProvider(widget.taskID).notifier).setEmail(value),
                  onCompanyChanged: (value) => ref.read(taskEditProvider(widget.taskID).notifier).setCompany(value),
                  onCompanyRemoved: () => ref.read(taskEditProvider(widget.taskID).notifier).removeCompany(),
                  onAddressChanged: (value) => ref.read(taskEditProvider(widget.taskID).notifier).setAddress(address: value),
                );
              },
            ),
          ),
        ),
        if (state.isLoading) ...[const ModalBarrier(color: Color(0x66000000), dismissible: false), const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary))],
      ],
    );
  }

  Future<void> _openTaskTypeSheet(String appointmentTypeID) async {
    await AppSheetTaskType.show(context: context, appointmentTypeID: appointmentTypeID, onSelected: (value) => ref.read(taskEditProvider(widget.taskID).notifier).setAppointmentType(value));
  }

  String _getTaskTypeName(Task task, List<TaskAppointmentType> appointmentTypes) {
    for (final type in appointmentTypes) {
      if (type.appointmentTypeID == task.appointmentTypeID) {
        return type.appointmentTypeName;
      }
    }

    return task.appointmentTypeName ?? '';
  }

  String _getPurposeName(Task task, List<Purpose> purposes) {
    for (final purpose in purposes) {
      if (purpose.purposeTypeID == task.purposeID) {
        return purpose.purposeTypeName;
      }
    }

    return task.purposeName ?? '';
  }

  String _getClientName(Task task, List<Client> clients) {
    for (final client in clients) {
      if (client.clientID == task.clientID) {
        return '${client.firstName ?? ''} ${client.lastName ?? ''}'.trim();
      }
    }

    return task.clientName ?? '';
  }

  String _getCompanyName(Task task, List<Company> companies) {
    for (final company in companies) {
      if (company.companyID == task.companyID) {
        return company.companyName ?? '';
      }
    }

    return task.companyName ?? '';
  }
}

class _TaskEditForm extends StatelessWidget {
  final Task task;
  final List<Company> companies;
  final String taskTypeName;
  final String purposeName;
  final String clientName;
  final String companyName;
  final TextEditingController titleController;
  final TextEditingController detailsController;
  final TextEditingController purposeOtherController;
  final TextEditingController mobileController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final VoidCallback onTaskTypeTap;
  final ValueChanged<DateTime> onScheduleStartChanged;
  final ValueChanged<DateTime> onScheduleEndChanged;
  final ValueChanged<TimeOfDay> onScheduleStartTimeChanged;
  final ValueChanged<TimeOfDay> onScheduleEndTimeChanged;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onDetailsChanged;
  final ValueChanged<Purpose> onPurposeChanged;
  final ValueChanged<String> onPurposeOtherChanged;
  final ValueChanged<String> onMobileChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<Company> onCompanyChanged;
  final VoidCallback onCompanyRemoved;
  final ValueChanged<Address> onAddressChanged;

  const _TaskEditForm({
    required this.task,
    required this.companies,
    required this.taskTypeName,
    required this.purposeName,
    required this.clientName,
    required this.companyName,
    required this.titleController,
    required this.detailsController,
    required this.purposeOtherController,
    required this.mobileController,
    required this.emailController,
    required this.addressController,
    required this.onTaskTypeTap,
    required this.onScheduleStartChanged,
    required this.onScheduleEndChanged,
    required this.onScheduleStartTimeChanged,
    required this.onScheduleEndTimeChanged,
    required this.onTitleChanged,
    required this.onDetailsChanged,
    required this.onPurposeChanged,
    required this.onPurposeOtherChanged,
    required this.onMobileChanged,
    required this.onEmailChanged,
    required this.onCompanyChanged,
    required this.onCompanyRemoved,
    required this.onAddressChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isShowPurposeOtherTextField = purposeName.toLowerCase() == 'other';
    final taskAddress = task.taskAddress ?? Address();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        spacing: 16,
        children: [
          Column(
            children: [
              FormInfoTile(
                label: 'Client Name',
                value: AppText(label: clientName),
                isHideIcon: true,
              ),
              FormInfoTile(
                label: 'Type',
                value: AppText(label: taskTypeName),
                onTap: onTaskTypeTap,
              ),
              FormInfoTile(
                label: 'Title',
                value: AppTextFormField(controller: titleController, onChanged: onTitleChanged),
                isHideIcon: true,
              ),
              FormInfoTile(
                label: 'Purpose',
                value: AppText(label: purposeName),
                onTap: () => AppSheet.openPurposeSheet(context: context, purposeTypeID: task.purposeID ?? '', onSelected: onPurposeChanged),
              ),
              if (isShowPurposeOtherTextField)
                FormInfoTile(
                  label: 'Purpose Other',
                  value: AppTextFormField(controller: purposeOtherController, onChanged: onPurposeOtherChanged, maxLines: 5),
                  height: 126,
                  // isShowBorderBottom: true,
                  isHideIcon: true,
                ),
              FormInfoTile(
                label: 'Details',
                height: 88,
                value: AppTextFormField(controller: detailsController, maxLines: 3, onChanged: onDetailsChanged),
                isHideIcon: true,
              ),
            ],
          ),
          FormDatetimeRangePicker(
            start: task.scheduledStartDate,
            end: task.scheduledEndDate,
            onStartDateSelected: onScheduleStartChanged,
            onStartTimeSelected: onScheduleStartTimeChanged,
            onEndDateSelected: onScheduleEndChanged,
            onEndTimeSelected: onScheduleEndTimeChanged,
          ),
          Column(
            children: [
              FormInfoTile(
                label: 'Mobile',
                value: AppTextFormField(controller: mobileController, isNumberOnly: true, onChanged: onMobileChanged),
                isShowBorderBottom: true,
                isHideIcon: true,
              ),
              FormInfoTile(
                label: 'Email',
                value: AppTextFormField(controller: emailController, onChanged: onEmailChanged),
                isShowBorderBottom: true,
                isHideIcon: true,
              ),
              FormCompanyWithDataTile(companyID: task.companyID ?? '', companyName: companyName, companies: companies, onSelected: onCompanyChanged, onRemove: (_) => onCompanyRemoved()),
            ],
          ),
          FormAddress(addressController: addressController, address: taskAddress, onSelected: onAddressChanged),
        ],
      ),
    );
  }
}

class _TaskEditAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onDone;

  const _TaskEditAppBar({required this.onDone});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      backgroundColor: const Color(0xFFEEEEEE),
      leadingWidth: 100,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: null,
              style: ButtonStyle(iconColor: WidgetStateProperty.all(AppUtility.colorPrimary)),
            ),
            AppText(label: 'Back', textColor: AppUtility.colorPrimary),
          ],
        ),
      ),
      title: const AppText(label: 'Edit Task', fontSize: 17, fontWeight: FontWeight.w600),
      actions: [
        TextButton(
          onPressed: onDone,
          style: TextButton.styleFrom(foregroundColor: AppUtility.colorPrimary),
          child: AppText(label: 'Done', textColor: AppUtility.colorPrimary),
        ),
      ],
    );
  }
}
