import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/models/appointment_detail.dart';
import 'package:wfs/features/appointment/models/outcome.dart';
import 'package:wfs/features/appointment/models/visit_activities.dart';
import 'package:wfs/features/appointment/widgets/app_camera.dart';
import 'package:wfs/features/appointment/widgets/app_cupertino_option.dart';
import 'package:wfs/features/appointment/widgets/app_map.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/features/appointment/widgets/app_text_form_field.dart';
import 'package:wfs/features/appointment/widgets/appointment_status.dart';
import 'package:wfs/features/appointment/widgets/appointment_type.dart';
import 'package:wfs/features/appointment/widgets/client_status.dart';
import 'package:wfs/features/appointment/widgets/level_status.dart';
import 'package:wfs/services/camera_service.dart';
import 'package:wfs/services/location_service.dart';

class Location {
  final double lat;
  final double lng;
  final String? address;

  const Location({required this.lat, required this.lng, this.address});
}

class AppointmentVisitPage extends ConsumerStatefulWidget {
  final String appointmentID;

  const AppointmentVisitPage({required this.appointmentID, super.key});

  @override
  ConsumerState<AppointmentVisitPage> createState() => _AppointmentVisitPageState();
}

class _AppointmentVisitPageState extends ConsumerState<AppointmentVisitPage> {
  static const colorPrimary = Color(0xFF007AFF);
  static const colorGray = Color.fromRGBO(60, 60, 67, 0.6);

  final locationService = LocationService();
  late final Future<Location?> locationFuture;

  final _formKey = GlobalKey<FormState>();
  final _noteFocus = FocusNode();
  TextEditingController meetingNotedController = TextEditingController();
  final now = DateTime.now();

  // Future<void> _requestCameraPermission() async => await requestCameraPermission();

  @override
  void initState() {
    super.initState();
  }

  Future<Location?> fetchLocation() async {
    final permission = await locationService.requestPermission(requestIfDenied: false);
    if (permission != LocationPermissionStatus.granted) return null;

    final pos = await locationService.getPosition();
    final address = await locationService.reverseGeocodeGoogle(pos.latitude, pos.longitude);

    return Location(lat: pos.latitude, lng: pos.longitude, address: address);
  }

  Future<bool> handlePermissionLocation() async {
    final status = await locationService.requestPermission();
    if (status != LocationPermissionStatus.granted) {
      if (!mounted) return false;

      switch (status) {
        case LocationPermissionStatus.servicesOff:
          await Geolocator.openLocationSettings();
          return false;
        case LocationPermissionStatus.denied:
          await Geolocator.openLocationSettings();
          return false;
        case LocationPermissionStatus.deniedForever:
          await Geolocator.openAppSettings();
          return false;
        case LocationPermissionStatus.granted:
          break;
      }
    }

    return true;
  }

