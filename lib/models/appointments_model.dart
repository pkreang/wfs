import 'package:wfs/models/appointmentaddresss_model.dart';
import 'package:wfs/models/client_model.dart';

class Appointments {
  String? appointmentTitle;
  String? appointmentTypeID;
  String? userID;
  String? clientID;
  String? companyID;
  DateTime? appointmentDateTimeFrom;
  DateTime? appointmentDateTimeTo;
  String? appointmentStatusID;
  String? purposeTypeID;
  String? noted;
  String? assignedBy;
  List<AppointmentAddresss>? appointmentAddress;
  List<String>? appointmentProducts;
  bool? isActive;
  String? createdBy;
  String? modifiedBy;
  String? appointmentTypeName;
  String? appointmentStatusName;
  String? purposeTypeName;
  Client? client;
  String? companyName;
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
    this.appointmentTypeName,
    this.appointmentStatusName,
    this.purposeTypeName,
    this.client,
    this.companyName,
  });

  Appointments.fromJson(Map<String, dynamic> json) {
    appointmentTitle = json['AppointmentTitle'];
    appointmentTypeID = json['AppointmentTypeID'];
    userID = json['UserID'];
    clientID = json['ClientID'];
    companyID = json['CompanyID'];
    appointmentDateTimeFrom = DateTime.parse(json['AppointmentDateTimeFrom']);
    appointmentDateTimeTo = DateTime.parse(json['AppointmentDateTimeTo']);
    appointmentStatusID = json['AppointmentStatusID'];
    purposeTypeID = json['PurposeTypeID'];
    noted = json['Noted'];
    assignedBy = json['AssignedBy'];
    if (json['addresses'] != null) {
      appointmentAddress = [];
      json['addresses'].forEach((v) {
        appointmentAddress!.add(new AppointmentAddresss.fromJson(v));
      });
    }
    appointmentProducts = json['AppointmentProducts'] != null
        ? json['AppointmentProducts'].cast<String>()
        : null;
    isActive = json['IsActive'];
    createdBy = json['CreatedBy'];
    modifiedBy = json['ModifiedBy'];
    appointmentTypeName = json['AppointmentTypeName'];
    appointmentStatusName = json['AppointmentStatusName'];
    purposeTypeName = json['PurposeTypeName'];
    companyName = json['CompanyName'];

    client = json['Client'] != null ? Client.fromJson(json['Client']) : null;
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
      data['addresses'] = this.appointmentAddress!
          .map((v) => v.toJson())
          .toList();
    }
    data['AppointmentProducts'] = this.appointmentProducts;
    data['IsActive'] = this.isActive;
    data['CreatedBy'] = this.createdBy;
    data['ModifiedBy'] = this.modifiedBy;
    data['AppointmentTypeName'] = this.appointmentTypeName;
    data['AppointmentStatusName'] = this.appointmentStatusName;
    data['purposeTypeName'] = this.purposeTypeName;
    data['CompanyName'] = this.companyName;

    if (this.client != null) {
      data['Client'] = this.client!.toJson();
    }
    return data;
  }
}
