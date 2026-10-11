enum SurveyAnswerType {
  text('TEXT'),
  score('SCORE');

  final String value;

  const SurveyAnswerType(this.value);

  static SurveyAnswerType fromValue(Object? value) {
    final text = value?.toString().toUpperCase();
    return SurveyAnswerType.values.firstWhere((type) => type.value == text || type.name.toUpperCase() == text, orElse: () => SurveyAnswerType.text);
  }
}

class SurveyQuestion {
  final String id;
  final String? questionTypeID;
  final String title;
  final String description;
  final SurveyAnswerType answerType;
  final int scoreMin;
  final int scoreMax;
  final bool isRequired;

  const SurveyQuestion({required this.id, this.questionTypeID, required this.title, required this.description, required this.answerType, this.scoreMin = 1, this.scoreMax = 5, this.isRequired = true});

  factory SurveyQuestion.fromJson(Map<String, dynamic> json) {
    return SurveyQuestion(
      id: (json['id'] ?? json['QuestionID'] ?? '').toString(),
      questionTypeID: (json['questionTypeID'] ?? json['QuestionTypeID'])?.toString(),
      title: (json['title'] ?? json['QuestionText'] ?? '').toString(),
      description: (json['description'] ?? json['Description'] ?? '').toString(),
      answerType: SurveyAnswerType.fromValue(json['answerType'] ?? json['AnswerType']),
      scoreMin: int.tryParse((json['scoreMin'] ?? json['ScoreMin'] ?? '').toString()) ?? 1,
      scoreMax: int.tryParse((json['scoreMax'] ?? json['ScoreMax'] ?? '').toString()) ?? 5,
      isRequired: (json['isRequired'] ?? json['IsRequired']) is bool ? (json['isRequired'] ?? json['IsRequired']) as bool : (json['isRequired'] ?? json['IsRequired'] ?? 1).toString() != '0',
    );
  }

  Map<String, dynamic> toJson() {
    //   "Questions": [
    //   {
    //     "QuestionText": "เจ้าหน้าที่ขายและช่างเทคนิคให้คำแนะนำและบริการด้วยความสุภาพเรียบร้อยเพียงใด?",
    //     "QuestionTypeID": "E87D1293-61B2-4C92-A123-5A5BB6C7D101"
    //   },
    //   {
    //     "QuestionText": "ระดับความพึงพอใจต่อประสิทธิภาพและความเร็วในการติดตั้งอุปกรณ์ในภาพรวม",
    //     "QuestionTypeID": "E87D1293-61B2-4C92-A123-5A5BB6C7D101"
    //   }
    // ]
    return {'id': id, 'QuestionTypeID': questionTypeID, 'QuestionText': title, 'answerType': answerType.value, 'scoreMin': scoreMin, 'scoreMax': scoreMax, 'isRequired': isRequired};
  }

  SurveyQuestion copyWith({String? id, String? questionTypeID, String? title, String? description, SurveyAnswerType? answerType, int? scoreMin, int? scoreMax, bool? isRequired}) {
    return SurveyQuestion(
      id: id ?? this.id,
      questionTypeID: questionTypeID ?? this.questionTypeID,
      title: title ?? this.title,
      description: description ?? this.description,
      answerType: answerType ?? this.answerType,
      scoreMin: scoreMin ?? this.scoreMin,
      scoreMax: scoreMax ?? this.scoreMax,
      isRequired: isRequired ?? this.isRequired,
    );
  }
}
