class Outcome {
  final String outcomeID;
  final String outcomeName;

  Outcome({required this.outcomeID, required this.outcomeName});

  factory Outcome.fromJson(Map<String, dynamic> json) {
    return Outcome(outcomeID: json['OutcomeID'] as String, outcomeName: json['OutcomeName'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'OutcomeID': outcomeID, 'OutcomeName': outcomeName};
  }

  static List<Outcome> listFromJson(List<dynamic> jsonList) => jsonList.map((e) => Outcome.fromJson(e as Map<String, dynamic>)).toList();
}
