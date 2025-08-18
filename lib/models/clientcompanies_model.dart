class ClientCompanies {
  String? companyID;
  String? position;
  String? noted;
  DateTime? availableTimeStart;
  DateTime? availableTimeEnd;
  String? createdBy;
  String? modifiedBy;

  ClientCompanies({
    this.companyID,
    this.position,
    this.noted,
    this.availableTimeStart,
    this.availableTimeEnd,
    this.createdBy,
    this.modifiedBy,
  });

  ClientCompanies.fromJson(Map<String, dynamic> json) {
    companyID = json['CompanyID'];
    position = json['Position'];
    noted = json['Noted'];
    availableTimeStart = json['AvailableTimeStart'];
    availableTimeEnd = json['AvailableTimeEnd'];
    createdBy = json['CreatedBy'];
    modifiedBy = json['ModifiedBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CompanyID'] = this.companyID;
    data['Position'] = this.position;
    data['Noted'] = this.noted;
    data['AvailableTimeStart'] = this.availableTimeStart;
    data['AvailableTimeEnd'] = this.availableTimeEnd;
    data['CreatedBy'] = this.createdBy;
    data['ModifiedBy'] = this.modifiedBy;
    return data;
  }
}
