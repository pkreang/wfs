class SurveyDashboardAnalytics {
  final int totalSent;
  final int totalResponded;
  final double responseRate;
  final double averageOverallScore;

  const SurveyDashboardAnalytics({
    required this.totalSent,
    required this.totalResponded,
    required this.responseRate,
    required this.averageOverallScore,
  });

  factory SurveyDashboardAnalytics.fromJson(Map<String, dynamic> json) {
    return SurveyDashboardAnalytics(
      totalSent: (json['TotalSent'] as num).toInt(),
      totalResponded: (json['TotalResponded'] as num).toInt(),
      responseRate: (json['ResponseRate'] as num).toDouble(),
      averageOverallScore: (json['AverageOverallScore'] as num).toDouble(),
    );
  }
}
