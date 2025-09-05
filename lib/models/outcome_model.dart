class Outcome {
  bool? isActive;
  String? outcomeID;
  String? createdDate;
  String? modifiedDate;
  String? outcomeName;
  String? outcomeDescription;
  String? createdBy;
  String? modifiedBy;

  Outcome({
    this.isActive,
    this.outcomeID,
    this.createdDate,
    this.modifiedDate,
    this.outcomeName,
    this.outcomeDescription,
    this.createdBy,
    this.modifiedBy,
  });

  Outcome.fromJson(Map<String, dynamic> json) {
    isActive = json['IsActive'];
    outcomeID = json['OutcomeID'];
    createdDate = json['CreatedDate'];
    modifiedDate = json['ModifiedDate'];
    outcomeName = json['OutcomeName'];
    outcomeDescription = json['OutcomeDescription'];
    createdBy = json['CreatedBy'];
    modifiedBy = json['ModifiedBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['IsActive'] = this.isActive;
    data['OutcomeID'] = this.outcomeID;
    data['CreatedDate'] = this.createdDate;
    data['ModifiedDate'] = this.modifiedDate;
    data['OutcomeName'] = this.outcomeName;
    data['OutcomeDescription'] = this.outcomeDescription;
    data['CreatedBy'] = this.createdBy;
    data['ModifiedBy'] = this.modifiedBy;
    return data;
  }
}
