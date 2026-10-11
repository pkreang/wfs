import 'package:wfs/features/survey/models/survey_question_model.dart';

class Survey {
  final String? surveyTemplateID;
  final String templateName;
  final String description;
  final bool isActive;
  final String? createdBy;
  final DateTime? createdDate;
  final List<SurveyQuestion> questions;

  // Fields kept for the existing local survey workflow.
  final String refCode;
  final DateTime? updatedAt;

  String? get surveyID => surveyTemplateID;
  String get title => templateName;
  String get status => isActive ? 'Active' : 'Inactive';
  DateTime? get createdAt => createdDate;

  const Survey({
    String? surveyTemplateID,
    String? surveyID,
    String? templateName,
    String? title,
    this.description = '',
    bool? isActive,
    String? status,
    this.createdBy,
    DateTime? createdDate,
    DateTime? createdAt,
    this.refCode = '',
    this.updatedAt,
    this.questions = const [],
  }) : surveyTemplateID = surveyTemplateID ?? surveyID,
       templateName = templateName ?? title ?? '',
       isActive = isActive ?? (status != 'Inactive' && status != 'inactive'),
       createdDate = createdDate ?? createdAt;

  factory Survey.empty() => const Survey();

  factory Survey.fromJson(Map<String, dynamic> json) {
    final rawQuestions = json['questions'] ?? json['Questions'] ?? const [];

    return Survey(
      surveyTemplateID: (json['SurveyTemplateID'] ?? json['surveyTemplateID'] ?? json['SurveyID'] ?? json['surveyID'] ?? json['id'])?.toString(),
      templateName: (json['TemplateName'] ?? json['templateName'] ?? json['Title'] ?? json['title'] ?? '').toString(),
      description: (json['Description'] ?? json['description'] ?? '').toString(),
      isActive: _parseIsActive(json['IsActive'] ?? json['isActive'] ?? json['Status'] ?? json['status']),
      createdBy: (json['CreatedBy'] ?? json['createdBy'])?.toString(),
      createdDate: _parseDate(json['CreatedDate'] ?? json['createdDate'] ?? json['CreatedAt'] ?? json['createdAt']),
      refCode: (json['RefCode'] ?? json['refCode'] ?? '').toString(),
      updatedAt: _parseDate(json['UpdatedAt'] ?? json['updatedAt'] ?? json['ModifiedDate'] ?? json['modifiedDate']),
      questions: rawQuestions is List ? rawQuestions.map((item) => SurveyQuestion.fromJson(Map<String, dynamic>.from(item as Map))).toList() : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'SurveyTemplateID': surveyTemplateID, 'TemplateName': templateName, 'Description': description, 'Questions': questions.map((question) => question.toJson()).toList()};
  }

  Survey copyWith({
    String? surveyTemplateID,
    String? surveyID,
    String? templateName,
    String? title,
    String? description,
    bool? isActive,
    String? status,
    String? createdBy,
    DateTime? createdDate,
    DateTime? createdAt,
    String? refCode,
    DateTime? updatedAt,
    List<SurveyQuestion>? questions,
  }) {
    return Survey(
      surveyTemplateID: surveyTemplateID ?? surveyID ?? this.surveyTemplateID,
      templateName: templateName ?? title ?? this.templateName,
      description: description ?? this.description,
      isActive: isActive ?? (status == null ? this.isActive : _parseIsActive(status)),
      createdBy: createdBy ?? this.createdBy,
      createdDate: createdDate ?? createdAt ?? this.createdDate,
      refCode: refCode ?? this.refCode,
      updatedAt: updatedAt ?? this.updatedAt,
      questions: questions ?? this.questions,
    );
  }
}

bool _parseIsActive(Object? value) {
  if (value is bool) return value;

  switch (value?.toString().toLowerCase()) {
    case 'false':
    case '0':
    case 'inactive':
      return false;
    default:
      return true;
  }
}

DateTime? _parseDate(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}
