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
  static const String addUser = '$baseUrl/user/';
  static const String getUserRoleUrl = '$baseUrl/user/role';
  static const String addCompanyUrl = '$baseUrl/company/';
  static const String getByIdApointmentUrl = '$baseUrl/appointment/id/';
  static const String getByDateApointmentUrl =
      '$baseUrl/appointment/bydate/?AppointmentDate=';
  static const String getSummaryApointmentUrl =
      '$baseUrl/appointment/summary/?AppointmentDate=';
  static const String getByIdClientUrl = '$baseUrl/client/id/';
  static const String getPurposeTypeUrl =
      '$baseUrl/purpose_type/?IsActive=true';
  static const String getSaleTerritorieUrl =
      '$baseUrl/sale/territory/?IsActive=true';
}
