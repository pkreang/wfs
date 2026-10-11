class SurveyDashboard {
  final String surveyID;
  final List<SurveyResponse> responses;
  final int totalResponses;
  final int completedResponses;
  final int totalScoreAnswers;
  final double averageScore;
  final DateTime? lastSubmittedAt;
  final Map<int, int> scoreDistribution;

  const SurveyDashboard({
    required this.surveyID,
    required this.responses,
    required this.totalResponses,
    required this.completedResponses,
    required this.totalScoreAnswers,
    required this.averageScore,
    this.lastSubmittedAt,
    required this.scoreDistribution,
  });

  double get completionRate =>
      totalResponses == 0 ? 0 : completedResponses / totalResponses;

  factory SurveyDashboard.fromResponses({
    required String surveyID,
    required List<SurveyResponse> responses,
  }) {
    final answeredResponses = responses
        .where((response) => response.isAnswered)
        .toList();
    final scores = answeredResponses
        .map((response) => response.overallScore)
        .whereType<double>()
        .toList();
    final scoreDistribution = <int, int>{};
    var totalScoreAnswers = 0;
    DateTime? lastSubmittedAt;

    for (final response in responses) {
      final submittedAt = response.respondedDate ?? response.sentDate;
      if (submittedAt != null &&
          (lastSubmittedAt == null || submittedAt.isAfter(lastSubmittedAt))) {
        lastSubmittedAt = submittedAt;
      }

      for (final detail in response.details) {
        final score = detail.score;
        if (score == null) continue;
        totalScoreAnswers++;
        final scoreKey = score.round().clamp(0, 10);
        scoreDistribution.update(
          scoreKey,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
    }

    return SurveyDashboard(
      surveyID: surveyID,
      responses: responses,
      totalResponses: responses.length,
      completedResponses: answeredResponses.length,
      totalScoreAnswers: totalScoreAnswers,
      averageScore: scores.isEmpty
          ? 0
          : scores.reduce((sum, score) => sum + score) / scores.length,
      lastSubmittedAt: lastSubmittedAt,
      scoreDistribution: scoreDistribution,
    );
  }
}

class SurveyResponse {
  final String surveyResponseID;
  final String surveyTemplateID;
  final String clientID;
  final String clientName;
  final String? appointmentID;
  final DateTime? sentDate;
  final String responseStatus;
  final DateTime? respondedDate;
  final double? overallScore;
  final bool isAnswered;
  final List<SurveyResponseDetail> details;

  const SurveyResponse({
    required this.surveyResponseID,
    required this.surveyTemplateID,
    required this.clientID,
    required this.clientName,
    this.appointmentID,
    this.sentDate,
    required this.responseStatus,
    this.respondedDate,
    this.overallScore,
    required this.isAnswered,
    required this.details,
  });

  factory SurveyResponse.fromJson(Map<String, dynamic> json) {
    final rawDetails = json['details'] ?? json['Details'];

    return SurveyResponse(
      surveyResponseID: _asString(
        json['SurveyResponseID'] ?? json['surveyResponseID'],
      ),
      surveyTemplateID: _asString(
        json['SurveyTemplateID'] ?? json['surveyTemplateID'],
      ),
      clientID: _asString(json['ClientID'] ?? json['clientID']),
      clientName: _asString(json['ClientName'] ?? json['clientName']),
      appointmentID: _asNullableString(
        json['AppointmentID'] ?? json['appointmentID'],
      ),
      sentDate: _asDate(json['SentDate'] ?? json['sentDate']),
      responseStatus: _asString(
        json['ResponseStatus'] ?? json['responseStatus'],
      ),
      respondedDate: _asDate(json['RespondedDate'] ?? json['respondedDate']),
      overallScore: _asDouble(json['OverallScore'] ?? json['overallScore']),
      isAnswered: _asBool(json['IsAnswered'] ?? json['isAnswered']),
      details: rawDetails is List
          ? rawDetails
                .whereType<Map>()
                .map(
                  (detail) => SurveyResponseDetail.fromJson(
                    Map<String, dynamic>.from(detail),
                  ),
                )
                .toList()
          : const [],
    );
  }
}

class SurveyResponseDetail {
  final String questionID;
  final String questionText;
  final String typeCode;
  final double? score;
  final String? freeText;

  const SurveyResponseDetail({
    required this.questionID,
    required this.questionText,
    required this.typeCode,
    this.score,
    this.freeText,
  });

  factory SurveyResponseDetail.fromJson(Map<String, dynamic> json) {
    return SurveyResponseDetail(
      questionID: _asString(json['QuestionID'] ?? json['questionID']),
      questionText: _asString(json['QuestionText'] ?? json['questionText']),
      typeCode: _asString(json['TypeCode'] ?? json['typeCode']),
      score: _asDouble(json['Score'] ?? json['score']),
      freeText: _asNullableString(json['FreeText'] ?? json['freeText']),
    );
  }
}

String _asString(Object? value) => value?.toString() ?? '';

String? _asNullableString(Object? value) {
  final text = value?.toString();
  return text == null || text.isEmpty ? null : text;
}

DateTime? _asDate(Object? value) =>
    value == null ? null : DateTime.tryParse(value.toString());

double? _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

bool _asBool(Object? value) {
  if (value is bool) return value;
  return value?.toString().toLowerCase() == 'true' || value?.toString() == '1';
}
