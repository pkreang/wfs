import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/widgets/app_map.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/features/company/models/company.dart';
import 'package:wfs/features/company/models/company_address.dart';
import 'package:wfs/features/company/views/company_edit_page.dart';
import 'package:wfs/features/company/widgets/company_status_capsule.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_action_tile.dart';
import 'package:wfs/widgets/app_detail_section_card.dart';

class CompanyDetailPage extends ConsumerStatefulWidget {
  final String companyID;

  const CompanyDetailPage({required this.companyID, super.key});

  @override
  ConsumerState<CompanyDetailPage> createState() => _CompanyDetailPageState();
}

class _CompanyDetailPageState extends ConsumerState<CompanyDetailPage> {
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
    final state = ref.watch(companyDetailProvider(widget.companyID));

    return state.when(
      loading: () => Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary)),
      error: (e, _) {
        return Center(
          child: AppText(label: "Company Not Found", textColor: Colors.red),
        );
      },
      data: (companyDetail) {
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
            title: AppText(label: 'Company Info', fontSize: 17, fontWeight: FontWeight.w600),
            actions: [
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute<bool>(builder: (BuildContext context) => CompanyEditPage(companyID: widget.companyID))),

                child: AppText(label: 'Edit', textColor: AppUtility.colorPrimary),
              ),
            ],
          ),
          body: buildContent(companyDetail),
        );
      },
    );
  }

  Widget buildContent(Company company) {
    final companyAddress = company.addresses.isNotEmpty ? company.addresses.first : null;
    final clients = company.clients;

    final lat = companyAddress?.latitude ?? 0;
    final lng = companyAddress?.longitude ?? 0;

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
                  AppText(label: company.companyName ?? '', fontSize: 26),
                  Wrap(
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    spacing: 6,
                    children: [CompanyStatusCapsule(isActive: company.isActive ?? false)],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  AppActionTile(icon: Icons.location_pin, title: 'map', onTap: () => openGoogleMap(lat, lng)),
                  // AppActionTile(
                  //   icon: Icons.person,
                  //   title: 'clients',
                  //   // onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ClientDetailPage(clientID: company.clientID))),
                  //   onTap: () {},
                  // ),
                  // AppActionTile(icon: Icons.menu_book, title: 'visit', onTap: () => {}),
                  // AppActionTile(icon: Icons.history, title: 'history', onTap: () => print('history page')),
                ],
              ),
            ],
          ),
          AppMap(lat: lat, lng: lng),
          AppDetailSectionCard(
            title: 'address',
            descWidget: AppText(label: companyAddress?.fullAddress ?? '', maxLines: 2),
            fullWidth: true,
          ),
          AppDetailSectionCard(
            title: 'territory',
            descWidget: AppText(label: company.salesTerritoryName ?? ''),
            fullWidth: true,
          ),
          AppDetailSectionCard(
            title: 'clients',
            descWidget: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: clients.length,
              itemBuilder: (_, index) {
                final client = clients[index];

                return Container(
                  alignment: Alignment.centerLeft,
                  height: 38,
                  child: AppText(label: client.clientName, textColor: AppUtility.colorPrimary),
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
