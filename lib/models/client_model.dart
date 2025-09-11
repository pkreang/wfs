import 'package:wfs/models/clientaddresses_model.dart';
import 'package:wfs/models/clientcompanies_model.dart';
import 'package:wfs/models/clientlevel_model.dart';
import 'package:wfs/models/clientproduct_model.dart';
import 'package:wfs/models/clientstatus_model.dart';
import 'package:wfs/models/company_model.dart';
import 'package:wfs/models/product_model.dart';
import 'package:wfs/models/sales_territory.dart';

class Client {
  String? clientStatusID;
  String? modifiedBy;
  String? clientLevelID;
  String? modifiedDate;
  String? firstName;
  String? noted;
  String? clientID;
  String? availableTimeStart;
  String? lastName;
  String? availableTimeEnd;
  String? phone;
  bool? isActive;
  String? email;
  String? createdBy;
  String? salesTerritoryID;
  String? createdDate;
  List<Product>? products;
  ClientLevel? clientLevel;
  ClientStatus? clientStatus;
  List<Company>? company;
  String? address;
  List<ClientAddresses>? clientAddresses;
  List<String>? clientProducts;
  List<ClientCompanies>? clientCompanies;
  SalesTerritory? salesTerritory;
  List<ClientProducts>? listClientProducts;

  Client({
    this.clientStatusID,
    this.modifiedBy,
    this.clientLevelID,
    this.modifiedDate,
    this.firstName,
    this.noted,
    this.clientID,
    this.availableTimeStart,
    this.lastName,
    this.availableTimeEnd,
    this.phone,
    this.isActive,
    this.email,
    this.createdBy,
    this.salesTerritoryID,
    this.createdDate,
    this.products,
    this.clientLevel,
    this.clientStatus,
    this.company,
    this.address,
    this.clientAddresses,
    this.clientProducts,
    this.clientCompanies,
    this.salesTerritory,
    this.listClientProducts,
  });

