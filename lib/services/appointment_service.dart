import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wfs/config/api_config.dart';
import '../models/appointment_model.dart'; // Import model ที่เราสร้างขึ้น

class AppointmentService {



  Future<List<Appointment>> fetchAppointments(String accessToken,String userID) async {
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
      
      return appointmentListJson.map((json) => Appointment.fromJson(json)).toList();
    } else {
      // ถ้า request ไม่สำเร็จ ให้โยน Error
      throw Exception('Failed to load appointments. Status code: ${response.statusCode}');
    }
  }
}