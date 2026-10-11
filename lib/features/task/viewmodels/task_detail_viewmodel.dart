import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/core/http/api_client.dart';
import 'package:wfs/features/appointment/models/address.dart';
import 'package:wfs/features/appointment/models/purpose.dart';
import 'package:wfs/features/client/models/client.dart';
import 'package:wfs/features/company/models/company.dart';
import 'package:wfs/features/task/models/task.dart' hide AppointmentType;
import 'package:wfs/features/task/models/task_appointment_type.dart';
import 'package:wfs/features/task/models/task_type.dart';
import 'package:wfs/features/task/services/task_service.dart';

@immutable
class TaskDetailState {
  final AsyncValue<Task> task;
  final bool isLoading;
  final String? errorMessage;

  const TaskDetailState({
    required this.task,
    this.isLoading = false,
    this.errorMessage,
  });

  TaskDetailState copyWith({
    AsyncValue<Task>? task,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return TaskDetailState(
      task: task ?? this.task,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}

class TaskDetailViewModel extends StateNotifier<TaskDetailState> {
  TaskDetailViewModel(this.ref, this.id)
    : super(const TaskDetailState(task: AsyncValue.loading())) {
    fetch();
  }

  final Ref ref;
  final String id;

  TaskService get _taskService => ref.read(taskServiceProvider);

  Future<void> fetch() async {
    state = state.copyWith(task: const AsyncLoading(), clearErrorMessage: true);

    final taskAsync = await AsyncValue.guard(
      () => _taskService.getById(ref, id),
    );
    state = state.copyWith(task: taskAsync);
  }

  void setTaskType(TaskType value) {
    _set((task) => task.copyWith(taskType: value));
  }

  void setAppointmentType(TaskAppointmentType value) {
    _set(
      (task) => task.copyWith(
        appointmentTypeID: value.appointmentTypeID,
        appointmentTypeName: value.appointmentTypeName,
      ),
    );
  }

  void setTitle(String value) {
    _set((task) => task.copyWith(title: value));
  }

  void setDetails(String value) {
    _set((task) => task.copyWith(details: value));
  }

  void setScheduledStartDate(DateTime value) {
    _set((task) => task.copyWith(scheduledStartDate: value));
  }

  void setScheduledEndDate(DateTime value) {
    _set((task) => task.copyWith(scheduledEndDate: value));
  }

  void setPurpose(Purpose value) {
    _set(
      (task) => task.copyWith(
        purposeID: value.purposeTypeID,
        purposeName: value.purposeTypeName,
      ),
    );
  }

  void setPurposeOther(String value) {
    _set((task) => task.copyWith(purposeOther: value));
  }

  void setMobile(String value) {
    _set((task) => task.copyWith(phone: value));
  }

  void setEmail(String value) {
    _set((task) => task.copyWith(email: value));
  }

  void setAddress({required Address address}) {
    _set((task) => task.copyWith(taskAddress: address));
  }

  void setClient(Client client) {
    _set(
      (task) => task.copyWith(
        clientID: client.clientID,
        clientName: '${client.firstName ?? ''} ${client.lastName ?? ''}'.trim(),
        companyID: '',
        companyName: '',
      ),
    );
  }

  void setCompany(Company company) {
    _set(
      (task) => task.copyWith(
        companyID: company.companyID ?? '',
        companyName: company.companyName ?? '',
      ),
    );
  }

  void removeCompany() {
    _set((task) => task.copyWith(companyID: '', companyName: ''));
  }

  void _set(Task Function(Task) update) {
    state = state.copyWith(
      task: state.task.whenData(update),
      clearErrorMessage: true,
    );
  }

  Future<bool> updateTask() async {
    final task = state.task.value;
    if (task == null) return false;

    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final response = await _taskService.updateTask(ref, task);
      if (response) {
        ref.invalidate(taskListProvider);
      }

      return response;
    } catch (e) {
      state = state.copyWith(
        errorMessage: e is ApiException ? e.message : 'Request failed',
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }

    return false;
  }

  Future<bool> updateTaskStatus({
    required String appointmentStatusID,
    String? cancelNoted,
  }) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final result = await _taskService.updateTaskStatus(
        ref: ref,
        taskID: id,
        appointmentStatusID: appointmentStatusID,
        cancelNoted: cancelNoted,
      );
      if (result) {
        state = state.copyWith(
          task: state.task.whenData(
            (task) => task.copyWith(
              appointmentStatusID: appointmentStatusID,
              cancelNoted: cancelNoted,
            ),
          ),
        );
        ref.invalidate(taskListProvider);
        ref.invalidate(taskDetailProvider);
      }

      return result;
    } catch (e) {
      state = state.copyWith(
        errorMessage: e is ApiException ? e.message : 'Request failed',
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }

    return false;
  }

  Future<bool> deleteTask() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final result = await _taskService.deleteTask(id, ref);
      if (result) ref.invalidate(taskListProvider);
      return result;
    } catch (e) {
      state = state.copyWith(
        errorMessage: e is ApiException ? e.message : 'Request failed',
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }

    return false;
  }
}
