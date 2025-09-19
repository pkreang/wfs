import 'package:wfs/features/appointment/models/address.dart';
import 'package:wfs/models/companyaddress.dart';

class ClientCompany {
  final String clientCompanyID;
  final String clientID;
  final String companyID;
  final String? position;
  final String? noted;
  final String? availableTimeStart;
  final String? availableTimeEnd;
  final bool isActive;
  final Company? company;

  const ClientCompany({
    required this.clientCompanyID,
    required this.clientID,
    required this.companyID,
    this.position,
    this.noted,
    this.availableTimeStart,
    this.availableTimeEnd,
    this.isActive = true,
    this.company,
  });

  factory ClientCompany.fromJson(Map<String, dynamic> json) => ClientCompany(
    clientCompanyID: json['ClientCompanyID'] as String,
    clientID: json['ClientID'] as String,
    companyID: json['CompanyID'] as String,
    position: json['Position'] as String?,
    noted: json['Noted'] as String?,
    availableTimeStart: (json['AvailableTimeStart'])?.toString(),
    availableTimeEnd: (json['AvailableTimeEnd'])?.toString(),
    isActive: (json['IsActive'] as bool?) ?? false,
    company: (json['Company'] != null) ? Company.fromJson(json['Company'] as Map<String, dynamic>) : null,
  );

  Map<String, dynamic> toJson() => {
    'ClientCompanyID': clientCompanyID,
    'ClientID': clientID,
    'CompanyID': companyID,
    'Position': position,
    'Noted': noted,
    'AvailableTimeStart': availableTimeStart,
    'AvailableTimeEnd': availableTimeEnd,
    'IsActive': isActive,
    'Company': company?.toJson(),
  };

  static List<ClientCompany> listFromJson(List<dynamic> jsonList) => jsonList.map((e) => ClientCompany.fromJson(e as Map<String, dynamic>)).toList();

  ClientCompany copyWith({
    String? clientCompanyID,
    String? clientID,
    String? companyID,
    String? position,
    String? noted,
    String? availableTimeStart,
    String? availableTimeEnd,
    bool? isActive,
    Company? company,
  }) {
    return ClientCompany(
      clientCompanyID: clientCompanyID ?? this.clientCompanyID,
      clientID: clientID ?? this.clientID,
      companyID: companyID ?? this.companyID,
      position: position ?? this.position,
      noted: noted ?? this.noted,
      availableTimeStart: availableTimeStart ?? this.availableTimeStart,
      availableTimeEnd: availableTimeEnd ?? this.availableTimeEnd,
      isActive: isActive ?? this.isActive,
      company: company ?? this.company,
    );
  }
}

class Company {
  final String companyID;
  final String companyName;
  final String? taxID;
  final String? noted;
  final String? salesTerritoryID;
  final bool? isActive;
  final List<CompanyAddress> addresses;

  const Company({required this.companyID, required this.companyName, this.taxID, this.noted, this.salesTerritoryID, this.isActive, this.addresses = const []});

  factory Company.fromJson(Map<String, dynamic> json) => Company(
    companyID: json['CompanyID'] as String,
    companyName: (json['CompanyName'] ?? '') as String,
    taxID: json['TaxID'] as String?,
    noted: json['Noted'] as String?,
    salesTerritoryID: json['SalesTerritoryID'] as String?,
    isActive: json['IsActive'] as bool?,
    addresses: (json['addresses'] as List<dynamic>?)?.map((e) => CompanyAddress.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
  );

  Map<String, dynamic> toJson() => {
    'CompanyID': companyID,
    'CompanyName': companyName,
    'TaxID': taxID,
    'Noted': noted,
    'SalesTerritoryID': salesTerritoryID,
    'IsActive': isActive,
    'addresses': addresses.map((e) => e.toJson()).toList(),
  };

  Company copyWith({String? companyID, String? companyName, String? taxID, String? noted, String? salesTerritoryID, bool? isActive, List<CompanyAddress>? addresses}) {
    return Company(
      companyID: companyID ?? this.companyID,
      companyName: companyName ?? this.companyName,
      taxID: taxID ?? this.taxID,
      noted: noted ?? this.noted,
      salesTerritoryID: salesTerritoryID ?? this.salesTerritoryID,
      isActive: isActive ?? this.isActive,
      addresses: addresses ?? this.addresses,
    );
  }
}
