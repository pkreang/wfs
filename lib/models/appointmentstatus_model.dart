class AppointmentStatus {
  int? ordering;
  String? appointmentStatusID;
  String? createdBy;
  String? modifiedBy;
  String? appointmentStatusName;
  String? appointmentStatusDescription;
  bool? isActive;
  String? createdDate;
  String? modifiedDate;

  AppointmentStatus({
    this.ordering,
    this.appointmentStatusID,
    this.createdBy,
    this.modifiedBy,
    this.appointmentStatusName,
    this.appointmentStatusDescription,
    this.isActive,
    this.createdDate,
    this.modifiedDate,
  });

  AppointmentStatus.fromJson(Map<String, dynamic> json) {
    ordering = json['Ordering'];
    appointmentStatusID = json['AppointmentStatusID'];
    createdBy = json['CreatedBy'];
    modifiedBy = json['ModifiedBy'];
    appointmentStatusName = json['AppointmentStatusName'];
    appointmentStatusDescription = json['AppointmentStatusDescription'];
    isActive = json['IsActive'];
    createdDate = json['CreatedDate'];
    modifiedDate = json['ModifiedDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Ordering'] = this.ordering;
    data['AppointmentStatusID'] = this.appointmentStatusID;
    data['CreatedBy'] = this.createdBy;
    data['ModifiedBy'] = this.modifiedBy;
    data['AppointmentStatusName'] = this.appointmentStatusName;
    data['AppointmentStatusDescription'] = this.appointmentStatusDescription;
    data['IsActive'] = this.isActive;
    data['CreatedDate'] = this.createdDate;
    data['ModifiedDate'] = this.modifiedDate;
    return data;
  }
}
