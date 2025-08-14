import 'package:wfs/models/clientlevel_model.dart';
import 'package:wfs/models/clientstatus_model.dart';
import 'package:wfs/models/company_model.dart';
import 'package:wfs/models/product_model.dart';

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
    lastName = json['LastName'];
    availableTimeEnd = json['AvailableTimeEnd'];
    phone = json['Phone'];
    isActive = json['IsActive'];
    email = json['Email'];
    createdBy = json['CreatedBy'];
    salesTerritoryID = json['SalesTerritoryID'];
    createdDate = json['CreatedDate'];
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
        company!.add(new Company.fromJson(v));
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
    return data;
  }
}
