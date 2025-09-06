class AppointmentStatus {
  final String appointmentStatusID;
  final String appointmentStatusName;

  AppointmentStatus({required this.appointmentStatusID, required this.appointmentStatusName});

  factory AppointmentStatus.fromJson(Map<String, dynamic> json) {
    return AppointmentStatus(appointmentStatusID: json['AppointmentStatusID'] as String, appointmentStatusName: json['AppointmentStatusName'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'AppointmentStatusID': appointmentStatusID, 'AppointmentStatusName': appointmentStatusName};
  }

  static List<AppointmentStatus> listFromJson(List<dynamic> jsonList) => jsonList.map((e) => AppointmentStatus.fromJson(e as Map<String, dynamic>)).toList();
}
