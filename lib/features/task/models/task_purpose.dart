class TaskPurpose {
  final String purposeTypeID;
  final String purposeTypeName;
  final String? purposeTypeDescription;
  final String? purposeTypeGroupsID;
  final int? ordering;
  final bool? isTask;
  final bool? isAppointment;
  final bool? isActive;

  const TaskPurpose({
    required this.purposeTypeID,
    required this.purposeTypeName,
    this.purposeTypeDescription,
    this.purposeTypeGroupsID,
    this.ordering,
    this.isTask,
    this.isAppointment,
    this.isActive,
  });

  factory TaskPurpose.fromJson(Map<String, dynamic> json) {
    return TaskPurpose(
      purposeTypeID: json['PurposeTypeID']?.toString() ?? '',
      purposeTypeName: json['PurposeTypeName']?.toString() ?? '',
      purposeTypeDescription: json['PurposeTypeDescription']?.toString(),
      purposeTypeGroupsID: json['PurposeTypeGroupsID']?.toString(),
      ordering: _parseInt(json['Ordering']),
      isTask: _parseBool(json['IsTask']),
      isAppointment: _parseBool(json['IsAppointment']),
      isActive: _parseBool(json['IsActive']),
    );
  }

  static List<TaskPurpose> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .whereType<Map>()
        .map((item) => TaskPurpose.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}

int? _parseInt(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}

bool? _parseBool(Object? value) {
  if (value is bool) return value;

  switch (value?.toString().toLowerCase()) {
    case 'true':
    case '1':
      return true;
    case 'false':
    case '0':
      return false;
    default:
      return null;
  }
}
