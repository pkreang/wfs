import 'package:flutter_test/flutter_test.dart';
import 'package:wfs/features/appointment/models/appointment.dart';
import 'package:wfs/features/appointment/models/appointment_by_date_response.dart';
import 'package:wfs/features/task/models/task.dart';

void main() {
  test('parses appointments, tasks, and pagination metadata', () {
    final response = AppointmentByDateResponse.fromJson({
      'status': 'success',
      'page': 1,
      'page_size': 2,
      'total_rows': 2,
      'total_pages': 1,
      'rows': [
        {
          'Type': 'appointment',
          'AppointmentID': 'appointment-id',
          'AppointmentDateTimeFrom': '2026-09-01T02:00:00',
          'AppointmentDateTimeTo': '2026-09-01T02:50:00',
          'ClientName': 'Daiken Cool',
          'ClientPhone': '0884162467',
          'ClientEmail': 'daiken.cool@gmail.com',
          'PurposeName': 'Product Demonstration',
        },
        {
          'Type': 'task',
          'AppointmentID': 'task-id',
          'AppointmentTitle': 'Meeting',
          'AppointmentTypeName': 'Online Meeting',
          'AppointmentDateTimeFrom': '2026-09-01T03:00:00',
          'AppointmentDateTimeTo': '2026-09-01T03:50:00',
        },
      ],
    });

    expect(response.status, 'success');
    expect(response.page, 1);
    expect(response.pageSize, 2);
    expect(response.totalRows, 2);
    expect(response.totalPages, 1);
    expect(response.itemCount, 2);

    expect(response.rows.first, isA<Appointment>());
    final appointment = response.rows.first as Appointment;
    expect(appointment.type, 'appointment');
    expect(appointment.phone, '0884162467');
    expect(appointment.email, 'daiken.cool@gmail.com');
    expect(appointment.purposeTypeName, 'Product Demonstration');

    expect(response.rows.last, isA<Task>());
    final task = response.rows.last as Task;
    expect(task.type, 'task');
    expect(task.taskID, 'task-id');
    expect(task.appointmentDateTimeTo, DateTime(2026, 9, 1, 3, 50));
  });
}
