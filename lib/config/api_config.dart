class ApiConfig {
  static const String baseUrl = 'https://sfe-api.appnormalthink.com';
  static const String loginUrl = '$baseUrl/login';
  static const String userRoleUrl = '$baseUrl/user/role';
  static const String appointmentUrl = '$baseUrl/appointment';
  static const String userIdUrl = '$baseUrl/user';
  static const String appointmentType =
      '$baseUrl/appointment/type/?IsActive=true';
  static const String appointmentStatus =
      '$baseUrl/appointment/status/?IsActive=true';
  static const String companyUrl = '$baseUrl/company';
  static const String clientUrl = '$baseUrl/client';
  static const String addAppointmentUrl = '$baseUrl/appointment/';
  static const String userProfileUrl = '$baseUrl/user/profile';
  static const String getListUserUrl = '$baseUrl/user/?IsActive=true';
}
