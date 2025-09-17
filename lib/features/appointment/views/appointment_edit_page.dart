import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
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
import 'package:wfs/lib/widgets/form_address.dart';
import 'package:wfs/lib/widgets/form_datetime_picker.dart';
import 'package:wfs/lib/widgets/form_info_tile.dart';

class AppointmentEditPage extends ConsumerStatefulWidget {
  final String appointmentID;
  const AppointmentEditPage({required this.appointmentID, super.key});

  @override
  ConsumerState<AppointmentEditPage> createState() => _AppointmentEditPageState();
}

class _AppointmentEditPageState extends ConsumerState<AppointmentEditPage> {
  static const colorPrimary = Color(0xFF007AFF);
  static const colorGrey = Color(0xFFC7C7CC);
  static const borderWidth = 0.33;
  static const borderSide = BorderSide(color: colorGrey, width: borderWidth);

  final TextEditingController addressController = TextEditingController();
  final TextEditingController notedController = TextEditingController();
  bool _noteInitialized = false;

  Future<void> openProdctSheet({required BuildContext context, required String productID, bool isUpdate = false}) async {
    final selected = await CupertinoOptionsPicker.show<Product>(
      context: context,
      title: 'Product',
      provider: productsProvider,
      label: (p) => p.productName,
      initialKey: (p) => p.productId,
      initialValue: productID,
    );

    if (selected == null) return;

    if (isUpdate) {
      ref.read(appointmentEditProvider(widget.appointmentID).notifier).updateProduct(selected);
    } else {
      ref.read(appointmentEditProvider(widget.appointmentID).notifier).addProduct(selected);
    }
  }

  void removeProduct(String productId) {
    ref.read(appointmentEditProvider(widget.appointmentID).notifier).removeProduct(productId);
  }

