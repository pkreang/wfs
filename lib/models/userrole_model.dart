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

  UserRole copyWith({String? userRoleName, String? userRoleID}) {
    return UserRole(userRoleName: userRoleName ?? this.userRoleName, userRoleID: userRoleID ?? this.userRoleID);
  }

  bool get isSupervisor => userRoleID == "8CFBD382-FA8B-459C-9BCF-6A3FDF66A8D6";
  bool get isSale => userRoleID == "BBCC9574-F8F2-402A-8ED1-784934A04FA0";
}