  Future<void> handleCheckIn() async {
    // final ok = _formKey.currentState?.validate() ?? true;
    // if (!ok) {
    //   _noteFocus.requestFocus();
    //   return;
    // }

    final permission = await handlePermissionLocation();
    if (!permission) return;

    final permissionCamera = await ensureCameraPermission();
    if (!permissionCamera) {
      return;
    }

    final imgBase64 = await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => AppCamera()));
    if (imgBase64 == null) return;

    ref.read(appointmentVisitProvider(widget.appointmentID).notifier).loading(true);

    final pos = await locationService.getPosition();
    await ref.read(appointmentVisitProvider(widget.appointmentID).notifier).checkIn(latitude: pos.latitude, longitude: pos.longitude, imgBase64: imgBase64);
    Navigator.pop(context, true);
  }

  Future<void> handleCheckOut() async {
    // final ok = _formKey.currentState?.validate() ?? true;
    // if (!ok) {
    //   _noteFocus.requestFocus();
    //   return;
    // }

    final permission = await handlePermissionLocation();
    if (!permission) return;

    ref.read(appointmentVisitProvider(widget.appointmentID).notifier).loading(true);

    final pos = await locationService.getPosition();
    if (pos == null) return;

    final isValidate = ref.read(appointmentVisitProvider(widget.appointmentID).notifier).validateOutcome();
    if (!isValidate) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(backgroundColor: Colors.red, content: AppText(label: 'Please Select Outcome.', textColor: Colors.white, textAlign: TextAlign.center, fontSize: 16)));

      ref.read(appointmentVisitProvider(widget.appointmentID).notifier).loading(false);

      return;
    }

    await ref.read(appointmentVisitProvider(widget.appointmentID).notifier).checkOut(latitude: pos.latitude, longitude: pos.longitude);
    Navigator.pop(context, true);
  }

  Future<void> openOutcomeSheet(BuildContext context) async {
    final selected = await CupertinoOptionsPicker.show<Outcome>(
      context: context,
      title: 'Outcome',
      provider: outcomeProvider,
      label: (p) => p.outcomeName,
      initialKey: (p) => p.outcomeID,
      initialValue: '',
    );

    if (selected == null) return;

    ref.read(appointmentVisitProvider(widget.appointmentID).notifier).setOutcome(selected);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appointmentVisitProvider(widget.appointmentID));

    return state.data.when(
      loading: () => Scaffold(backgroundColor: Colors.white, body: Center(child: CircularProgressIndicator(color: colorPrimary))),
      error: (e, _) => Center(child: AppText(label: "Appointment Not Found", textColor: Colors.red)),
      data: (detail) {
        final visitActivities = detail.visitActivities;
        final location = state.location.value;

        final isCheckIn = visitActivities.isEmpty;
        final title = isCheckIn ? 'Check In' : 'Check Out';
        final isShowButton = visitActivities.isEmpty || (visitActivities.isNotEmpty && visitActivities.first.outcomeID == null);
        final isCanEdit = visitActivities.isEmpty || (visitActivities.isNotEmpty && visitActivities.first.outcomeID == null);

        final isVisitComplete = visitActivities.isNotEmpty && visitActivities.first.outcomeID != null;
        if (isVisitComplete) {
          return Container(
            alignment: Alignment.center,
            color: Colors.white,
            child: Column(
              spacing: 16,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppText(label: 'Visit Completed', fontSize: 20),
                SizedBox(
                  width: 220,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: colorPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                    child: AppText(label: 'Back', fontSize: 17, textColor: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

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
                        IconButton(icon: const Icon(Icons.chevron_left), onPressed: null, style: ButtonStyle(iconColor: WidgetStateProperty.all(colorPrimary))),
                        AppText(label: 'Cancel', textColor: colorPrimary),
                      ],
                    ),
                  ),
                  title: AppText(label: title, fontSize: 17, fontWeight: FontWeight.w600),
                ),
                body: Column(
                  children: [
                    buildContent(detail, state.visitActivity, location, isCheckIn, isCanEdit),
                    if (isShowButton)
                      SafeArea(
                        minimum: const EdgeInsets.only(bottom: 12),
                        child: SizedBox(
                          width: 220,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => isCheckIn ? handleCheckIn() : handleCheckOut(),
                            style: ElevatedButton.styleFrom(backgroundColor: colorPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                            child: AppText(label: title, fontSize: 17, textColor: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            if (state.isLoading) ...[const ModalBarrier(color: Color(0x66000000), dismissible: false), const Center(child: CircularProgressIndicator(color: colorPrimary))],
          ],
        );
      },
    );
  }

  Widget buildContent(AppointmentDetail appointmentDetail, VisitActivity? visitActivity, Location? location, bool isCheckIn, bool isCanEdit) {
    final client = appointmentDetail.client;

    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          spacing: 16,
          children: [
            Column(
              spacing: 24,
              children: [
                Column(
                  spacing: 6,
                  children: [
                    AppText(label: appointmentDetail.clientName, fontSize: 26),
                    Wrap(
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      spacing: 6,
                      children: [
                        ClientStatus(clientStatusName: client.clientStatusName),
                        LevelStatus(levelStatusName: client.clientLevelName),
                        AppointmentType(appointmentTypeName: appointmentDetail.appointmentTypeName),
                        AppointmentStatus(appointmentStatusName: appointmentDetail.appointmentStatusName),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Column(
              spacing: 16,
              children: [
                AppMap(lat: location?.lat ?? 0, lng: location?.lng ?? 0),
                buildContentCard(title: 'current time', descWidget: AppText(label: DateFormat.Hm().format(now), textColor: colorGray), fullWidth: true),
                buildContentCard(title: 'current location', descWidget: AppText(label: location?.address ?? '', textColor: colorGray, maxLines: null), fullWidth: true),
                if (!isCheckIn)
                  buildContentCard(
                    title: 'outcome',
                    descWidget: AppText(label: visitActivity?.outcomeName ?? '', textColor: colorGray, maxLines: null),
                    onTap: isCanEdit ? () => openOutcomeSheet(context) : null,
                    fullWidth: true,
                    isHideIcon: !isCanEdit,
                  ),
                Form(
                  key: _formKey,
                  child: buildContentCard(
                    title: 'meeting note',
                    descWidget: AppTextFormField(
                      focusNode: _noteFocus,
                      controller: meetingNotedController,
                      onChanged: (value) => ref.read(appointmentVisitProvider(widget.appointmentID).notifier).setNotes(value),
                      maxLines: 3,
                      // isValidate: true,
                      autovalidateMode: AutovalidateMode.disabled,
                      isDisabled: !isCanEdit,
                    ),
                    fullWidth: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildContentCard({required String title, required Widget descWidget, VoidCallback? onTap, bool fullWidth = false, bool isHideIcon = true}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(11)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(label: title, fontSize: 12),
            Row(
              children: [
                Expanded(child: descWidget),
                if (!isHideIcon) ...[Icon(Icons.chevron_right, size: 24, color: colorGray)],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
