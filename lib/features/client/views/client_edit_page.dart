import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/models/address.dart';
import 'package:wfs/features/appointment/models/appointment_detail.dart';
import 'package:wfs/features/appointment/models/appointment_status.dart';
import 'package:wfs/features/appointment/models/product.dart';
import 'package:wfs/features/appointment/widgets/app_cupertino_option.dart';
import 'package:wfs/features/appointment/widgets/app_sheet.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/features/appointment/widgets/app_text_form_field.dart';
import 'package:wfs/features/appointment/widgets/appointment_status_capsule.dart';
import 'package:wfs/features/appointment/widgets/appointment_type_capsule.dart';
import 'package:wfs/features/appointment/widgets/cancel_appointment_dialog.dart';
import 'package:wfs/features/client/models/client.dart';
import 'package:wfs/features/client/widgets/client_level_capsule.dart';
import 'package:wfs/features/client/widgets/client_status_capsule.dart';
import 'package:wfs/lib/widgets/form_address.dart';
import 'package:wfs/lib/widgets/form_datetime_picker.dart';
import 'package:wfs/lib/widgets/form_info_tile.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_companies_field.dart';

class ClientEditPage extends ConsumerStatefulWidget {
  final String clientID;
  const ClientEditPage({required this.clientID, super.key});

  @override
  ConsumerState<ClientEditPage> createState() => _ClientEditPageState();
}

class _ClientEditPageState extends ConsumerState<ClientEditPage> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  bool _noteInitialized = false;

  void handleSave() async {
    // final result = await ref.read(appointmentEditProvider(widget.appointmentID).notifier).updateAppointment(noted: notedController.text);
    // if (!result) return;

    // if (!mounted) return;
    // Navigator.pop(context, result);
  }

  @override
  void dispose() {
    addressController.dispose();
    mobileController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clientEditProvider(widget.clientID));
    final isDisabled = (state.isDirty && !state.isLoading);

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
              title: AppText(label: 'Edit Client', fontSize: 17, fontWeight: FontWeight.w600),
              actions: [
                TextButton(
                  onPressed: isDisabled ? () => handleSave() : null,
                  style: TextButton.styleFrom(foregroundColor: isDisabled ? AppUtility.colorPrimary : Colors.grey),
                  child: AppText(label: 'Done', textColor: isDisabled ? AppUtility.colorPrimary : Colors.grey),
                ),
              ],
            ),
            body: state.data.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary)),
              error: (e, _) => Center(
                child: AppText(label: "Client Not Found", textColor: Colors.red),
              ),
              data: (client) => buildContent(client),
            ),
          ),
        ),

        if (state.isLoading) ...[const ModalBarrier(color: Color(0x66000000), dismissible: false), const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary))],
      ],
    );
  }

  Widget buildContent(Client client) {
    // final address = appointmentDetail.address;
    // final client = appointmentDetail.client;
    // final salesTerritory = client.salesTerritory;
    // final products = appointmentDetail.products;

    // bool isShowCancelNote = appointmentDetail.appointmentStatusName == 'Canceled';

    // if (!_noteInitialized) {
    //   notedController.text = appointmentDetail.noted;
    //   _noteInitialized = true;
    // }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 24,
        children: [
          AppText(label: client.clientName, fontSize: 26),
          Column(
            spacing: 16,
            children: [
              Column(
                children: [
                  FormInfoTile(
                    label: 'status',
                    value: ClientStatusCapsule(clientStatusName: client.clientStatusName),
                    // onTap: () => AppSheet.openAppointmentStatusSheet(
                    //   context: context,
                    //   appointmentStatusID: appointmentDetail.appointmentStatusID,
                    //   onSelected: (value) => handleAppointmentStatusChange(appointmentDetail, value),
                    // ),
                  ),
                  FormInfoTile(
                    label: 'level',
                    value: ClientLevelCapsule(clientLevelName: client.clientLevelName),
                    // onTap: () => AppSheet.openPurposeSheet(
                    //   context: context,
                    //   purposeTypeID: appointmentDetail.purposeTypeID,
                    //   onSelected: (value) => ref.read(appointmentEditProvider(widget.appointmentID).notifier).setPurpose(value),
                    // ),
                  ),
                  FormInfoTile(
                    label: 'territory',
                    value: AppText(label: client.salesTerritoryName ?? ''),
                    // onTap: () => AppSheet.openTerritorySheet(
                    //   context: context,
                    //   territoryID: client.salesTerritoryID ?? '',
                    //   onSelected: (value) => ref.read(clientEditProvider(widget.clientID).notifier).setTerritory(value),
                    // ),
                    isShowBorderBottom: true,
                  ),
                ],
              ),
              FormAddress(addressContoller: addressController, address: Address(), onSelected: (value) {}),
              Column(
                children: [
                  FormInfoTile(
                    label: 'mobile',
                    value: AppTextFormField(controller: mobileController, onChanged: (value) => ref.read(clientEditProvider(widget.clientID).notifier).setMobile(value)),
                    isHideIcon: true,
                  ),
                  FormInfoTile(
                    label: 'email',
                    value: AppTextFormField(controller: emailController, onChanged: (value) => ref.read(clientEditProvider(widget.clientID).notifier).setEmail(value)),
                    isHideIcon: true,
                  ),
                ],
              ),
              AppCompaniesField(companies: [], onAdd: () {}, onEdit: (value) {}, onRemove: (value) {}),
            ],
          ),
        ],
      ),
    );
  }
}
