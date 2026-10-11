import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/survey/models/survey_recipient.dart';
import 'package:wfs/features/survey/models/survey_recipient_filter.dart';
import 'package:wfs/features/survey/pages/survey_recipient_answer.dart';
import 'package:wfs/features/survey/widgets/survey_recipient_tile.dart';
import 'package:wfs/features/survey/widgets/survey_recipient_filter_sheet.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';

class SurveyRecipientListPage extends ConsumerStatefulWidget {
  final String surveyTemplateID;
  final String title;

  const SurveyRecipientListPage({required this.surveyTemplateID, required this.title, super.key});

  @override
  ConsumerState<SurveyRecipientListPage> createState() => _SurveyRecipientListPageState();
}

class _SurveyRecipientListPageState extends ConsumerState<SurveyRecipientListPage> {
  String _searchQuery = '';
  SurveyRecipientFilter _filter = emptySurveyRecipientFilter;

  ({String surveyTemplateID, String sText, SurveyRecipientFilter filter}) get _searchParams => (surveyTemplateID: widget.surveyTemplateID, sText: _searchQuery, filter: _filter);

  Future<void> _showFilterSheet() async {
    final filter = await showFilterSheet(context: context, initialFilter: _filter);
    if (!mounted || filter == null) return;
    setState(() => _filter = filter);
    ref.invalidate(surveyRecipientListProvider(_searchParams));
  }

  void _search(String query) {
    setState(() => _searchQuery = query.trim());
    ref.invalidate(surveyRecipientListProvider(_searchParams));
  }

  Future<void> _refresh() async {
    try {
      final next = ref.refresh(surveyRecipientListProvider(_searchParams).future);
      await next;
    } catch (_) {
      // The provider state shows the request error.
    }
  }

  @override
  Widget build(BuildContext context) {
    final answers = ref.watch(surveyRecipientListProvider(_searchParams));
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppUtility.colorPrimary),
        centerTitle: true,
        title: AppText(label: '', fontSize: 17, fontWeight: FontWeight.w600),
        actions: [
          IconButton(
            tooltip: 'Filter',
            icon: Icon(Icons.filter_list, color: _filter != emptySurveyRecipientFilter ? AppUtility.colorPrimary : null),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEFEFEF)),
            Expanded(
              child: answers.when(
                skipLoadingOnRefresh: false,
                loading: () => const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary)),
                error: (_, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppText(label: 'Unable to load', textColor: AppUtility.colorRed),
                      const SizedBox(height: 8),
                      TextButton(onPressed: _refresh, child: const Text('Retry')),
                    ],
                  ),
                ),
                data: _buildRecipientList,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: TextField(
          textInputAction: TextInputAction.done,
          onSubmitted: _search,
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

  Widget _buildRecipientList(List<SurveyRecipient> answers) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: answers.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 240),
                Center(child: AppText(label: 'No Recipient found')),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: answers.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => SurveyRecipientAnswerPage(surveyResponseID: answers[index].surveyResponseID))),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SurveyRecipientTile(recipient: answers[index]),
                ),
              ),
            ),
    );
  }
}
