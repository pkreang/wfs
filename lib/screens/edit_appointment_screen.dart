import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wfs/models/appointmentaddress_model.dart';
import 'package:wfs/models/appointments_model.dart';
import 'package:wfs/models/appointmentstatus_model.dart';
import 'package:wfs/models/appointmenttype_model.dart';
import 'package:wfs/models/product_model.dart';
import 'package:wfs/models/purposetype_model.dart';
import 'package:wfs/models/territory_model.dart';
import 'package:wfs/providers/appointment_provider.dart';
import 'package:wfs/providers/appointmentstatus_provider.dart';
import 'package:wfs/providers/appointmenttype_provider.dart';
import 'package:wfs/providers/product_provider.dart';
import 'package:wfs/providers/purposetype_provider.dart';
import 'package:wfs/providers/saleterritorie_provider.dart';
import 'package:wfs/utility/date_picker_helper.dart';
import 'package:wfs/utility/time_picker_helper.dart';
import 'package:wfs/widgets/app_cupertino_option.dart';
import 'package:wfs/widgets/app_text.dart';

class EditAppointmentScreen extends ConsumerStatefulWidget {
  final String appointmentID;
  const EditAppointmentScreen({required this.appointmentID, super.key});

  @override
  ConsumerState<EditAppointmentScreen> createState() =>
      _EditAppointmentScreenState();
}

class _EditAppointmentScreenState extends ConsumerState<EditAppointmentScreen> {
  static const colorPrimary = Color(0xFF007AFF);
  static const colorGrey = Color(0xFFC7C7CC);
  static const borderWidth = 0.33;
  static const borderSide = BorderSide(color: colorGrey, width: borderWidth);

  bool isCanEdit = true;

  late final TextEditingController notedController;
  bool _noteInitialized = false;

  Future<void> openAppointmentTypeSheet(
    BuildContext context,
    String appointmentTypeID,
  ) async {
    final selected = await CupertinoOptionsPicker.show<AppointmentType>(
      context: context,
      title: 'Meeting',
      provider: appointmentTypeGetList,
      label: (p) => p.appointmentTypeName ?? "",
      initialKey: (p) => p.appointmentTypeID ?? "",
      initialValue: appointmentTypeID,
    );

    if (selected == null) return;
    // ref
    //     .read(appointmentEditProvider(widget.appointmentID).notifier)
    //     .setAppointmentType(selected);
  }

  Future<void> openAppointmentStatusSheet(
    BuildContext context,
    String appointmentStatusID,
  ) async {
    final selected = await CupertinoOptionsPicker.show<AppointmentStatus>(
      context: context,
      title: 'Status',
      provider: appointmentStatusGetList,
      label: (p) => p.appointmentStatusName ?? "",
      initialKey: (p) => p.appointmentStatusID ?? "",
      initialValue: appointmentStatusID,
    );

    if (selected == null) return;

    // ref
    //     .read(appointmentEditProvider(widget.appointmentID).notifier)
    //     .setAppointmentStatus(selected);
  }

  Future<void> openPurposeSheet(
    BuildContext context,
    String purposeTypeID,
  ) async {
    final selected = await CupertinoOptionsPicker.show<PurposeType>(
      context: context,
      title: 'Purpose',
      provider: perposeTypeGetList,
      label: (p) => p.purposeTypeName ?? "",
      initialKey: (p) => p.purposeTypeID ?? "",
      initialValue: purposeTypeID,
    );

    if (selected == null) return;

    // ref
    //     .read(appointmentEditProvider(widget.appointmentID).notifier)
    //     .setPurpose(selected);
  }

  Future<void> openTerritorySheet(
    BuildContext context,
    String territoryID,
  ) async {
    final selected = await CupertinoOptionsPicker.show<Territory>(
      context: context,
      title: 'Territory',
      provider: territoryGetListProvider,
      label: (p) => p.salesTerritoryName,
      initialKey: (p) => p.salesTerritoryID,
      initialValue: territoryID,
    );

    if (selected == null) return;

    // ref
    //     .read(appointmentEditProvider(widget.appointmentID).notifier)
    //     .setTerritory(selected);
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void openDatePicker({
    required String datetime,
    required Function(DateTime) onSelected,
    String? limitFirstDate,
  }) async {
    final picked = await DatePickerHelper.pickDate(
      context,
      initialDate: DateTime.parse(datetime),
      limitFirstDate: limitFirstDate == null
          ? null
          : DateTime.parse(limitFirstDate),
    );
    if (picked != null) onSelected(picked);
  }

  void openTimePicker({
    required String datetime,
    required Function(TimeOfDay) onSelected,
    String? limitFirstDate,
  }) async {
    final picked = await showCupertinoTimeDialog(initial: datetime, context);

    if (picked != null) {
      if (limitFirstDate != null) {
        final current = DateTime.parse(datetime);
        final limit = DateTime.parse(limitFirstDate);
        final limitTime = TimeOfDay(hour: limit.hour, minute: limit.minute);

        if (isSameDay(limit, current) && picked.isBefore(limitTime)) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: AppText(
                label: 'Please select a time after the appointment start time.',
                textColor: Colors.white,
                maxLines: 2,
              ),
            ),
          );
          return;
        }
      }

