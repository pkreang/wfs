import 'dart:convert';

import 'package:wfs/features/appointment/models/address.dart';
import 'package:wfs/features/appointment/models/sales_territory.dart';
import 'package:wfs/features/client/models/client_company.dart';
import 'package:wfs/features/client/models/client_level.dart';
import 'package:wfs/features/client/models/client_status.dart';
import 'package:wfs/features/tag/models/tag.dart';
import 'package:wfs/models/auth_model.dart';

extension TimeFormat on String {
  String toHHmm() {
    final parts = split(":");
    return (parts.length >= 2) ? "${parts[0]}:${parts[1]}" : this;
  }
}

class DealValue {
  final String? dealValueItemID;
  final String detail;
  final num? saleAmount;

  const DealValue({this.dealValueItemID, required this.detail, this.saleAmount});

  factory DealValue.fromJson(Map<String, dynamic> json) {
    return DealValue(
      dealValueItemID: (json['DealValueItemID'] ?? json['DealValueItemID'] ?? '').toString(),
      detail: (json['Detail'] ?? json['Detail'] ?? '').toString(),
      saleAmount: num.tryParse((json['SaleAmount'] ?? json['SaleAmount'] ?? '').toString()),
    );
  }

  Map<String, dynamic> toJson() => {'detail': detail, 'sale_amount': saleAmount, 'note': null};

  static List<DealValue> listFromJson(Object? value) {
    if (value == null) return const [];
    if (value is String) {
      if (value.trim().isEmpty) return const [];
      try {
        final decoded = jsonDecode(value);
        return listFromJson(decoded);
      } catch (_) {
        return const [];
      }
    }
    if (value is List) {
      return value.whereType<Map>().map((item) => DealValue.fromJson(Map<String, dynamic>.from(item))).where((item) => item.detail.trim().isNotEmpty).toList();
    }
    return const [];
  }

  static String? encodeList(List<DealValue>? values) {
    if (values == null || values.isEmpty) return null;
    return jsonEncode(values.map((item) => item.toJson()).toList());
  }
}

class Client {
  final String? clientID;
  final String? clientLevelID;
  final ClientLevel? clientLevel;
  final String? clientStatusID;
  final ClientStatus? clientStatus;
  final String? firstName;
  final String? lastName;
  final String? noted;
  final String? phone;
  final String? email;
  final String? availableTimeStart;
  final String? availableTimeEnd;
  final SalesTerritory? salesTerritory;
  final String? salesTerritoryID;
  final String? salesTerritoryName;
  final List<Address>? addresses;
  final List<ClientCompany>? companies;
  final String? createdBy;
  final String? saleID;
  final String? saleName;
  final List<Tag>? tags;
  final int? closeProbability;
  final double? budget;
  final String? jobTitle;
  final String? lineID;
  final String? reportLine;
  final int? noOfSubordinate;
  final String? clientType;
  final List<DealValue>? dealValues;

