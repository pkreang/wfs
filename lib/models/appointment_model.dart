class Appointment {
  final String id;
  final String title;
  final String typeName;
  final String statusName;
  final DateTime dateTime;
  final String companyName;
  final String customerAddress;
  final String noted;

  Appointment({
    required this.id,
    required this.title,
    required this.typeName,
    required this.statusName,
    required this.dateTime,
    required this.companyName,
    required this.customerAddress,
    required this.noted,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['AppointmentID'] ?? '',
      title: json['AppointmentTitle'] ?? 'No Title',
      typeName: json['AppointmentType']?['AppointmentTypeName'] ?? 'N/A',
      statusName: json['AppointmentStatus']?['AppointmentStatusName'] ?? 'N/A',
      dateTime: DateTime.tryParse(json['AppointmentDateTime'] ?? '') ?? DateTime.now(),
      companyName: json['Company']?['CompanyName'] ?? 'No Company',
      customerAddress: json['Customer']?['Address'] ?? 'No Address',
      noted: json['Noted'] ?? '',
    );
  }
}