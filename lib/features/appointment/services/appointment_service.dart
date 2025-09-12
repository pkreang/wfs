import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/http/api_client.dart';
import 'package:wfs/features/appointment/models/appointment.dart';
import 'package:wfs/features/appointment/models/appointment_detail.dart';
import 'package:wfs/features/appointment/models/appointment_status.dart';
import 'package:wfs/features/appointment/models/appointment_type.dart';
import 'package:wfs/features/appointment/models/company.dart';
import 'package:wfs/features/appointment/models/outcome.dart';
import 'package:wfs/features/appointment/models/product.dart';
import 'package:wfs/features/appointment/models/purpose.dart';
import 'package:wfs/features/appointment/models/territory.dart';
import 'package:wfs/features/appointment/models/visit_activities.dart';
import 'package:wfs/providers/auth_provider.dart';



class AppointmentService {
  final apiClient = ApiClient('https://sfe-api.appnormalthink.com');
  final token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJzeXN0ZW1hZG1pbkBtYWlsLmNvbSIsImV4cCI6MTc1NzAyOTY1NX0.9_GjEOLlXxOgBSqqZKcSPVPpm_fI8C3_T6DN4w_8JnU";
  

  
  Future<List<Appointment>> fetchAppointments() async {



    final appointments = await apiClient.get(
      path: "/appointment/?IsActive=true", //&AppointmentDate=2025-08-04&UserID=9E0DC5F7-1FD6-41F3-9137-14711FC510F6
      decode: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['appointments'] as List? ?? const [];
        return Appointment.listFromJson(list);
      },
      headers: {"Authorization": "Bearer $token"},
    );

    return appointments;
  }

  Future<AppointmentDetail> fetchAppointmentById(Ref ref,String appointmentID) async {

  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;


    final appointment = await apiClient.get(
      path: "/appointment/id/$appointmentID",
      decode: (json) => AppointmentDetail.fromJson((json as Map<String, dynamic>)["appointment"][0]),
      headers: {"Authorization": "Bearer $accessToken"},
    );

    return appointment;
  }

  Future<List<Product>> fetchProducts(Ref ref) async {
     final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;

    final products = await apiClient.get(
      path: "/product/?SearchName=Test&IsActive=true",
      decode: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['products'] as List? ?? const [];

        return Product.listFromJson(list);
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );

    return products;
  }

  Future<List<AppointmentType>> fetchAppointmentTypd(Ref ref) async {

         final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;
    final appointmentType = await apiClient.get(
      path: "/appointment/type/?IsActive=true",
      decode: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['appointment_types'] as List? ?? const [];

        return AppointmentType.listFromJson(list);
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );

    return appointmentType;
  }

  Future<List<AppointmentStatus>> fetchAppointmentStatus(Ref ref) async {

         final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;
    final appointmentStatus = await apiClient.get(
      path: "/appointment/status/?IsActive=true",
      decode: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['appointment_status'] as List? ?? const [];

        return AppointmentStatus.listFromJson(list);
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );

    return appointmentStatus;
  }

  Future<List<Purpose>> fetchPurposes(Ref ref) async {


     final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;    final purposes = await apiClient.get(
      path: "/purpose_type/?IsActive=true",
      decode: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['purpose_types'] as List? ?? const [];

        return Purpose.listFromJson(list);
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );

    return purposes;
  }

  Future<List<Territory>> fetchTerritories(Ref ref) async {
         final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;
    final territories = await apiClient.get(
      path: "/sale/territory/?IsActive=true",
      decode: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['sale_territorie'] as List? ?? const [];

        return Territory.listFromJson(list);
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );

    return territories;
  }

  Future<List<Outcome>> fetchOutcomes() async {
    List<Outcome> outcomes = [
      Outcome(outcomeID: "239513F7-C338-41D0-A73B-34E91C78348F", outcomeName: "Order Placed"),
      Outcome(outcomeID: "2", outcomeName: "Quotation Sent"),
      Outcome(outcomeID: "3", outcomeName: "Follow-up needed"),
    ];

    return outcomes;
  }

  Future<List<Company>> fetchCompanies(Ref ref) async {
         final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;
    final companies = await apiClient.get(
      path: "/company/?IsActive=true",
      decode: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['companies'] as List? ?? const [];

        return Company.listFromJson(list);
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );

    return companies;
  }

  Future<bool> updateAppointment(AppointmentDetail appointmentDetail,Ref ref) async {

         final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;
    try {
      return await apiClient.put(path: "/appointment/${appointmentDetail.appointmentId.toString()}", body: appointmentDetail.toJsonUpdate(), headers: {"Authorization": "Bearer $accessToken"});
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> deleteAppointment(String appointmentID,Ref ref) async {
     final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;
    try {
      return await apiClient.delete(path: "/appointment/$appointmentID", headers: {"Authorization": "Bearer $accessToken"});
    } catch (e) {
      print('deleteAppointment catch: $e');
      return false;
    }
  }

  Future<List<VisitActivity>> fetchVisitActivities(String appointmentID,Ref ref) async {

         final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;
    final visitActivities = await apiClient.get(
      path: "/appointment/visit?IsActive=true&AppointmentID=$appointmentID",
      decode: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['visit_activities'] as List? ?? const [];
        return VisitActivity.listFromJson(list);
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );

    return visitActivities;
  }

  Future<({bool ok, String activityId, String modifiedBy})> checkIn(VisitActivity visitActivity,Ref ref) async {
    
             final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;
    try {
      return await apiClient.post(
        path: "/appointment/visit/In",
        body: visitActivity.toJson(),
        decode: (json) {
          final map = json as Map<String, dynamic>;
          if ((map['status'] as String?)?.toLowerCase() != "success") return (ok: false, activityId: '', modifiedBy: '');

          final visitActivity = (map['visit_activity'] as Map?)?.cast<String, dynamic>();
          final activityID = visitActivity?['ActivityID']?.toString() ?? '';
          final modifiedBy = visitActivity?['ModifiedBy']?.toString() ?? '';

          return (ok: activityID.isNotEmpty, activityId: activityID, modifiedBy: modifiedBy);
        },
        headers: {"Authorization": "Bearer $accessToken"},
      );
    } catch (e) {
      print('checkIn catch: $e');
      return (ok: false, activityId: '', modifiedBy: '');
    }
  }

  Future<bool> uploadImage({required String activityId, required String modifiedBy, required String imgBase64}) async {

    try {
      return await apiClient.post(
        path: "/appointment/upload-image",
        body: {'ActivityID': activityId, 'ModifiedBy': modifiedBy, 'ImageData': imgBase64},
        decode: (json) {
          final map = json as Map<String, dynamic>;
          print('uploadImage map: $map');
          return (map['status'] as String?)?.toLowerCase() != "success";
        },
        headers: {"Authorization": "Bearer $token"},
      );
    } catch (e) {
      print('uploadImage catch: $e');
      return false;
    }
  }

  Future<bool> checkOut(VisitActivity visitActivity,Ref ref) async {
             final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;
    try {
      return await apiClient.post(
        path: "/appointment/visit/out",
        body: visitActivity.toJson(),
        decode: (json) {
          final map = json as Map<String, dynamic>;
          return (map['status'] as String?)?.toLowerCase() != "success";
        },
        headers: {"Authorization": "Bearer $accessToken"},
      );
    } catch (e) {
      print('checkOut catch: $e');
      return false;
    }
  }
}
