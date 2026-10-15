import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/http/api_client.dart';
import 'package:wfs/features/lead/models/lead.dart';
import 'package:wfs/features/lead/models/lead_history.dart';
import 'package:wfs/features/lead/models/lead_status.dart';
import 'package:wfs/providers/auth_provider.dart';

class LeadService {
  final apiClient = ApiClient('https://sfe-api.appnormalthink.com');

  Future<List<Lead>> fetchLeads(Ref ref, {String? startDate, endDate, status}) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    final queryParameters = <String, String>{'PageSize': '200000', if (startDate != null) 'CreateDateFrom': startDate, if (endDate != null) 'CreateDateto': endDate};

    if (status?.trim().isNotEmpty ?? false) {
      queryParameters['PipelineStatus'] = status!.trim();
    }

    final leads = await apiClient.getOnly(
      path: "/lead",
      query: queryParameters,
      decode: (json) {
        final map = json as Map<String, dynamic>;

        final list = map['rows'] as List? ?? const [];

        return list.map((e) => Lead.fromJson(e as Map<String, dynamic>)).toList();
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );

    return leads;
  }

  Future<Lead> getById(Ref ref, String leadID) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    final leads = await apiClient.getOnly(
      path: "/lead/$leadID",
      decode: (json) {
        final map = json as Map<String, dynamic>;

        return Lead.fromJson(map);
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );

    return leads;
  }

  Future<List<LeadStatus>> fetchLeadStatus(Ref ref) async {
    return LeadStatus.defaults;
  }

  Future<bool> createLead(Lead lead, Ref ref) async {
    final authState = ref.watch(authProvider);
    final accessToken = authState.accessToken;
    final userID = authState.userID ?? '';

    return await apiClient.post(
      path: "/lead",
      body: lead.toJsonCreate(userID, authState),
      decode: (json) {
        final map = json as Map<String, dynamic>;

        return ((map['status'] as String?)?.toLowerCase() == "success");
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );

    //     {
    //     "first_name": "โทนี่ 13",
    //     "last_name": "กะต๊าาก",
    //     "close_probability": 0.0,
    //     "budget": 1200000.00,
    //     "company_id": null,
    //     "company_name": "บริษัท กะต๊าก13 คอป จำกัด",
    //     "position": "Founder",
    //     "sale_id": "2F5C7F03-3D09-4189-A218-A6D536DC153F",
    //     "pipeline_stage_id": "930E506C-018B-46AE-9690-6CE0D2FE9413"
    // }
  }

  // Future<bool> updateDealValues({required Ref ref, required String leadID, required List<DealValue> dealValues}) async {
  //   final db = await _db;
  //   final now = DateTime.now();
  //   final count = await db.update(_leadTable, {'DealValues': DealValue.encodeList(dealValues), 'UpdatedAt': now.toIso8601String()}, where: 'LeadID = ?', whereArgs: [leadID]);

  //   return count > 0;
  // }

  Future<bool> updateLead({required Ref ref, required Lead lead}) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    final leads = await apiClient.put(
      path: "/lead/${lead.leadID ?? ''}",
      body: {
        "first_name": lead.firstName,
        "last_name": lead.lastName,
        "phone": lead.phone,
        "email": lead.email,
        "close_probability": (lead.closeProbability ?? 0).toDouble(),
        "budget": lead.budget,
        "company_id": lead.companyID,
        "company_name": lead.companyName,
        "position": lead.position,
        "sale_id": lead.saleID,
        "pipeline_stage_id": lead.pipelineStageID,
        "close_lost_reason": lead.closeLostReason,
        "deal_date": null, // 🟢 หน้าจอระบุและส่งวันที่ปิดดีลมาเองตรงนี้เลย!
        "job_title": lead.jobTitle,
        "line_id": lead.lineID,
        "reporting_line": lead.reportLine,
        "number_of_subordinates": lead.noOfSubordinate,
        "note": lead.note,
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );

    return leads;
  }

  Future<bool> unQualify(String leadID, String note, Ref ref) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    return await apiClient.put(path: "/lead/${leadID.toString()}/unqualified", headers: {"Authorization": "Bearer $accessToken"}, body: {"note": note});
  }

