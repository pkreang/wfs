import 'package:intl/intl.dart';
import 'package:wfs/features/appointment/models/address.dart';
import 'package:wfs/features/task/models/task_type.dart';

const Object _noValue = Object();

class Task {
  final String? type;
  final String? taskID;
  final TaskType taskType;
  final String title;
  final String? details;
  final DateTime? appointmentDateTimeFrom;
  final DateTime? appointmentDateTimeTo;
  final DateTime scheduledStartDate;
  final DateTime scheduledEndDate;

  final String? purposeID;
  final String? purposeName;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? modifiedBy;
  final String? appointmentTypeID;
  final String? appointmentTypeName;
  final String? appointmentStatusID;
  final String? clientName;
  final String? companyName;
  final String? appointmentStatusName;

  final String? purposeOther;
  final String? phone;
  final String? email;
  final String? cancelNoted;
  final String? saleName;
  final String? iconLabel;
  final String? clientID;
  final String? companyID;
  final String? refInviteID;
  final String? userID;
  final String? assignedBy;
  final bool? isNotificationCompleted;
  final bool? isActive;
  final AppointmentType? appointmentType;
  final Address? taskAddress;

  const Task({
    this.type,
    this.taskID,
    required this.taskType,
    required this.title,
    this.details,
    required this.scheduledStartDate,
    required this.scheduledEndDate,
    this.purposeID,
    this.purposeName,
    this.companyID,
    this.companyName,
    this.clientID,
    this.clientName,

    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.modifiedBy,
    this.appointmentTypeID,
    this.appointmentTypeName,
    this.appointmentStatusID,

    this.appointmentDateTimeFrom,
    this.appointmentDateTimeTo,
    this.appointmentStatusName,
    // this.purposeName,
    this.purposeOther,
    this.phone,
    this.email,
    this.cancelNoted,
    this.saleName,
    this.iconLabel,
    this.refInviteID,
    this.userID,
    this.assignedBy,
    this.isNotificationCompleted,
    this.isActive,
    this.appointmentType,
    this.taskAddress,
  });

