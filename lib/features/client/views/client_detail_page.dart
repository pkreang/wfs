import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/features/client/models/client.dart';
import 'package:wfs/features/client/views/client_edit_page.dart';
import 'package:wfs/features/client/widgets/client_level_capsule.dart';
import 'package:wfs/features/client/widgets/client_status_capsule.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_action_tile.dart';
import 'package:wfs/widgets/app_detail_section_card.dart';

class ClientDetailPage extends ConsumerStatefulWidget {
  final String clientID;
  final bool isCanEdit;

  const ClientDetailPage({required this.clientID, this.isCanEdit = false, super.key});

  @override
  ConsumerState<ClientDetailPage> createState() => _ClientDetailPageState();
}

class _ClientDetailPageState extends ConsumerState<ClientDetailPage> {
  Future<void> callPhone(String? phone) async {
    if (phone == null || phone.trim().isEmpty) return;
    final sanitized = phone.replaceAll(' ', '');
    final uri = Uri(scheme: 'tel', path: sanitized);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open phone dialer';
    }
  }

  Future<void> sendEmail(String? email) async {
    if (email == null || email.trim().isEmpty) return;
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open email app';
    }
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
    final state = ref.watch(clientDetailProvider(widget.clientID));

    return state.when(
      loading: () => Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary)),
      error: (e, _) {
        return Center(
          child: AppText(label: "Client Not Found", textColor: Colors.red),
        );
      },
      data: (appointmentDetail) {
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
                        AppText(label: 'Back', textColor: AppUtility.colorPrimary),
                      ],
                    ),
                    onPressed: null,
                    style: ButtonStyle(iconColor: WidgetStateProperty.all(AppUtility.colorPrimary)),
                  ),
                ],
              ),
            ),
            title: AppText(label: 'Client Info', fontSize: 17, fontWeight: FontWeight.w600),
            actions: [
              if (widget.isCanEdit)
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute<bool>(builder: (BuildContext context) => ClientEditPage(clientID: widget.clientID))),
                  child: AppText(label: 'Edit', textColor: AppUtility.colorPrimary),
                ),
            ],
          ),
          body: buildContent(appointmentDetail),
        );
      },
    );
  }

  Widget buildContent(Client client) {
    final clientCompanies = client.companies;
    double lat = 0;
    double lng = 0;

    if ((clientCompanies ?? []).isNotEmpty) {
      final company = (clientCompanies ?? []).first.company;
      if ((company?.addresses ?? []).isNotEmpty) {
        final companyAddress = (company?.addresses ?? []).first;
        lat = companyAddress.latitude ?? 0;
        lng = companyAddress.longitude ?? 0;
      }
    }

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
                  AppText(label: client.clientName, fontSize: 26),
                  Wrap(
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    spacing: 6,
                    children: [
                      ClientStatusCapsule(clientStatusName: client.clientStatus?.clientStatusName ?? ''),
                      ClientLevelCapsule(clientLevelName: client.clientLevel?.clientLevelName ?? ''),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  AppActionTile(icon: Icons.phone, title: 'call', onTap: () => callPhone(client.phone)),
                  AppActionTile(icon: Icons.mail, title: 'mail', onTap: () => sendEmail(client.email)),
                  AppActionTile(icon: Icons.location_pin, title: 'map', onTap: () => openGoogleMap(lat, lng)),
                  // AppActionTile(icon: Icons.menu_book, title: 'visit', onTap: () => {}),
                  // AppActionTile(icon: Icons.history, title: 'history', onTap: () => print('history page')),
                ],
              ),
            ],
          ),
          AppDetailSectionCard(
            title: 'territory',
            descWidget: AppText(label: client.salesTerritoryName ?? ''),
            fullWidth: true,
          ),
          AppDetailSectionCard(
            title: 'mobile',
            descWidget: AppText(label: client.phone ?? ''),
            fullWidth: true,
          ),
          AppDetailSectionCard(
            title: 'email',
            descWidget: AppText(label: client.email ?? ''),
            fullWidth: true,
          ),
          AppDetailSectionCard(
            title: 'company',
            descWidget: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (clientCompanies ?? []).length,
              itemBuilder: (_, index) {
                final clientCompany = (clientCompanies ?? [])[index];

                return Container(
                  alignment: Alignment.centerLeft,
                  height: 38,
                  child: AppText(label: clientCompany.company?.companyName ?? '', textColor: AppUtility.colorPrimary),
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
