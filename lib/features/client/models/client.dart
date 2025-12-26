import 'package:wfs/features/appointment/models/address.dart';
import 'package:wfs/features/appointment/models/sales_territory.dart';
import 'package:wfs/features/client/models/client_company.dart';
import 'package:wfs/features/client/models/client_level.dart';
import 'package:wfs/features/client/models/client_status.dart';

extension TimeFormat on String {
  String toHHmm() {
    final parts = split(":");
    return (parts.length >= 2) ? "${parts[0]}:${parts[1]}" : this;
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
  });

  factory Client.fromJson(Map<String, dynamic> json) {
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
    );
  }

  Map<String, dynamic> toJsonCreate(String userID) {
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
      "SalesTerritoryID": salesTerritoryID,
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
      "ClientSales": [saleID],
    };
  }

  Map<String, dynamic> toJsonUpdate(String modifiedBy) {
    return {
      "FirstName": firstName,
      "LastName": lastName,
      // "Address": "123 Bangkok",
      "Phone": phone,
      "Email": email,
      "SalesTerritoryID": salesTerritoryID,
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
    );
  }

  String get clientName => '$firstName $lastName';
}
