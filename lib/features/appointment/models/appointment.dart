class Appointment {
  final String appointmentId;
  final String appointmentTitle;

  Appointment({required this.appointmentId, required this.appointmentTitle});

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(appointmentId: json['AppointmentID'] as String, appointmentTitle: json['AppointmentTitle'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'AppointmentID': appointmentId, 'AppointmentTitle': appointmentTitle};
  }

  static List<Appointment> listFromJson(List<dynamic> jsonList) => jsonList.map((e) => Appointment.fromJson(e as Map<String, dynamic>)).toList();
}
