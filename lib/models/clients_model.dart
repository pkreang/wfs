import 'package:wfs/models/clientlevel_model.dart';
import 'package:wfs/models/clientstatus_model.dart';

class Clients {
  String? salesTerritoryID;
  String? createdDate;
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
  ClientLevel? clientLevel;
  ClientStatus? clientStatus;
  List<Null>? companies;
  List<Null>? products;

  Clients({
    this.salesTerritoryID,
    this.createdDate,
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
    this.clientLevel,
    this.clientStatus,
    this.companies,
    this.products,
  });

  Clients.fromJson(Map<String, dynamic> json) {
    salesTerritoryID = json['SalesTerritoryID'];
    createdDate = json['CreatedDate'];
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
    clientLevel = json['ClientLevel'] != null
        ? new ClientLevel.fromJson(json['ClientLevel'])
        : null;
    clientStatus = json['ClientStatus'] != null
        ? new ClientStatus.fromJson(json['ClientStatus'])
        : null;
    // if (json['companies'] != null) {
    //   companies = <Null>[];
    //   json['companies'].forEach((v) {
    //     companies!.add(new Null.fromJson(v));
    //   });
    // }
    // if (json['products'] != null) {
    //   products = <Null>[];
    //   json['products'].forEach((v) {
    //     products!.add(new Null.fromJson(v));
    //   });
    // }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SalesTerritoryID'] = this.salesTerritoryID;
    data['CreatedDate'] = this.createdDate;
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
    if (this.clientLevel != null) {
      data['ClientLevel'] = this.clientLevel!.toJson();
    }
    if (this.clientStatus != null) {
      data['ClientStatus'] = this.clientStatus!.toJson();
    }
    // if (this.companies != null) {
    //   data['companies'] = this.companies!.map((v) => v.toJson()).toList();
    // }
    // if (this.products != null) {
    //   data['products'] = this.products!.map((v) => v.toJson()).toList();
    // }
    return data;
  }
}
