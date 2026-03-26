import 'package:intl/intl.dart';
import 'package:wfs/features/appointment/models/address.dart';
import 'package:wfs/features/appointment/models/client.dart';
import 'package:wfs/features/appointment/models/product.dart';
import 'package:wfs/features/appointment/models/visit_activities.dart';
import 'package:wfs/features/tag/models/tag.dart';

class AppointmentDetail {
  final String userID;
  final String clientID;
  final String clientName;
  final String noted;
  final String? assignedBy;
  final String appointmentTitle;
  final String appointmentTypeID;
  final String appointmentTypeName;
  final String appointmentStatusID;
  final String appointmentStatusName;
  final String appointmentID;
  final String purposeTypeID;
  final String purposeTypeName;
  final String? companyID;
  final String? companyName;
  final String appointmentDateTimeFrom;
  final String appointmentDateTimeTo;
  final String? purposeOther;
  final Address address;
  final String phone;
  final String email;
  final List<Product> products;
  final List<VisitActivity> visitActivities;
  final Client client;
  final String modifiedBy;
  final String createdBy;
  final bool isActive;
  final String saleName;
  final List<Tag> tags;

  AppointmentDetail({
    required this.userID,
    required this.clientID,
    required this.clientName,
    required this.noted,
    this.assignedBy,
    required this.appointmentTitle,
    required this.appointmentTypeID,
    required this.appointmentTypeName,
    required this.appointmentStatusID,
    required this.appointmentStatusName,
    required this.appointmentID,
    required this.purposeTypeID,
    required this.purposeTypeName,
    required this.companyID,
    required this.companyName,
    required this.appointmentDateTimeFrom,
    required this.appointmentDateTimeTo,
    this.purposeOther,
    required this.address,
    required this.phone,
    required this.email,
    required this.products,
    required this.visitActivities,
    required this.client,
    required this.modifiedBy,
    required this.createdBy,
    required this.isActive,
    required this.saleName,
    required this.tags,
  });

  factory AppointmentDetail.fromJson(Map<String, dynamic> json) => AppointmentDetail(
    userID: json["UserID"],
    clientID: json["ClientID"],
    clientName: json["ClientName"] ?? '',
    noted: json["Noted"] ?? '',
    assignedBy: json["AssignedBy"],
    appointmentTitle: json["AppointmentTitle"],
    appointmentTypeID: json["AppointmentTypeID"],
    appointmentTypeName: json["AppointmentTypeName"] ?? '',
    appointmentStatusID: json["AppointmentStatusID"],
    appointmentStatusName: json["AppointmentStatusName"] ?? '',
    appointmentID: json["AppointmentID"],
    purposeTypeID: json["PurposeTypeID"],
    purposeTypeName: json['PurposeTypeName'] ?? '',
    companyID: json["CompanyID"] ?? '',
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
    saleName: json["SaleName"] ?? '',
    tags: (json["tags"] as List? ?? []).map((e) => Tag.fromJson(e)).toList(),
  );

  Map<String, dynamic> toJson() => {
    "UserID": userID,
    "ClientID": clientID,
    "ClientName": clientName,
    "Noted": noted,
    "AssignedBy": assignedBy,
    "AppointmentTitle": appointmentTitle,
    "AppointmentTypeID": appointmentTypeID,
    "AppointmentTypeName": appointmentTypeName,
    "AppointmentStatusID": appointmentStatusID,
    "AppointmentStatusName": appointmentStatusName,
    "AppointmentID": appointmentID,
    "PurposeTypeID": purposeTypeID,
    'PurposeTypeName': purposeTypeName,
    "CompanyID": companyID,
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
    "SaleName": saleName,
    "tags": tags.map((e) => e.toJson()).toList(),
  };

