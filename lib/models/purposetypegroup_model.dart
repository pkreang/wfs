class PurposeTypeGroup {
  bool? isActive;
  String? purposeTypeGroupsID;
  String? createdDate;
  String? modifiedDate;
  String? purposeTypeGroupsDescription;
  String? createdBy;
  String? purposeTypeGroupsName;
  String? modifiedBy;

  PurposeTypeGroup({
    this.isActive,
    this.purposeTypeGroupsID,
    this.createdDate,
    this.modifiedDate,
    this.purposeTypeGroupsDescription,
    this.createdBy,
    this.purposeTypeGroupsName,
    this.modifiedBy,
  });

  PurposeTypeGroup.fromJson(Map<String, dynamic> json) {
    isActive = json['IsActive'];
    purposeTypeGroupsID = json['PurposeTypeGroupsID'];
    createdDate = json['CreatedDate'];
    modifiedDate = json['ModifiedDate'];
    purposeTypeGroupsDescription = json['PurposeTypeGroupsDescription'];
    createdBy = json['CreatedBy'];
    purposeTypeGroupsName = json['PurposeTypeGroupsName'];
    modifiedBy = json['ModifiedBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['IsActive'] = this.isActive;
    data['PurposeTypeGroupsID'] = this.purposeTypeGroupsID;
    data['CreatedDate'] = this.createdDate;
    data['ModifiedDate'] = this.modifiedDate;
    data['PurposeTypeGroupsDescription'] = this.purposeTypeGroupsDescription;
    data['CreatedBy'] = this.createdBy;
    data['PurposeTypeGroupsName'] = this.purposeTypeGroupsName;
    data['ModifiedBy'] = this.modifiedBy;
    return data;
  }
}
