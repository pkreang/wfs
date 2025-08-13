class ClientStatus {
  String? clientStatusID;
  String? clientStatusDescription;
  bool? isActive;
  String? createdDate;
  String? modifiedDate;
  int? ordering;
  String? clientStatusName;
  String? createdBy;
  String? modifiedBy;

  ClientStatus({
    this.clientStatusID,
    this.clientStatusDescription,
    this.isActive,
    this.createdDate,
    this.modifiedDate,
    this.ordering,
    this.clientStatusName,
    this.createdBy,
    this.modifiedBy,
  });

  ClientStatus.fromJson(Map<String, dynamic> json) {
    clientStatusID = json['ClientStatusID'];
    clientStatusDescription = json['ClientStatusDescription'];
    isActive = json['IsActive'];
    createdDate = json['CreatedDate'];
    modifiedDate = json['ModifiedDate'];
    ordering = json['Ordering'];
    clientStatusName = json['ClientStatusName'];
    createdBy = json['CreatedBy'];
    modifiedBy = json['ModifiedBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ClientStatusID'] = this.clientStatusID;
    data['ClientStatusDescription'] = this.clientStatusDescription;
    data['IsActive'] = this.isActive;
    data['CreatedDate'] = this.createdDate;
    data['ModifiedDate'] = this.modifiedDate;
    data['Ordering'] = this.ordering;
    data['ClientStatusName'] = this.clientStatusName;
    data['CreatedBy'] = this.createdBy;
    data['ModifiedBy'] = this.modifiedBy;
    return data;
  }
}
