import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/survey/models/survey_dashboard_model.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';

class SurveyRecipientAnswerPage extends ConsumerWidget {
  final String surveyResponseID;

  const SurveyRecipientAnswerPage({required this.surveyResponseID, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = surveyRecipientAnswerProvider(surveyResponseID);
    final response = ref.watch(provider);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppUtility.colorPrimary),
        centerTitle: true,
        title: const AppText(label: 'คำตอบ', fontSize: 17, fontWeight: FontWeight.w600),
      ),
      body: SafeArea(
        child: response.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary)),
          error: (_, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppText(label: 'ไม่สามารถโหลดคำตอบได้', textColor: AppUtility.colorRed),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => ref.invalidate(provider),
                  child: const AppText(label: 'ลองใหม่', textColor: AppUtility.colorPrimary),
                ),
              ],
            ),
          ),
          data: (response) => RefreshIndicator(
            onRefresh: () async {
              try {
                final next = ref.refresh(provider.future);
                await next;
              } catch (_) {
                // The provider displays the request error and retry action.
              }
            },
            child: response.details.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 240),
                      Center(child: AppText(label: 'ยังไม่ได้ตอบแบบสอบถาม')),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: response.details.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _AnswerCard(detail: response.details[index]),
                  ),
          ),
        ),
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  final SurveyResponseDetail detail;

  const _AnswerCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    final isScore = detail.typeCode == 'SCORE_0_10';
    final String answer;
    if (isScore) {
      final score = detail.score;
      answer = score == null ? 'ยังไม่ได้ตอบ' : 'score: ${score.toInt().toString()}';
    } else if (detail.typeCode == 'FREE_TEXT') {
      final text = detail.freeText;
      answer = text == null || text.trim().isEmpty ? 'ยังไม่ได้ตอบ' : 'คำตอบ: $text';
    } else {
      answer = '-';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(label: detail.questionText, fontSize: 16, fontWeight: FontWeight.w600, maxLines: null),
          const SizedBox(height: 12),
          AppText(label: answer, fontSize: 14, fontWeight: FontWeight.w400, textColor: AppUtility.colorPrimary, maxLines: null),
        ],
      ),
    );
  }
}
