class ClientLevel {
  String? clientLevelName;
  String? clientLevelDescription;
  bool? isActive;
  String? createdDate;
  String? modifiedDate;
  int? ordering;
  String? clientLevelID;
  String? createdBy;
  String? modifiedBy;

  ClientLevel({
    this.clientLevelName,
    this.clientLevelDescription,
    this.isActive,
    this.createdDate,
    this.modifiedDate,
    this.ordering,
    this.clientLevelID,
    this.createdBy,
    this.modifiedBy,
  });

  ClientLevel.fromJson(Map<String, dynamic> json) {
    clientLevelName = json['ClientLevelName'];
    clientLevelDescription = json['ClientLevelDescription'];
    isActive = json['IsActive'];
    createdDate = json['CreatedDate'];
    modifiedDate = json['ModifiedDate'];
    ordering = json['Ordering'];
    clientLevelID = json['ClientLevelID'];
    createdBy = json['CreatedBy'];
    modifiedBy = json['ModifiedBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ClientLevelName'] = this.clientLevelName;
    data['ClientLevelDescription'] = this.clientLevelDescription;
    data['IsActive'] = this.isActive;
    data['CreatedDate'] = this.createdDate;
    data['ModifiedDate'] = this.modifiedDate;
    data['Ordering'] = this.ordering;
    data['ClientLevelID'] = this.clientLevelID;
    data['CreatedBy'] = this.createdBy;
    data['ModifiedBy'] = this.modifiedBy;
    return data;
  }
}
