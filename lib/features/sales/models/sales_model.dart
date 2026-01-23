class Sales {
  String? userID;
  String? firstName;
  String? lastName;
  String? fullName;
  String? userRoleID;
  String? userRoleName;
  String? managerID;

  Sales({this.userID, this.firstName, this.lastName, this.fullName, this.userRoleID, this.userRoleName, this.managerID});

  Sales.fromJson(Map<String, dynamic> json) {
    userID = json['UserID'];
    firstName = json['FirstName'];
    lastName = json['LastName'];
    fullName = json['FullName'];
    userRoleID = json['UserRoleID'];
    userRoleName = json['UserRoleName'];
    managerID = json['ManagerID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['UserID'] = userID;
    data['FirstName'] = firstName;
    data['LastName'] = lastName;
    data['FullName'] = fullName;
    data['UserRoleID'] = userRoleID;
    data['UserRoleName'] = userRoleName;
    data['ManagerID'] = managerID;
    return data;
  }

  Sales copyWith({String? userID, String? firstName, String? lastName, String? fullName, String? userRoleID, String? userRoleName, String? managerID}) {
    return Sales(
      userID: userID ?? this.userID,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      userRoleID: userRoleID ?? this.userRoleID,
      userRoleName: userRoleName ?? this.userRoleName,
      managerID: managerID ?? this.managerID,
    );
  }
}
