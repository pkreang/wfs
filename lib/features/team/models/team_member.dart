class TeamMember {
  String? userID;
  String? firstName;
  String? lastName;
  String? fullName;
  String? email;
  String? phoneNumber;
  String? userRoleID;
  String? userRoleName;
  String? managerID;
  String? managerName;
  bool? isActive;
  String? createdDate;
  String? modifiedDate;
  String? createdBy;
  String? modifiedBy;

  TeamMember({
    this.userID,
    this.firstName,
    this.lastName,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.userRoleID,
    this.userRoleName,
    this.managerID,
    this.managerName,
    this.isActive,
    this.createdDate,
    this.modifiedDate,
    this.createdBy,
    this.modifiedBy,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      userID: json['UserID'],
      firstName: json['FirstName'],
      lastName: json['LastName'],
      fullName: json['FullName'],
      email: json['Email'],
      phoneNumber: json['PhoneNumber'],
      userRoleID: json['UserRoleID'],
      userRoleName: json['UserRoleName'],
      managerID: json['ManagerID'],
      managerName: json['ManagerName'],
      isActive: json['IsActive'],
      createdDate: json['CreatedDate'],
      modifiedDate: json['ModifiedDate'],
      createdBy: json['CreatedBy'],
      modifiedBy: json['ModifiedBy'],
    );
  }

  Map<String, dynamic> toJson() => {
    'UserID': userID,
    'FirstName': firstName,
    'LastName': lastName,
    'FullName': fullName,
    'Email': email,
    'PhoneNumber': phoneNumber,
    'UserRoleID': userRoleID,
    'UserRoleName': userRoleName,
    'ManagerID': managerID,
    'ManagerName': managerName,
    'IsActive': isActive,
    'CreatedDate': createdDate,
    'ModifiedDate': modifiedDate,
    'CreatedBy': createdBy,
    'ModifiedBy': modifiedBy,
  };

  TeamMember copyWith({
    String? userID,
    String? firstName,
    String? lastName,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? userRoleID,
    String? userRoleName,
    String? managerID,
    String? managerName,
    bool? isActive,
    String? createdDate,
    String? modifiedDate,
    String? createdBy,
    String? modifiedBy,
  }) {
    return TeamMember(
      userID: userID ?? this.userID,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userRoleID: userRoleID ?? this.userRoleID,
      userRoleName: userRoleName ?? this.userRoleName,
      managerID: managerID ?? this.managerID,
      managerName: managerName ?? this.managerName,
      isActive: isActive ?? this.isActive,
      createdDate: createdDate ?? this.createdDate,
      modifiedDate: modifiedDate ?? this.modifiedDate,
      createdBy: createdBy ?? this.createdBy,
      modifiedBy: modifiedBy ?? this.modifiedBy,
    );
  }

  static List<TeamMember> listFromJson(List<dynamic> jsonList) => jsonList.map((e) => TeamMember.fromJson(e as Map<String, dynamic>)).toList();
}
