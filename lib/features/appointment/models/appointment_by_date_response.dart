import 'package:wfs/features/appointment/models/appointment.dart';
import 'package:wfs/features/task/models/task.dart';

class AppointmentByDateResponse {
  final String status;
  final int page;
  final int pageSize;
  final int totalRows;
  final int totalPages;
  final List<dynamic> rows;

  const AppointmentByDateResponse({required this.status, required this.page, required this.pageSize, required this.totalRows, required this.totalPages, required this.rows});

  int get itemCount => rows.length;

  factory AppointmentByDateResponse.fromJson(Map<String, dynamic> json) {
    final rows = <dynamic>[];
    final rawRows = json['appointments'] as List? ?? const [];

    for (final rawRow in rawRows) {
      if (rawRow is! Map) continue;

      final row = Map<String, dynamic>.from(rawRow);
      final type = (row['Type'] ?? row['type'])?.toString().trim().toLowerCase();

      if (type == 'appointment') {
        rows.add(Appointment.fromJson(row));
      } else if (type == 'task') {
        rows.add(Task.fromJson(row));
      }
    }

    return AppointmentByDateResponse(
      status: (json['status'] ?? '').toString(),
      page: _parseInt(json['page'], fallback: 1),
      pageSize: _parseInt(json['page_size'], fallback: rows.length),
      totalRows: _parseInt(json['total_rows'], fallback: rows.length),
      totalPages: _parseInt(json['total_pages'], fallback: 1),
      rows: rows,
    );
  }

  AppointmentByDateResponse copyWith({String? status, int? page, int? pageSize, int? totalRows, int? totalPages, List<dynamic>? rows}) {
    return AppointmentByDateResponse(
      status: status ?? this.status,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      totalRows: totalRows ?? this.totalRows,
      totalPages: totalPages ?? this.totalPages,
      rows: rows ?? this.rows,
    );
  }
}

int _parseInt(Object? value, {required int fallback}) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
