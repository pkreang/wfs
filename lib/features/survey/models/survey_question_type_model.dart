class SurveyQuestionType {
  final String questionTypeID;
  final String typeCode;
  final String typeName;
  final String typeDescription;

  const SurveyQuestionType({required this.questionTypeID, required this.typeCode, required this.typeName, required this.typeDescription});

  factory SurveyQuestionType.fromJson(Map<String, dynamic> json) {
    return SurveyQuestionType(
      questionTypeID: (json['QuestionTypeID'] ?? json['questionTypeID'] ?? json['id'] ?? '').toString(),
      typeCode: (json['TypeCode'] ?? json['typeCode'] ?? '').toString(),
      typeName: (json['TypeName'] ?? json['typeName'] ?? json['QuestionTypeName'] ?? json['questionTypeName'] ?? json['Name'] ?? json['name'] ?? '').toString(),
      typeDescription: (json['TypeDescription'] ?? json['typeDescription'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {'QuestionTypeID': questionTypeID, 'TypeCode': typeCode, 'TypeName': typeName, 'TypeDescription': typeDescription};

  static List<SurveyQuestionType> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((item) => SurveyQuestionType.fromJson(Map<String, dynamic>.from(item as Map))).toList();
  }
}
