import 'package:intl/intl.dart';
import 'package:wfs/features/appointment/models/address.dart';
import 'package:wfs/features/appointment/models/client.dart';
import 'package:wfs/features/appointment/models/product.dart';
import 'package:wfs/features/appointment/models/visit_activities.dart';

class AppointmentDetail {
  final String userId;
  final String clientId;
  final String clientName;
  final String noted;
  final String? assignedBy;
  final String appointmentTitle;
  final String appointmentTypeId;
  final String appointmentTypeName;
  final String appointmentStatusId;
  final String appointmentStatusName;
  final String appointmentId;
  final String purposeTypeId;
  final String purposeTypeName;
  final String? companyId;
  final String companyName;
  final String appointmentDateTimeFrom;
  final String appointmentDateTimeTo;
  final String purposeOther;
  final Address address;
  final String phone;
  final String email;
  final List<Product> products;
  final List<VisitActivity> visitActivities;
  final Client client;
  final String modifiedBy;
  final String createdBy;
  final bool isActive;

  AppointmentDetail({
    required this.userId,
    required this.clientId,
    required this.clientName,
    required this.noted,
    this.assignedBy,
    required this.appointmentTitle,
    required this.appointmentTypeId,
    required this.appointmentTypeName,
    required this.appointmentStatusId,
    required this.appointmentStatusName,
    required this.appointmentId,
    required this.purposeTypeId,
    required this.purposeTypeName,
    required this.companyId,
    required this.companyName,
    required this.appointmentDateTimeFrom,
    required this.appointmentDateTimeTo,
    required this.purposeOther,
    required this.address,
    required this.phone,
    required this.email,
    required this.products,
    required this.visitActivities,
    required this.client,
    required this.modifiedBy,
    required this.createdBy,
    required this.isActive,
  });

  factory AppointmentDetail.fromJson(Map<String, dynamic> json) => AppointmentDetail(
    userId: json["UserID"],
    clientId: json["ClientID"],
    clientName: json["ClientName"] ?? '',
    noted: json["Noted"] ?? '',
    assignedBy: json["AssignedBy"],
    appointmentTitle: json["AppointmentTitle"],
    appointmentTypeId: json["AppointmentTypeID"],
    appointmentTypeName: json["AppointmentTypeName"] ?? '',
    appointmentStatusId: json["AppointmentStatusID"],
    appointmentStatusName: json["AppointmentStatusName"] ?? '',
    appointmentId: json["AppointmentID"],
    purposeTypeId: json["PurposeTypeID"],
    purposeTypeName: json['PurposeTypeName'] ?? '',
    companyId: json["CompanyID"],
    companyName: json["CompanyName"] ?? '',
    appointmentDateTimeFrom: json["AppointmentDateTimeFrom"],
    appointmentDateTimeTo: json["AppointmentDateTimeTo"],
    purposeOther: json["PurposeOther"] ?? '',
    address: Address.fromJson((json["addresses"] as List).isNotEmpty ? json["addresses"][0] : null),
    phone: json["Phone"] ?? '',
    email: json["Email"] ?? '',
    products: (json["products"] as List).map((e) => Product.fromJson(e)).toList(),
    visitActivities: (json["VisitActivities"] as List? ?? []).map((e) => VisitActivity.fromJson(e)).toList(),
    client: Client.fromJson(json["Client"]),
    modifiedBy: json["ModifiedBy"],
    createdBy: json["CreatedBy"],
    isActive: json["IsActive"],
  );

  Map<String, dynamic> toJson() => {
    "UserID": userId,
    "ClientID": clientId,
    "ClientName": clientName,
    "Noted": noted,
    "AssignedBy": assignedBy,
    "AppointmentTitle": appointmentTitle,
    "AppointmentTypeID": appointmentTypeId,
    "AppointmentTypeName": appointmentTypeName,
    "AppointmentStatusID": appointmentStatusId,
    "AppointmentStatusName": appointmentStatusName,
    "AppointmentID": appointmentId,
    "PurposeTypeID": purposeTypeId,
    'PurposeTypeName': purposeTypeName,
    "CompanyID": companyId,
    "CompanyName": companyName,
    "AppointmentDateTimeFrom": appointmentDateTimeFrom,
    "AppointmentDateTimeTo": appointmentDateTimeTo,
    "PurposeOther": purposeOther,
    "address": address.toJson(),
    "Phone": phone,
    "Email": email,
    "products": products.map((e) => e.toJson()).toList(),
    "Client": client.toJson(),
    "ModifiedBy": modifiedBy,
    "CreatedBy": createdBy,
    "IsActive": isActive,
  };

