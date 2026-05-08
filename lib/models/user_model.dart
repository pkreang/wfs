import 'package:wfs/models/userrole_model.dart';

class User {
  String? firstName;
  String? lastName;
  String? phoneNumber;
  String? hashedPassword;
  String? userRoleID;
  String? userRoleName;
  String? createdBy;
  String? modifiedBy;
  String? userID;
  String? email;
  String? managerID;
  String? managerName;
  String? territoryID;
  String? territoryName;
  bool? isActive;
  String? createdDate;
  String? modifiedDate;
  UserRole? userRole;
  String? pincode;
  List<String>? clientIDs;

  User({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.hashedPassword,
    this.userRoleID,
    this.userRoleName,
    this.createdBy,
    this.modifiedBy,
    this.userID,
    this.email,
    this.managerID,
    this.managerName,
    this.territoryID,
    this.territoryName,
    this.isActive,
    this.createdDate,
    this.modifiedDate,
    this.userRole,
    this.pincode,
    this.clientIDs,
  });

  User.fromJson(Map<String, dynamic> json) {
    firstName = json['FirstName'];
    lastName = json['LastName'];
    phoneNumber = json['PhoneNumber'];
    hashedPassword = json['HashedPassword'];
    userRoleID = json['UserRoleID'];
    userRoleName = json['UserRoleName'];
    createdBy = json['CreatedBy'];
    modifiedBy = json['ModifiedBy'];
    userID = json['UserID'];
    email = json['Email'];
    managerID = json['ManagerID'];
    managerName = json['ManagerName'];
    territoryID = json['TerritoryID'];
    territoryName = json['TerritoryName'];
    isActive = json['IsActive'];
    createdDate = json['CreatedDate'];
    modifiedDate = json['ModifiedDate'];
    userRole = json['UserRole'] != null ? new UserRole.fromJson(json['UserRole']) : null;
    pincode = json['Pincode'];

    if (json['clients'] != null) {
      clientIDs = (json['clients'] as List).map((client) => client['ClientID'] as String).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['FirstName'] = this.firstName;
    data['LastName'] = this.lastName;
    data['PhoneNumber'] = this.phoneNumber;
    data['HashedPassword'] = this.hashedPassword;
    data['UserRoleID'] = this.userRoleID;
    data['UserRoleName'] = this.userRoleName;
    data['CreatedBy'] = this.createdBy;
    data['ModifiedBy'] = this.modifiedBy;
    data['UserID'] = this.userID;
    data['Email'] = this.email;
    data['ManagerID'] = this.managerID;
    data['ManagerName'] = this.managerName;
    data['TerritoryID'] = this.territoryID;
    data['TerritoryName'] = this.territoryName;
    data['IsActive'] = this.isActive;
    data['CreatedDate'] = this.createdDate;
    data['ModifiedDate'] = this.modifiedDate;
    if (this.userRole != null) {
      data['UserRole'] = this.userRole!.toJson();
    }
    data['Pincode'] = this.pincode;
    if (this.clientIDs != null) {
      data['ClientIDs'] = this.clientIDs;
    }
    return data;
  }

  Map<String, dynamic> toJsonCreate(String userCreate) => {
    "FirstName": firstName,
    "LastName": lastName,
    "PhoneNumber": phoneNumber,
    "UserRoleID": userRoleID,
    "UserRoleName": userRoleName,
    "CreatedBy": createdBy,
    "ModifiedBy": modifiedBy,
    "UserID": "1111111",
    "Email": email,
    "ManagerID": managerID ?? userCreate,
    "ManagerName": managerName,
    "SalesTerritoryID": territoryID,
    "IsActive": true,
    "CreatedDate": createdDate ?? DateTime.now().toIso8601String(),
    "ModifiedDate": modifiedDate ?? DateTime.now().toIso8601String(),
    "UserRole": userRole?.toJson(),
    "ClientIDs": clientIDs,
  };

  Map<String, dynamic> toJsonUpdate(String userCreate) => {
    "FirstName": firstName,
    "LastName": lastName,
    "PhoneNumber": phoneNumber,
    "UserRoleID": userRoleID,
    "UserRoleName": userRoleName,
    "CreatedBy": createdBy,
    "ModifiedBy": modifiedBy,
    "UserID": "1111111",
    "Email": email,
    "ManagerID": managerID,
    "ManagerName": managerName,
    "SalesTerritoryID": territoryID,
    "IsActive": true,
    "CreatedDate": createdDate ?? DateTime.now().toIso8601String(),
    "ModifiedDate": modifiedDate ?? DateTime.now().toIso8601String(),
    "UserRole": userRole?.toJson(),
    "ClientIDs": clientIDs,
  };

  String get fullname {
    final parts = [firstName, lastName].where((e) => (e ?? '').isNotEmpty).join(' ');
    return parts;
  }

  User copyWith({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? hashedPassword,
    String? userRoleID,
    String? userRoleName,
    String? createdBy,
    String? modifiedBy,
    String? userID,
    String? email,
    String? managerID,
    String? managerName,
    String? territoryID,
    String? territoryName,
    bool? isActive,
    String? createdDate,
    String? modifiedDate,
    UserRole? userRole,
    String? pincode,
    List<String>? clientIDs,
  }) {
    return User(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      hashedPassword: hashedPassword ?? this.hashedPassword,
      userRoleID: userRoleID ?? this.userRoleID,
      userRoleName: userRoleName ?? this.userRoleName,
      createdBy: createdBy ?? this.createdBy,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      userID: userID ?? this.userID,
      email: email ?? this.email,
      managerID: managerID ?? this.managerID,
      managerName: managerName ?? this.managerName,
      territoryID: territoryID ?? this.territoryID,
      territoryName: territoryName ?? this.territoryName,
      isActive: isActive ?? this.isActive,
      createdDate: createdDate ?? this.createdDate,
      modifiedDate: modifiedDate ?? this.modifiedDate,
      userRole: userRole ?? this.userRole,
      pincode: pincode ?? this.pincode,
      clientIDs: clientIDs ?? this.clientIDs,
    );
  }
}
