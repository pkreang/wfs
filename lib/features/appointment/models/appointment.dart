import 'package:wfs/features/appointment/models/address.dart';

class Appointment {
  String? appointmentID;
  String? appointmentTitle;
  String? appointmentTypeID;
  String? appointmentTypeName;
  String? userID;
  String? clientID;
  String? clientName;
  String? companyID;
  String? companyName;
  DateTime appointmentDateTimeFrom;
  String? appointmentTimeFrom;
  DateTime appointmentDateTimeTo;
  String? appointmentTimeTo;
  String? appointmentStatusID;
  String? appointmentStatusName;
  String? purposeTypeID;
  String? purposeTypeName;
  String? salesTerritoryID;
  String? salesTerritoryName;
  String? noted;
  String? assignedBy;
  String? phone;
  String? email;
  String? purposeOther;
  String? address;
  Address? appointmentAddress;
  // ? appointmentProducts;
  bool? isActive;
  String? createdBy;
  String? modifiedBy;

  Appointment({
    this.appointmentID,
    this.appointmentTitle,
    this.appointmentTypeID,
    this.appointmentTypeName,
    this.userID,
    this.clientID,
    this.clientName,
    this.companyID,
    this.companyName,
    required this.appointmentDateTimeFrom,
    this.appointmentTimeFrom,
    required this.appointmentDateTimeTo,
    this.appointmentTimeTo,
    this.appointmentStatusID,
    this.appointmentStatusName,
    this.purposeTypeID,
    this.purposeTypeName,
    this.salesTerritoryID,
    this.salesTerritoryName,
    this.noted,
    this.assignedBy,
    this.phone,
    this.email,
    this.purposeOther,
    this.address,
    this.appointmentAddress,
    // this.appointmentProducts,
    this.isActive,
    this.createdBy,
    this.modifiedBy,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      appointmentID: json['AppointmentID'] ?? '',
      appointmentTitle: json['AppointmentTitle'] ?? '',
      appointmentTypeID: json['AppointmentTypeID'] ?? '',
      appointmentTypeName: json['AppointmentTypeName'] ?? '',
      userID: json['UserID'] ?? '',
      clientID: json['ClientID'] ?? '',
      clientName: json['ClientName'] ?? '',
      companyID: json['CompanyID'] ?? '',
      companyName: json['CompanyName'] ?? '',
      appointmentDateTimeFrom: DateTime.parse(json['AppointmentDateTimeFrom'] ?? ''),
      appointmentTimeFrom: json['AppointmentTimeFrom'] ?? '',
      appointmentDateTimeTo: DateTime.parse(json['AppointmentDateTimeTo'] ?? ''),
      appointmentTimeTo: json['AppointmentTimeTo'] ?? '',
      appointmentStatusID: json['AppointmentStatusID'] ?? '',
      appointmentStatusName: json['AppointmentStatusName'] ?? '',
      purposeTypeID: json['PurposeTypeID'] ?? '',
      purposeTypeName: json['PurposeTypeName'] ?? '',
      salesTerritoryID: json['SalesTerritoryID'] ?? '',
      salesTerritoryName: json['SalesTerritoryName'] ?? '',
      noted: json['Noted'] ?? '',
      assignedBy: json['AssignedBy'] ?? '',
      phone: json['Phone'] ?? '',
      email: json['Email'] ?? '',
      purposeOther: json['PurposeOther'] ?? '',
      address: json['Address'] ?? '',
      appointmentAddress: json['AppointmentAddress'] != null ? Address.fromJson(json['AppointmentAddress']) : null,
      // appointmentProducts: json['AppointmentProducts'] ?? '',
      isActive: json['IsActive'] ?? true,
      createdBy: json['CreatedBy'] ?? '',
      modifiedBy: json['ModifiedBy'] ?? '',
    );
  }

  static List<Appointment> listFromJson(List<dynamic> jsonList) => jsonList.map((e) => Appointment.fromJson(e as Map<String, dynamic>)).toList();

  Map<String, dynamic> toJson() {
    final addressJson = appointmentAddress?.toJson();
    if (addressJson != null) {
      addressJson["AppointmentAddress"] = addressJson["Address"];
    }

    return {
      'AppointmentTitle': appointmentTitle,
      'AppointmentTypeID': appointmentTypeID,
      'UserID': userID,
      'ClientID': clientID,
      'CompanyID': companyID,
      'AppointmentDateTimeFrom': appointmentDateTimeFrom.toIso8601String(),
      'AppointmentDateTimeTo': appointmentDateTimeTo.toIso8601String(),
      'AppointmentStatusID': appointmentStatusID,
      'PurposeTypeID': purposeTypeID,
      'Noted': noted,
      'AssignedBy': assignedBy,
      'Phone': phone,
      'Email': email,
      'PurposeOther': purposeOther,
      'AppointmentAddress': addressJson,
      'AppointmentProducts': [],
      'IsActive': isActive,
      'CreatedBy': createdBy,
      'ModifiedBy': modifiedBy,
    };
  }

  // Map<String, dynamic> toJsonSave() {
  //   return {

  //   }
  // }

  Appointment copyWith({
    String? appointmentTitle,
    String? appointmentTypeID,
    String? appointmentTypeName,
    String? userID,
    String? clientID,
    String? clientName,
    String? companyID,
    String? companyName,
    DateTime? appointmentDateTimeFrom,
    DateTime? appointmentDateTimeTo,
    String? appointmentStatusID,
    String? appointmentStatusName,
    String? purposeTypeID,
    String? purposeTypeName,
    String? salesTerritoryID,
    String? salesTerritoryName,
    String? noted,
    String? assignedBy,
    String? phone,
    String? email,
    String? purposeOther,
    Address? appointmentAddress,
    // Null? appointmentProducts,
    bool? isActive,
    String? createdBy,
    String? modifiedBy,
    bool isClearPurposeOther = false,
    bool isRemoveCompany = false,
    bool isRemoveAddress = false,
  }) {
    return Appointment(
      appointmentTitle: appointmentTitle ?? this.appointmentTitle,
      appointmentTypeID: appointmentTypeID ?? this.appointmentTypeID,
      appointmentTypeName: appointmentTypeName ?? this.appointmentTypeName,
      userID: userID ?? this.userID,
      clientID: clientID ?? this.clientID,
      clientName: clientName ?? this.clientName,
      companyID: isRemoveCompany ? null : companyID ?? this.companyID,
      companyName: isRemoveCompany ? null : companyName ?? this.companyName,
      appointmentDateTimeFrom: appointmentDateTimeFrom ?? this.appointmentDateTimeFrom,
      appointmentDateTimeTo: appointmentDateTimeTo ?? this.appointmentDateTimeTo,
      appointmentStatusID: appointmentStatusID ?? this.appointmentStatusID,
      appointmentStatusName: appointmentStatusName ?? this.appointmentStatusName,
      purposeTypeID: purposeTypeID ?? this.purposeTypeID,
      purposeTypeName: purposeTypeName ?? this.purposeTypeName,
      salesTerritoryID: salesTerritoryID ?? this.salesTerritoryID,
      salesTerritoryName: salesTerritoryName ?? this.salesTerritoryName,
      noted: noted ?? this.noted,
      assignedBy: assignedBy ?? this.assignedBy,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      purposeOther: isClearPurposeOther ? null : purposeOther ?? this.purposeOther,
      appointmentAddress: isRemoveAddress ? null : appointmentAddress ?? this.appointmentAddress,
      // appointmentProducts: appointmentProducts ?? this.appointmentProducts,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      modifiedBy: modifiedBy ?? this.modifiedBy,
    );
  }
}
