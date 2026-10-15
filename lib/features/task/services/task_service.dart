import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wfs/core/http/api_client.dart';
import 'package:wfs/features/task/models/task.dart' hide AppointmentType;
import 'package:wfs/features/task/models/task_appointment_type.dart';
import 'package:wfs/features/task/models/task_purpose.dart';
import 'package:wfs/features/task/models/task_response.dart';
import 'package:wfs/providers/auth_provider.dart';

class TaskService {
  static const _databaseName = 'wfs_tasks.db';
  static const _databaseVersion = 1;
  static const _taskTable = 'tasks';

  Database? _database;
  final apiClient = ApiClient('https://sfe-api.appnormalthink.com');

  Future<Database> get _db async {
    final existing = _database;
    if (existing != null) return existing;

    final databasePath = await getDatabasesPath();
    final path = '$databasePath/$_databaseName';

    _database = await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_taskTable (
        TaskID TEXT PRIMARY KEY,
        TaskType TEXT NOT NULL,
        Title TEXT NOT NULL,
        Details TEXT,
        Status TEXT NOT NULL,
        ScheduledDate TEXT NOT NULL,
        CreatedAt TEXT NOT NULL,
        UpdatedAt TEXT NOT NULL,
        CreatedBy TEXT,
        ModifiedBy TEXT
      )
    ''');
  }

  Future<TaskResponse> createTask(Ref ref, Task task) async {
    final accessToken = ref.read(authProvider).accessToken;

    return await apiClient.post(
      path: "/task",
      body: task.toCreate(),
      decode: (json) {
        final map = json as Map<String, dynamic>;
        return TaskResponse.fromJson(map);
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );
  }

  Future<List<Task>> fetchTasks(Ref ref, {required DateTime dateFrom, required DateTime dateTo}) async {
    final accessToken = ref.read(authProvider).accessToken;

    return apiClient.getOnly(
      path: '/task',
      query: {'date_from': _formatApiDate(dateFrom), 'Page': '1', 'PageSize': '300'},
      headers: {'Authorization': 'Bearer $accessToken'},
      decode: (json) {
        final map = json as Map<String, dynamic>;
        final rows = map['rows'] as List? ?? const [];
        return Task.listFromJson(rows);
      },
    );
  }

  Future<List<TaskAppointmentType>> fetchTaskTypes(Ref ref) async {
    final accessToken = ref.read(authProvider).accessToken;

    return apiClient.get(
      path: '/task/type/?IsActive=true',
      headers: {'Authorization': 'Bearer $accessToken'},
      decode: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['appointment_types'] as List? ?? const [];
        return TaskAppointmentType.listFromJson(list);
      },
    );
  }

  Future<List<TaskPurpose>> fetchTaskPurposes(Ref ref) async {
    final accessToken = ref.read(authProvider).accessToken;

    return apiClient.get(
      path: '/task_purpose/?IsActive=true',
      headers: {'Authorization': 'Bearer $accessToken'},
      decode: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['purpose_types'] as List? ?? const [];
        return TaskPurpose.listFromJson(list);
      },
    );
  }

  String _formatApiDate(DateTime value) {
    String twoDigits(int number) => number.toString().padLeft(2, '0');

    return '${value.year.toString().padLeft(4, '0')}-'
        '${twoDigits(value.month)}-'
        '${twoDigits(value.day)}';
  }

  Future<Task> getById(Ref ref, String taskID) async {
    final accessToken = ref.read(authProvider).accessToken;

    return apiClient.getOnly(
      path: '/task/id/${Uri.encodeComponent(taskID)}',
      headers: {'Authorization': 'Bearer $accessToken'},
      decode: (json) {
        final response = json as Map<String, dynamic>;
        final data = response['task'] ?? response['Task'] ?? response['tasks'] ?? response['rows'] ?? response['data'];

        if (data is List && data.isNotEmpty && data.first is Map) {
          return Task.fromJson(Map<String, dynamic>.from(data.first as Map));
        }
        if (data is Map) {
          return Task.fromJson(Map<String, dynamic>.from(data));
        }

        // Some API versions return the task object directly.
        if (response.containsKey('TaskID') || response.containsKey('AppointmentID')) {
          return Task.fromJson(response);
        }
        throw const FormatException('Task was not included in the response');
      },
    );
  }

  Future<bool> updateTask(Ref ref, Task task) async {
    final accessToken = ref.read(authProvider).accessToken;

    return await apiClient.put(path: "/task/${task.taskID.toString()}", body: task.toCreate(), headers: {"Authorization": "Bearer $accessToken"});
  }

  Future<bool> updateTaskStatus({required Ref ref, required String taskID, required String appointmentStatusID, String? cancelNoted}) async {
    final accessToken = ref.read(authProvider).accessToken;
    final path = Uri(path: '/task/update_status', queryParameters: {'TaskID': taskID, 'AppointmentStatusID': appointmentStatusID, 'CancelNoted': cancelNoted ?? ''}).toString();

    return apiClient.post(
      path: path,
      body: const {},
      decode: (json) {
        final map = json as Map<String, dynamic>;
        return (map['status'] as String?)?.toLowerCase() == 'success';
      },
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }

  Future<bool> deleteTask(String taskID, Ref ref) async {
    final accessToken = ref.read(authProvider).accessToken;

    return await apiClient.delete(path: "/task/${taskID.toString()}", headers: {"Authorization": "Bearer $accessToken"});
  }
}