  Map<String, dynamic> toJsonUpdate() {
    return {
      "UserID": userID,
      "ClientID": clientID,
      "CompanyID": companyID,
      "Noted": noted,
      "AssignedBy": assignedBy,
      "AppointmentTitle": appointmentTitle,
      "AppointmentTypeID": appointmentTypeID,
      "AppointmentStatusID": appointmentStatusID,
      "PurposeTypeID": purposeTypeID,
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
        "SubDistrictID": address.subDistrictID,
        "DistrictID": address.districtID,
        "ProvinceID": address.provinceID,
        "CountryID": address.countryID,
      },
      "AppointmentProducts": products.map((p) => p.productId).toList(),
      "ModifiedBy": modifiedBy,

      // "addresses": addresses.map((e) => e.toJson()).toList(),
      // "products": products.map((e) => e.toJson()).toList(),
      // "Client": client.toJson(),
    };
  }

  AppointmentDetail copyWith({
    String? userID,
    String? clientID,
    String? clientName,
    String? noted,
    String? assignedBy,
    String? appointmentTitle,
    String? appointmentTypeID,
    String? appointmentTypeName,
    String? appointmentStatusID,
    String? appointmentStatusName,
    String? appointmentID,
    String? purposeTypeID,
    String? purposeTypeName,
    String? purposeOther,
    String? companyID,
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
    String? saleName,
    List<Tag>? tags,
    bool isClearPurposeOther = false,
    bool isRemoveCompany = false,
    bool isRemoveAddress = false,
  }) {
    return AppointmentDetail(
      userID: userID ?? this.userID,
      clientID: clientID ?? this.clientID,
      clientName: clientName ?? this.clientName,
      noted: noted ?? this.noted,
      assignedBy: assignedBy,
      appointmentTitle: appointmentTitle ?? this.appointmentTitle,
      appointmentTypeID: appointmentTypeID ?? this.appointmentTypeID,
      appointmentTypeName: appointmentTypeName ?? this.appointmentTypeName,
      appointmentStatusID: appointmentStatusID ?? this.appointmentStatusID,
      appointmentStatusName: appointmentStatusName ?? this.appointmentStatusName,
      appointmentID: appointmentID ?? this.appointmentID,
      purposeTypeID: purposeTypeID ?? this.purposeTypeID,
      purposeTypeName: purposeTypeName ?? this.purposeTypeName,
      // companyID: isRemoveCompany ? null : companyID ?? this.companyID,
      companyID: companyID ?? this.companyID,
      companyName: isRemoveCompany ? null : companyName ?? this.companyName,
      appointmentDateTimeFrom: appointmentDateTimeFrom ?? this.appointmentDateTimeFrom,
      appointmentDateTimeTo: appointmentDateTimeTo ?? this.appointmentDateTimeTo,
      // address: address ?? this.address,
      address: isRemoveAddress ? Address() : address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      products: products ?? this.products,
      visitActivities: visitActivities ?? this.visitActivities,
      client: client ?? this.client,
      purposeOther: isClearPurposeOther ? null : purposeOther ?? this.purposeOther,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      createdBy: createdBy ?? this.createdBy,
      isActive: isActive ?? this.isActive,
      saleName: saleName ?? this.saleName,
      tags: tags ?? this.tags,
    );
  }
}

extension Status on String {
  bool get isCompleted => this == 'Completed' || this == 'C9B78060-8F8C-46FA-92A6-65D932701EB7';
  bool get isCanceled => this == 'Canceled' || this == '16CBDB62-30BB-4679-A1ED-CB935E11B7E2';
  bool get isOnline => this == 'Online' || this == '28C8F53B-068B-48D5-AB31-BE7E65993096';
  bool get isOnCall => this == 'On Call' || this == '61CDDF98-CCDE-4DB3-837C-DCCCDB42AEBE';
}

extension PurposeType on String {
  bool get isOther => this == 'Other' || this == '43F70CB5-60A5-4E6D-9754-52A42D0EFBBB';
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

  String dateTime() {
    final date = DateTime.tryParse(this);
    if (date == null) return this;

    return DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
  }
}
