class UserProfile {
  String? username;
  String? role;
  String? userId;

  UserProfile({this.username, this.role, this.userId});

  UserProfile.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    role = json['role'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['username'] = this.username;
    data['role'] = this.role;
    data['user_id'] = this.userId;
    return data;
  }
}
