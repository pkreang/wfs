class Company {
  final String companyID;
  final String salesTerritoryID;
  final bool isActive;
  final DateTime createdDate;
  final DateTime modifiedDate;
  final String taxID;
  final String companyName;
  final String noted;
  final String createdBy;
  final String modifiedBy;

  Company({
    required this.companyID,
    required this.salesTerritoryID,
    required this.isActive,
    required this.createdDate,
    required this.modifiedDate,
    required this.taxID,
    required this.companyName,
    required this.noted,
    required this.createdBy,
    required this.modifiedBy,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      companyID: json['CompanyID'] ?? '',
      salesTerritoryID: json['SalesTerritoryID'] ?? '',
      isActive: json['IsActive'] ?? false,
      createdDate: DateTime.parse(
        json['CreatedDate'] ?? DateTime.now().toIso8601String(),
      ),
      modifiedDate: DateTime.parse(
        json['ModifiedDate'] ?? DateTime.now().toIso8601String(),
      ),
      taxID: json['TaxID'] ?? '',
      companyName: json['CompanyName'] ?? '',
      noted: json['Noted'] ?? '',
      createdBy: json['CreatedBy'] ?? '',
      modifiedBy: json['ModifiedBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CompanyID': companyID,
      'SalesTerritoryID': salesTerritoryID,
      'IsActive': isActive,
      'CreatedDate': createdDate.toIso8601String(),
      'ModifiedDate': modifiedDate.toIso8601String(),
      'TaxID': taxID,
      'CompanyName': companyName,
      'Noted': noted,
      'CreatedBy': createdBy,
      'ModifiedBy': modifiedBy,
    };
  }
}

class CompanyResponse {
  final String status;
  final List<Company> companies;

  CompanyResponse({required this.status, required this.companies});

  factory CompanyResponse.fromJson(Map<String, dynamic> json) {
    return CompanyResponse(
      status: json['status'] ?? '',
      companies:
          (json['companies'] as List<dynamic>?)
              ?.map((companyJson) => Company.fromJson(companyJson))
              .toList() ??
          [],
    );
  }
}
