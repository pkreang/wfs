class PurposeType {
  String? purposeTypeID;
  String? purposeTypeGroupsID;
  bool? isActive;
  String? createdDate;
  String? modifiedDate;
  String? purposeTypeName;
  String? purposeTypeDescription;
  int? ordering;
  String? createdBy;
  String? modifiedBy;

  PurposeType({
    this.purposeTypeID,
    this.purposeTypeGroupsID,
    this.isActive,
    this.createdDate,
    this.modifiedDate,
    this.purposeTypeName,
    this.purposeTypeDescription,
    this.ordering,
    this.createdBy,
    this.modifiedBy,
  });

  PurposeType.fromJson(Map<String, dynamic> json) {
    purposeTypeID = json['PurposeTypeID'];
    purposeTypeGroupsID = json['PurposeTypeGroupsID'];
    isActive = json['IsActive'];
    createdDate = json['CreatedDate'];
    modifiedDate = json['ModifiedDate'];
    purposeTypeName = json['PurposeTypeName'];
    purposeTypeDescription = json['PurposeTypeDescription'];
    ordering = json['Ordering'];
    createdBy = json['CreatedBy'];
    modifiedBy = json['ModifiedBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['PurposeTypeID'] = this.purposeTypeID;
    data['PurposeTypeGroupsID'] = this.purposeTypeGroupsID;
    data['IsActive'] = this.isActive;
    data['CreatedDate'] = this.createdDate;
    data['ModifiedDate'] = this.modifiedDate;
    data['PurposeTypeName'] = this.purposeTypeName;
    data['PurposeTypeDescription'] = this.purposeTypeDescription;
    data['Ordering'] = this.ordering;
    data['CreatedBy'] = this.createdBy;
    data['ModifiedBy'] = this.modifiedBy;
    return data;
  }
}
