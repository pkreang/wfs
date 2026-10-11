import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/survey/pages/survey_form_page.dart';
import 'package:wfs/features/survey/widgets/survey_list_widget.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_filter_sheet.dart';
import 'package:wfs/widgets/app_text.dart';

Future<void> showFilterSheet({required BuildContext context, required WidgetRef ref}) async {
  FocusScope.of(context).unfocus();
  final selectedStatus = ValueNotifier<bool?>(ref.read(surveyListProvider).isActive);

  try {
    await AppFilterSheet.show<void>(
      context: context,
      child: ValueListenableBuilder<bool?>(
        valueListenable: selectedStatus,
        builder: (context, status, child) {
          Widget buildStatusChip({required String label, required bool value}) {
            final isSelected = status == value;

            return GestureDetector(
              onTap: () => selectedStatus.value = value,
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

          return Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              children: [
                buildStatusChip(label: 'Active', value: true),
                buildStatusChip(label: 'InActive', value: false),
              ],
            ),
          );
        },
      ),
      onClear: () => selectedStatus.value = null,
      onSearch: () => ref.read(surveyListProvider.notifier).setStatusFilter(selectedStatus.value),
    );
  } finally {
    selectedStatus.dispose();
  }
}

class SurveyListPage extends ConsumerWidget {
  const SurveyListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(surveyListProvider);
    final countText = state.surveys.when(data: (surveys) => '${surveys.length} Entry', loading: () => 'Loading...', error: (_, _) => 'Error');

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        centerTitle: true,
        leadingWidth: 98,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SurveyFormPage(), fullscreenDialog: true)),
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
            const AppText(label: 'Survey', fontSize: 17, fontWeight: FontWeight.w600),
            AppText(label: countText, fontSize: 12, textColor: Colors.grey),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Filter',
            icon: Icon(Icons.filter_list, color: state.isActive != null ? AppUtility.colorPrimary : null),
            onPressed: () => showFilterSheet(context: context, ref: ref),
          ),
        ],
        shape: const Border(bottom: BorderSide(color: Color.fromRGBO(60, 60, 67, 0.36), width: 0.5)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(ref),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEFEFEF)),
            const Expanded(child: SurveyListWidget()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(WidgetRef ref) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: TextField(
          textInputAction: TextInputAction.done,
          onSubmitted: (query) => ref.read(surveyListProvider.notifier).setSearchQuery(query),
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
      ),
    );
  }
}