  Client.fromJson(Map<String, dynamic> json) {
    clientStatusID = json['ClientStatusID'];
    modifiedBy = json['ModifiedBy'];
    clientLevelID = json['ClientLevelID'];
    modifiedDate = json['ModifiedDate'];
    firstName = json['FirstName'];
    noted = json['Noted'];
    clientID = json['ClientID'];
    availableTimeStart = json['AvailableTimeStart'];
    availableTimeEnd = json['AvailableTimeEnd'];
    lastName = json['LastName'];
    phone = json['Phone'];
    isActive = json['IsActive'];
    email = json['Email'];
    createdBy = json['CreatedBy'];
    salesTerritoryID = json['SalesTerritoryID'];
    createdDate = json['CreatedDate'];
    address = json['address'];
    salesTerritory = json['salesTerritory'];

    if (json['products'] != null) {
      products = [];
      json['products'].forEach((v) {
        products!.add(new Product.fromJson(v));
      });
    }
    clientLevel = json['ClientLevel'] != null
        ? new ClientLevel.fromJson(json['ClientLevel'])
        : null;
    clientStatus = json['ClientStatus'] != null
        ? new ClientStatus.fromJson(json['ClientStatus'])
        : null;
    if (json['company'] != null) {
      company = [];
      json['company'].forEach((v) {
        company!.add(Company.fromJson(v));
      });
    }
    if (json['companies'] != null) {
      clientCompanies = [];
      json['companies'].forEach((v) {
        clientCompanies!.add(ClientCompanies.fromJson(v));
      });
    }

    if (json['ClientAddresses'] != null) {
      clientAddresses = <ClientAddresses>[];
      json['ClientAddresses'].forEach((v) {
        clientAddresses!.add(new ClientAddresses.fromJson(v));
      });
    }
    if (json['addresses'] != null) {
      clientAddresses = <ClientAddresses>[];
      json['addresses'].forEach((v) {
        clientAddresses!.add(new ClientAddresses.fromJson(v));
      });
    }
    if (json['ClientProducts'] != null) {
      clientProducts = json['ClientProducts'].cast<String>();
    }
    if (json['ClientCompanies'] != null) {
      clientCompanies = <ClientCompanies>[];
      json['ClientCompanies'].forEach((v) {
        clientCompanies!.add(new ClientCompanies.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ClientStatusID'] = this.clientStatusID;
    data['ModifiedBy'] = this.modifiedBy;
    data['ClientLevelID'] = this.clientLevelID;
    data['ModifiedDate'] = this.modifiedDate;
    data['FirstName'] = this.firstName;
    data['Noted'] = this.noted;
    data['ClientID'] = this.clientID;
    data['AvailableTimeStart'] = this.availableTimeStart;
    data['LastName'] = this.lastName;
    data['AvailableTimeEnd'] = this.availableTimeEnd;
    data['Phone'] = this.phone;
    data['IsActive'] = this.isActive;
    data['Email'] = this.email;
    data['CreatedBy'] = this.createdBy;
    data['SalesTerritoryID'] = this.salesTerritoryID;
    data['CreatedDate'] = this.createdDate;
    data['address'] = this.address;
    data['salesTerritory'] = this.salesTerritory;

    if (this.products != null) {
      data['products'] = this.products!.map((v) => v.toJson()).toList();
    }
    if (this.clientLevel != null) {
      data['ClientLevel'] = this.clientLevel!.toJson();
    }
    if (this.clientStatus != null) {
      data['ClientStatus'] = this.clientStatus!.toJson();
    }
    if (this.company != null) {
      data['company'] = this.company!.map((v) => v.toJson()).toList();
    }
    if (this.clientAddresses != null) {
      data['addresses'] = this.clientAddresses!.map((v) => v.toJson()).toList();
    }
    if (this.clientAddresses != null) {
      data['ClientAddresses'] = this.clientAddresses!
          .map((v) => v.toJson())
          .toList();
    }

    data['ClientProducts'] = this.clientProducts;
    if (this.clientCompanies != null) {
      data['ClientCompanies'] = this.clientCompanies!
          .map((v) => v.toJson())
          .toList();
    }
    return data;
  }

  Client copyWith({
    String? clientStatusID,
    String? modifiedBy,
    String? clientLevelID,
    String? modifiedDate,
    String? firstName,
    String? noted,
    String? clientID,
    String? availableTimeStart,
    String? lastName,
    String? availableTimeEnd,
    String? phone,
    bool? isActive,
    String? email,
    String? createdBy,
    String? salesTerritoryID,
    String? createdDate,
    List<Product>? products,
    ClientLevel? clientLevel,
    ClientStatus? clientStatus,
    List<Company>? company,
    String? address,
    List<ClientAddresses>? clientAddresses,
    List<String>? clientProducts,
    List<ClientCompanies>? clientCompanies,
    SalesTerritory? salesTerritory,
  }) {
    return Client(
      clientStatusID: clientStatusID ?? this.clientStatusID,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      clientLevelID: clientLevelID ?? this.clientLevelID,
      modifiedDate: modifiedDate ?? this.modifiedDate,
      firstName: firstName ?? this.firstName,
      noted: noted ?? this.noted,
      clientID: clientID ?? this.clientID,
      availableTimeStart: availableTimeStart ?? this.availableTimeStart,
      lastName: lastName ?? this.lastName,
      availableTimeEnd: availableTimeEnd ?? this.availableTimeEnd,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      email: email ?? this.email,
      createdBy: createdBy ?? this.createdBy,
      salesTerritoryID: salesTerritoryID ?? this.salesTerritoryID,
      createdDate: createdDate ?? this.createdDate,
      products: products ?? this.products,
      clientLevel: clientLevel ?? this.clientLevel,
      clientStatus: clientStatus ?? this.clientStatus,
      company: company ?? this.company,
      address: address ?? this.address,
      clientAddresses: clientAddresses ?? this.clientAddresses,
      clientProducts: clientProducts ?? this.clientProducts,
      clientCompanies: clientCompanies ?? this.clientCompanies,
      salesTerritory: salesTerritory ?? this.salesTerritory,
    );
  }
}
