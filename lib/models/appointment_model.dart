class Appointment {
  final String id;
  final String appointmentDate;
  final String clientName;
  final String clientPhone;
  final String clientEmail;
  final String appointmentTypeName;
  final String appointmentStatusName;
  final String appointmentTimeFrom;
  final String appointmentTimeto;
  final String companyName;
  final String customerAddress;
  final String product;

  Appointment({
    required this.id,
    required this.appointmentDate,
    required this.clientName,
    required this.clientPhone,
    required this.clientEmail,
    required this.appointmentTypeName,
    required this.appointmentStatusName,
    required this.appointmentTimeFrom,
    required this.appointmentTimeto,  
    required this.companyName,
    required this.customerAddress,
    required this.product
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['AppointmentID'] ?? '',
      clientName: json['ClientName'] ?? 'No Title',
      clientPhone: json['ClientPhone'] ?? 'No Phone',
      clientEmail: json['ClientEmail'] ?? 'No Email',
      appointmentTypeName: json['AppointmentTypeName']?? 'N/A',
      appointmentStatusName: json['AppointmentStatusName'] ?? 'N/A',
      appointmentDate: json['AppointmentDate']?? 'N/A',
      appointmentTimeFrom: json['AppointmentTimeFrom']?? 'N/A',
      appointmentTimeto: json['AppointmentTimeTo']?? 'N/A',
      companyName: json['CompanyName']?? 'No Company',
      customerAddress: json['Address'] ?? 'No Address',
      product : json['Products'] ?? 'No Product'
    );
  }
}