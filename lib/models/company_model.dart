import 'package:wfs/models/client_model.dart';
import 'package:wfs/models/companyaddress.dart';

class Company {
  String? companyName;
  String? taxID;
  String? noted;
  String? createdBy;
  String? modifiedBy;
  String? companyID;
  String? salesTerritoryID;
  bool? isActive;
  String? createdDate;
  String? modifiedDate;
  List<CompanyAddress>? CompanyAddresses;
  List<Client>? Clients;

  Company({
    this.companyName,
    this.taxID,
    this.noted,
    this.createdBy,
    this.modifiedBy,
    this.companyID,
    this.salesTerritoryID,
    this.isActive,
    this.createdDate,
    this.modifiedDate,
    this.CompanyAddresses,
    this.Clients,
  });

  Company.fromJson(Map<String, dynamic> json) {
    companyName = json['CompanyName'];
    taxID = json['TaxID'];
    noted = json['Noted'];
    createdBy = json['CreatedBy'];
    modifiedBy = json['ModifiedBy'];
    companyID = json['CompanyID'];
    salesTerritoryID = json['SalesTerritoryID'];
    isActive = json['IsActive'];
    createdDate = json['CreatedDate'];
    modifiedDate = json['ModifiedDate'];
    if (json['CompanyAddresses'] != null) {
      CompanyAddresses = <CompanyAddress>[];
      json['CompanyAddresses'].forEach((v) {
        CompanyAddresses!.add(new CompanyAddress.fromJson(v));
      });
    }
    if (json['addresses'] != null) {
      CompanyAddresses = <CompanyAddress>[];
      json['addresses'].forEach((v) {
        CompanyAddresses!.add(new CompanyAddress.fromJson(v));
      });
    }
    if (json['Clients'] != null) {
      Clients = <Client>[];
      json['Clients'].forEach((v) {
        Clients!.add(new Client.fromJson(v));
      });
    } else {
      Clients = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CompanyName'] = this.companyName;
    data['TaxID'] = this.taxID;
    data['Noted'] = this.noted;
    data['CreatedBy'] = this.createdBy;
    data['ModifiedBy'] = this.modifiedBy;
    data['CompanyID'] = this.companyID;
    data['SalesTerritoryID'] = this.salesTerritoryID;
    data['IsActive'] = this.isActive;
    data['CreatedDate'] = this.createdDate;
    data['ModifiedDate'] = this.modifiedDate;
    if (this.CompanyAddresses != null) {
      data['CompanyAddresses'] = this.CompanyAddresses!
          .map((v) => v.toJson())
          .toList();
    }
    if (this.Clients != null) {
      data['Clients'] = this.Clients!.map((v) => v.toJson()).toList();
    } else {
      data['Clients'] = null;
    }
    return data;
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
