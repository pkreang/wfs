import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
import 'package:wfs/features/client/views/client_detail_page.dart';
import 'package:wfs/providers/appointment_provider.dart';
import 'package:wfs/providers/auth_provider.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_action_tile.dart';
import 'package:wfs/widgets/app_detail_section_card.dart';

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

  Future<void> showCompleteConfirmDialog({required BuildContext context, required WidgetRef ref, required DateTime currentDate, required String appointmentID}) async {
    return showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: const Text("Complete Appointment", textScaler: TextScaler.noScaling),
          content: const Text("Are you sure you want to complete this appointment?", textScaler: TextScaler.noScaling),
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
              onPressed: () => confirmCompleteAppointment(context: dialogContext, ref: ref, currentDate: currentDate, appointmentID: appointmentID),
              child: AppText(label: 'Complete', textColor: Color(0xFF007BFE)),
            ),
          ],
        );
      },
    );
  }

  void confirmCompleteAppointment({required BuildContext context, required WidgetRef ref, required DateTime currentDate, required String appointmentID}) async {
    Navigator.pop(context);

    if (appointmentID.isEmpty) {
      return;
    }

    await ref
        .read(appointmentProvider.notifier)
        .updateAppointmentStatus(
          appointmentID: appointmentID,
          appointmentStatusID: "C9B78060-8F8C-46FA-92A6-65D932701EB7",
          onSuccess: () async {
            final now = DateTime.now();
            final bool isSameDate = currentDate.year == now.year && currentDate.month == now.month && currentDate.day == now.day;

            if (isSameDate) {
              ref.invalidate(appointmentsProvider(DateTime(currentDate.year, currentDate.month, currentDate.day)));
              ref.invalidate(appointmentSummaryProvider(DateTime(currentDate.year, currentDate.month, currentDate.day)));
            }

            ref.read(appointmentDetailProvider(widget.appointmentID).notifier).refresh();

            ref.read(selectedMonthProvider.notifier).setMonth(currentDate);
            ref.read(selectedDateProvider.notifier).setDate(currentDate);

            ref.read(appointmentMarkDateProvider(DateTime(currentDate.year, currentDate.month, 1)).notifier).refresh();
            ref.read(appointmentsByDateProvider(DateFormat("yyyy-MM-dd").format(currentDate)).notifier).refresh();
          },
        );
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
    final authState = ref.watch(authProvider);
    final address = appointmentDetail.address;
    final client = appointmentDetail.client;
    final salesTerritory = client.salesTerritory;
    final clientCompany = client.companies.isNotEmpty ? client.companies.first : null;
    final companyAddresses = (clientCompany?.company?.addresses ?? []);
    final companyAddress = companyAddresses.isNotEmpty ? companyAddresses.first : null;
    final tags = appointmentDetail.tags;
    // final products = appointmentDetail.products;

    bool isVisit = appointmentDetail.appointmentTypeID == "7DEEC491-A5AE-4856-B981-7E91870179FF";
    bool isOnline = appointmentDetail.appointmentTypeID.isOnline;
    bool isOnCall = appointmentDetail.appointmentTypeID.isOnCall;
    bool isComplete = appointmentDetail.appointmentStatusID.isCompleted;
    bool isCanceled = appointmentDetail.appointmentStatusID.isCanceled;

    //* appointmentType = visit, appointmentStatus != complete
    final isShowIconCheckIn = isVisit && (!isComplete && !isCanceled);
    final isShowIconComplete = (isOnline || isOnCall) && !isComplete && !isCanceled;

    final visitActivities = appointmentDetail.visitActivities;
    final isCheckIn = visitActivities.isEmpty;
    final visitTitle = isCheckIn ? 'check in' : 'check out';

    final latitude = companyAddress?.latitude ?? 0;
    final longitude = companyAddress?.longitude ?? 0;

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
                  AppActionTile(
                    icon: Icons.person,
                    title: 'clients',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ClientDetailPage(clientID: client.clientID))),
                  ),
                  AppActionTile(icon: Icons.location_pin, title: 'map', onTap: () => openGoogleMap(latitude, longitude)),
                  if (isShowIconCheckIn) AppActionTile(icon: Icons.menu_book, title: visitTitle, onTap: () => callVisitPage()),
                  if (isShowIconComplete)
                    AppActionTile(
                      icon: Icons.check_circle,
                      title: 'complete',
                      onTap: () => showCompleteConfirmDialog(
                        context: context,
                        ref: ref,
                        currentDate: DateTime.tryParse(appointmentDetail.appointmentDateTimeFrom) ?? DateTime.now(),
                        appointmentID: appointmentDetail.appointmentID,
                      ),
                    ),
                  // AppActionTile(icon: Icons.history, title: 'history', onTap: () => print('history page')),
                ],
              ),
            ],
          ),
          AppMap(lat: latitude, lng: longitude),
          AppDetailSectionCard(
            title: 'purpose',
            descWidget: AppText(label: appointmentDetail.purposeTypeName, textColor: colorPrimary),
            fullWidth: true,
          ),
          Row(
            spacing: 16,
            children: [
              Expanded(
                child: AppDetailSectionCard(
                  title: 'time',
                  descWidget: AppText(label: '${appointmentDetail.appointmentDateTimeFrom.dateTimetoHHmm()} - ${appointmentDetail.appointmentDateTimeTo.dateTimetoHHmm()}'),
                ),
              ),
              Expanded(
                child: AppDetailSectionCard(
                  title: 'territory',
                  descWidget: AppText(label: salesTerritory?.salesTerritoryName ?? ''),
                ),
              ),
            ],
          ),
          AppDetailSectionCard(
            title: 'address',
            descWidget: AppText(label: address.fullAddress, maxLines: 2),
            fullWidth: true,
          ),
          AppDetailSectionCard(
            title: 'mobile',
            descWidget: AppText(label: appointmentDetail.phone),
            fullWidth: true,
          ),
          AppDetailSectionCard(
            title: 'email',
            descWidget: AppText(label: appointmentDetail.email),
            fullWidth: true,
          ),
          AppDetailSectionCard(
            title: 'company',
            descWidget: AppText(label: appointmentDetail.companyName ?? ''),
            fullWidth: true,
          ),
          // AppDetailSectionCard(
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
          AppDetailSectionCard(
            title: 'note',
            descWidget: AppText(label: appointmentDetail.noted, maxLines: null),
            fullWidth: true,
          ),
          if (authState.isSupervisor)
            AppDetailSectionCard(
              title: 'sales',
              descWidget: AppText(label: appointmentDetail.saleName, maxLines: null),
              fullWidth: true,
            ),
          AppDetailSectionCard(
            title: 'tags',
            descWidget: tags.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: AppText(label: 'ไม่พบข้อมูล tag', textColor: AppUtility.textGray),
                  )
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tags.length,
                    itemBuilder: (_, index) {
                      final tag = tags[index];

                      return Container(
                        alignment: Alignment.centerLeft,
                        height: 38,
                        child: AppText(label: tag.tagName ?? '', textColor: AppUtility.colorPrimary),
                      );
                    },
                    separatorBuilder: (_, _) => const Divider(height: 0, thickness: 0.33, color: Color(0xFFC7C7CC)),
                  ),
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}
