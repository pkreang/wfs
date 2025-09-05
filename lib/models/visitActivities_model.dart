import 'package:wfs/models/outcome_model.dart';

class VisitActivities {
  String? checkInTime;
  String? refImg;
  String? checkOutTime;
  bool? isActive;
  double? checkInLatitude;
  String? createdBy;
  double? checkInLongitude;
  String? createdDate;
  String? appointmentID;
  double? checkOutLatitude;
  String? modifiedBy;
  String? activityID;
  double? checkOutLongitude;
  String? modifiedDate;
  String? userID;
  String? notes;
  String? clientID;
  String? outcomeID;
  Outcome? outcome;

  VisitActivities({
    this.checkInTime,
    this.refImg,
    this.checkOutTime,
    this.isActive,
    this.checkInLatitude,
    this.createdBy,
    this.checkInLongitude,
    this.createdDate,
    this.appointmentID,
    this.checkOutLatitude,
    this.modifiedBy,
    this.activityID,
    this.checkOutLongitude,
    this.modifiedDate,
    this.userID,
    this.notes,
    this.clientID,
    this.outcomeID,
    this.outcome,
  });

  VisitActivities.fromJson(Map<String, dynamic> json) {
    checkInTime = json['CheckInTime'];
    refImg = json['RefImg'];
    checkOutTime = json['CheckOutTime'];
    isActive = json['IsActive'];
    checkInLatitude = json['CheckInLatitude'];
    createdBy = json['CreatedBy'];
    checkInLongitude = json['CheckInLongitude'];
    createdDate = json['CreatedDate'];
    appointmentID = json['AppointmentID'];
    checkOutLatitude = json['CheckOutLatitude'];
    modifiedBy = json['ModifiedBy'];
    activityID = json['ActivityID'];
    checkOutLongitude = json['CheckOutLongitude'];
    modifiedDate = json['ModifiedDate'];
    userID = json['UserID'];
    notes = json['Notes'];
    clientID = json['ClientID'];
    outcomeID = json['OutcomeID'];
    outcome = json['outcome'] != null
        ? new Outcome.fromJson(json['outcome'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CheckInTime'] = this.checkInTime;
    data['RefImg'] = this.refImg;
    data['CheckOutTime'] = this.checkOutTime;
    data['IsActive'] = this.isActive;
    data['CheckInLatitude'] = this.checkInLatitude;
    data['CreatedBy'] = this.createdBy;
    data['CheckInLongitude'] = this.checkInLongitude;
    data['CreatedDate'] = this.createdDate;
    data['AppointmentID'] = this.appointmentID;
    data['CheckOutLatitude'] = this.checkOutLatitude;
    data['ModifiedBy'] = this.modifiedBy;
    data['ActivityID'] = this.activityID;
    data['CheckOutLongitude'] = this.checkOutLongitude;
    data['ModifiedDate'] = this.modifiedDate;
    data['UserID'] = this.userID;
    data['Notes'] = this.notes;
    data['ClientID'] = this.clientID;
    data['OutcomeID'] = this.outcomeID;
    if (this.outcome != null) {
      data['outcome'] = this.outcome!.toJson();
    }
    return data;
  }
}
