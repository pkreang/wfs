class TaskAppointmentType {
  final String appointmentTypeID;
  final String appointmentTypeName;
  final String? appointmentTypeDescription;
  final String? iconLabel;

  const TaskAppointmentType({
    required this.appointmentTypeID,
    required this.appointmentTypeName,
    this.appointmentTypeDescription,
    this.iconLabel,
  });

  factory TaskAppointmentType.fromJson(Map<String, dynamic> json) {
    return TaskAppointmentType(
      appointmentTypeID: json['AppointmentTypeID']?.toString() ?? '',
      appointmentTypeName: json['AppointmentTypeName']?.toString() ?? '',
      appointmentTypeDescription: json['AppointmentTypeDescription']
          ?.toString(),
      iconLabel: json['IconLabel']?.toString(),
    );
  }

  static List<TaskAppointmentType> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .whereType<Map>()
        .map(
          (item) =>
              TaskAppointmentType.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }
}
