import 'package:flutter/material.dart';
import 'package:wfs/features/survey/models/survey_dashboard_model.dart';

class SurveyDashboardChartSlice {
  final String label;
  final int value;
  final Color color;

  const SurveyDashboardChartSlice({
    required this.label,
    required this.value,
    required this.color,
  });
}

class SurveyQuestionAnalyticsMock {
  final String question;
  final int totalAnswers;
  final List<SurveyDashboardChartSlice> distribution;

  const SurveyQuestionAnalyticsMock({
    required this.question,
    required this.totalAnswers,
    required this.distribution,
  });
}

class SurveyRecentTextResponseMock {
  final String respondent;
  final String answer;
  final DateTime submittedAt;

  const SurveyRecentTextResponseMock({
    required this.respondent,
    required this.answer,
    required this.submittedAt,
  });
}

class SurveyDashboardMockData {
  final int totalResponses;
  final int completedResponses;
  final double completionRate;
  final List<SurveyDashboardChartSlice> satisfactionOverview;
  final List<SurveyDashboardChartSlice> responseCategories;
  final List<SurveyDashboardChartSlice> scoreDistribution;
  final List<SurveyDashboardChartSlice> surveyTypeBreakdown;
  final List<SurveyQuestionAnalyticsMock> questionAnalytics;
  final List<SurveyRecentTextResponseMock> recentTextResponses;

  const SurveyDashboardMockData({
    required this.totalResponses,
    required this.completedResponses,
    required this.completionRate,
    required this.satisfactionOverview,
    required this.responseCategories,
    required this.scoreDistribution,
    required this.surveyTypeBreakdown,
    required this.questionAnalytics,
    required this.recentTextResponses,
  });

  factory SurveyDashboardMockData.fromDashboard(SurveyDashboard dashboard) {
    final totalResponses = dashboard.totalResponses == 0
        ? 120
        : dashboard.totalResponses;
    final completedResponses = (totalResponses * 0.78).round();
    final scoreAnswerTotal = dashboard.totalScoreAnswers == 0
        ? 96
        : dashboard.totalScoreAnswers;

    return SurveyDashboardMockData(
      totalResponses: totalResponses,
      completedResponses: completedResponses,
      completionRate: completedResponses / totalResponses,
      satisfactionOverview: const [
        SurveyDashboardChartSlice(
          label: 'Satisfaction',
          value: 60,
          color: Color(0xFF34C759),
        ),
        SurveyDashboardChartSlice(
          label: 'Neutral',
          value: 25,
          color: Color(0xFFFF9500),
        ),
        SurveyDashboardChartSlice(
          label: 'Negative',
          value: 15,
          color: Color(0xFFFF3B30),
        ),
      ],
      responseCategories: [
        SurveyDashboardChartSlice(
          label: 'Completed',
          value: completedResponses,
          color: const Color(0xFF007AFF),
        ),
        SurveyDashboardChartSlice(
          label: 'Partial',
          value: (totalResponses * 0.14).round(),
          color: const Color(0xFF7B61FF),
        ),
        SurveyDashboardChartSlice(
          label: 'Abandoned',
          value: (totalResponses * 0.08).round(),
          color: const Color(0xFFC7C7CC),
        ),
      ],
      scoreDistribution: [
        SurveyDashboardChartSlice(
          label: '5',
          value: (scoreAnswerTotal * 0.38).round(),
          color: const Color(0xFF34C759),
        ),
        SurveyDashboardChartSlice(
          label: '4',
          value: (scoreAnswerTotal * 0.28).round(),
          color: const Color(0xFF7ED321),
        ),
        SurveyDashboardChartSlice(
          label: '3',
          value: (scoreAnswerTotal * 0.19).round(),
          color: const Color(0xFFFFCC00),
        ),
        SurveyDashboardChartSlice(
          label: '2',
          value: (scoreAnswerTotal * 0.10).round(),
          color: const Color(0xFFFF9500),
        ),
        SurveyDashboardChartSlice(
          label: '1',
          value: (scoreAnswerTotal * 0.05).round(),
          color: const Color(0xFFFF3B30),
        ),
      ],
      surveyTypeBreakdown: const [
        SurveyDashboardChartSlice(
          label: 'Score answers',
          value: 64,
          color: Color(0xFF007AFF),
        ),
        SurveyDashboardChartSlice(
          label: 'Text answers',
          value: 24,
          color: Color(0xFF7B61FF),
        ),
        SurveyDashboardChartSlice(
          label: 'Mixed',
          value: 12,
          color: Color(0xFFFF9500),
        ),
      ],
      questionAnalytics: const [
        SurveyQuestionAnalyticsMock(
          question: 'How satisfied are you with our service?',
          totalAnswers: 120,
          distribution: [
            SurveyDashboardChartSlice(
              label: 'Positive',
              value: 72,
              color: Color(0xFF34C759),
            ),
            SurveyDashboardChartSlice(
              label: 'Neutral',
              value: 30,
              color: Color(0xFFFF9500),
            ),
            SurveyDashboardChartSlice(
              label: 'Negative',
              value: 18,
              color: Color(0xFFFF3B30),
            ),
          ],
        ),
        SurveyQuestionAnalyticsMock(
          question: 'Would you recommend us?',
          totalAnswers: 118,
          distribution: [
            SurveyDashboardChartSlice(
              label: 'Yes',
              value: 84,
              color: Color(0xFF007AFF),
            ),
            SurveyDashboardChartSlice(
              label: 'Maybe',
              value: 22,
              color: Color(0xFFFF9500),
            ),
            SurveyDashboardChartSlice(
              label: 'No',
              value: 12,
              color: Color(0xFFFF3B30),
            ),
          ],
        ),
      ],
      recentTextResponses: [
        SurveyRecentTextResponseMock(
          respondent: 'Customer A',
          answer: 'The team responded quickly and solved the issue clearly.',
          submittedAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        SurveyRecentTextResponseMock(
          respondent: 'Customer B',
          answer: 'Good service overall. I would like more proactive updates.',
          submittedAt: DateTime.now().subtract(const Duration(hours: 8)),
        ),
        SurveyRecentTextResponseMock(
          respondent: 'Customer C',
          answer: 'The product is useful, but onboarding could be shorter.',
          submittedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
    );
  }
}
