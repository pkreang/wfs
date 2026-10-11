import 'dart:convert';

import 'package:wfs/features/client/models/client_company.dart';
import 'package:wfs/features/company/models/company.dart';
import 'package:wfs/features/company/models/company_address.dart';
import 'package:wfs/features/lead/models/lead_history.dart';
import 'package:wfs/features/lead/models/lead_status.dart';
import 'package:wfs/models/auth_model.dart';

const Object _noValue = Object();

class DealValue {
  final String? dealValueItemID;
  final String detail;
  final num? saleAmount;

  const DealValue({
    this.dealValueItemID,
    required this.detail,
    this.saleAmount,
  });

  factory DealValue.fromJson(Map<String, dynamic> json) {
    return DealValue(
      dealValueItemID:
          (json['DealValueItemID'] ?? json['DealValueItemID'] ?? '').toString(),
      detail: (json['Detail'] ?? json['Detail'] ?? '').toString(),
      saleAmount: num.tryParse(
        (json['SaleAmount'] ?? json['SaleAmount'] ?? '').toString(),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'detail': detail,
    'sale_amount': saleAmount,
    'note': null,
  };

  static List<DealValue> listFromJson(Object? value) {
    if (value == null) return const [];
    if (value is String) {
      if (value.trim().isEmpty) return const [];
      try {
        final decoded = jsonDecode(value);
        return listFromJson(decoded);
      } catch (_) {
        return const [];
      }
    }
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => DealValue.fromJson(Map<String, dynamic>.from(item)))
          .where((item) => item.detail.trim().isNotEmpty)
          .toList();
    }
    return const [];
  }

  static String? encodeList(List<DealValue>? values) {
    if (values == null || values.isEmpty) return null;
    return jsonEncode(values.map((item) => item.toJson()).toList());
  }
}

class Lead {
  final String? leadID;
  final String? leadName;
  final String? firstName;
  final String? lastName;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? companyID;
  final String? companyName;
  final String? ownerName;
  final int? closeProbability;
  final double? budget;
  final String? position;
  final double? price;
  final List<DealValue>? dealValues;
  final bool? isQualified;
  final bool? isUnqualified;
  final int? qualifyRound;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? source;
  final String? interest;
  final String? notes;
  final String? attachFilePath;
  final String? attachFileName;
  final String? closeResult;
  final String? closeLostReason;
  final String? pipelineStageID;
  final String? leadStatusID;
  final String? leadStatus;
  final String? leadStatusName;
  final String? createdBy;
  final String? modifiedBy;
  final List<LeadHistory>? histories;
  final String? saleID;
  final String? saleName;
  final String? jobTitle;
  final String? lineID;
  final String? reportLine;
  final int? noOfSubordinate;
  final String? note;
  final Company? company;
  final List<ClientCompany> companies;
  final String? salesTerritoryID;
  final String? salesTerritoryName;
  final String? unqualifiedNote;

