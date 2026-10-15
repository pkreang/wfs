import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/task/models/task.dart';
import 'package:wfs/features/task/models/task_type.dart';
import 'package:wfs/features/task/services/task_service.dart';
import 'package:wfs/features/task/viewmodels/task_detail_viewmodel.dart';

void main() {
  test('discards edits on exit while detail stays open', () async {
    final service = _TaskService();
    final container = ProviderContainer(overrides: [taskServiceProvider.overrideWithValue(service)]);
    addTearDown(container.dispose);
    final detail = taskDetailProvider('task-id');
    final edit = taskEditProvider('task-id');
    container.listen(detail, (_, _) {});
    await _waitForTask(container, detail);
    final subscription = container.listen(edit, (_, _) {});
    await _waitForTask(container, edit);

    final notifier = container.read(edit.notifier);
    notifier.setTitle('Unsaved title');
    notifier.setMobile('999');
    notifier.setScheduledStartDate(DateTime(2026, 10, 16, 14));

    expect(container.read(edit).task.requireValue.title, 'Unsaved title');
    expect(container.read(detail).task.requireValue.title, 'Saved title');
    expect(container.read(detail).task.requireValue.phone, '123');
    expect(container.read(detail).task.requireValue.scheduledStartDate, service.task.scheduledStartDate);

    subscription.close();
    await container.pump();
    container.listen(edit, (_, _) {});
    final reopened = await _waitForTask(container, edit);
    expect(reopened.title, 'Saved title');
    expect(reopened.phone, '123');
    expect(reopened.scheduledStartDate, service.task.scheduledStartDate);
    expect(service.fetchCount, 3);
  });
}

Future<Task> _waitForTask(ProviderContainer container, ProviderListenable<TaskDetailState> provider) async {
  final loaded = Completer<Task>();
  final subscription = container.listen(provider, (_, next) {
    if (next.task.hasValue && !loaded.isCompleted) {
      loaded.complete(next.task.requireValue);
    }
  }, fireImmediately: true);
  try {
    return await loaded.future.timeout(const Duration(seconds: 5));
  } finally {
    subscription.close();
  }
}

class _TaskService extends TaskService {
  int fetchCount = 0;
  final task = Task(taskID: 'task-id', taskType: TaskType.call, title: 'Saved title', phone: '123', scheduledStartDate: DateTime(2026, 10, 15, 10), scheduledEndDate: DateTime(2026, 10, 15, 11));

  @override
  Future<Task> getById(Ref ref, String taskID) async {
    fetchCount++;
    return task;
  }
}