  factory Task.empty() {
    return Task(taskType: TaskType.call, title: '', scheduledStartDate: DateTime.now(), scheduledEndDate: DateTime.now().add(const Duration(minutes: 5)));
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    final appointmentTypeJson = json['AppointmentType'];
    final appointmentType = appointmentTypeJson is Map ? AppointmentType.fromJson(Map<String, dynamic>.from(appointmentTypeJson)) : null;
    final taskAddressJson = json['task_address'] ?? json['TaskAddress'];
    final taskAddress = taskAddressJson is Map ? _taskAddressFromJson(Map<String, dynamic>.from(taskAddressJson)) : null;

    return Task(
      type: (json['Type'] ?? json['type'])?.toString(),
      taskID: (json['AppointmentID'] ?? json['TaskID'] ?? json['taskID'] ?? json['id'])?.toString(),
      taskType: TaskType.fromValue(json['AppointmentTypeName'] ?? json['TaskType'] ?? json['task_type'] ?? appointmentType?.appointmentTypeName),
      title: (json['AppointmentTitle'] ?? json['Title'] ?? json['title'] ?? '').toString(),
      details: (json['Noted'] ?? json['Details'] ?? json['details'])?.toString(),
      // status: TaskStatus.fromValue(json['status_name'] ?? json['Status'] ?? json['status']),
      scheduledStartDate: _parseDate(json['AppointmentDateTimeFrom'] ?? json['ScheduledDate'] ?? json['scheduled_date']) ?? DateTime.now(),
      scheduledEndDate: _parseDate(json['AppointmentDateTimeEnd'] ?? json['ScheduledDate'] ?? json['scheduled_date']) ?? DateTime.now(),
      createdAt: _parseDate(json['CreatedDate'] ?? json['CreatedAt'] ?? json['createdAt']),
      updatedAt: _parseDate(json['ModifiedDate'] ?? json['UpdatedAt'] ?? json['updatedAt']),
      createdBy: (json['CreatedBy'] ?? json['createdBy'])?.toString(),
      modifiedBy: (json['ModifiedBy'] ?? json['modifiedBy'])?.toString(),
      appointmentTypeID: (json['AppointmentTypeID'] ?? json['appointment_type_id'] ?? appointmentType?.appointmentTypeID)?.toString(),
      appointmentTypeName: (json['AppointmentTypeName'] ?? json['appointment_type_name'] ?? appointmentType?.appointmentTypeName)?.toString(),
      appointmentStatusID: (json['AppointmentStatusID'] ?? json['appointment_status_id'])?.toString(),
      clientName: (json['client_name'] ?? json['ClientName'])?.toString(),
      companyName: (json['company_name'] ?? json['CompanyName'])?.toString(),
      appointmentDateTimeFrom: _parseDate(json['AppointmentDateTimeFrom']),
      appointmentDateTimeTo: _parseDate(json['AppointmentDateTimeTo']),
      appointmentStatusName: (json['status_name'] ?? json['AppointmentStatusName'])?.toString(),
      purposeID: (json['PurposeTypeID'] ?? json['PurposeID'] ?? json['purpose_id'])?.toString(),
      purposeName: (json['purpose_name'] ?? json['PurposeName'] ?? json['PurposeTypeName'])?.toString(),
      purposeOther: (json['PurposeOther'] ?? json['purpose_other'])?.toString(),
      phone: json['Phone']?.toString(),
      email: json['Email']?.toString(),
      cancelNoted: (json['CancelNoted'] ?? json['cancel_noted'])?.toString(),
      saleName: (json['sale_name'] ?? json['SaleName']) ?? json['saleName'],
      iconLabel: (json['icon_label'] ?? json['IconLabel'] ?? appointmentType?.iconLabel)?.toString(),
      clientID: (json['ClientID'] ?? json['client_id'])?.toString(),
      companyID: (json['CompanyID'] ?? json['company_id'])?.toString(),
      refInviteID: (json['RefInviteID'] ?? json['ref_invite_id'])?.toString(),
      userID: (json['UserID'] ?? json['user_id'])?.toString(),
      assignedBy: (json['AssignedBy'] ?? json['assigned_by'])?.toString(),
      isNotificationCompleted: _parseBool(json['IsNotificationCompleted'] ?? json['is_notification_completed']),
      isActive: _parseBool(json['IsActive'] ?? json['is_active']),
      appointmentType: appointmentType,
      taskAddress: taskAddress,
    );
  }

  static Address _taskAddressFromJson(Map<String, dynamic> json) {
    return Address.fromJson({
      'Latitude': json['latitude'] ?? json['Latitude'],
      'Longitude': json['longitude'] ?? json['Longitude'],
      'Address': json['address'] ?? json['Address'],
      'SubDistrictID': json['sub_district_id'] ?? json['SubDistrictID'],
      'SubDistrictName': json['sub_district_name'] ?? json['SubDistrictName'],
      'DistrictID': json['district_id'] ?? json['DistrictID'],
      'DistrictName': json['district_name'] ?? json['DistrictName'],
      'ProvinceID': json['province_id'] ?? json['ProvinceID'],
      'ProvinceName': json['province_name'] ?? json['ProvinceName'],
      'PostCode': json['post_code'] ?? json['PostCode'],
      'CountryID': json['country_id'] ?? json['CountryID'],
      'CountryName': json['country_name'] ?? json['CountryName'],
    });
  }