  void deleteAppointment(String appointmentId) {
    Widget actionContainer({required AppText appText, required VoidCallback onTap}) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 11),
          width: double.infinity,
          height: 44,
          decoration: BoxDecoration(color: Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(10)),
          child: appText,
        ),
      );
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(13)),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            color: Color(0xFFEEEEEE),
            child: Column(
              spacing: 10,
              mainAxisSize: MainAxisSize.min,
              children: [
                actionContainer(
                  appText: AppText(label: 'Delete Appointment', textColor: Color(0xFFFF382B)),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    showDeleteConfirmDialog(context);
                  },
                ),
                actionContainer(
                  appText: AppText(label: 'Cancel', textColor: Color(0xFF007BFE)),
                  onTap: () => Navigator.pop(bottomSheetContext),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> showDeleteConfirmDialog(BuildContext context) async {
    return showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: const Text("Delete Appointment", textScaler: TextScaler.noScaling),
          content: const Text("Are you sure you want to delete this appointment?", textScaler: TextScaler.noScaling),
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
              onPressed: () => confirmDeleteAppointment(dialogContext),
              child: AppText(label: 'Delete', textColor: Color(0xFFFF382B)),
            ),
          ],
        );
      },
    );
  }

  void confirmDeleteAppointment(BuildContext dialogContext) async {
    Navigator.pop(dialogContext);

    final result = await ref.read(appointmentEditProvider(widget.appointmentID).notifier).deleteAppointment();
    if (!result) return;

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void handleSave() async {
    final result = await ref.read(appointmentEditProvider(widget.appointmentID).notifier).updateAppointment(noted: notedController.text);
    if (!result) return;

    if (!mounted) return;
    Navigator.pop(context, result);
  }

  void handleAppointmentStatusChange(AppointmentDetail appointmentDetail, AppointmentStatus value) async {
    if (value.appointmentStatusName != 'Canceled') {
      ref.read(appointmentEditProvider(widget.appointmentID).notifier).setAppointmentStatus(value);
      return;
    }

    ref.read(appointmentEditProvider(widget.appointmentID).notifier).setIsLoading(true);

    final date = DateTime.tryParse(appointmentDetail.appointmentDateTimeFrom) ?? DateTime.now();
    await showCancelAppointmentDialog(context: context, ref: ref, appointmentID: appointmentDetail.appointmentID, currentDate: date);

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  void dispose() {
    addressController.dispose();
    notedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appointmentEditProvider(widget.appointmentID));
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
                      style: ButtonStyle(iconColor: WidgetStateProperty.all(colorPrimary)),
                    ),
                    AppText(label: 'Back', textColor: colorPrimary),
                  ],
                ),
              ),
              title: AppText(label: 'Edit Appointment', fontSize: 17, fontWeight: FontWeight.w600),
              actions: [
                TextButton(
                  onPressed: isDisabled ? () => handleSave() : null,
                  style: TextButton.styleFrom(foregroundColor: isDisabled ? colorPrimary : Colors.grey),
                  child: AppText(label: 'Done', textColor: isDisabled ? colorPrimary : Colors.grey),
                ),
              ],
            ),
            body: state.data.when(
              loading: () => const Center(child: CircularProgressIndicator(color: colorPrimary)),
              error: (e, _) => Center(
                child: AppText(label: "Appointment Not Found", textColor: Colors.red),
              ),
              data: (detail) => buildContent(detail),
            ),
          ),
        ),

        if (state.isLoading) ...[const ModalBarrier(color: Color(0x66000000), dismissible: false), const Center(child: CircularProgressIndicator(color: colorPrimary))],
      ],
    );
  }

  Widget buildContent(AppointmentDetail appointmentDetail) {
    final address = appointmentDetail.address;
    final client = appointmentDetail.client;
    final salesTerritory = client.salesTerritory;
    final products = appointmentDetail.products;

    bool isShowCancelNote = appointmentDetail.appointmentStatusName == 'Canceled';

    if (!_noteInitialized) {
      notedController.text = appointmentDetail.noted;
      _noteInitialized = true;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 24,
        children: [
          AppText(label: appointmentDetail.clientName, fontSize: 26),
          Column(
            spacing: 16,
            children: [
              Column(
                children: [
                  FormInfoTile(
                    label: 'meeting',
                    value: AppointmentTypeCapsule(appointmentTypeName: appointmentDetail.appointmentTypeName),
                    onTap: () => AppSheet.openMeetingSheet(
                      context: context,
                      appointmentTypeID: appointmentDetail.appointmentTypeID,
                      onSelected: (value) => ref.read(appointmentEditProvider(widget.appointmentID).notifier).setAppointmentType(value),
                    ),
                  ),
                  FormInfoTile(
                    label: 'status',
                    value: AppointmentStatusCapsule(appointmentStatusName: appointmentDetail.appointmentStatusName),
                    onTap: () => AppSheet.openAppointmentStatusSheet(
                      context: context,
                      appointmentStatusID: appointmentDetail.appointmentStatusID,
                      onSelected: (value) => handleAppointmentStatusChange(appointmentDetail, value),
                    ),
                  ),
                  FormInfoTile(
                    label: 'purpose',
                    value: AppText(label: appointmentDetail.purposeTypeName),
                    onTap: () => AppSheet.openPurposeSheet(
                      context: context,
                      purposeTypeID: appointmentDetail.purposeTypeID,
                      onSelected: (value) => ref.read(appointmentEditProvider(widget.appointmentID).notifier).setPurpose(value),
                    ),
                  ),
                  FormInfoTile(
                    label: 'territory',
                    value: AppText(label: salesTerritory?.salesTerritoryName ?? ''),
                    onTap: () => AppSheet.openTerritorySheet(
                      context: context,
                      territoryID: salesTerritory?.salesTerritoryID ?? '',
                      onSelected: (value) => ref.read(appointmentEditProvider(widget.appointmentID).notifier).setTerritory(value),
                    ),
                    isShowBorderBottom: true,
                  ),
                ],
              ),
              // if (isShowCancelNote)
              //   Column(
              //     children: [FormInfoTile(label: 'canceled note', value: AppTextFormField(maxLines: 5), height: 126, isShowBorderBottom: true, isHideIcon: true)],
              //   ),
              Column(
                children: [
                  FormDatetimePicker(
                    label: 'Starts',
                    datetime: DateTime.parse(appointmentDetail.appointmentDateTimeFrom),
                    onDateSelected: (value) => ref.read(appointmentEditProvider(widget.appointmentID).notifier).setAppointmentFromDate(value),
                    onTimeSelected: (value) => ref.read(appointmentEditProvider(widget.appointmentID).notifier).setAppointmentFromTime(value),
                  ),
                  FormDatetimePicker(
                    label: 'Ends',
                    datetime: DateTime.parse(appointmentDetail.appointmentDateTimeTo),
                    onDateSelected: (value) => ref.read(appointmentEditProvider(widget.appointmentID).notifier).setAppointmentToDate(value),
                    onTimeSelected: (value) => ref.read(appointmentEditProvider(widget.appointmentID).notifier).setAppointmentToTime(value),
                  ),
                ],
              ),
              Column(
                children: [
                  FormInfoTile(
                    label: 'mobile',
                    value: AppText(label: appointmentDetail.phone),
                    isHideIcon: true,
                  ),
                  FormInfoTile(
                    label: 'email',
                    value: AppText(label: appointmentDetail.email),
                    isHideIcon: true,
                  ),
                  FormInfoTile(
                    label: 'company',
                    value: AppText(label: appointmentDetail.companyName),
                    isHideIcon: true,
                    isShowBorderBottom: true,
                  ),
                ],
              ),
              FormAddress(addressContoller: addressController, address: address, onSelected: (value) {}),
              // productTile(products: products),
              FormInfoTile(
                label: 'note',
                value: AppTextFormField(controller: notedController, onChanged: (value) => ref.read(appointmentEditProvider(widget.appointmentID).notifier).setNoted(value), maxLines: 5),
                height: 126,
                isShowBorderBottom: true,
                isHideIcon: true,
              ),
              GestureDetector(
                onTap: () => deleteAppointment(appointmentDetail.appointmentID),
                child: Container(
                  width: double.infinity,
                  height: 44,
                  color: Colors.white,
                  child: Center(
                    child: AppText(label: 'Delete Appointment', fontSize: 17, textColor: Color(0xFFFF382B)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget productTile({required List<Product> products, bool isShowBorderBottom = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: borderSide, bottom: borderSide),
      ),
      child: Stack(
        children: [
          const Positioned(
            left: 16 + 100,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: borderWidth,
              child: ColoredBox(color: colorGrey),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 16),
              SizedBox(
                width: 100,
                child: Center(
                  child: AppText(label: 'products', textColor: Color(0xFF007AFF)),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      itemBuilder: (_, index) {
                        final product = products[index];

                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: colorGrey, width: borderWidth),
                            ),
                          ),
                          height: 44,
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => removeProduct(product.productId),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: Icon(Icons.remove_circle, color: Color(0xFFFF382B), size: 24),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => openProdctSheet(context: context, productID: product.productId, isUpdate: true),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: AppText(label: product.productName),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    GestureDetector(
                      onTap: () => openProdctSheet(context: context, productID: ""),
                      child: SizedBox(
                        height: 44,
                        child: Row(
                          children: const [
                            SizedBox(width: 16),
                            Icon(Icons.add_circle, color: Color(0xFF31C859), size: 24),
                            SizedBox(width: 16),
                            AppText(label: 'add product'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