  Future<bool> deleteLead(String leadID, Ref ref) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    return await apiClient.delete(path: "/lead/${leadID.toString()}", headers: {"Authorization": "Bearer $accessToken"});
  }

  Future<bool> addDealValue({required Ref ref, required String leadID, required DealValue dealValue}) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    final leads = await apiClient.post(
      path: "/lead/$leadID/item",
      body: dealValue.toJson(),
      decode: (json) {
        final map = json as Map<String, dynamic>;

        return ((map['status'] as String?)?.toLowerCase() == "success");
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );

    return leads;
  }

  Future<bool> removeDealValue({required Ref ref, required String leadID}) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    return await apiClient.delete(path: "/lead/item/${leadID.toString()}", headers: {"Authorization": "Bearer $accessToken"});
  }

  Future<List<LeadHistory>> fetchLeadHistory(Ref ref, String leadID) async {
    return const [];
  }
}

/*
Old API-backed implementation kept for reference.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/http/api_client.dart';
import 'package:wfs/features/lead/models/lead.dart';
import 'package:wfs/features/lead/models/lead_history.dart';
import 'package:wfs/features/lead/models/lead_status.dart';
import 'package:wfs/providers/auth_provider.dart';

class LeadService {
  final apiClient = ApiClient('https://sfe-api.appnormalthink.com');

  Future<List<Lead>> fetchLeads(Ref ref) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    return await apiClient.get(
      path: "/lead/?IsActive=true",
      decode: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['leads'] ?? map['lead'] ?? map['Lead'] ?? map['Leads'] ?? const [];

        return (list as List).map((e) => Lead.fromJson(e as Map<String, dynamic>)).toList();
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );
  }

  Future<Lead> getById(Ref ref, String leadID) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    return await apiClient.get(
      path: "/lead/id/$leadID",
      decode: (json) {
        final map = json as Map<String, dynamic>;
        final leadJson = map['lead'] ?? map['Lead'] ?? map;

        return Lead.fromJson(leadJson as Map<String, dynamic>);
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );
  }

  Future<List<LeadStatus>> fetchLeadStatus(Ref ref) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    try {
      return await apiClient.get(
        path: "/lead/status/?IsActive=true",
        decode: (json) {
          final map = json as Map<String, dynamic>;
          final list = map['lead_status'] ?? map['leadStatus'] ?? map['statuses'] ?? map['LeadStatus'] ?? const [];

          return LeadStatus.listFromJson(list as List);
        },
        headers: {"Authorization": "Bearer $accessToken"},
      );
    } catch (_) {
      return LeadStatus.defaults;
    }
  }

  Future<(bool, String)> createLead(Lead lead, Ref ref) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;
    final userID = authState.userID ?? '';

    return await apiClient.post(
      path: "/lead/",
      body: lead.toJsonCreate(userID),
      decode: (json) {
        final map = json as Map<String, dynamic>;
        final leadJson = map['lead'] ?? map['Lead'] ?? const {};
        final leadID = leadJson is Map ? (leadJson['LeadID'] ?? leadJson['leadID'] ?? leadJson['id'])?.toString() ?? '' : '';

        return ((map['status'] as String?)?.toLowerCase() == "success", leadID);
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );
  }

  Future<bool> updateLeadStatus({required Ref ref, required String leadID, required LeadStatus status, String? remarks}) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;
    final userID = authState.userID ?? '';

    return await apiClient.post(
      path: "/lead/update_status",
      body: {'LeadID': leadID, 'LeadStatusID': status.leadStatusID, 'LeadStatusName': status.leadStatusName, 'Remarks': remarks, 'ModifiedBy': userID},
      decode: (json) {
        final map = json as Map<String, dynamic>;
        return (map['status'] as String?)?.toLowerCase() == "success";
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );
  }

  Future<List<LeadHistory>> fetchLeadHistory(Ref ref, String leadID) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    return await apiClient.get(
      path: "/lead/history/$leadID",
      decode: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['histories'] ?? map['history'] ?? map['activities'] ?? map['lead_history'] ?? const [];

        return LeadHistory.listFromJson(list as List);
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );
  }
}
*/
