class VisitActivity {
  final String? activityID;
  final String appointmentID;
  final String userID;
  final String clientID;
  final String? outcomeID;
  final String? outcomeName;
  final String? checkInTime;
  final String? checkOutTime;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final String? notes;
  final String createdBy;
  final String modifiedBy;
  final bool isActive;

  VisitActivity({
    this.activityID,
    required this.appointmentID,
    required this.userID,
    required this.clientID,
    this.outcomeID,
    this.outcomeName,
    this.checkInTime,
    this.checkOutTime,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.notes,
    required this.createdBy,
    required this.modifiedBy,
    required this.isActive,
  });

  factory VisitActivity.fromJson(Map<String, dynamic> json) {
    return VisitActivity(
      activityID: json['ActivityID'],
      appointmentID: json['AppointmentID'],
      userID: json['UserID'],
      clientID: json['ClientID'],
      outcomeID: json['OutcomeID'],
      outcomeName: json['OutcomeName'],
      checkInTime: json['CheckInTime'],
      checkOutTime: json['CheckOutTime'],
      checkInLatitude: json['CheckInLatitude'],
      checkInLongitude: json['CheckInLongitude'],
      checkOutLatitude: json['CheckOutLatitude'],
      checkOutLongitude: json['CheckOutLongitude'],
      notes: json['Notes'],
      createdBy: json['CreatedBy'],
      modifiedBy: json['ModifiedBy'],
      isActive: json['IsActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ActivityID': activityID,
      'AppointmentID': appointmentID,
      'UserID': userID,
      'ClientID': clientID,
      'OutcomeID': outcomeID,
      'CheckInTime': checkInTime,
      'CheckOutTime': checkOutTime,
      'CheckInLatitude': checkInLatitude,
      'CheckInLongitude': checkInLongitude,
      'CheckOutLatitude': checkOutLatitude,
      'CheckOutLongitude': checkOutLongitude,
      'Notes': notes,
      'CreatedBy': createdBy,
      'ModifiedBy': modifiedBy,
      'IsActive': isActive,
    };
  }

  static List<VisitActivity> listFromJson(List<dynamic> jsonList) => jsonList.map((e) => VisitActivity.fromJson(e as Map<String, dynamic>)).toList();

  VisitActivity copyWith({
    String? activityID,
    String? appointmentID,
    String? userID,
    String? clientID,
    String? outcomeID,
    String? outcomeName,
    String? checkInTime,
    String? checkOutTime,
    double? checkInLatitude,
    double? checkInLongitude,
    double? checkOutLatitude,
    double? checkOutLongitude,
    String? notes,
    String? createdBy,
    String? modifiedBy,
    bool? isActive,
  }) {
    return VisitActivity(
      activityID: activityID ?? this.activityID,
      appointmentID: appointmentID ?? this.appointmentID,
      userID: userID ?? this.userID,
      clientID: clientID ?? this.clientID,
      outcomeID: outcomeID ?? this.outcomeID,
      outcomeName: outcomeName ?? this.outcomeName,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      checkInLatitude: checkInLatitude ?? this.checkInLatitude,
      checkInLongitude: checkInLongitude ?? this.checkInLongitude,
      checkOutLatitude: checkOutLatitude ?? this.checkOutLatitude,
      checkOutLongitude: checkOutLongitude ?? this.checkOutLongitude,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      isActive: isActive ?? this.isActive,
    );
  }
}
