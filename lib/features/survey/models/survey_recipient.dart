class SurveyRecipient {
  final String surveyResponseID;
  final String companyName;
  final String clientName;
  final String email;
  final String salesName;
  final DateTime? sentDate;
  final DateTime? respondedDate;
  final String responseStatus;

  const SurveyRecipient({
    required this.surveyResponseID,
    this.companyName = '',
    required this.clientName,
    required this.email,
    this.salesName = '',
    required this.sentDate,
    this.respondedDate,
    this.responseStatus = '',
  });

  factory SurveyRecipient.fromJson(Map<String, dynamic> json) {
    final rawSentDate = json['SentDate'] ?? json['sentDate'];
    final rawRespondedDate = json['RespondedDate'] ?? json['respondedDate'];
    return SurveyRecipient(
      surveyResponseID:
          (json['SurveyResponseID'] ?? json['surveyResponseID'] ?? '')
              .toString(),
      companyName: _firstNonEmpty(json, ['CompanyName', 'companyName']),
      clientName: _firstNonEmpty(json, [
        'ClientName',
        'clientName',
        'LeadName',
        'leadName',
      ]),
      email: _firstNonEmpty(json, [
        'Email',
        'email',
        'ClientEmail',
        'clientEmail',
        'LeadEmail',
        'leadEmail',
      ]),
      salesName: _firstNonEmpty(json, [
        'SalesName',
        'salesName',
        'SaleName',
        'saleName',
      ]),
      sentDate: rawSentDate == null
          ? null
          : DateTime.tryParse(rawSentDate.toString()),
      respondedDate: rawRespondedDate == null
          ? null
          : DateTime.tryParse(rawRespondedDate.toString()),
      responseStatus: _firstNonEmpty(json, [
        'ResponseStatus',
        'responseStatus',
      ]),
    );
  }

  static String _firstNonEmpty(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return '';
  }
}
