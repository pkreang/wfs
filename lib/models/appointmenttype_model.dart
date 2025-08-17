class AppointmentType {
  String? appointmentTypeDescription;
  String? appointmentTypeName;
  String? createdBy;
  String? modifiedBy;
  bool? isActive;
  String? appointmentTypeID;
  String? createdDate;
  String? modifiedDate;

  AppointmentType({
    this.appointmentTypeDescription,
    this.appointmentTypeName,
    this.createdBy,
    this.modifiedBy,
    this.isActive,
    this.appointmentTypeID,
    this.createdDate,
    this.modifiedDate,
  });

  AppointmentType.fromJson(Map<String, dynamic> json) {
    appointmentTypeDescription = json['AppointmentTypeDescription'];
    appointmentTypeName = json['AppointmentTypeName'];
    createdBy = json['CreatedBy'];
    modifiedBy = json['ModifiedBy'];
    isActive = json['IsActive'];
    appointmentTypeID = json['AppointmentTypeID'];
    createdDate = json['CreatedDate'];
    modifiedDate = json['ModifiedDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['AppointmentTypeDescription'] = this.appointmentTypeDescription;
    data['AppointmentTypeName'] = this.appointmentTypeName;
    data['CreatedBy'] = this.createdBy;
    data['ModifiedBy'] = this.modifiedBy;
    data['IsActive'] = this.isActive;
    data['AppointmentTypeID'] = this.appointmentTypeID;
    data['CreatedDate'] = this.createdDate;
    data['ModifiedDate'] = this.modifiedDate;
    return data;
  }
}