      onSelected(picked);
    }
  }

  Future<void> openProdctSheet({
    required BuildContext context,
    required String productID,
    bool isUpdate = false,
  }) async {
    final selected = await CupertinoOptionsPicker.show<Product>(
      context: context,
      title: 'Product',
      provider: ProductGetList,
      label: (p) => p.productName ?? "",
      initialKey: (p) => p.productID ?? "",
      initialValue: productID,
    );

    if (selected == null) return;

    if (isUpdate) {
      // ref
      //     .read(appointmentEditProvider(widget.appointmentID).notifier)
      //     .updateProduct(selected);
    } else {
      // ref
      //     .read(appointmentEditProvider(widget.appointmentID).notifier)
      //     .addProduct(selected);
    }
  }

  void removeProduct(String productId) {
    // ref
    //     .read(appointmentEditProvider(widget.appointmentID).notifier)
    //     .removeProduct(productId);
  }

  void deleteAppointment(String appointmentId) {
    Widget actionContainer({
      required AppText appText,
      required VoidCallback onTap,
    }) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 11),
          width: double.infinity,
          height: 44,
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(10),
          ),
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
                  appText: AppText(
                    label: 'Delete Appointment',
                    textColor: Color(0xFFFF382B),
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    showDeleteConfirmDialog(context);
                  },
                ),
                actionContainer(
                  appText: AppText(
                    label: 'Cancel',
                    textColor: Color(0xFF007BFE),
                  ),
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
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("Delete Appointment"),
          content: const Text(
            "Are you sure you want to delete this appointment?",
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: AppText(label: 'Cancel', textColor: Color(0xFF007BFE)),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => confirmDeleteAppointment(),
              child: AppText(label: 'Delete', textColor: Color(0xFFFF382B)),
            ),
          ],
        );
      },
    );
  }

  void confirmDeleteAppointment() async {
    // Navigator.pop(context);
    // final result = await ref
    //     .read(appointmentEditProvider(widget.appointmentID).notifier)
    //     .deleteAppointment();
    // if (!result) return;

    // Navigator.of(
    //   context,
    // ).popUntil((route) => route.settings.name == '/appointmentList');
  }

  void handleSave() async {
    // final result = await ref
    //     .read(appointmentEditProvider(widget.appointmentID).notifier)
    //     .updateAppointment(noted: notedController.text);
    // if (!result) return;

    // if (!mounted) return;
    // Navigator.pop(context, result);
  }

  @override
  void initState() {
    super.initState();
    notedController = TextEditingController();
  }

  @override
  void dispose() {
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
                      style: ButtonStyle(
                        iconColor: WidgetStateProperty.all(colorPrimary),
                      ),
                    ),
                    AppText(label: 'Back', textColor: colorPrimary),
                  ],
                ),
              ),
              title: AppText(
                label: 'Edit Appointment',
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
              actions: [
                TextButton(
                  onPressed: isDisabled ? () => handleSave() : null,
                  style: TextButton.styleFrom(
                    foregroundColor: isDisabled ? colorPrimary : Colors.grey,
                  ),
                  child: AppText(
                    label: 'Done',
                    textColor: isDisabled ? colorPrimary : Colors.grey,
                  ),
                ),
              ],
            ),
            body: state.data.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: colorPrimary),
              ),
              error: (e, _) => Center(
                child: AppText(
                  label: "Appointment Not Found",
                  textColor: Colors.red,
                ),
              ),
              data: (detail) => buildContent(detail),
            ),
          ),
        ),

        if (state.isLoading) ...[
          const ModalBarrier(color: Color(0x66000000), dismissible: false),
          const Center(child: CircularProgressIndicator(color: colorPrimary)),
        ],
      ],
    );
  }

  Widget buildContent(Appointments appointment) {
    final address = appointment.appointmentAddress;
    final client = appointment.client;
    final salesTerritory = client?.salesTerritory;

    //bool isShowCancelNote = appointments.appointmentStatusName == 'Canceled';

    if (!_noteInitialized) {
      notedController.text = appointment.noted ?? "";
      _noteInitialized = true;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 24,
        children: [
          AppText(
            label: '${client?.firstName} ${client?.lastName}',
            fontSize: 26,
          ),
          Column(
            spacing: 16,
            children: [
              Column(
                children: [
                  infoTile(
                    label: 'meeting',
                    value: AppText(
                      label: appointment.appointmentTypeName ?? '',
                    ),
                    onTap: () => openAppointmentTypeSheet(
                      context,
                      appointment.appointmentTypeID ?? "",
                    ),
                  ),
                  infoTile(
                    label: 'status',
                    value: AppText(
                      label: appointment.appointmentStatusName ?? '',
                    ),
                    onTap: () => openAppointmentStatusSheet(
                      context,
                      appointment.appointmentStatusID ?? "",
                    ),
                  ),
                  infoTile(
                    label: 'purpose',
                    value: AppText(label: appointment.purposeTypeName ?? ""),
                    onTap: isCanEdit
                        ? () => openPurposeSheet(
                            context,
                            appointment.purposeTypeID ?? "",
                          )
                        : null,
                    isHideIcon: !isCanEdit,
                  ),
                  infoTile(
                    label: 'territory',
                    value: AppText(
                      label: salesTerritory?.salesTerritoryName ?? '',
                    ),
                    onTap: isCanEdit
                        ? () => openTerritorySheet(
                            context,
                            salesTerritory?.salesTerritoryID ?? '',
                          )
                        : null,
                    isHideIcon: !isCanEdit,
                    isShowBorderBottom: true,
                  ),
                ],
              ),
              // if (isShowCancelNote)
              //   Column(
              //     children: [
              //       infoTile(
              //         label: 'canceled note',
              //         value: AppTextFormField(maxLines: 5),
              //         height: 126,
              //         isShowBorderBottom: true,
              //         isHideIcon: true,
              //       ),
              //   ],
              // ),
              // Column(
              //   children: [
              // datetime(
              //   label: 'Starts',
              //   datetime: appointmentDetail.appointmentDateTimeFrom,
              //   dateOnTap: isCanEdit
              //       ? () => openDatePicker(
              //           datetime: appointmentDetail.appointmentDateTimeFrom,
              //           onSelected: (value) => ref
              //               .read(
              //                 appointmentEditProvider(
              //                   widget.appointmentID,
              //                 ).notifier,
              //               )
              //               .setAppointmentFromDate(value),
              //         )
              //       : null,
              //   timeOnTap: isCanEdit
              //       ? () => openTimePicker(
              //           datetime: appointmentDetail.appointmentDateTimeFrom,
              //           onSelected: (value) => ref
              //               .read(
              //                 appointmentEditProvider(
              //                   widget.appointmentID,
              //                 ).notifier,
              //               )
              //               .setAppointmentFromTime(value),
              //         )
              //       : null,
              // ),
              // datetime(
              //   label: 'Ends',
              //   datetime: appointmentDetail.appointmentDateTimeTo,
              //   dateOnTap: isCanEdit
              //       ? () => openDatePicker(
              //           datetime: appointmentDetail.appointmentDateTimeTo,
              //           onSelected: (value) => ref
              //               .read(
              //                 appointmentEditProvider(
              //                   widget.appointmentID,
              //                 ).notifier,
              //               )
              //               .setAppointmentToDate(value),
              //           limitFirstDate:
              //               appointmentDetail.appointmentDateTimeFrom,
              //         )
              //       : null,
              //   timeOnTap: isCanEdit
              //       ? () => openTimePicker(
              //           datetime: appointmentDetail.appointmentDateTimeTo,
              //           onSelected: (value) => ref
              //               .read(
              //                 appointmentEditProvider(
              //                   widget.appointmentID,
              //                 ).notifier,
              //               )
              //               .setAppointmentToTime(value),
              //           limitFirstDate:
              //               appointmentDetail.appointmentDateTimeFrom,
              //         )
              //       : null,
              // ),
              //   ],
              // ),
              Column(
                children: [
                  infoTile(
                    label: 'mobile',
                    value: AppText(label: client?.phone ?? ""),
                    isHideIcon: true,
                  ),
                  infoTile(
                    label: 'email',
                    value: AppText(label: client?.email ?? ""),
                    isHideIcon: true,
                  ),
                  infoTile(
                    label: 'company',
                    value: AppText(label: appointment.companyName ?? ""),
                    isHideIcon: true,
                    isShowBorderBottom: true,
                  ),
                ],
              ),
              addressWidget(address == null ? null : address[0]),
              // productTile(products: products),
              // infoTile(
              //   label: 'note',
              //   value: AppTextFormField(
              //     controller: notedController,
              //     onChanged: (value) => ref
              //         .read(
              //           appointmentEditProvider(widget.appointmentID).notifier,
              //         )
              //         .setNoted(value),
              //     maxLines: 5,
              //   ),
              //   height: 126,
              //   isShowBorderBottom: true,
              //   isHideIcon: true,
              // ),
              //GestureDetector(
              // onTap: () => deleteAppointment(appointmentDetail.appointmentId),
              // child: Container(
              //   width: double.infinity,
              //   height: 44,
              //   color: Colors.white,
              //   child: Center(
              //     child: AppText(
              //       label: 'Delete Appointment',
              //       fontSize: 17,
              //       textColor: Color(0xFFFF382B),
              //     ),
              //   ),
              // ),
              //),
            ],
          ),
        ],
      ),
    );
  }

  Widget infoTile({
    required String label,
    required Widget value,
    VoidCallback? onTap,
    double height = 44,
    bool isShowBorderMiddle = true,
    bool isShowBorderBottom = false,
    bool isHideIcon = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Color(0xFFFFFFFF),
          border: Border(
            top: borderSide,
            bottom: isShowBorderBottom ? borderSide : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Container(
              width: 100,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: BorderDirectional(
                  end: isShowBorderMiddle
                      ? BorderSide(color: colorGrey, width: borderWidth)
                      : BorderSide.none,
                ),
              ),
              child: AppText(label: label, textColor: const Color(0xFF007AFF)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Align(alignment: Alignment.centerLeft, child: value),
            ),
            if (!isHideIcon) ...[
              Icon(Icons.chevron_right, size: 24, color: colorGrey),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget datetime({
    required String label,
    required String datetime,
    bool isShowBorderBottom = false,
    VoidCallback? dateOnTap,
    timeOnTap,
  }) {
    final dt = DateTime.parse(datetime);
    final date = DateFormat("MMM d, yyyy").format(dt);
    final time = DateFormat("h:mm a").format(dt);

    Widget datetimeField({required String value, VoidCallback? onTap}) {
      return GestureDetector(
        onTap: onTap,
        child: IntrinsicWidth(
          child: Container(
            height: 35,
            padding: EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color.fromRGBO(118, 118, 128, 0.12),
              borderRadius: BorderRadius.all(Radius.circular(7)),
            ),
            child: AppText(label: value, fontSize: 17),
          ),
        ),
      );
    }

    return infoTile(
      label: label,
      value: Container(
        margin: EdgeInsets.only(right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: 4,
          children: [
            datetimeField(value: date, onTap: dateOnTap),
            datetimeField(value: time, onTap: timeOnTap),
          ],
        ),
      ),
      isShowBorderMiddle: false,
      isShowBorderBottom: isShowBorderBottom,
      isHideIcon: true,
    );
  }

  Widget addressWidget(AppointmentAddress? address) {
    Widget addressField({
      required Widget child,
      bool hasRightBorder = false,
      bool hasBottomBorder = true,
    }) {
      return Container(
        height: 44,
        decoration: BoxDecoration(
          border: Border(
            right: hasRightBorder ? borderSide : BorderSide.none,
            bottom: hasBottomBorder ? borderSide : BorderSide.none,
          ),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        child: child,
      );
    }

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
                  child: AppText(
                    label: 'address',
                    textColor: Color(0xFF007AFF),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    addressField(child: AppText(label: address?.address ?? "")),
                    addressField(
                      child: AppText(label: address?.subDistrictName ?? ""),
                    ),
                    addressField(
                      child: AppText(label: address?.districtName ?? ""),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: addressField(
                            child: AppText(label: address?.provinceName ?? ""),
                            hasRightBorder: true,
                          ),
                        ),
                        Expanded(
                          child: addressField(
                            child: AppText(label: address?.countryName ?? ""),
                          ),
                        ),
                      ],
                    ),
                    addressField(
                      child: AppText(label: address?.postCode ?? ""),
                      hasBottomBorder: false,
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

  Widget productTile({
    required List<Product> products,
    bool isShowBorderBottom = false,
  }) {
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
                  child: AppText(
                    label: 'products',
                    textColor: Color(0xFF007AFF),
                  ),
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
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: colorGrey,
                                width: borderWidth,
                              ),
                            ),
                          ),
                          height: 44,
                          child: Row(
                            children: [
                              GestureDetector(
                                // onTap: () => removeProduct(product.productId),
                                // child: Padding(
                                //   padding: const EdgeInsets.only(left: 16),
                                //   child: Icon(
                                //     Icons.remove_circle,
                                //     color: Color(0xFFFF382B),
                                //     size: 24,
                                //   ),
                                // ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  // onTap: () => openProdctSheet(
                                  //   context: context,
                                  //   productID: product.productId,
                                  //   isUpdate: true,
                                  // ),
                                  // child: Padding(
                                  //   padding: const EdgeInsets.only(left: 16),
                                  //   child: AppText(label: product.productName),
                                  // ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    GestureDetector(
                      onTap: () =>
                          openProdctSheet(context: context, productID: ""),
                      child: SizedBox(
                        height: 44,
                        child: Row(
                          children: const [
                            SizedBox(width: 16),
                            Icon(
                              Icons.add_circle,
                              color: Color(0xFF31C859),
                              size: 24,
                            ),
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
