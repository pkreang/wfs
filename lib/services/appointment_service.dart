import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wfs/config/api_config.dart';
import 'package:wfs/models/appointment_model.dart';
import 'package:wfs/models/appointments_model.dart';

class AppointmentService {
  Future<List<Appointment>> fetchAppointments(
    String accessToken,
    String userID,
  ) async {
    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }

    final uri = Uri.parse(ApiConfig.appointmentUrl).replace(
      queryParameters: {
        'UserID': userID,
        // หากมีพารามิเตอร์อื่น ๆ สามารถเพิ่มต่อที่นี่ได้
        // 'param2': 'value2'
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // จากโครงสร้าง JSON ข้อมูลนัดหมายอยู่ใน list ซ้อน list
      final List<dynamic> appointmentListJson = data['appointments'];
      // แปลง List ของ JSON เป็น List ของ Appointment object

      return appointmentListJson
          .map((json) => Appointment.fromJson(json))
          .toList();
    } else {
      // ถ้า request ไม่สำเร็จ ให้โยน Error
      throw Exception(
        'Failed to load appointments. Status code: ${response.statusCode}',
      );
    }
  }

  Future<Appointments> Edit(
    String accessToken,
    String guid,
    Appointments appointment,
  ) async {
    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.editAppointmentUrl + guid),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(appointment),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final dynamic appointmentListJson = data['appointment'];
        return Appointments.fromJson(appointmentListJson);
      } else {
        throw Exception(
          'Failed to load appointments. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to load appointments. Status code:');
    }
  }

  Future<void> Add(String accessToken, Appointments appointment) async {
    //     String jsonString = '''
    // {
    //     "AppointmentTitle": "นัดพบลูกค้า"  ,
    //     "AppointmentTypeID": "7DEEC491-A5AE-4856-B981-7E91870179FF"  ,
    //     "UserID": "9E0DC5F7-1FD6-41F3-9137-14711FC510F6"  ,
    //     "ClientID" : "471638B8-F144-4446-8DC6-29CADA5EEEB0"    ,
    //     "CompanyID"  : "627DC383-E210-46A2-9819-FB355146BB0B"  ,
    //     "AppointmentDateTimeFrom": "2025-08-14T18:00:00",
    //     "AppointmentDateTimeTo": "2025-08-14T18:00:00",
    //     "AppointmentStatusID" : "4E2DC36E-53E6-4E9B-BAC2-1F2629BD745B"  ,
    //     "PurposeTypeID"  : "A0794CE9-507E-4F6A-86A6-299282D7BF7F"  ,
    //     "Noted": null,
    //     "AssignedBy": null,
    //     "AppointmentAddress"  : {
    //         "Address":"123/4 Sukhumvit Road",
    //         "CountryID":1,
    //         "ProvinceID":1,
    //         "DistrictID":13,
    //         "SubDistrictID":2583,
    //         "Latitude": null,
    //         "Longitude":null,
    //         "IsPrimary": true  ,
    //         "IsActive": true
    //     } ,
    //     "AppointmentProducts":[
    //       "E30AC1C5-37DD-49E4-90CD-26CC4D70848F","96EBF916-B4CF-46B2-B660-4A8D4F00CFA6"
    //     ],
    //     "IsActive" : true  ,
    //     "CreatedBy"   : "9E0DC5F7-1FD6-41F3-9137-14711FC510F6" ,
    //     "ModifiedBy"   : "9E0DC5F7-1FD6-41F3-9137-14711FC510F6"
    // }
    // ''';

    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.addAppointmentUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(appointment),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('สำเร็จ: $data');
      } else {
        print('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('เกิดข้อผิดพลาด: $e');
    }
  }

  Future<Appointments> GetById(String accessToken, String guid) async {
    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }

    final uri = Uri.parse(ApiConfig.getByIdApointmentUrl + guid);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> appointmentListJson = data['appointment'];
      return Appointments.fromJson(appointmentListJson[0]);
    } else {
      throw Exception(
        'Failed to load appointments. Status code: ${response.statusCode}',
      );
    }
  }

  Future<List<Appointments>> GetByDate(String accessToken, String date) async {
    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }

    final uri = Uri.parse(ApiConfig.getByDateApointmentUrl + date);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> appointmentListJson = data['appointments'];
      return appointmentListJson
          .map((json) => Appointments.fromJson(json))
          .toList();
    } else {
      throw Exception(
        'Failed to load appointments. Status code: ${response.statusCode}',
      );
    }
  }

  Future<List<Appointments>> GetSummary(String accessToken, String date) async {
    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }

    final uri = Uri.parse(ApiConfig.getSummaryApointmentUrl + date);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> appointmentListJson = data['appointments'];
      return appointmentListJson
          .map((json) => Appointments.fromJson(json))
          .toList();
    } else {
      throw Exception(
        'Failed to load appointments. Status code: ${response.statusCode}',
      );
    }
  }

  Future<String> Delete(String accessToken, String guid) async {
    if (accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.deleteAppointmentUrl + guid),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: "",
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data.toString();
      } else {
        throw Exception(
          'Failed to load appointments. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to load appointments. Status code:');
    }
  }
}
