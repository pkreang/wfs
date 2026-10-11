import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/features/task/models/task.dart';
import 'package:wfs/features/task/services/task_service.dart';

@immutable
class TaskListState {
  final AsyncValue<List<Task>> tasks;
  final AsyncValue<Map<String, bool>> markedDates;
  final String? errorMessage;
  final DateTime selectedDate;
  final DateTime displayedMonth;

  const TaskListState({
    required this.tasks,
    required this.markedDates,
    required this.selectedDate,
    required this.displayedMonth,
    this.errorMessage,
  });

  TaskListState copyWith({
    AsyncValue<List<Task>>? tasks,
    AsyncValue<Map<String, bool>>? markedDates,
    String? errorMessage,
    DateTime? selectedDate,
    DateTime? displayedMonth,
    bool clearErrorMessage = false,
  }) {
    return TaskListState(
      tasks: tasks ?? this.tasks,
      markedDates: markedDates ?? this.markedDates,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      selectedDate: selectedDate ?? this.selectedDate,
      displayedMonth: displayedMonth ?? this.displayedMonth,
    );
  }
}

class TaskListViewModel extends StateNotifier<TaskListState> {
  TaskListViewModel(this.ref, {required this.service})
    : super(
        TaskListState(
          tasks: const AsyncValue.loading(),
          markedDates: const AsyncValue.loading(),
          selectedDate: _startOfDay(DateTime.now()),
          displayedMonth: _startOfMonth(DateTime.now()),
        ),
      ) {
    fetch();
  }

  final Ref ref;
  final TaskService service;
  int _taskRequest = 0;
  int _markedDateRequest = 0;

  Future<void> fetch() async {
    await Future.wait([fetchTasksForSelectedDate(), fetchMarkedDates()]);
  }

  Future<void> fetchTasksForSelectedDate() async {
    final request = ++_taskRequest;
    final selectedDate = state.selectedDate;
    state = state.copyWith(
      tasks: const AsyncValue.loading(),
      clearErrorMessage: true,
    );

    final result = await AsyncValue.guard(
      () => service.fetchTasks(
        ref,
        dateFrom: _startOfDay(selectedDate),
        dateTo: _endOfDay(selectedDate),
      ),
    );

    if (request != _taskRequest) return;
    state = state.copyWith(
      tasks: result.whenData(
        (tasks) => _sortTasks(
          tasks
              .where((task) => _isSameDay(_taskDate(task), selectedDate))
              .toList(),
        ),
      ),
    );
  }

  Future<void> fetchMarkedDates() async {
    final request = ++_markedDateRequest;
    final displayedMonth = state.displayedMonth;
    state = state.copyWith(markedDates: const AsyncValue.loading());

    final result = await AsyncValue.guard(
      () => service.fetchTasks(
        ref,
        dateFrom: _startOfMonth(displayedMonth),
        dateTo: _endOfMonth(displayedMonth),
      ),
    );

    if (request != _markedDateRequest) return;
    state = state.copyWith(
      markedDates: result.whenData((tasks) {
        return <String, bool>{
          for (final task in tasks)
            if (_isInMonth(_taskDate(task), displayedMonth))
              _dateKey(_taskDate(task)): true,
        };
      }),
    );
  }

  Future<void> selectDate(DateTime date) async {
    final selectedDate = _startOfDay(date);
    state = state.copyWith(selectedDate: selectedDate);
    await fetchTasksForSelectedDate();
  }

  Future<void> nextMonth() => _setDisplayedMonth(
    DateTime(state.displayedMonth.year, state.displayedMonth.month + 1),
  );

  Future<void> previousMonth() => _setDisplayedMonth(
    DateTime(state.displayedMonth.year, state.displayedMonth.month - 1),
  );

  Future<void> _setDisplayedMonth(DateTime month) async {
    state = state.copyWith(displayedMonth: _startOfMonth(month));
    await fetchMarkedDates();
  }

  Future<bool> deleteTask(String taskID) async {
    try {
      final result = await service.deleteTask(taskID, ref);
      if (result) await fetch();
      return result;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Request failed');
      return false;
    }
  }

  List<Task> _sortTasks(List<Task> tasks) {
    const statusOrder = <String, int>{
      'Scheduled': 0,
      'Completed': 1,
      'Canceled': 2,
    };

    return [...tasks]..sort((a, b) {
      final statusA =
          statusOrder[(a.appointmentStatusName ?? '').trim()] ?? 999;
      final statusB =
          statusOrder[(b.appointmentStatusName ?? '').trim()] ?? 999;
      if (statusA != statusB) return statusA.compareTo(statusB);
      return _taskDate(a).compareTo(_taskDate(b));
    });
  }
}

DateTime _taskDate(Task task) =>
    (task.appointmentDateTimeFrom ?? task.scheduledStartDate).toLocal();

DateTime _startOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day);

DateTime _endOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day, 23, 59, 59);

DateTime _startOfMonth(DateTime date) => DateTime(date.year, date.month);

DateTime _endOfMonth(DateTime date) =>
    DateTime(date.year, date.month + 1, 0, 23, 59, 59);

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool _isInMonth(DateTime date, DateTime month) =>
    date.year == month.year && date.month == month.month;

String _dateKey(DateTime date) {
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${date.year.toString().padLeft(4, '0')}-'
      '${twoDigits(date.month)}-'
      '${twoDigits(date.day)}';
}
