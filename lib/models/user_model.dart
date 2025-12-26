import 'package:wfs/models/userrole_model.dart';

class User {
  String? firstName;
  String? lastName;
  String? phoneNumber;
  String? hashedPassword;
  String? userRoleID;
  String? createdBy;
  String? modifiedBy;
  String? userID;
  String? email;
  String? managerID;
  bool? isActive;
  String? createdDate;
  String? modifiedDate;
  UserRole? userRole;

  User({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.hashedPassword,
    this.userRoleID,
    this.createdBy,
    this.modifiedBy,
    this.userID,
    this.email,
    this.managerID,
    this.isActive,
    this.createdDate,
    this.modifiedDate,
    this.userRole,
  });

  User.fromJson(Map<String, dynamic> json) {
    firstName = json['FirstName'];
    lastName = json['LastName'];
    phoneNumber = json['PhoneNumber'];
    hashedPassword = json['HashedPassword'];
    userRoleID = json['UserRoleID'];
    createdBy = json['CreatedBy'];
    modifiedBy = json['ModifiedBy'];
    userID = json['UserID'];
    email = json['Email'];
    managerID = json['ManagerID'];
    isActive = json['IsActive'];
    createdDate = json['CreatedDate'];
    modifiedDate = json['ModifiedDate'];
    userRole = json['UserRole'] != null ? new UserRole.fromJson(json['UserRole']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['FirstName'] = this.firstName;
    data['LastName'] = this.lastName;
    data['PhoneNumber'] = this.phoneNumber;
    data['HashedPassword'] = this.hashedPassword;
    data['UserRoleID'] = this.userRoleID;
    data['CreatedBy'] = this.createdBy;
    data['ModifiedBy'] = this.modifiedBy;
    data['UserID'] = this.userID;
    data['Email'] = this.email;
    data['ManagerID'] = this.managerID;
    data['IsActive'] = this.isActive;
    data['CreatedDate'] = this.createdDate;
    data['ModifiedDate'] = this.modifiedDate;
    if (this.userRole != null) {
      data['UserRole'] = this.userRole!.toJson();
    }
    return data;
  }

  String get fullname {
    final parts = [firstName, lastName].where((e) => (e ?? '').isNotEmpty).join(' ');
    return parts;
  }
}
