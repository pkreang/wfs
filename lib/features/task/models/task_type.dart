enum TaskType {
  clientVisitEvent('Client Visit Event'),
  call('Call'),
  lunchMeetingEvent('Lunch Meeting Event'),
  activityEvent('Activity Event'),
  followUpCall('Follow-up Call'),
  appointmentEvent('Appointment Event');

  final String label;

  const TaskType(this.label);

  static TaskType fromValue(Object? value) {
    final text = value?.toString().trim();
    return TaskType.values.firstWhere(
      (type) => type.name == text || type.label == text,
      orElse: () => TaskType.call,
    );
  }
}