  Map<String, dynamic> toJsonUpdate() {
    return {
      "UserID": userId,
      "ClientID": clientId,
      "CompanyID": companyId,
      "Noted": noted,
      "AssignedBy": assignedBy,
      "AppointmentTitle": appointmentTitle,
      "AppointmentTypeID": appointmentTypeId,
      "AppointmentStatusID": appointmentStatusId,
      "PurposeTypeID": purposeTypeId,
      "SalesTerritoryID": client.salesTerritory?.salesTerritoryID,
      "AppointmentDateTimeFrom": appointmentDateTimeFrom,
      "AppointmentDateTimeTo": appointmentDateTimeTo,
      "Phone": phone,
      "Email": email,
      "PurposeOther": purposeOther,
      "AppointmentAddress": {
        "Latitude": address.latitude,
        "Longitude": address.longitude,
        "Address": address.address,
        "SubDistrictID": address.subDistrictId,
        "DistrictID": address.districtId,
        "ProvinceID": address.provinceId,
        "CountryID": address.countryId,
      },
      "AppointmentProducts": products.map((p) => p.productId).toList(),
      "ModifiedBy": modifiedBy,

      // "addresses": addresses.map((e) => e.toJson()).toList(),
      // "products": products.map((e) => e.toJson()).toList(),
      // "Client": client.toJson(),
    };
  }

  AppointmentDetail copyWith({
    String? userId,
    String? clientId,
    String? clientName,
    String? noted,
    String? assignedBy,
    String? appointmentTitle,
    String? appointmentTypeId,
    String? appointmentTypeName,
    String? appointmentStatusId,
    String? appointmentStatusName,
    String? appointmentId,
    String? purposeTypeId,
    String? purposeTypeName,
    String? companyId,
    String? companyName,
    String? appointmentDateTimeFrom,
    String? appointmentDateTimeTo,
    Address? address,
    String? phone,
    String? email,
    List<Product>? products,
    List<VisitActivity>? visitActivities,
    Client? client,
    String? modifiedBy,
    String? createdBy,
    bool? isActive,
  }) {
    return AppointmentDetail(
      userId: userId ?? this.userId,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      noted: noted ?? this.noted,
      assignedBy: assignedBy,
      appointmentTitle: appointmentTitle ?? this.appointmentTitle,
      appointmentTypeId: appointmentTypeId ?? this.appointmentTypeId,
      appointmentTypeName: appointmentTypeName ?? this.appointmentTypeName,
      appointmentStatusId: appointmentStatusId ?? this.appointmentStatusId,
      appointmentStatusName: appointmentStatusName ?? this.appointmentStatusName,
      appointmentId: appointmentId ?? this.appointmentId,
      purposeTypeId: purposeTypeId ?? this.purposeTypeId,
      purposeTypeName: purposeTypeName ?? this.purposeTypeName,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      appointmentDateTimeFrom: appointmentDateTimeFrom ?? this.appointmentDateTimeFrom,
      appointmentDateTimeTo: appointmentDateTimeTo ?? this.appointmentDateTimeTo,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      products: products ?? this.products,
      visitActivities: visitActivities ?? this.visitActivities,
      client: client ?? this.client,
      purposeOther: purposeOther,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      createdBy: createdBy ?? this.createdBy,
      isActive: isActive ?? this.isActive,
    );
  }
}

extension TimeFormat on String {
  String toHHmmss() {
    final date = DateTime.tryParse(this);
    if (date == null) return this;

    final midnight = DateTime(date.year, date.month, date.day);
    return DateFormat.Hms().format(midnight);
  }

  String dateTimetoHHmm() {
    final date = DateTime.tryParse(this);
    if (date == null) return this;

    final midnight = DateTime(date.year, date.month, date.day, date.hour, date.minute);

    return DateFormat.Hm().format(midnight);
  }
}
