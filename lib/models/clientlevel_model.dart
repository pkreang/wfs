class ClientLevel {
  String? clientLevelDescription;
  String? clientLevelName;
  bool? isActive;
  String? createdDate;
  String? modifiedDate;
  String? clientLevelID;
  int? ordering;
  String? createdBy;
  String? modifiedBy;

  ClientLevel({
    this.clientLevelDescription,
    this.clientLevelName,
    this.isActive,
    this.createdDate,
    this.modifiedDate,
    this.clientLevelID,
    this.ordering,
    this.createdBy,
    this.modifiedBy,
  });

  ClientLevel.fromJson(Map<String, dynamic> json) {
    clientLevelDescription = json['ClientLevelDescription'];
    clientLevelName = json['ClientLevelName'];
    isActive = json['IsActive'];
    createdDate = json['CreatedDate'];
    modifiedDate = json['ModifiedDate'];
    clientLevelID = json['ClientLevelID'];
    ordering = json['Ordering'];
    createdBy = json['CreatedBy'];
    modifiedBy = json['ModifiedBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ClientLevelDescription'] = this.clientLevelDescription;
    data['ClientLevelName'] = this.clientLevelName;
    data['IsActive'] = this.isActive;
    data['CreatedDate'] = this.createdDate;
    data['ModifiedDate'] = this.modifiedDate;
    data['ClientLevelID'] = this.clientLevelID;
    data['Ordering'] = this.ordering;
    data['CreatedBy'] = this.createdBy;
    data['ModifiedBy'] = this.modifiedBy;
    return data;
  }
}
