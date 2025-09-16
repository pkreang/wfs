import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/models/address.dart';
import 'package:wfs/features/appointment/models/appointment_detail.dart';
import 'package:wfs/features/appointment/views/appointment_edit_page.dart';
import 'package:wfs/features/appointment/views/appointment_visit_page.dart';
import 'package:wfs/features/appointment/widgets/app_map.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/features/appointment/widgets/appointment_status_capsule.dart';
import 'package:wfs/features/appointment/widgets/appointment_type_capsule.dart';
import 'package:wfs/features/appointment/widgets/client_status.dart';
import 'package:wfs/features/appointment/widgets/level_status.dart';

class AppointmentDetailPage extends ConsumerStatefulWidget {
  final String appointmentID;
  const AppointmentDetailPage({required this.appointmentID, super.key});

  @override
  ConsumerState<AppointmentDetailPage> createState() => _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends ConsumerState<AppointmentDetailPage> {
  final baseLineHeight = 22;
  final colorPrimary = const Color(0xFF007AFF);
  final colorGray = const Color(0x993C3C43);

  @override
  void initState() {
    super.initState();
  }

  void callEditPage() async {
    final result = await Navigator.push(context, MaterialPageRoute<bool>(builder: (BuildContext context) => AppointmentEditPage(appointmentID: widget.appointmentID)));
    if (result == true && mounted) {
      await ref.read(appointmentDetailProvider(widget.appointmentID).notifier).refresh();
    }
  }

  void callVisitPage() async {
    final result = await Navigator.push(context, MaterialPageRoute<bool>(builder: (BuildContext context) => AppointmentVisitPage(appointmentID: widget.appointmentID)));
    if (result == true && mounted) {
      await ref.read(appointmentDetailProvider(widget.appointmentID).notifier).refresh();
    }
  }

  void handelComplete() async {
    await ref
        .read(appointmentProvider.notifier)
        .updateAppointmentStatus(
          appointmentID: widget.appointmentID,
          appointmentStatusID: "C9B78060-8F8C-46FA-92A6-65D932701EB7",
          currentDate: DateTime.now(),
          onSuccess: () => ref.read(appointmentDetailProvider(widget.appointmentID).notifier).refresh(),
        );
    // await ref.read(appointmentDetailProvider(widget.appointmentID).notifier).updateAppointmentStatus(appointmentID: widget.appointmentID, appointmentStatusID: "C9B78060-8F8C-46FA-92A6-65D932701EB7");
    // if (result == true && mounted) {
    //   await ref.read(appointmentDetailProvider(widget.appointmentID).notifier).refresh();
    // }
  }

  Future<void> openGoogleMap(double lat, double lng) async {
    if (lat == 0 || lng == 0) return;

    final uri = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open Google Maps';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appointmentDetailProvider(widget.appointmentID));

    return state.when(
      loading: () => Center(child: CircularProgressIndicator(color: colorPrimary)),
      error: (e, _) {
        return Center(
          child: AppText(label: "Appointment Not Found", textColor: Colors.red),
        );
      },
      data: (appointmentDetail) {
        final isComplete = appointmentDetail.appointmentStatusID.isCompleted;
        final isCanceled = appointmentDetail.appointmentStatusID.isCanceled;

        return Scaffold(
          backgroundColor: Color(0xFFEEEEEE),
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Color(0xFFEEEEEE),
            leadingWidth: 80,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Row(
                children: [
                  IconButton(
                    icon: Row(
                      children: [
                        const Icon(Icons.chevron_left),
                        AppText(label: 'Back', textColor: colorPrimary),
                      ],
                    ),
                    onPressed: null,
                    style: ButtonStyle(iconColor: WidgetStateProperty.all(colorPrimary)),
                  ),
                ],
              ),
            ),
            title: AppText(label: 'Appointment details', fontSize: 17, fontWeight: FontWeight.w600),
            actions: [
              if (!isComplete && !isCanceled)
                TextButton(
                  onPressed: () => callEditPage(),
                  child: AppText(label: 'Edit', textColor: colorPrimary),
                ),
            ],
          ),
          body: buildContent(appointmentDetail),
        );
      },
    );
  }

  Widget buildContent(AppointmentDetail appointmentDetail) {
    final address = appointmentDetail.address;
    final client = appointmentDetail.client;
    final salesTerritory = client.salesTerritory;
    // final products = appointmentDetail.products;

    //* appointmentType = visit, appointmentStatus != complete
    final isShowIconCheckIn = appointmentDetail.appointmentTypeID == "7DEEC491-A5AE-4856-B981-7E91870179FF" && appointmentDetail.appointmentStatusID != "C9B78060-8F8C-46FA-92A6-65D932701EB7";
    final isShowIconComplete = appointmentDetail.appointmentTypeID != "7DEEC491-A5AE-4856-B981-7E91870179FF" && !appointmentDetail.appointmentStatusID.isCompleted;

    final visitActivities = appointmentDetail.visitActivities;
    final isCheckIn = visitActivities.isEmpty;
    final visitTitle = isCheckIn ? 'check in' : 'check out';

    final latitude = visitActivities.isNotEmpty ? visitActivities.first.checkInLatitude : 0.0;
    final longitude = visitActivities.isNotEmpty ? visitActivities.first.checkInLongitude : 0.0;

    return SingleChildScrollView(
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
                      AppointmentTypeCapsule(appointmentTypeName: appointmentDetail.appointmentTypeName),
                      AppointmentStatusCapsule(appointmentStatusName: appointmentDetail.appointmentStatusName),
                      ClientStatus(clientStatusName: client.clientStatusName),
                      LevelStatus(levelStatusName: client.clientLevelName),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  buildActionCard(icon: Icons.person, title: 'clients', onTap: () => print('client page')),
                  buildActionCard(icon: Icons.location_pin, title: 'map', onTap: () => openGoogleMap(latitude ?? 0, longitude ?? 0)),
                  if (isShowIconCheckIn) buildActionCard(icon: Icons.menu_book, title: visitTitle, onTap: () => callVisitPage()),
                  if (isShowIconComplete) buildActionCard(icon: Icons.check_circle, title: 'complete', onTap: () => handelComplete()),
                  buildActionCard(icon: Icons.history, title: 'history', onTap: () => print('history page')),
                ],
              ),
            ],
          ),
          AppMap(lat: latitude, lng: longitude),
          buildContentCard(
            title: 'purpose',
            descWidget: AppText(label: appointmentDetail.purposeTypeName, textColor: colorPrimary),
            fullWidth: true,
          ),
          Row(
            spacing: 16,
            children: [
              Expanded(
                child: buildContentCard(
                  title: 'time',
                  descWidget: AppText(label: '${appointmentDetail.appointmentDateTimeFrom.dateTimetoHHmm()} - ${appointmentDetail.appointmentDateTimeTo.dateTimetoHHmm()}'),
                ),
              ),
              Expanded(
                child: buildContentCard(
                  title: 'territory',
                  descWidget: AppText(label: salesTerritory?.salesTerritoryName ?? ''),
                ),
              ),
            ],
          ),
          buildContentCard(
            title: 'address',
            descWidget: AppText(label: address.fullAddress, maxLines: 2),
            fullWidth: true,
          ),
          buildContentCard(
            title: 'mobile',
            descWidget: AppText(label: appointmentDetail.phone),
            fullWidth: true,
          ),
          buildContentCard(
            title: 'email',
            descWidget: AppText(label: appointmentDetail.email),
            fullWidth: true,
          ),
          buildContentCard(
            title: 'company',
            descWidget: AppText(label: appointmentDetail.companyName),
            fullWidth: true,
          ),
          // buildContentCard(
          //   title: 'products',
          //   descWidget: ListView.separated(
          //     padding: EdgeInsets.zero,
          //     shrinkWrap: true,
          //     physics: const NeverScrollableScrollPhysics(),
          //     itemCount: products.length,
          //     itemBuilder: (_, index) {
          //       return Container(
          //         alignment: Alignment.centerLeft,
          //         height: 38,
          //         child: AppText(label: products[index].productName, textColor: colorPrimary),
          //       );
          //     },
          //     separatorBuilder: (_, _) => const Divider(height: 0, thickness: 0.33, color: Color(0xFFC7C7CC)),
          //   ),
          //   fullWidth: true,
          // ),
          buildContentCard(
            title: 'note',
            descWidget: AppText(label: appointmentDetail.noted, maxLines: null),
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget buildActionCard({required IconData icon, required String title, required VoidCallback onTap}) {
    return Material(
      color: const Color(0xFFFFFFFF),
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: onTap,
        splashColor: const Color(0x33007AFF),
        highlightColor: Colors.transparent,
        child: Container(
          width: 70,
          height: 58,
          padding: EdgeInsets.all(6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: colorPrimary, size: 24),
              AppText(label: title, textColor: colorPrimary, fontSize: 12, lineHeight: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildContentCard({required String title, required Widget descWidget, bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(11)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(label: title, fontSize: 12),
          descWidget,
        ],
      ),
    );
  }
}
