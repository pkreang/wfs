import 'package:wfs/features/company/models/client.dart';
import 'package:wfs/features/company/models/company_address.dart';

class Company {
  final String? companyID;
  final String? companyName;
  final String? taxID;
  final String? noted;
  final String? salesTerritoryID;
  final String? salesTerritoryName;
  final bool? isActive;
  final List<Client> clients;
  final List<CompanyAddress> addresses;
  final String? createdBy;
  final String? modifiedBy;

  const Company({
    this.companyID,
    this.companyName,
    this.taxID,
    this.noted,
    this.salesTerritoryID,
    this.salesTerritoryName,
    this.isActive,
    this.clients = const [],
    this.addresses = const [],
    this.createdBy,
    this.modifiedBy,
  });

  factory Company.fromJson(Map<String, dynamic> json) => Company(
    companyID: json['CompanyID'] as String?,
    companyName: (json['CompanyName'] ?? '') as String?,
    taxID: json['TaxID'] as String?,
    noted: json['Noted'] as String?,
    salesTerritoryID: json['SalesTerritoryID'] as String?,
    salesTerritoryName: json['SalesTerritoryName'] as String?,
    isActive: json['IsActive'] as bool?,
    clients: (json['clients'] as List<dynamic>?)?.map((e) => Client.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
    addresses: (json['addresses'] as List<dynamic>?)?.map((e) => CompanyAddress.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
    createdBy: json['CreatedBy'] as String?,
    modifiedBy: json['ModifiedBy'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'CompanyID': companyID,
    'CompanyName': companyName,
    'TaxID': taxID,
    'Noted': noted,
    'SalesTerritoryID': salesTerritoryID,
    'SalesTerritoryName': salesTerritoryName,
    'IsActive': isActive,
    'clients': clients.map((e) => e.toJson()).toList(),
    'addresses': addresses.map((e) => e.toJson()).toList(),
    'CreatedBy': createdBy,
    'ModifiedBy': modifiedBy,
  };

  Map<String, dynamic> toJsonCreate(String createdBy, modifiedBy) => {
    "CompanyName": companyName,
    "TaxID": taxID,
    "SalesTerritoryID": salesTerritoryID,
    "Noted": noted ?? '',
    "IsActive": true,
    "CreatedBy": createdBy,
    "ModifiedBy": modifiedBy,
    "CompanyAddresses": addresses.map((e) => e.toJson()).toList(),
    "Clients": null,
  };

  Map<String, dynamic> toJsonUpdate(String modifiedBy) => {
    "CompanyName": companyName,
    "TaxID": taxID,
    "SalesTerritoryID": salesTerritoryID,
    "Noted": noted,
    "IsActive": isActive,
    "CreatedBy": createdBy,
    "ModifiedBy": modifiedBy,
    "Clients": clients.map((e) {
      final obj = {"CompanyID": null, "Position": null, "Noted": null, "AvailableTimeStart": null, "AvailableTimeEnd": null, "IsActive": true, "CreatedBy": null, "ModifiedBy": null};

      return {...obj, ...e.toJson()};
    }).toList(),
    "CompanyAddresses": addresses.map((e) => e.toJsonUpdate()).toList(),

    // "Clients": [
    //   {
    //     "ClientID": "D9809A76-98F3-4009-9112-026754C31CC7",
    //     "CompanyID": null,
    //     "Position": null,
    //     "Noted": null,
    //     "AvailableTimeStart": null,
    //     "AvailableTimeEnd": null,
    //     "IsActive": true,
    //     "CreatedBy": null,
    //     "ModifiedBy": null,
    //   },
    // ],
  };

  Company copyWith({
    String? companyID,
    String? companyName,
    String? taxID,
    String? noted,
    String? salesTerritoryID,
    String? salesTerritoryName,
    bool? isActive,
    List<Client>? clients,
    List<CompanyAddress>? addresses,
    String? createdBy,
    String? modifiedBy,
  }) {
    return Company(
      companyID: companyID ?? this.companyID,
      companyName: companyName ?? this.companyName,
      taxID: taxID ?? this.taxID,
      noted: noted ?? this.noted,
      salesTerritoryID: salesTerritoryID ?? this.salesTerritoryID,
      salesTerritoryName: salesTerritoryName ?? this.salesTerritoryName,
      isActive: isActive ?? this.isActive,
      clients: clients ?? this.clients,
      addresses: addresses ?? this.addresses,
      createdBy: createdBy ?? this.createdBy,
      modifiedBy: modifiedBy ?? this.modifiedBy,
    );
  }
}