  Map<String, dynamic> toCreate() {
    return {
      'task_type': appointmentTypeID,
      'title': title,
      'details': details,
      'status': "4E2DC36E-53E6-4E9B-BAC2-1F2629BD745B",
      'scheduled_start': scheduledStartDate.toIso8601String(),
      'scheduled_end': scheduledEndDate.toIso8601String(),
      'purpose_id': purposeID,
      'purpose_other': purposeOther,
      'client_id': clientID,
      'company_id': companyID,
      'phone': phone,
      'email': email,
      "task_address": {
        "latitude": taskAddress?.latitude,
        "longitude": taskAddress?.longitude,
        "address": taskAddress?.address,
        "sub_district_id": taskAddress?.subDistrictID,
        "sub_district_name": taskAddress?.subDistrictName,
        "district_id": taskAddress?.districtID,
        "district_name": taskAddress?.districtName,
        "province_id": taskAddress?.provinceID,
        "province_name": taskAddress?.provinceName,
        "post_code": taskAddress?.postCode,
        "country_id": taskAddress?.countryID ?? 1,
        "country_name": taskAddress?.countryName,
      },

      // "task_type": "7DEEC491-A5AE-4856-B981-7E91870179FF",
      // "title": "zzzz นัดเข้าพบเพื่อพรีเซนต์ Final Proposal และเซ็นปิดดิล",
      // "details": "อย่าลืมเตรียมเล่มเอกสารสัญญาและของที่ระลึกไปด้วย",
      // "status": "4E2DC36E-53E6-4E9B-BAC2-1F2629BD745B",
      // "scheduled_start": "2026-06-21T10:00:00",
      // "scheduled_end": "2026-06-21T12:00:00",
      // "client_id": "24BE836B-5FA3-49FA-9F44-0C7642756EDB",
      // "company_id": "F3784297-9432-43AD-9877-F8763ADD8A4D",
      // "purpose_id": "A0794CE9-507E-4F6A-86A6-299282D7BF7F",
      // "purpose_other": null,
    };
  }

  Task copyWith({
    Object? type = _noValue,
    String? taskID,
    TaskType? taskType,
    String? title,
    Object? details = _noValue,
    // TaskStatus? status,
    DateTime? scheduledStartDate,
    DateTime? scheduledEndDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? modifiedBy,
    Object? appointmentTypeID = _noValue,
    Object? appointmentTypeName = _noValue,
    Object? appointmentStatusID = _noValue,
    Object? clientID = _noValue,
    Object? clientName = _noValue,
    Object? companyID = _noValue,
    Object? companyName = _noValue,
    Object? appointmentDateTimeFrom = _noValue,
    Object? appointmentDateTimeTo = _noValue,
    Object? appointmentStatusName = _noValue,
    Object? purposeID = _noValue,
    Object? purposeName = _noValue,
    Object? purposeOther = _noValue,
    Object? phone = _noValue,
    Object? email = _noValue,
    Object? cancelNoted = _noValue,
    Object? saleName = _noValue,
    Object? iconLabel = _noValue,
    Object? refInviteID = _noValue,
    Object? userID = _noValue,
    Object? assignedBy = _noValue,
    Object? isNotificationCompleted = _noValue,
    Object? isActive = _noValue,
    Object? appointmentType = _noValue,
    Object? taskAddress = _noValue,
  }) {
    return Task(
      type: type == _noValue ? this.type : type as String?,
      taskID: taskID ?? this.taskID,
      taskType: taskType ?? this.taskType,
      title: title ?? this.title,
      details: details == _noValue ? this.details : details as String?,
      // status: status ?? this.status,
      scheduledStartDate: scheduledStartDate ?? this.scheduledStartDate,
      scheduledEndDate: scheduledEndDate ?? this.scheduledEndDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      appointmentTypeID: appointmentTypeID == _noValue ? this.appointmentTypeID : appointmentTypeID as String?,
      appointmentTypeName: appointmentTypeName == _noValue ? this.appointmentTypeName : appointmentTypeName as String?,
      appointmentStatusID: appointmentStatusID == _noValue ? this.appointmentStatusID : appointmentStatusID as String?,
      clientID: clientID == _noValue ? this.clientID : clientID as String?,
      clientName: clientName == _noValue ? this.clientName : clientName as String?,
      companyID: companyID == _noValue ? this.companyID : companyID as String?,
      companyName: companyName == _noValue ? this.companyName : companyName as String?,
      appointmentDateTimeFrom: appointmentDateTimeFrom == _noValue ? this.appointmentDateTimeFrom : appointmentDateTimeFrom as DateTime?,
      appointmentDateTimeTo: appointmentDateTimeTo == _noValue ? this.appointmentDateTimeTo : appointmentDateTimeTo as DateTime?,
      appointmentStatusName: appointmentStatusName == _noValue ? this.appointmentStatusName : appointmentStatusName as String?,
      purposeID: purposeID == _noValue ? this.purposeID : purposeID as String?,
      purposeName: purposeName == _noValue ? this.purposeName : purposeName as String?,
      purposeOther: purposeOther == _noValue ? this.purposeOther : purposeOther as String?,
      phone: phone == _noValue ? this.phone : phone as String?,
      email: email == _noValue ? this.email : email as String?,
      cancelNoted: cancelNoted == _noValue ? this.cancelNoted : cancelNoted as String?,
      saleName: saleName == _noValue ? this.saleName : saleName as String?,
      iconLabel: iconLabel == _noValue ? this.iconLabel : iconLabel as String?,
      refInviteID: refInviteID == _noValue ? this.refInviteID : refInviteID as String?,
      userID: userID == _noValue ? this.userID : userID as String?,
      assignedBy: assignedBy == _noValue ? this.assignedBy : assignedBy as String?,
      isNotificationCompleted: isNotificationCompleted == _noValue ? this.isNotificationCompleted : isNotificationCompleted as bool?,
      isActive: isActive == _noValue ? this.isActive : isActive as bool?,
      appointmentType: appointmentType == _noValue ? this.appointmentType : appointmentType as AppointmentType?,
      taskAddress: taskAddress == _noValue ? this.taskAddress : taskAddress as Address?,
    );
  }

