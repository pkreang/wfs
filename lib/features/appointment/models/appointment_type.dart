class AppointmentType {
  final String appointmentTypeID;
  final String appointmentTypeName;

  AppointmentType({required this.appointmentTypeID, required this.appointmentTypeName});

  factory AppointmentType.fromJson(Map<String, dynamic> json) {
    return AppointmentType(appointmentTypeID: json['AppointmentTypeID'] as String, appointmentTypeName: json['AppointmentTypeName'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'AppointmentTypeID': appointmentTypeID, 'AppointmentTypeName': appointmentTypeName};
  }

  static List<AppointmentType> listFromJson(List<dynamic> jsonList) => jsonList.map((e) => AppointmentType.fromJson(e as Map<String, dynamic>)).toList();
}
