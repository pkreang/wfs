class ClientStatus {
  String? clientStatusID;
  String? clientStatusName;
  String? clientStatusDescription;
  int? ordering;
  bool? isActive;
  String? createdDate;
  String? modifiedDate;
  String? createdBy;
  String? modifiedBy;

  ClientStatus({
    this.clientStatusID,
    this.clientStatusName,
    this.clientStatusDescription,
    this.ordering,
    this.isActive,
    this.createdDate,
    this.modifiedDate,
    this.createdBy,
    this.modifiedBy,
  });

  ClientStatus.fromJson(Map<String, dynamic> json) {
    clientStatusID = json['ClientStatusID'];
    clientStatusName = json['ClientStatusName'];
    clientStatusDescription = json['ClientStatusDescription'];
    ordering = json['Ordering'];
    isActive = json['IsActive'];
    createdDate = json['CreatedDate'];
    modifiedDate = json['ModifiedDate'];
    createdBy = json['CreatedBy'];
    modifiedBy = json['ModifiedBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ClientStatusID'] = this.clientStatusID;
    data['ClientStatusName'] = this.clientStatusName;
    data['ClientStatusDescription'] = this.clientStatusDescription;
    data['Ordering'] = this.ordering;
    data['IsActive'] = this.isActive;
    data['CreatedDate'] = this.createdDate;
    data['ModifiedDate'] = this.modifiedDate;
    data['CreatedBy'] = this.createdBy;
    data['ModifiedBy'] = this.modifiedBy;
    return data;
  }
}
