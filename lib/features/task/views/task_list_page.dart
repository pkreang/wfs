import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/task/views/task_create_page.dart';
import 'package:wfs/features/task/views/task_detail_page.dart';
import 'package:wfs/features/task/widgets/task_info.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';

class TaskScreen extends ConsumerWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(taskListProvider);
    final notifier = ref.read(taskListProvider.notifier);
    final countText = state.tasks.when(data: (tasks) => '${tasks.length} Entry', loading: () => 'Loading...', error: (_, _) => 'Error');

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leadingWidth: 98,
        leading: GestureDetector(
          onTap: () async {
            await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const TaskCreatePage(clientType: ''), fullscreenDialog: true));
            if (!context.mounted) return;
            await ref.read(taskListProvider.notifier).fetch();
          },
          child: Row(
            children: [
              IconButton(
                icon: Row(
                  children: [
                    const Icon(Icons.add),
                    AppText(label: 'Create', textColor: AppUtility.colorPrimary, fontSize: 17, fontWeight: FontWeight.w500),
                  ],
                ),
                onPressed: null,
                style: ButtonStyle(iconColor: WidgetStateProperty.all(AppUtility.colorPrimary)),
              ),
            ],
          ),
        ),
        title: Column(
          children: [
            const AppText(label: 'Task', fontSize: 17, fontWeight: FontWeight.w600),
            AppText(label: countText, fontSize: 12, textColor: Colors.grey),
          ],
        ),
        shape: const Border(bottom: BorderSide(color: Color.fromRGBO(60, 60, 67, 0.36), width: 0.5)),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppUtility.colorPrimary,
          onRefresh: notifier.fetch,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              state.markedDates.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 72),
                  child: Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary)),
                ),
                error: (_, _) => _TaskCalendar(
                  markedDates: const {},
                  displayedMonth: state.displayedMonth,
                  selectedDate: state.selectedDate,
                  onPreviousMonth: notifier.previousMonth,
                  onNextMonth: notifier.nextMonth,
                  onSelectDate: notifier.selectDate,
                ),
                data: (markedDates) => _TaskCalendar(
                  markedDates: markedDates,
                  displayedMonth: state.displayedMonth,
                  selectedDate: state.selectedDate,
                  onPreviousMonth: notifier.previousMonth,
                  onNextMonth: notifier.nextMonth,
                  onSelectDate: notifier.selectDate,
                ),
              ),
              const SizedBox(height: 24),
              state.tasks.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary)),
                ),
                error: (_, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Column(
                      children: [
                        const AppText(label: 'No tasks found.'),
                        TextButton(
                          onPressed: notifier.fetchTasksForSelectedDate,
                          child: const AppText(label: 'Retry', textColor: AppUtility.colorPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (tasks) {
                  if (tasks.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: AppText(label: 'No tasks found.')),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskInfo(
                        task: task,
                        onTap: () async {
                          await Navigator.of(context).push(MaterialPageRoute(builder: (context) => TaskDetailPage(taskID: task.taskID ?? '')));
                          if (!context.mounted) return;
                          await ref.read(taskListProvider.notifier).fetch();
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskCalendar extends StatelessWidget {
  final Map<String, bool> markedDates;
  final DateTime displayedMonth;
  final DateTime selectedDate;
  final Future<void> Function() onPreviousMonth;
  final Future<void> Function() onNextMonth;
  final Future<void> Function(DateTime date) onSelectDate;

  const _TaskCalendar({required this.markedDates, required this.displayedMonth, required this.selectedDate, required this.onPreviousMonth, required this.onNextMonth, required this.onSelectDate});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
                onPressed: onPreviousMonth,
              ),
              AppText(label: DateFormat('MMMM yyyy').format(displayedMonth), fontSize: 18, fontWeight: FontWeight.bold),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 20),
                onPressed: onNextMonth,
              ),
            ],
          ),
        ),
        const _TaskWeekdays(),
        _TaskDaysGrid(markedDates: markedDates, displayedMonth: displayedMonth, selectedDate: selectedDate, onSelectDate: onSelectDate),
      ],
    );
  }
}

class _TaskWeekdays extends StatelessWidget {
  const _TaskWeekdays();

  @override
  Widget build(BuildContext context) {
    const weekdays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekdays.map((day) => AppText(label: day, fontSize: 12, textColor: Colors.grey)).toList(),
      ),
    );
  }
}

class _TaskDaysGrid extends StatelessWidget {
  final Map<String, bool> markedDates;
  final DateTime displayedMonth;
  final DateTime selectedDate;
  final Future<void> Function(DateTime date) onSelectDate;

  const _TaskDaysGrid({required this.markedDates, required this.displayedMonth, required this.selectedDate, required this.onSelectDate});

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(displayedMonth.year, displayedMonth.month + 1, 0).day;
    final firstWeekday = DateTime(displayedMonth.year, displayedMonth.month).weekday;
    final startOffset = firstWeekday == DateTime.sunday ? 0 : firstWeekday;
    final itemCount = startOffset + daysInMonth;

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1.6),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            if (index < startOffset) return const SizedBox.shrink();

            final dayNumber = index - startOffset + 1;
            final date = DateTime(displayedMonth.year, displayedMonth.month, dayNumber);
            final isSelected = _isSameDay(date, selectedDate);
            final hasTask = markedDates[_dateKey(date)] ?? false;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelectDate(date),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: isSelected ? const Color.fromRGBO(0, 0, 0, 0.12) : Colors.transparent, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: AppText(label: '$dayNumber', textColor: Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                  ),
                  if (hasTask) const Positioned(top: 31, child: Icon(Icons.circle, size: 8, color: AppUtility.colorPrimary)),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        const Divider(height: 0.5, thickness: 0.5, color: Color.fromRGBO(60, 60, 67, 0.36)),
      ],
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

String _dateKey(DateTime date) {
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${date.year.toString().padLeft(4, '0')}-'
      '${twoDigits(date.month)}-'
      '${twoDigits(date.day)}';
}
