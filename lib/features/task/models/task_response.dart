import 'package:wfs/features/task/models/task.dart';

class TaskResponse {
  final bool success;
  final String message;
  final String? taskID;
  final Task? task;
  final bool isClientVisit;

  const TaskResponse({
    required this.success,
    this.message = '',
    this.taskID,
    this.task,
    this.isClientVisit = false,
  });

  factory TaskResponse.success({
    String? taskID,
    Task? task,
    String message = '',
    bool isClientVisit = false,
  }) {
    return TaskResponse(
      success: true,
      message: message,
      taskID: taskID ?? task?.taskID,
      task: task,
      isClientVisit: isClientVisit,
    );
  }

  factory TaskResponse.failure(String message) {
    return TaskResponse(success: false, message: message);
  }

  factory TaskResponse.fromJson(Map<String, dynamic> json) {
    final taskJson = json['task'] ?? json['Task'];
    final task = taskJson is Map<String, dynamic>
        ? Task.fromJson(taskJson)
        : null;
    final status = json['status'] ?? json['success'];
    final success = status is bool
        ? status
        : status.toString().toLowerCase() == 'success';
    final clientVisit = json['IsClientVisit'] ?? json['isClientVisit'];

    return TaskResponse(
      success: success,
      message: (json['message'] ?? '').toString(),
      taskID:
          (json['id'] ??
                  json['ID'] ??
                  json['TaskID'] ??
                  json['taskID'] ??
                  task?.taskID)
              ?.toString(),
      task: task,
      isClientVisit: clientVisit is bool
          ? clientVisit
          : clientVisit.toString().toLowerCase() == 'true',
    );
  }
}
