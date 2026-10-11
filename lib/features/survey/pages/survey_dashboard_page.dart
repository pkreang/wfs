import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';

class SurveyDashboardPage extends ConsumerWidget {
  final String surveyID;
  final String? title;

  const SurveyDashboardPage({required this.surveyID, this.title, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(surveyDashboardProvider(surveyID));

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        centerTitle: true,
        leadingWidth: 80,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chevron_left, color: AppUtility.colorPrimary),
              AppText(label: 'Back', textColor: AppUtility.colorPrimary),
            ],
          ),
        ),
        title: const AppText(label: 'Survey Dashboard', fontSize: 17, fontWeight: FontWeight.w600),
        shape: const Border(bottom: BorderSide(color: Color.fromRGBO(60, 60, 67, 0.36), width: 0.5)),
      ),
      body: state.dashboard.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary)),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppText(label: 'ไม่สามารถโหลดข้อมูล Survey Dashboard ได้', textColor: AppUtility.colorRed, maxLines: null, textAlign: TextAlign.center),
              TextButton(
                onPressed: () => ref.read(surveyDashboardProvider(surveyID).notifier).fetch(),
                child: const AppText(label: 'ลองใหม่', textColor: AppUtility.colorPrimary),
              ),
            ],
          ),
        ),
        data: (dashboard) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // _DashboardHeader(title: title ?? 'Survey results', surveyID: surveyID),
              // const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 720;
                  final cardWidth = isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;
                  final cards = [
                    _DashboardMetricCard(title: 'Total sent', value: dashboard.totalSent.toString(), icon: Icons.send_rounded, accentColor: const Color(0xFF1F6FEB)),
                    _DashboardMetricCard(title: 'Total responded', value: dashboard.totalResponded.toString(), icon: Icons.task_alt_rounded, accentColor: const Color(0xFF10B981)),
                    _DashboardMetricCard(title: 'Response rate', value: '${dashboard.responseRate.toStringAsFixed(1)}%', icon: Icons.analytics_rounded, accentColor: const Color(0xFF7B61FF)),
                    _DashboardMetricCard(title: 'Average overall score', value: dashboard.averageOverallScore.toStringAsFixed(1), icon: Icons.star_rounded, accentColor: const Color(0xFFF59E0B)),
                  ];

                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [for (final card in cards) SizedBox(width: cardWidth, child: card)],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final String title;
  final String surveyID;

  const _DashboardHeader({required this.title, required this.surveyID});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11)),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.pie_chart_outline_rounded, color: AppUtility.colorPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(label: title, fontSize: 16, fontWeight: FontWeight.w600, lineHeight: 20, maxLines: 2),
                const SizedBox(height: 2),
                AppText(label: 'Survey ID: $surveyID', fontSize: 12, textColor: AppUtility.textGray, lineHeight: 16, maxLines: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// This card belongs only to the survey dashboard.
class _DashboardMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;

  const _DashboardMetricCard({required this.title, required this.value, required this.icon, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: AppText(label: title, fontSize: 13, fontWeight: FontWeight.w600, textColor: const Color(0xFF374151), maxLines: 2),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AppText(label: value, fontSize: 24, fontWeight: FontWeight.w700, lineHeight: 28, maxLines: 2),
        ],
      ),
    );
  }
}
