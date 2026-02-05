import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wfs/config/api_config.dart';
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
import 'package:http/http.dart' as http;

class AppointmentService {
  final apiClient = ApiClient('https://sfe-api.appnormalthink.com');

  Future<List<Appointment>> fetchAppointmentsByDate(Ref ref, String date) async {
    final authState = ref.watch(authProvider);
    final accessToken = authState.accessToken;

    final appointments = await apiClient.get(
      path: "/appointment/bydate/?AppointmentDate=$date",
      decode: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['appointments'] as List? ?? const [];

        return Appointment.listFromJson(list);
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );

    return appointments;
  }

  Future<List<String>> fetchAppointmentByMonthYear(Ref ref, String month, year) async {
    final authState = ref.watch(authProvider);
    final accessToken = authState.accessToken;

    final appointmentDates = await apiClient.get(
      path: "/appointment/dates/?Month=$month&Year=$year",
      decode: (json) {
        final map = json as Map<String, dynamic>;
        return List<String>.from(map['appointment_dates']);
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );

    return appointmentDates;
  }

  Future<AppointmentDetail> fetchAppointmentById(Ref ref, String appointmentID) async {
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
    final accessToken = authState.accessToken;
    final purposes = await apiClient.get(
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

  // Future<List<Company>> fetchCompanies(Ref ref) async {
  //   final authState = ref.watch(authProvider);
  //   final accessToken = authState.accessToken;
  //   final companies = await apiClient.get(
  //     path: "/company/?IsActive=true",
  //     decode: (json) {
  //       final map = json as Map<String, dynamic>;
  //       final list = map['companies'] as List? ?? const [];

  //       return Company.listFromJson(list);
  //     },
  //     headers: {"Authorization": "Bearer $accessToken"},
  //   );

  //   return companies;
  // }

  Future<bool> createAppointment(Appointment appointment, Ref ref) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    try {
      return await apiClient.post(
        path: "/appointment/",
        body: appointment.toJson(),
        decode: (json) {
          final map = json as Map<String, dynamic>;
          return (map['status'] as String?)?.toLowerCase() == "success";
        },
        headers: {"Authorization": "Bearer $accessToken"},
      );
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateAppointment(AppointmentDetail appointmentDetail, Ref ref) async {
    final authState = ref.watch(authProvider);
    final accessToken = authState.accessToken;
    try {
      return await apiClient.put(path: "/appointment/${appointmentDetail.appointmentID.toString()}", body: appointmentDetail.toJsonUpdate(), headers: {"Authorization": "Bearer $accessToken"});
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> deleteAppointment(String appointmentID, Ref ref) async {
    final authState = ref.watch(authProvider);
    final accessToken = authState.accessToken;
    try {
      return await apiClient.delete(path: "/appointment/$appointmentID", headers: {"Authorization": "Bearer $accessToken"});
    } catch (e) {
      print('deleteAppointment catch: $e');
      return false;
    }
  }

  Future<List<VisitActivity>> fetchVisitActivities(String appointmentID, Ref ref) async {
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

  Future<({bool ok, String activityId, String modifiedBy})> checkIn(VisitActivity visitActivity, Ref ref) async {
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

  Future<bool> uploadImage({required Ref ref, required String activityId, required String modifiedBy, required String imgBase64}) async {
    try {
      final authState = ref.watch(authProvider);
      final accessToken = authState.accessToken;

      return await apiClient.post(
        path: "/appointment/upload-image",
        body: {'ActivityID': activityId, 'ModifiedBy': modifiedBy, 'ImageData': imgBase64},
        decode: (json) {
          final map = json as Map<String, dynamic>;
          return (map['status'] as String?)?.toLowerCase() == "success";
        },
        headers: {"Authorization": "Bearer $accessToken"},
      );
    } catch (e) {
      print('uploadImage catch: $e');
      return false;
    }
  }

  Future<bool> checkOut(VisitActivity visitActivity, Ref ref) async {
    final authState = ref.watch(authProvider);
    final accessToken = authState.accessToken;
    try {
      return await apiClient.post(
        path: "/appointment/visit/out",
        body: visitActivity.toJson(),
        decode: (json) {
          final map = json as Map<String, dynamic>;
          return (map['status'] as String?)?.toLowerCase() == "success";
        },
        headers: {"Authorization": "Bearer $accessToken"},
      );
    } catch (e) {
      print('checkOut catch: $e');
      return false;
    }
  }

  Future<bool> updateAppointmentStatus(Ref ref, String appointmentID, String appointmentStatusID, String? cancelNoted) async {
    final authState = ref.watch(authProvider);
    final accessToken = authState.accessToken;
    try {
      return await apiClient.post(
        path: "/appointment/update_status",
        body: {'AppointmentID': appointmentID, 'AppointmentStatusID': appointmentStatusID, 'CancelNoted': cancelNoted},
        decode: (json) {
          final map = json as Map<String, dynamic>;
          return (map['status'] as String?)?.toLowerCase() == "success";
        },
        headers: {"Authorization": "Bearer $accessToken"},
      );
    } catch (e) {
      print('updateAppointmentStatus catch: $e');
      return false;
    }
  }

  Future<File?> getImage(WidgetRef ref, String activityID) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/appointment/get-image/${activityID.toString()}');

      final response = await http.get(uri, headers: {'Authorization': 'Bearer $accessToken'});

      if (response.statusCode == 200) {
        // Parse JSON response
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success') {
          // Decode base64 image data
          final base64String = jsonData['image_data'] as String;
          final bytes = base64.decode(base64String);

          // Get filename from response or use default
          final fileName = jsonData['file_name'] ?? 'appointment_$activityID.jpg';

          // Save to temporary file
          final dir = await getTemporaryDirectory();
          final file = File('${dir.path}/$fileName');
          await file.writeAsBytes(bytes);

          return file;
        } else {
          print('Failed to get image: ${jsonData['status']}');
          return null;
        }
      } else {
        print('Failed to get image. Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting profile image: $e');
      return null;
    }
  }

  Future<List<Appointment>> getNotifications(WidgetRef ref) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    final appointments = await apiClient.get(
      path: "/appointment/notification",
      decode: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['appointments'] as List? ?? const [];

        return list.map((e) => Appointment.fromJson(e as Map<String, dynamic>)).toList();
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );

    return appointments;
  }

  Future<void> markNotification({required String appointmentID, required WidgetRef ref}) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    final url = Uri.parse('https://sfe-api.appnormalthink.com/notification/');

    await http.post(url, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'}, body: json.encode({'RefID': appointmentID, 'NotificationType': 'Appointment'}));
  }
}
