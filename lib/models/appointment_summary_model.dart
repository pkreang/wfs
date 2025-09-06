class AppointmentSummary {
  final int completed;
  final int pending;
  final int canceled;
  final int total;

  AppointmentSummary({
    required this.completed,
    required this.pending,
    required this.canceled,
    required this.total,
  });

  factory AppointmentSummary.fromJson(Map<String, dynamic> json) {
    return AppointmentSummary(
      completed: json['Completed'] ?? 0,
      pending: json['Pending'] ?? 0,
      canceled: json['Canceled'] ?? 0,
      total: json['Total'] ?? 0,

     
    );
  }
}
