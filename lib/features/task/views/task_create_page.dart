import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/models/address.dart';
import 'package:wfs/features/appointment/views/appointment_detail_page.dart';
import 'package:wfs/features/appointment/models/purpose.dart';
import 'package:wfs/features/client/models/client.dart';
import 'package:wfs/features/company/models/company.dart';
import 'package:wfs/features/task/models/task.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/utility/appdialogs.dart';
import 'package:wfs/utility/validator.dart';
import 'package:wfs/widgets/app_sheet.dart';
import 'package:wfs/widgets/app_text.dart';
import 'package:wfs/widgets/app_text_form_field.dart';
import 'package:wfs/widgets/capsule_widget.dart';
import 'package:wfs/widgets/form_address.dart';
import 'package:wfs/widgets/form_company_with_data_tile.dart';
import 'package:wfs/widgets/form_datetime_range_picker.dart';
import 'package:wfs/widgets/form_info_tile.dart';

class TaskCreatePage extends ConsumerStatefulWidget {
  final String? clientID;
  final String clientType;

  const TaskCreatePage({this.clientID, required this.clientType, super.key});

  @override
  ConsumerState<TaskCreatePage> createState() => _TaskCreatePageState();
}

class _TaskCreatePageState extends ConsumerState<TaskCreatePage> {
  bool isInit = false;
  bool isShowPurposeOtherTextField = false;
  final titleController = TextEditingController();
  final detailsController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final purposeOtherController = TextEditingController();

  late final provider = taskCreateProvider((clientID: widget.clientID, clientType: widget.clientType));

  void handlePurposeChange(Purpose value) {
    ref.read(provider.notifier).setPurpose(value);
    isShowPurposeOtherTextField = value.purposeTypeName.toLowerCase() == "other";
  }

  void _initializeControllers(Task task) {
    if (isInit) return;

    isInit = true;
    titleController.text = task.title;
    detailsController.text = task.details ?? '';
    purposeOtherController.text = task.purposeOther ?? '';
    mobileController.text = task.phone ?? '';
    emailController.text = task.email ?? '';
    addressController.text = task.taskAddress?.address ?? '';
  }

  void handleSave() async {
    final task = ref.read(provider).data.value;
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

    if (isShowPurposeOtherTextField && Validator.required(purposeOtherController.text) != null) {
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
      AppDialogs.error(context, message: "กรุณากรอกข้อมูล Address");
      return;
    }

    final result = await ref.read(provider.notifier).createTask();
    if (!mounted) return;
    if (!result.success) {
      final errMsg = ref.read(provider).errorMessage;
      if (errMsg != null && errMsg.isNotEmpty) {
        AppDialogs.alert(context, title: 'ไม่สามารถดำเนินการได้', message: errMsg);
      }
      return;
    }

    final createdID = result.taskID;
    if (result.isClientVisit && createdID != null && createdID.isNotEmpty) {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => AppointmentDetailPage(appointmentID: createdID)), (route) => route.isFirst);
      return;
    }

    AppDialogs.success(context, title: "SUCCESS", message: "Data saved successfully", btnOkOnPress: () => Navigator.of(context).popUntil((route) => route.isFirst));
  }

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(provider);

    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            backgroundColor: const Color(0xFFEEEEEE),
            appBar: _TaskFormAppBar(title: 'Create Task', onDone: handleSave),
            body: state.data.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary)),
              error: (_, _) => const Center(
                child: AppText(label: 'Task Not Found', textColor: Colors.red),
              ),
              data: (task) {
                _initializeControllers(task);
                return _TaskForm(
                  task: task,
                  clientType: widget.clientType,
                  companies: state.companies,
                  titleController: titleController,
                  detailsController: detailsController,
                  mobileController: mobileController,
                  emailController: emailController,
                  addressController: addressController,
                  purposeOtherController: purposeOtherController,
                  isShowPurposeOtherTextField: isShowPurposeOtherTextField,
                  onTaskTypeTap: () => _openTaskTypeSheet(task.appointmentTypeID ?? ''),
                  onScheduleStartChanged: (value) {
                    final notifier = ref.read(provider.notifier);
                    notifier.setScheduledStartDate(value);

                    if (task.scheduledEndDate.isBefore(value)) {
                      notifier.setScheduledEndDate(value);
                    }
                  },
                  onScheduleStartTimeChanged: (value) => ref.read(provider.notifier).setScheduleStartTime(value),
                  onScheduleEndChanged: (value) => ref.read(provider.notifier).setScheduledEndDate(value),
                  onScheduleEndTimeChanged: (value) => ref.read(provider.notifier).setScheduleEndTime(value),
                  onTitleChanged: (value) => ref.read(provider.notifier).setTitle(value),
                  onDetailsChanged: (value) => ref.read(provider.notifier).setDetails(value),
                  onPurposeChanged: (value) => handlePurposeChange(value),
                  onPurposeOtherChanged: (value) => ref.read(provider.notifier).setPurposeOther(value),
                  onClienteChanged: (value) => ref.read(provider.notifier).setClient(value),
                  onMobileChanged: (value) => ref.read(provider.notifier).setMobile(value),
                  onEmailChanged: (value) => ref.read(provider.notifier).setEmail(value),
                  onCompanyChanged: (value) => ref.read(provider.notifier).setCompany(value),
                  onCompanyRemoved: () => ref.read(provider.notifier).removeCompany(),
                  onAddressChanged: (value) => ref.read(provider.notifier).setAddress(address: value),
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
    await AppSheetTaskType.show(context: context, appointmentTypeID: appointmentTypeID, onSelected: (value) => ref.read(provider.notifier).setAppointmentType(value));
  }
}

