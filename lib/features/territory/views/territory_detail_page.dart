import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/features/territory/models/territory_model.dart';
import 'package:wfs/features/territory/views/territory_edit_screen.dart';
import 'package:wfs/features/territory/widgets/territory_status_capsule.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_detail_section_card.dart';

class TerritoryDetailPage extends ConsumerStatefulWidget {
  final String territoryID;

  const TerritoryDetailPage({required this.territoryID, super.key});

  @override
  ConsumerState<TerritoryDetailPage> createState() => _TerritoryDetailPageState();
}

class _TerritoryDetailPageState extends ConsumerState<TerritoryDetailPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(territoryDetailProvider(widget.territoryID));

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary)),
      error: (e, _) => Center(
        child: AppText(label: 'Territory Not Found', textColor: Colors.red),
      ),
      data: (territory) {
        return Scaffold(
          backgroundColor: const Color(0xFFEEEEEE),
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: const Color(0xFFEEEEEE),
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
            title: AppText(label: 'Territory Info', fontSize: 17, fontWeight: FontWeight.w600),
            actions: [
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute<bool>(builder: (context) => TerritoryEditScreen(territoryID: widget.territoryID))),
                child: const AppText(label: 'Edit', textColor: AppUtility.colorPrimary),
              ),
            ],
          ),
          body: buildContent(territory),
        );
      },
    );
  }

  Widget buildContent(TerritoryModel territory) {
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
                  AppText(label: territory.salesTerritoryName, fontSize: 26, textAlign: TextAlign.center, maxLines: null),
                  Wrap(
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    spacing: 6,
                    children: [TerritoryStatusCapsule(isActive: territory.isActive)],
                  ),
                ],
              ),
            ],
          ),
          AppDetailSectionCard(
            title: 'Territory Name',
            descWidget: AppText(label: territory.salesTerritoryName, maxLines: null),
            fullWidth: true,
          ),
          AppDetailSectionCard(
            title: 'Description',
            descWidget: AppText(label: territory.salesTerritoryDescription, maxLines: null),
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}
