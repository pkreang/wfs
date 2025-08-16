import 'package:wfs/models/appointmentaddresss_model.dart';

class Appointments {
  String? appointmentTitle;
  String? appointmentTypeID;
  String? userID;
  String? clientID;
  String? companyID;
  String? appointmentDateTimeFrom;
  String? appointmentDateTimeTo;
  String? appointmentStatusID;
  String? purposeTypeID;
  String? noted;
  String? assignedBy;
  AppointmentAddresss? appointmentAddress;
  List<String>? appointmentProducts;
  bool? isActive;
  String? createdBy;
  String? modifiedBy;

  Appointments({
    this.appointmentTitle,
    this.appointmentTypeID,
    this.userID,
    this.clientID,
    this.companyID,
    this.appointmentDateTimeFrom,
    this.appointmentDateTimeTo,
    this.appointmentStatusID,
    this.purposeTypeID,
    this.noted,
    this.assignedBy,
    this.appointmentAddress,
    this.appointmentProducts,
    this.isActive,
    this.createdBy,
    this.modifiedBy,
  });

  Appointments.fromJson(Map<String, dynamic> json) {
    appointmentTitle = json['AppointmentTitle'];
    appointmentTypeID = json['AppointmentTypeID'];
    userID = json['UserID'];
    clientID = json['ClientID'];
    companyID = json['CompanyID'];
    appointmentDateTimeFrom = json['AppointmentDateTimeFrom'];
    appointmentDateTimeTo = json['AppointmentDateTimeTo'];
    appointmentStatusID = json['AppointmentStatusID'];
    purposeTypeID = json['PurposeTypeID'];
    noted = json['Noted'];
    assignedBy = json['AssignedBy'];
    appointmentAddress = json['AppointmentAddress'] != null
        ? new AppointmentAddresss.fromJson(json['AppointmentAddress'])
        : null;
    appointmentProducts = json['AppointmentProducts'].cast<String>();
    isActive = json['IsActive'];
    createdBy = json['CreatedBy'];
    modifiedBy = json['ModifiedBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['AppointmentTitle'] = this.appointmentTitle;
    data['AppointmentTypeID'] = this.appointmentTypeID;
    data['UserID'] = this.userID;
    data['ClientID'] = this.clientID;
    data['CompanyID'] = this.companyID;
    data['AppointmentDateTimeFrom'] = this.appointmentDateTimeFrom;
    data['AppointmentDateTimeTo'] = this.appointmentDateTimeTo;
    data['AppointmentStatusID'] = this.appointmentStatusID;
    data['PurposeTypeID'] = this.purposeTypeID;
    data['Noted'] = this.noted;
    data['AssignedBy'] = this.assignedBy;
    if (this.appointmentAddress != null) {
      data['AppointmentAddress'] = this.appointmentAddress!.toJson();
    }
    data['AppointmentProducts'] = this.appointmentProducts;
    data['IsActive'] = this.isActive;
    data['CreatedBy'] = this.createdBy;
    data['ModifiedBy'] = this.modifiedBy;
    return data;
  }
}
