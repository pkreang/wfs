class ClientLevel {
  String? clientLevelID;
  String? clientLevelName;
  String? clientLevelDescription;
  int? ordering;
  bool? isActive;
  String? createdDate;
  String? modifiedDate;
  String? createdBy;
  String? modifiedBy;

  ClientLevel({
    this.clientLevelID,
    this.clientLevelName,
    this.clientLevelDescription,
    this.ordering,
    this.isActive,
    this.createdDate,
    this.modifiedDate,
    this.createdBy,
    this.modifiedBy,
  });

  ClientLevel.fromJson(Map<String, dynamic> json) {
    clientLevelID = json['ClientLevelID'];
    clientLevelName = json['ClientLevelName'];
    clientLevelDescription = json['ClientLevelDescription'];
    ordering = json['Ordering'];
    isActive = json['IsActive'];
    createdDate = json['CreatedDate'];
    modifiedDate = json['ModifiedDate'];
    createdBy = json['CreatedBy'];
    modifiedBy = json['ModifiedBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ClientLevelID'] = this.clientLevelID;
    data['ClientLevelName'] = this.clientLevelName;
    data['ClientLevelDescription'] = this.clientLevelDescription;
    data['Ordering'] = this.ordering;
    data['IsActive'] = this.isActive;
    data['CreatedDate'] = this.createdDate;
    data['ModifiedDate'] = this.modifiedDate;
    data['CreatedBy'] = this.createdBy;
    data['ModifiedBy'] = this.modifiedBy;
    return data;
  }
}
