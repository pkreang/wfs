import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/models/address.dart';
import 'package:wfs/features/appointment/models/appointment.dart';
import 'package:wfs/features/appointment/widgets/app_sheet.dart';
import 'package:wfs/features/appointment/widgets/appointment_status_capsule.dart';
import 'package:wfs/features/appointment/widgets/appointment_type_capsule.dart';
import 'package:wfs/lib/widgets/form_address.dart';
import 'package:wfs/lib/widgets/form_company_tile.dart';
import 'package:wfs/lib/widgets/form_datetime_picker.dart';
import 'package:wfs/lib/widgets/form_info_tile.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/utility/appdialogs.dart';
import 'package:wfs/utility/validator.dart';
import 'package:wfs/widgets/app_text.dart';

class CreateAppointmentScreen extends ConsumerStatefulWidget {
  final String clientId;
  const CreateAppointmentScreen({required this.clientId, super.key});

  @override
  ConsumerState<CreateAppointmentScreen> createState() => _CreateAppointmentScreenState();
}

class _CreateAppointmentScreenState extends ConsumerState<CreateAppointmentScreen> {
  final TextEditingController txtAddress = TextEditingController();

  void handleSave() async {
    final asyncAppointment = ref.read(appointmentCreateProvider(widget.clientId)).appointment;
    final appointment = asyncAppointment.value;

    if (appointment == null) {
      AppDialogs.error(context, message: "ไม่พบข้อมูล Appointment");
      return;
    }

    final appointmentAddress = appointment.appointmentAddress;

    if (Validator.required(appointment.appointmentTypeID) != null) {
      AppDialogs.error(context, message: "กรุณาเลือก Meeting");
      return;
    }

    if (Validator.required(appointment.purposeTypeID) != null) {
      AppDialogs.error(context, message: "กรุณาเลือก Purpose");
      return;
    }

    if (Validator.required(appointment.appointmentStatusID) != null) {
      AppDialogs.error(context, message: "กรุณาเลือก Status");
      return;
    }

    if (Validator.required(appointment.companyID) != null) {
      AppDialogs.error(context, message: "กรุณาเลือก Company");
      return;
    }

    if (Validator.required(txtAddress.text) != null) {
      AppDialogs.error(context, message: "กรุณากรอกข้อมูล Address");
      return;
    }

    if (Validator.required((appointmentAddress?.provinceID ?? '').toString()) != null) {
      AppDialogs.error(context, message: "กรุณาเลือก Province");
      return;
    }

    if (Validator.required((appointmentAddress?.districtID ?? '').toString()) != null) {
      AppDialogs.error(context, message: "กรุณาเลือก District");
      return;
    }

    if (Validator.required((appointmentAddress?.subDistrictID ?? '').toString()) != null) {
      AppDialogs.error(context, message: "กรุณาเลือก SubDistrict");
      return;
    }

    if (Validator.required(appointmentAddress?.postCode) != null) {
      AppDialogs.error(context, message: "ไม่มีข้อมูล PostCode");
      return;
    }

    final result = await ref.read(appointmentCreateProvider(widget.clientId).notifier).saveAppointment();
    if (!result) return;

    AppDialogs.success(context, btnOkOnPress: () => Navigator.of(context).popUntil((route) => route.isFirst));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appointmentCreateProvider(widget.clientId));

    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            backgroundColor: Color(0xFFEEEEEE),
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Color(0xFFEEEEEE),
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
              title: AppText(label: 'Create Appointment', fontSize: 17, fontWeight: FontWeight.w600),
              actions: [
                TextButton(
                  onPressed: () => handleSave(),
                  style: TextButton.styleFrom(foregroundColor: AppUtility.colorPrimary),
                  child: AppText(label: 'Create', textColor: AppUtility.colorPrimary),
                ),
              ],
            ),
            body: state.appointment.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary)),
              error: (e, _) => Center(
                child: AppText(label: "Client Not Found", textColor: Colors.red),
              ),
              data: (appointment) => buildContent(appointment),
            ),
          ),
        ),

        if (state.isLoading) ...[const ModalBarrier(color: Color(0x66000000), dismissible: false), const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary))],
      ],
    );
  }

  Widget buildContent(Appointment appointment) {
    final appointmentAddress = appointment.appointmentAddress ?? Address();
    txtAddress.text = appointmentAddress.address ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 24,
        children: [
          Column(
            spacing: 16,
            children: [
              Column(
                children: [
                  FormInfoTile(
                    label: 'Client Name',
                    value: AppText(label: appointment.clientName ?? ''),
                    isShowBorderBottom: true,
                    isHideIcon: true,
                  ),
                  FormInfoTile(
                    label: 'meeting',
                    value: AppointmentTypeCapsule(appointmentTypeName: appointment.appointmentTypeName ?? ''),
                    onTap: () => AppSheet.openMeetingSheet(
                      context: context,
                      appointmentTypeID: appointment.appointmentTypeID ?? '',
                      onSelected: (value) => ref.read(appointmentCreateProvider(widget.clientId).notifier).setAppointmentType(value),
                    ),
                    isShowBorderBottom: true,
                  ),
                  FormInfoTile(
                    label: 'status',
                    value: AppointmentStatusCapsule(appointmentStatusName: appointment.appointmentStatusName ?? ''),
                    onTap: () => AppSheet.openAppointmentStatusSheet(
                      context: context,
                      appointmentStatusID: appointment.appointmentStatusID ?? '',
                      onSelected: (value) => ref.read(appointmentCreateProvider(widget.clientId).notifier).setAppointmentStatus(value),
                    ),
                    isShowBorderBottom: true,
                  ),
                  FormInfoTile(
                    label: 'purpose',
                    value: AppText(label: appointment.purposeTypeName ?? ''),
                    onTap: () => AppSheet.openPurposeSheet(
                      context: context,
                      purposeTypeID: appointment.purposeTypeID ?? '',
                      onSelected: (value) => ref.read(appointmentCreateProvider(widget.clientId).notifier).setPurpose(value),
                    ),
                    isShowBorderBottom: true,
                  ),
                  FormInfoTile(
                    label: 'territory',
                    value: AppText(label: appointment.salesTerritoryName ?? ''),
                    isShowBorderBottom: true,
                    isHideIcon: true,
                  ),
                ],
              ),
              Column(
                children: [
                  FormDatetimePicker(
                    label: 'Starts',
                    datetime: appointment.appointmentDateTimeFrom,
                    onDateSelected: (value) => ref.read(appointmentCreateProvider(widget.clientId).notifier).setAppointmentFromDate(value),
                    onTimeSelected: (value) => ref.read(appointmentCreateProvider(widget.clientId).notifier).setAppointmentFromTime(value),
                  ),
                  FormDatetimePicker(
                    label: 'Ends',
                    datetime: appointment.appointmentDateTimeTo,
                    onDateSelected: (value) => ref.read(appointmentCreateProvider(widget.clientId).notifier).setAppointmentToDate(value),
                    onTimeSelected: (value) => ref.read(appointmentCreateProvider(widget.clientId).notifier).setAppointmentToTime(value),
                  ),
                ],
              ),
              Column(
                children: [
                  FormInfoTile(
                    label: 'mobile',
                    value: AppText(label: appointment.phone ?? ''),
                    isShowBorderBottom: true,
                    isHideIcon: true,
                  ),
                  FormInfoTile(
                    label: 'email',
                    value: AppText(label: appointment.email ?? ''),
                    isShowBorderBottom: true,
                    isHideIcon: true,
                  ),
                  FormCompanyTile(
                    companyID: appointment.companyID ?? '',
                    companyName: appointment.companyName ?? '',
                    onSelected: (value) => ref.read(appointmentCreateProvider(widget.clientId).notifier).setCompany(value),
                    onRemove: (_) => ref.read(appointmentCreateProvider(widget.clientId).notifier).removeCompany(),
                  ),
                ],
              ),
              // addressWidget(),
              FormAddress(
                addressContoller: txtAddress,
                address: appointmentAddress,
                onSelected: (value) => ref.read(appointmentCreateProvider(widget.clientId).notifier).setAddress(address: value),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
