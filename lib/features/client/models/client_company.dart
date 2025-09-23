import 'package:wfs/features/company/models/company.dart';

class ClientCompany {
  final String? clientCompanyID;
  final String? clientID;
  final String companyID;
  final String? position;
  final String? noted;
  final String? availableTimeStart;
  final String? availableTimeEnd;
  final bool isActive;
  final Company? company;
  final String? createdBy;
  final String? modifiedBy;

  const ClientCompany({
    this.clientCompanyID,
    this.clientID,
    required this.companyID,
    this.position,
    this.noted,
    this.availableTimeStart,
    this.availableTimeEnd,
    this.isActive = true,
    this.company,
    this.createdBy,
    this.modifiedBy,
  });

  factory ClientCompany.fromJson(Map<String, dynamic> json) => ClientCompany(
    clientCompanyID: json['ClientCompanyID'] as String?,
    clientID: json['ClientID'] as String?,
    companyID: json['CompanyID'] as String,
    position: json['Position'] as String?,
    noted: json['Noted'] as String?,
    availableTimeStart: (json['AvailableTimeStart'])?.toString(),
    availableTimeEnd: (json['AvailableTimeEnd'])?.toString(),
    isActive: (json['IsActive'] as bool?) ?? false,
    company: (json['Company'] != null) ? Company.fromJson(json['Company'] as Map<String, dynamic>) : null,
    createdBy: json['CreatedBy'] as String?,
    modifiedBy: json['ModifiedBy'] as String?,
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
    // 'Company': company?.toJson(),
    'CreatedBy': createdBy,
    'ModifiedBy': modifiedBy,
  };

  static List<ClientCompany> listFromJson(List<dynamic> jsonList) => jsonList.map((e) => ClientCompany.fromJson(e as Map<String, dynamic>)).toList();

  static List<Map<String, dynamic>> toJsonList(List<ClientCompany> items) {
    return items.map((e) {
      final map = e.toJson();
      return map;
    }).toList();
  }

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
    String? createdBy,
    String? modifiedBy,
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
      createdBy: createdBy ?? this.createdBy,
      modifiedBy: modifiedBy ?? this.modifiedBy,
    );
  }
}
