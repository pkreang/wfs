import 'package:flutter_riverpod/flutter_riverpod.dart';

class DatePickerState {
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime currentMonth;

  DatePickerState({this.startDate, this.endDate, required this.currentMonth});

  DatePickerState copyWith({DateTime? startDate, DateTime? endDate, DateTime? currentMonth}) {
    return DatePickerState(startDate: startDate ?? this.startDate, endDate: endDate ?? this.endDate, currentMonth: currentMonth ?? this.currentMonth);
  }
}

class DatePickerNotifier extends StateNotifier<DatePickerState> {
  DatePickerNotifier() : super(DatePickerState(currentMonth: DateTime.now()));

  void setStartDate(DateTime date) {
    state = state.copyWith(startDate: date);
  }

  void setEndDate(DateTime? date) {
    state = state.copyWith(endDate: date);
  }

  void setCurrentMonth(DateTime month) {
    state = state.copyWith(currentMonth: month);
  }

  void reset() {
    state = DatePickerState(currentMonth: DateTime.now());
  }
}

final datePickerProvider = StateNotifierProvider<DatePickerNotifier, DatePickerState>((ref) {
  return DatePickerNotifier();
});

// เพิ่ม StateProvider สำหรับ selected date range
final selectedDateRangeProvider = StateProvider<({DateTime start, DateTime? end})>((ref) {
  final now = DateTime.now();
  return (start: DateTime(now.year, now.month, now.day), end: null);
});