  const Lead({
    this.leadID,
    this.leadName,
    this.firstName,
    this.lastName,
    this.contactPerson,
    this.phone,
    this.email,
    this.companyID,
    this.companyName,
    this.ownerName,
    this.closeProbability,
    this.budget,
    this.position,
    this.price,
    this.dealValues,
    this.isQualified,
    this.isUnqualified,
    this.qualifyRound,
    this.createdAt,
    this.updatedAt,
    this.source,
    this.interest,
    this.notes,
    this.attachFilePath,
    this.attachFileName,
    this.closeResult,
    this.closeLostReason,
    this.pipelineStageID,
    this.leadStatusID,
    this.leadStatus,
    this.leadStatusName,
    this.createdBy,
    this.modifiedBy,
    this.histories,
    this.saleID,
    this.saleName,
    this.jobTitle,
    this.lineID,
    this.reportLine,
    this.noOfSubordinate,
    this.note,
    this.company,
    this.companies = const [],
    this.salesTerritoryID,
    this.salesTerritoryName,
    this.unqualifiedNote,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    final statusJson =
        json['LeadStatus'] ??
        json['leadStatus'] ??
        json['Status'] ??
        json['status'];
    final status = statusJson is Map<String, dynamic>
        ? LeadStatus.fromJson(statusJson)
        : null;
    final histories =
        json['histories'] ??
        json['Histories'] ??
        json['history'] ??
        json['History'] ??
        json['activities'] ??
        json['Activities'];
    final closeProbabilityValue =
        json['close_probability'] ??
        json['closeProbability'] ??
        json['CloseProbability'];
    final companyID =
        (json['company_id'] ?? json['companyID'] ?? json['CompanyID'])
            ?.toString();
    final companyName =
        (json['company_name'] ?? json['companyName'] ?? json['CompanyName'])
            ?.toString();
    final companies = ClientCompany.listFromJson(json['companies'] ?? []);
    Company? company;
    if (json['company_address'] != null) {
      company = Company(
        companyID: companyID,
        companyName: companyName,
        addresses: [
          CompanyAddress.fromJson(
            json['company_address'] as Map<String, dynamic>,
          ),
        ],
      );
    } else {
      for (final clientCompany in companies) {
        if ((companyID == null ||
                companyID.isEmpty ||
                clientCompany.companyID == companyID) &&
            clientCompany.company != null) {
          company = clientCompany.company;
          break;
        }
      }
    }

    return Lead(
      leadID: (json['lead_id'] ?? json['leadID'] ?? json['LeadID'])?.toString(),
      leadName: (json['lead_name'] ?? json['leadName'] ?? json['LeadName'])
          ?.toString(),
      firstName: (json['first_name'] ?? json['firstName'] ?? json['FirstName'])
          ?.toString(),
      lastName: (json['last_name'] ?? json['lastName'] ?? json['LastName'])
          ?.toString(),
      pipelineStageID:
          (json['pipeline_stage_id'] ??
                  json['pipelineStageID'] ??
                  json['pipelineStageId'] ??
                  json['PipelineStageID'] ??
                  json['PipelineStageId'])
              ?.toString(),
      leadStatus:
          (json['lead_status'] ??
                  json['leadStatusName'] ??
                  json['LeadStatusName'] ??
                  status?.leadStatusName)
              ?.toString(),
      ownerName: (json['owner_name'] ?? json['ownerName'] ?? json['OwnerName'])
          ?.toString(),
      closeProbability: closeProbabilityValue is num
          ? closeProbabilityValue.toInt()
          : int.tryParse((closeProbabilityValue ?? '').toString()),
      saleID: (json['sale_id'] ?? json['saleID'] ?? json['SaleID'])?.toString(),
      saleName:
          (json['sale_name'] ??
                  json['saleName'] ??
                  json['SaleName'] ??
                  json['owner_name'])
              ?.toString(),
      companyID: companyID,
      companyName: companyName,
      dealValues: DealValue.listFromJson(json['deal_items']),
      closeLostReason: json['close_lost_reason']?.toString(),
      isUnqualified: json['is_unqualified'] as bool?,

      // totalAmnt
      // contactPerson: (json['ContactPerson'] ?? json['contactPerson'])?.toString(),
      // phone: (json['Phone'] ?? json['phone'] ?? json['PhoneNumber'] ?? json['phoneNumber'])?.toString(),
      // email: (json['Email'] ?? json['email'])?.toString(),
      budget: double.tryParse(
        (json['Budget'] ?? json['budget'] ?? '').toString(),
      ),
      // position: (json['Position'] ?? json['position'])?.toString(),
      // price: double.tryParse((json['Price'] ?? json['price'] ?? '').toString()),
      // dealValues: _parseDealValues(json['DealValues'] ?? json['dealValues'], json['Position'] ?? json['position'], json['Price'] ?? json['price']),
      // isQualified: _parseNullableBool(json['IsQualified'] ?? json['isQualified']),
      // qualifyRound: _parseNullableInt(json['QualifyRound'] ?? json['qualifyRound']),
      // createdAt: _parseDate(json['CreatedAt'] ?? json['createdAt'] ?? json['CreatedDate'] ?? json['createdDate']),
      // updatedAt: _parseDate(json['UpdatedAt'] ?? json['updatedAt'] ?? json['ModifiedDate'] ?? json['modifiedDate']),
      // source: (json['Source'] ?? json['source'])?.toString(),
      // interest: (json['Interest'] ?? json['interest'])?.toString(),
      // notes: (json['Notes'] ?? json['notes'] ?? json['Noted'] ?? json['noted'])?.toString(),
      // attachFilePath: (json['AttachFilePath'] ?? json['attachFilePath'])?.toString(),
      // attachFileName: (json['AttachFileName'] ?? json['attachFileName'])?.toString(),
      // closeResult: (json['CloseResult'] ?? json['closeResult'])?.toString(),
      // closeLostReason: (json['CloseLostReason'] ?? json['closeLostReason'])?.toString(),
      leadStatusID:
          (json['lead_status_id'] ??
                  json['leadStatusID'] ??
                  json['LeadStatusID'] ??
                  json['statusID'] ??
                  json['StatusID'] ??
                  status?.leadStatusID)
              ?.toString(),
      leadStatusName:
          (json['lead_status_name'] ??
                  json['leadStatusName'] ??
                  json['LeadStatusName'] ??
                  json['statusName'] ??
                  json['StatusName'] ??
                  status?.leadStatusName)
              ?.toString(),
      // createdBy: (json['CreatedBy'] ?? json['createdBy'])?.toString(),
      // modifiedBy: (json['ModifiedBy'] ?? json['modifiedBy'])?.toString(),
      phone: json['phone'],
      email: json['email'],
      histories: histories is List
          ? LeadHistory.listFromJson(histories)
          : const [],
      jobTitle: json['job_title'],
      lineID: json['line_id'],
      reportLine: json['reporting_line'],
      noOfSubordinate: json['number_of_subordinates'],
      note: json['note'],
      company: company,
      companies: companies,
      salesTerritoryID: json['SalesTerritoryID'],
      salesTerritoryName: json['SalesTerritoryName'],
      unqualifiedNote: json['unqualified_note'],
    );
  }

  Map<String, dynamic> toJsonCreate(String userID, AuthState authState) {
    return {
      "first_name": firstName,
      "last_name": lastName,
      "phone": phone,
      "email": email,
      "close_probability": closeProbability,
      "budget": budget,
      "company_id": companyID,
      "company_name": companyName,
      "position": position,
      "sale_id": authState.isSales ? userID : saleID,
      "pipeline_stage_id": pipelineStageID,
      "job_title": jobTitle,
      "line_id": lineID,
      "reporting_line": reportLine,
      "number_of_subordinates": noOfSubordinate,
      "note": note,
    };
  }

  Lead copyWith({
    String? leadID,
    String? firstName,
    String? lastName,
    String? contactPerson,
    String? phone,
    String? email,
    String? companyID,
    String? companyName,
    String? ownerName,
    Object? closeProbability = _noValue,
    Object? budget = _noValue,
    Object? position = _noValue,
    Object? price = _noValue,
    Object? dealValues = _noValue,
    Object? isQualified = _noValue,
    Object? isUnqualified = _noValue,
    Object? qualifyRound = _noValue,
    String? source,
    String? interest,
    String? notes,
    Object? attachFilePath = _noValue,
    Object? attachFileName = _noValue,
    Object? closeResult = _noValue,
    Object? closeLostReason = _noValue,
    String? pipelineStageID,
    String? leadStatusID,
    String? leadStatus,
    String? leadStatusName,
    String? createdBy,
    String? modifiedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<LeadHistory>? histories,
    String? jobTitle,
    String? lineID,
    String? reportLine,
    int? noOfSubordinate,
    String? note,
    String? saleID,
    String? saleName,
    String? unqualifiedNote,
    Company? company,
    List<ClientCompany>? companies,
  }) {
    return Lead(
      leadID: leadID ?? this.leadID,
      leadName: leadName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      companyID: companyID ?? this.companyID,
      companyName: companyName ?? this.companyName,
      ownerName: ownerName ?? this.ownerName,
      closeProbability: closeProbability == _noValue
          ? this.closeProbability
          : closeProbability as int?,
      budget: budget == _noValue ? this.budget : budget as double?,
      position: position == _noValue ? this.position : position as String?,
      price: price == _noValue ? this.price : price as double?,
      dealValues: dealValues == _noValue
          ? this.dealValues
          : dealValues as List<DealValue>?,
      isQualified: isQualified == _noValue
          ? this.isQualified
          : isQualified as bool?,
      isUnqualified: isUnqualified == _noValue
          ? this.isUnqualified
          : isUnqualified as bool?,
      qualifyRound: qualifyRound == _noValue
          ? this.qualifyRound
          : qualifyRound as int?,
      source: source ?? this.source,
      interest: interest ?? this.interest,
      notes: notes ?? this.notes,
      attachFilePath: attachFilePath == _noValue
          ? this.attachFilePath
          : attachFilePath as String?,
      attachFileName: attachFileName == _noValue
          ? this.attachFileName
          : attachFileName as String?,
      closeResult: closeResult == _noValue
          ? this.closeResult
          : closeResult as String?,
      closeLostReason: closeLostReason == _noValue
          ? this.closeLostReason
          : closeLostReason as String?,
      pipelineStageID: pipelineStageID ?? this.pipelineStageID,
      leadStatusID: leadStatusID ?? this.leadStatusID,
      leadStatus: leadStatus ?? this.leadStatus,
      leadStatusName: leadStatusName ?? this.leadStatusName,
      createdBy: createdBy ?? this.createdBy,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      histories: histories ?? this.histories,
      jobTitle: jobTitle ?? this.jobTitle,
      lineID: lineID ?? this.lineID,
      reportLine: reportLine ?? this.reportLine,
      noOfSubordinate: noOfSubordinate ?? this.noOfSubordinate,
      note: note ?? this.note,
      saleID: saleID ?? this.saleID,
      saleName: saleName ?? this.saleName,
      unqualifiedNote: unqualifiedNote ?? this.unqualifiedNote,
      company: company ?? this.company,
      companies: companies ?? this.companies,
      salesTerritoryID: salesTerritoryID,
      salesTerritoryName: salesTerritoryName,
    );
  }

  // String get statusName => leadStatus?.leadStatusName ?? leadStatusName ?? '';
}

// DateTime? _parseDate(Object? value) {
//   if (value == null) return null;
//   return DateTime.tryParse(value.toString());
// }

// bool? _parseNullableBool(Object? value) {
//   if (value == null) return null;
//   if (value is bool) return value;
//   if (value is num) {
//     if (value == 1) return true;
//     if (value == 0) return false;
//   }

//   final text = value.toString().toLowerCase().trim();
//   if (text == 'true' || text == '1') return true;
//   if (text == 'false' || text == '0') return false;
//   return null;
// }

// int? _parseNullableInt(Object? value) {
//   if (value == null) return null;
//   if (value is int) return value;
//   if (value is num) return value.toInt();
//   return int.tryParse(value.toString());
// }
