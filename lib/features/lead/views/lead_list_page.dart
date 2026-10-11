import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/widgets/app_datepicker.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/features/lead/models/lead.dart';
import 'package:wfs/features/lead/views/lead_create_page.dart';
import 'package:wfs/features/lead/views/lead_detail_page.dart';
import 'package:wfs/features/lead/widgets/lead_list_item.dart';
import 'package:wfs/providers/lead_filter_provider.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_filter_sheet.dart';

Future<void> refreshLeads(WidgetRef ref) async {
  ref.invalidate(leadListProvider);
}

Future<bool> showFilterSheet({required BuildContext context, required WidgetRef ref}) async {
  var completed = false;

  void resetFilters() {
    ref.read(leadFilterProvider.notifier).reset();
  }

  AppFilterSheet.show(
    context: context,
    child: Consumer(
      builder: (context, ref, child) {
        final filter = ref.watch(leadFilterProvider);
        final currentMonth = filter.startDate ?? DateTime.now();

        Widget buildStatusChip({required String label, required String value}) {
          final isSelected = filter.status == value;

          return GestureDetector(
            onTap: () => ref.read(leadFilterProvider.notifier).setStatus(value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: isSelected ? const Color(0xFF0689FF) : Colors.grey.shade400, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: AppText(label: label, fontSize: 14, textColor: isSelected ? const Color(0xFF0689FF) : Colors.grey),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            GestureDetector(
              onTap: () async {
                await showDialog<DateTime>(
                  context: context,
                  builder: (pickerContext) => Dialog(
                    child: AppDatePicker(
                      appointmentMarkDate: const {},
                      currentMonth: currentMonth,
                      selectedDate: filter.startDate,
                      onConfirm: (date) => ref.read(leadFilterProvider.notifier).setStartDate(date),
                      onClose: () => Navigator.of(pickerContext).pop(),
                    ),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AppText(
                  label: filter.startDate == null ? 'เลือกวันที่เริ่มต้น' : 'วันที่เริ่มต้น: ${DateFormat('dd/MM/yyyy').format(filter.startDate!)}',
                  fontSize: 14,
                  textColor: filter.startDate == null ? Colors.grey : Colors.black,
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                await showDialog<DateTime>(
                  context: context,
                  builder: (pickerContext) => Dialog(
                    child: AppDatePicker(
                      appointmentMarkDate: const {},
                      currentMonth: currentMonth,
                      selectedDate: filter.endDate,
                      onConfirm: (date) => ref.read(leadFilterProvider.notifier).setEndDate(date),
                      onClose: () => Navigator.of(pickerContext).pop(),
                    ),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AppText(
                  label: filter.endDate == null ? 'เลือกวันที่สิ้นสุด' : 'วันที่สิ้นสุด: ${DateFormat('dd/MM/yyyy').format(filter.endDate!)}',
                  fontSize: 14,
                  textColor: filter.endDate == null ? Colors.grey : Colors.black,
                ),
              ),
            ),
            Wrap(
              spacing: 8,
              children: [
                buildStatusChip(label: 'ทั้งหมด', value: 'all'),
                buildStatusChip(label: 'Active', value: 'Active'),
                buildStatusChip(label: 'Win', value: 'Win'),
                buildStatusChip(label: 'Lose', value: 'Lose'),
                buildStatusChip(label: 'UnQualify', value: 'UnQualify'),
              ],
            ),
          ],
        );
      },
    ),
    onClear: () {
      resetFilters();
    },
    onClose: () => ref.read(leadFilterProvider.notifier).discardChanges(),
    onSearch: () {
      ref.read(leadFilterProvider.notifier).search();
      // final filter = ref.read(dashboardAppliedFilterProvider);
      ref.invalidate(leadListProvider);
      // ref.invalidate(appointmentSummaryProvider(filter.startDate));
    },
  );

  return completed;
}

class LeadScreen extends ConsumerStatefulWidget {
  const LeadScreen({super.key});

  @override
  ConsumerState<LeadScreen> createState() => _LeadScreenState();
}

class _LeadScreenState extends ConsumerState<LeadScreen> {
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
    ref.read(leadListProvider.notifier).setSearchQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leadListProvider);
    final isFilterSearched = ref.watch(leadFilterProvider.select((filter) => filter.isSearch));
    final countText = state.leads.when(data: (leads) => '${leads.length} Entry', loading: () => 'Loading...', error: (err, stack) => 'Error');

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        centerTitle: true,
        leadingWidth: 98,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CreateLeadScreen(), fullscreenDialog: true)),
          child: Row(
            children: [
              IconButton(
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
            const AppText(label: 'Lead', fontSize: 17, fontWeight: FontWeight.w600),
            AppText(label: countText, fontSize: 12, textColor: Colors.grey),
          ],
        ),
        actions: [
          Center(
            child: IconButton(
              icon: Icon(Icons.filter_list, color: isFilterSearched ? AppUtility.colorPrimary : null),
              onPressed: () => showFilterSheet(context: context, ref: ref),
            ),
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
                onRefresh: () async => refreshLeads(ref),
                child: state.leads.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                  data: (leads) {
                    if (leads.isEmpty) {
                      return const Center(child: AppText(label: 'No leads found.'));
                    }
                    return _buildLeadList(state.sections);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildLeadList(Map<String, List<Lead>> sections) {
    final sectionKeys = sections.keys.toList()..sort();
    if (sectionKeys.isEmpty) {
      return const Center(child: AppText(label: 'No leads found.'));
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: sectionKeys.length,
      itemBuilder: (context, index) {
        final sectionKey = sectionKeys[index];
        final sectionLeads = sections[sectionKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: AppText(label: sectionKey, textColor: const Color(0xFF6E6E73), fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEFEFEF)),
            ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sectionLeads.length,
              itemBuilder: (context, itemIndex) {
                final lead = sectionLeads[itemIndex];
                return LeadListItem(
                  lead: lead,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => LeadDetailPage(leadID: lead.leadID ?? ''))),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