  static List<Task> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((item) => Task.fromJson(item as Map<String, dynamic>)).toList();
  }
}

extension TimeFormat on String {
  String toHHmmss() {
    final date = DateTime.tryParse(this);
    if (date == null) return this;

    final midnight = DateTime(date.year, date.month, date.day);
    return DateFormat.Hms().format(midnight);
  }

  String dateTimetoHHmm() {
    final date = DateTime.tryParse(this);
    if (date == null) return this;

    final midnight = DateTime(date.year, date.month, date.day, date.hour, date.minute);

    return DateFormat.Hm().format(midnight);
  }

  String dateTime() {
    final date = DateTime.tryParse(this);
    if (date == null) return this;

    return DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
  }
}

class AppointmentType {
  final String? iconLabel;
  final String? appointmentTypeID;
  final bool? isActive;
  final DateTime? createdDate;
  final DateTime? modifiedDate;
  final String? appointmentTypeDescription;
  final String? appointmentTypeName;
  final bool? isClientVisit;
  final String? createdBy;
  final String? modifiedBy;

  const AppointmentType({
    this.iconLabel,
    this.appointmentTypeID,
    this.isActive,
    this.createdDate,
    this.modifiedDate,
    this.appointmentTypeDescription,
    this.appointmentTypeName,
    this.isClientVisit,
    this.createdBy,
    this.modifiedBy,
  });

  factory AppointmentType.fromJson(Map<String, dynamic> json) {
    return AppointmentType(
      iconLabel: (json['IconLabel'] ?? json['icon_label'])?.toString(),
      appointmentTypeID: (json['AppointmentTypeID'] ?? json['appointment_type_id'])?.toString(),
      isActive: _parseBool(json['IsActive'] ?? json['is_active']),
      createdDate: _parseDate(json['CreatedDate'] ?? json['created_date']),
      modifiedDate: _parseDate(json['ModifiedDate'] ?? json['modified_date']),
      appointmentTypeDescription: (json['AppointmentTypeDescription'] ?? json['appointment_type_description'])?.toString(),
      appointmentTypeName: (json['AppointmentTypeName'] ?? json['appointment_type_name'])?.toString(),
      isClientVisit: _parseBool(json['IsClientVisit'] ?? json['is_client_visit']),
      createdBy: (json['CreatedBy'] ?? json['created_by'])?.toString(),
      modifiedBy: (json['ModifiedBy'] ?? json['modified_by'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IconLabel': iconLabel,
      'AppointmentTypeID': appointmentTypeID,
      'IsActive': isActive,
      'CreatedDate': createdDate?.toIso8601String(),
      'ModifiedDate': modifiedDate?.toIso8601String(),
      'AppointmentTypeDescription': appointmentTypeDescription,
      'AppointmentTypeName': appointmentTypeName,
      'IsClientVisit': isClientVisit,
      'CreatedBy': createdBy,
      'ModifiedBy': modifiedBy,
    };
  }
}

DateTime? _parseDate(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}

bool? _parseBool(Object? value) {
  if (value is bool) return value;
  if (value == null) return null;

  switch (value.toString().toLowerCase()) {
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
