import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/features/territory/models/territory_model.dart';
import 'package:wfs/features/territory/views/territory_create_screen.dart';
import 'package:wfs/features/territory/views/territory_detail_page.dart';
import 'package:wfs/features/territory/widgets/territory_status_capsule.dart';
import 'package:wfs/utility/app_utility.dart';

final territorySearchProvider = StateProvider.autoDispose<String>((ref) => '');

final filteredTerritoriesProvider = Provider.autoDispose<AsyncValue<List<TerritoryModel>>>((ref) {
  final state = ref.watch(territoryListProvider);
  final searchQuery = ref.watch(territorySearchProvider).toLowerCase().trim();

  return state.territories.when(
    data: (territories) {
      if (searchQuery.isEmpty) return AsyncValue.data(territories);

      final filteredList = territories.where((territory) {
        final territoryName = territory.salesTerritoryName.toLowerCase();
        final territoryDescription = territory.salesTerritoryDescription.toLowerCase();

        if (searchQuery.startsWith('name:')) {
          final nameQuery = searchQuery.substring(5).trim();
          return territoryName.contains(nameQuery);
        }

        if (searchQuery.startsWith('description:')) {
          final descriptionQuery = searchQuery.substring(12).trim();
          return territoryDescription.contains(descriptionQuery);
        }

        return territoryName.contains(searchQuery) || territoryDescription.contains(searchQuery);
      }).toList();

      return AsyncValue.data(filteredList);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

final filteredTerritorySectionsProvider = Provider.autoDispose<Map<String, List<TerritoryModel>>>((ref) {
  final territoriesAsync = ref.watch(filteredTerritoriesProvider);

  return territoriesAsync.maybeWhen(
    data: (territories) {
      final Map<String, List<TerritoryModel>> sections = {};
      for (final territory in territories) {
        final name = territory.salesTerritoryName.trim();
        if (name.isEmpty) continue;
        final firstChar = name[0].toUpperCase();
        sections.putIfAbsent(firstChar, () => []).add(territory);
      }
      return sections;
    },
    orElse: () => const {},
  );
});

Future<void> refreshTerritories(WidgetRef ref) async {
  ref.invalidate(territoryListProvider);
}

class TerritoryScreen extends ConsumerStatefulWidget {
  const TerritoryScreen({super.key});

  @override
  ConsumerState<TerritoryScreen> createState() => _TerritoryScreenState();
}

class _TerritoryScreenState extends ConsumerState<TerritoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(territorySearchProvider.notifier).state = _searchController.text;
  }

  void _handleDeleteTerritory(String territoryID) {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('Delete Territory', textScaler: TextScaler.noScaling),
          content: const Text('Are you sure you want to delete this territory?', textScaler: TextScaler.noScaling),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const AppText(label: 'Cancel', textColor: Color(0xFF007BFE)),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () async {
                Navigator.pop(dialogContext);
                await ref.read(territoryListProvider.notifier).onRemoveTerritory(territoryID);
              },
              child: const AppText(label: 'Delete', textColor: Color(0xFFFF382B)),
            ),
          ],
        );
      },
    );
  }

  void _openTerritoryDetail(TerritoryModel territory) {
    final territoryID = territory.salesTerritoryID ?? '';

    if (territoryID.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Territory ID not found')));
      return;
    }

    Navigator.of(context).push(MaterialPageRoute(builder: (context) => TerritoryDetailPage(territoryID: territoryID)));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(territoryListProvider);
    final filteredTerritories = ref.watch(filteredTerritoriesProvider);
    final filteredSections = ref.watch(filteredTerritorySectionsProvider);
    final countText = filteredTerritories.when(data: (items) => '${items.length} Territory', loading: () => 'Loading...', error: (_, __) => 'Error');

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF6F6F6),
          appBar: AppBar(
            centerTitle: true,
            leadingWidth: 98,
            leading: GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CreateTerritoryScreen(), fullscreenDialog: true)),
              child: Row(
                children: [
                  state.isEdit
                      ? const SizedBox.shrink()
                      : IconButton(
                          icon: Row(
                            children: [
                              const Icon(Icons.add),
                              AppText(label: 'Create', textColor: AppUtility.colorPrimary, fontSize: 17, fontWeight: FontWeight.w500),
                            ],
                          ),
                          onPressed: null,
                          style: ButtonStyle(iconColor: WidgetStateProperty.all(AppUtility.colorPrimary)),
                        ),
                ],
              ),
            ),
            title: Column(
              children: [
                const AppText(label: 'Territory', fontSize: 17, fontWeight: FontWeight.w600),
                AppText(label: countText, fontSize: 12, textColor: Colors.grey),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => ref.read(territoryListProvider.notifier).setEditMode(),
                child: AppText(label: state.isEdit ? 'Done' : 'Edit', textColor: AppUtility.colorPrimary, fontSize: 17, fontWeight: FontWeight.w500),
              ),
            ],
            shape: const Border(bottom: BorderSide(color: Color.fromRGBO(60, 60, 67, 0.36), width: 0.5)),
          ),
          body: SafeArea(
            child: Column(
              children: [
                _buildSearchBar(),
                const Divider(height: 1, thickness: 1, color: Color(0xFFEFEFEF)),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => refreshTerritories(ref),
                    child: filteredTerritories.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, _) => Center(child: Text('Error: $error')),
                      data: (items) {
                        if (items.isEmpty) {
                          return const Center(child: AppText(label: 'No territories found.'));
                        }

                        return _buildTerritoryList(filteredSections, state.isEdit);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (state.isLoading) ...[const ModalBarrier(color: Color(0x66000000), dismissible: false), const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary))],
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: const Color(0xFFFFFFFF),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
          filled: true,
          fillColor: const Color(0xFFF2F2F7),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildTerritoryList(Map<String, List<TerritoryModel>> sections, bool isEdit) {
    final sectionKeys = sections.keys.toList()..sort();

    if (sectionKeys.isEmpty) {
      return const Center(child: AppText(label: 'No territories found.'));
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: sectionKeys.length,
      itemBuilder: (context, index) {
        final sectionKey = sectionKeys[index];
        final sectionTerritories = sections[sectionKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: AppText(label: sectionKey, textColor: const Color(0xFF6E6E73), fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEFEFEF)),
            ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sectionTerritories.length,
              itemBuilder: (context, itemIndex) => _buildTerritoryCard(sectionTerritories[itemIndex], isEdit),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTerritoryCard(TerritoryModel territory, bool isEdit) {
    return Container(
      color: const Color(0xFFFFFFFF),
      child: Row(
        children: [
          if (isEdit)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: GestureDetector(
                onTap: () => _handleDeleteTerritory(territory.salesTerritoryID ?? ''),
                child: const Icon(Icons.remove_circle, color: Color(0xFFFF382B), size: 24),
              ),
            ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _openTerritoryDetail(territory),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                spacing: 8,
                                children: [
                                  Flexible(child: AppText(label: territory.salesTerritoryName, fontSize: 17)),
                                  TerritoryStatusCapsule(isActive: territory.isActive),
                                ],
                              ),
                              const SizedBox(height: 8),
                              AppText(label: territory.salesTerritoryDescription.isEmpty ? 'No description' : territory.salesTerritoryDescription, textColor: Colors.grey, fontSize: 14, maxLines: 2),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade300),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 0.33, thickness: 0.33, indent: 1, color: Color(0xFFCBCBCB)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
