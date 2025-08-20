class ClientStatus {
  String? clientStatusID;
  int? ordering;
  String? createdBy;
  String? modifiedBy;
  String? clientStatusName;
  String? clientStatusDescription;
  bool? isActive;
  String? createdDate;
  String? modifiedDate;

  ClientStatus({
    this.clientStatusID,
    this.ordering,
    this.createdBy,
    this.modifiedBy,
    this.clientStatusName,
    this.clientStatusDescription,
    this.isActive,
    this.createdDate,
    this.modifiedDate,
  });

  ClientStatus.fromJson(Map<String, dynamic> json) {
    clientStatusID = json['ClientStatusID'];
    ordering = json['Ordering'];
    createdBy = json['CreatedBy'];
    modifiedBy = json['ModifiedBy'];
    clientStatusName = json['ClientStatusName'];
    clientStatusDescription = json['ClientStatusDescription'];
    isActive = json['IsActive'];
    createdDate = json['CreatedDate'];
    modifiedDate = json['ModifiedDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ClientStatusID'] = this.clientStatusID;
    data['Ordering'] = this.ordering;
    data['CreatedBy'] = this.createdBy;
    data['ModifiedBy'] = this.modifiedBy;
    data['ClientStatusName'] = this.clientStatusName;
    data['ClientStatusDescription'] = this.clientStatusDescription;
    data['IsActive'] = this.isActive;
    data['CreatedDate'] = this.createdDate;
    data['ModifiedDate'] = this.modifiedDate;
    return data;
  }
}
