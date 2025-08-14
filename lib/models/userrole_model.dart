class UserRole {
  String? userRoleName;
  String? userRoleID;

  UserRole({this.userRoleName, this.userRoleID});

  UserRole.fromJson(Map<String, dynamic> json) {
    userRoleName = json['UserRoleName'];
    userRoleID = json['UserRoleID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['UserRoleName'] = this.userRoleName;
    data['UserRoleID'] = this.userRoleID;
    return data;
  }
}