  Client({
    this.clientID,
    this.clientLevelID,
    this.clientLevel,
    this.clientStatusID,
    this.clientStatus,
    this.firstName,
    this.lastName,
    this.noted,
    this.phone,
    this.email,
    this.availableTimeStart,
    this.availableTimeEnd,
    this.salesTerritory,
    this.salesTerritoryID,
    this.salesTerritoryName,
    this.addresses,
    this.companies,
    this.createdBy,
    this.saleID,
    this.saleName,
    this.tags,
    this.closeProbability,
    this.budget,
    this.jobTitle,
    this.lineID,
    this.reportLine,
    this.noOfSubordinate,
    this.clientType,
    this.dealValues,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    final closeProbabilityValue = json['close_probability'] ?? json['closeProbability'] ?? json['CloseProbability'];

    return Client(
      clientID: json['ClientID'],
      clientLevelID: json['ClientLevelID'],
      clientLevel: ClientLevel.fromJson(json['ClientLevel'] as Map<String, dynamic>),
      clientStatusID: json['ClientStatusID'],
      clientStatus: ClientStatus.fromJson(json['ClientStatus'] as Map<String, dynamic>),
      firstName: json['FirstName'],
      lastName: json['LastName'],
      noted: json['Noted'],
      phone: json['Phone'],
      email: json['Email'],
      availableTimeStart: (json['AvailableTimeStart'] ?? "").toString().toHHmm(),
      availableTimeEnd: (json['AvailableTimeEnd'] ?? "").toString().toHHmm(),
      salesTerritory: (json['SalesTerritory'] != null) ? SalesTerritory.fromJson(json['SalesTerritory'] as Map<String, dynamic>) : null,
      salesTerritoryID: json['SalesTerritoryID'],
      salesTerritoryName: json['SalesTerritoryName'],
      addresses: Address.listFromJson(json['addresses'] ?? []),
      companies: ClientCompany.listFromJson(json['companies'] ?? []),
      createdBy: json['CreatedBy'],
      saleID: json['SaleID'],
      saleName: json['SaleName'],
      tags: Tag.listFromJson(json['tags'] ?? []),
      closeProbability: closeProbabilityValue is num ? closeProbabilityValue.toInt() : int.tryParse((closeProbabilityValue ?? '').toString()),
      budget: double.tryParse((json['Budget'] ?? json['budget'] ?? '').toString()),
      jobTitle: json['JobTitle'],
      lineID: json['LineID'],
      reportLine: json['ReportingLine'],
      noOfSubordinate: json['NumberOfSubordinates'],
      clientType: json['clientType'],
      dealValues: DealValue.listFromJson(json['DealValueTracking']),
    );
  }

  factory Client.fromTaskLookupJson(Map<String, dynamic> json) {
    return Client(clientID: json['ClientID']?.toString(), firstName: json['ClientName']?.toString() ?? '', lastName: '', phone: json['Phone']?.toString(), email: json['Email']?.toString(), clientType: json['ClientType']?.toString());
  }

  Map<String, dynamic> toJsonCreate(String userID, AuthState authState) {
    if ((companies ?? []).isEmpty) return {};

    String address = "";

    for (var clientCompany in companies!) {
      if ((clientCompany.company?.addresses ?? []).isEmpty) return {};

      for (var companyAddress in clientCompany.company!.addresses) {
        address = companyAddress.address ?? '';
      }
    }

    return {
      "FirstName": firstName,
      "LastName": lastName,
      "Address": address,
      "Phone": phone,
      "Email": email,
      "SalesTerritoryID": authState.isSales ? authState.territoryID : salesTerritoryID,
      "ClientStatusID": clientStatusID,
      "ClientLevelID": clientLevelID,
      "Noted": "",
      "AvailableTimeStart": availableTimeStart ?? '',
      "AvailableTimeEnd": availableTimeEnd ?? '',
      "IsActive": true,
      "CreatedBy": userID,
      "ModifiedBy": userID,
      "ClientAddresses": null,
      "ClientProducts": null,
      "ClientCompanies": (companies ?? []).map((v) => v.toJson()).toList(),
      "ClientSales": [authState.isSales ? authState.userID : saleID],
      "Tags": (tags ?? []).map((v) => v.toJson()).toList(),
      "CloseProbability": closeProbability,
      "Budget": budget,
      "JobTitle": jobTitle,
      "LineID": lineID,
      "ReportingLine": reportLine,
      "NumberOfSubordinates": noOfSubordinate,
    };
  }

  Map<String, dynamic> toJsonUpdate(String modifiedBy, AuthState authState) {
    return {
      "FirstName": firstName,
      "LastName": lastName,
      // "Address": "123 Bangkok",
      "Phone": phone,
      "Email": email,
      "SalesTerritoryID": authState.isSales ? authState.territoryID : salesTerritoryID,
      "ClientStatusID": clientStatusID,
      "ClientLevelID": clientLevelID,
      "Noted": noted,
      "AvailableTimeStart": availableTimeStart,
      "AvailableTimeEnd": availableTimeEnd,
      "IsActive": true,
      "CreatedBy": createdBy,
      "ModifiedBy": modifiedBy,
      "ClientAddresses": null,
      "ClientProducts": null,
      "ClientCompanies": (companies ?? []).map((v) => v.toJson()).toList(),
      "ClientSales": [saleID],
      "CloseProbability": 99.99,
      "Budget": 100,
      "JobTitle": jobTitle,
      "LineID": lineID,
      "ReportingLine": reportLine,
      "NumberOfSubordinates": noOfSubordinate,
    };
  }

  Client copyWith({
    String? clientID,
    String? clientLevelID,
    ClientLevel? clientLevel,
    String? clientStatusID,
    ClientStatus? clientStatus,
    String? firstName,
    String? lastName,
    String? noted,
    String? phone,
    String? email,
    String? availableTimeStart,
    String? availableTimeEnd,
    SalesTerritory? salesTerritory,
    String? salesTerritoryID,
    String? salesTerritoryName,
    List<Address>? addresses,
    List<ClientCompany>? companies,
    String? createdBy,
    String? saleID,
    String? saleName,
    List<Tag>? tags,
    final int? closeProbability,
    final double? budget,
    String? jobTitle,
    String? lineID,
    String? reportLine,
    int? noOfSubordinate,
  }) {
    return Client(
      clientID: clientID ?? this.clientID,
      clientLevelID: clientLevelID ?? this.clientLevelID,
      clientLevel: clientLevel ?? this.clientLevel,
      clientStatusID: clientStatusID ?? this.clientStatusID,
      clientStatus: clientStatus ?? this.clientStatus,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      noted: noted ?? this.noted,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      availableTimeStart: availableTimeStart ?? this.availableTimeStart,
      availableTimeEnd: availableTimeEnd ?? this.availableTimeEnd,
      salesTerritory: salesTerritory ?? this.salesTerritory,
      salesTerritoryID: salesTerritoryID ?? this.salesTerritoryID,
      salesTerritoryName: salesTerritoryName ?? this.salesTerritoryName,
      addresses: addresses ?? this.addresses,
      companies: companies ?? this.companies,
      createdBy: createdBy ?? this.createdBy,
      saleID: saleID ?? this.saleID,
      saleName: saleName ?? this.saleName,
      tags: tags ?? this.tags,
      closeProbability: closeProbability ?? this.closeProbability,
      budget: budget ?? this.budget,
      jobTitle: jobTitle ?? this.jobTitle,
      lineID: lineID ?? this.lineID,
      reportLine: reportLine ?? this.reportLine,
      noOfSubordinate: noOfSubordinate ?? this.noOfSubordinate,
    );
  }

  String get clientName => '$firstName $lastName';
}