class _TaskForm extends StatelessWidget {
  final Task task;
  final String clientType;
  final List<Company> companies;
  final TextEditingController titleController;
  final TextEditingController detailsController;
  final TextEditingController purposeOtherController;
  final TextEditingController mobileController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final bool isShowPurposeOtherTextField;
  final VoidCallback onTaskTypeTap;
  final ValueChanged<DateTime> onScheduleStartChanged;
  final ValueChanged<TimeOfDay> onScheduleStartTimeChanged;
  final ValueChanged<DateTime> onScheduleEndChanged;
  final ValueChanged<TimeOfDay> onScheduleEndTimeChanged;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onDetailsChanged;
  final ValueChanged<Purpose> onPurposeChanged;
  final ValueChanged<String> onPurposeOtherChanged;
  final ValueChanged<Client> onClienteChanged;
  final ValueChanged<String> onMobileChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<Company> onCompanyChanged;
  final VoidCallback onCompanyRemoved;
  final ValueChanged<Address> onAddressChanged;

  const _TaskForm({
    required this.task,
    required this.clientType,
    required this.companies,
    required this.titleController,
    required this.detailsController,
    required this.purposeOtherController,
    required this.mobileController,
    required this.emailController,
    required this.addressController,
    required this.isShowPurposeOtherTextField,
    required this.onTaskTypeTap,
    required this.onScheduleStartChanged,
    required this.onScheduleStartTimeChanged,
    required this.onScheduleEndChanged,
    required this.onScheduleEndTimeChanged,
    required this.onTitleChanged,
    required this.onDetailsChanged,
    required this.onPurposeChanged,
    required this.onPurposeOtherChanged,
    required this.onClienteChanged,
    required this.onMobileChanged,
    required this.onEmailChanged,
    required this.onCompanyChanged,
    required this.onCompanyRemoved,
    required this.onAddressChanged,
  });

  @override
  Widget build(BuildContext context) {
    final taskAddress = task.taskAddress ?? Address();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        spacing: 16,
        children: [
          Column(
            children: [
              FormInfoTile(
                label: 'Name',
                value: Row(
                  spacing: 8,
                  children: [
                    if (clientType != "") CapsuleWidget(label: clientType, capsuleStyle: CapsuleStyle(Color(0xFF2F80ED), Color.fromRGBO(47, 128, 237, 0.2))),
                    Expanded(child: AppText(label: task.clientName ?? '')),
                  ],
                ),
                isHideIcon: true,
              ),
              FormInfoTile(
                label: 'Title',
                value: AppTextFormField(controller: titleController, onChanged: onTitleChanged),
                isHideIcon: true,
              ),
              FormInfoTile(
                label: 'Type',
                value: AppText(label: task.appointmentTypeName ?? ''),
                onTap: onTaskTypeTap,
              ),
              FormInfoTile(
                label: 'Purpose',
                value: AppText(label: task.purposeName ?? ''),
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
              FormCompanyWithDataTile(companyID: task.companyID ?? '', companyName: task.companyName ?? '', companies: companies, onSelected: onCompanyChanged, onRemove: (_) => onCompanyRemoved()),
            ],
          ),
          FormAddress(addressController: addressController, address: taskAddress, onSelected: onAddressChanged),

          // FormInfoTile(
          //   label: 'Type',
          //   value: AppText(label: task.appointmentTypeName ?? ''),
          //   onTap: onTaskTypeTap,
          // ),
          // FormInfoTile(
          //   label: 'Title',
          //   value: AppTextFormField(controller: titleController, onChanged: onTitleChanged),
          //   isHideIcon: true,
          // ),
          // FormInfoTile(
          //   label: 'Details',
          //   height: 88,
          //   value: AppTextFormField(controller: detailsController, maxLines: 3, onChanged: onDetailsChanged),
          //   isHideIcon: true,
          // ),
          // TaskSchedulePicker(label: 'schedule start', datetime: task.scheduledStartDate, onChanged: onScheduleStartChanged),
          // TaskSchedulePicker(label: 'schedule end', datetime: task.scheduledEndDate, isShowBorderBottom: true, onChanged: onScheduleEndChanged),
          // FormInfoTile(
          //   label: 'purpose',
          //   value: AppText(label: task.purposeName ?? ''),
          //   onTap: () => AppSheet.openPurposeSheet(context: context, purposeTypeID: task.purposeID ?? '', onSelected: onPurposeChanged),
          //   isShowBorderBottom: true,
          // ),

          // FormInfoTile(
          //   label: 'client',
          //   value: AppText(label: task.clientName ?? ''),
          //   onTap: () => AppSheet.openClientSheet(context: context, clientID: task.clientID ?? '', onSelected: onClienteChanged),
          //   isShowBorderBottom: true,
          // ),
          // FormCompanyWithDataTile(companyID: task.companyID ?? '', companyName: task.companyName ?? '', companies: companies, onSelected: onCompanyChanged, onRemove: (_) => onCompanyRemoved()),
        ],
      ),
    );
  }
}

class _TaskFormAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onDone;

  const _TaskFormAppBar({required this.title, required this.onDone});

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
      title: AppText(label: title, fontSize: 17, fontWeight: FontWeight.w600),
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
