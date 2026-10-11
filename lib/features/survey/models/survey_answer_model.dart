class SurveyQuestionAnswer {
  final String questionID;
  final String? textAnswer;
  final int? scoreAnswer;

  const SurveyQuestionAnswer({required this.questionID, this.textAnswer, this.scoreAnswer});

  factory SurveyQuestionAnswer.fromJson(Map<String, dynamic> json) {
    return SurveyQuestionAnswer(
      questionID: (json['questionID'] ?? json['QuestionID'] ?? '').toString(),
      textAnswer: (json['textAnswer'] ?? json['TextAnswer'])?.toString(),
      scoreAnswer: int.tryParse((json['scoreAnswer'] ?? json['ScoreAnswer'] ?? '').toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {'questionID': questionID, 'textAnswer': textAnswer, 'scoreAnswer': scoreAnswer};
  }
}

class SurveySubmission {
  final String? submissionID;
  final String surveyID;
  final String refCode;
  final DateTime submittedAt;
  final List<SurveyQuestionAnswer> answers;

  const SurveySubmission({this.submissionID, required this.surveyID, required this.refCode, required this.submittedAt, required this.answers});

  factory SurveySubmission.fromJson(Map<String, dynamic> json) {
    final answers = json['answers'] ?? json['Answers'] ?? const [];

    return SurveySubmission(
      submissionID: (json['submissionID'] ?? json['SubmissionID'] ?? json['id'])?.toString(),
      surveyID: (json['surveyID'] ?? json['SurveyID'] ?? '').toString(),
      refCode: (json['refCode'] ?? json['RefCode'] ?? '').toString(),
      submittedAt: DateTime.tryParse((json['submittedAt'] ?? json['SubmittedAt'] ?? '').toString()) ?? DateTime.now(),
      answers: answers is List ? answers.map((item) => SurveyQuestionAnswer.fromJson(item as Map<String, dynamic>)).toList() : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'submissionID': submissionID, 'surveyID': surveyID, 'refCode': refCode, 'submittedAt': submittedAt.toIso8601String(), 'answers': answers.map((answer) => answer.toJson()).toList()};
  }
}
