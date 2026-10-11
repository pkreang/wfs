import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeadDashboard2DatePickerState {
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime currentMonth;

  LeadDashboard2DatePickerState({this.startDate, this.endDate, required this.currentMonth});

  LeadDashboard2DatePickerState copyWith({DateTime? startDate, DateTime? endDate, DateTime? currentMonth}) {
    return LeadDashboard2DatePickerState(startDate: startDate ?? this.startDate, endDate: endDate ?? this.endDate, currentMonth: currentMonth ?? this.currentMonth);
  }
}

class LeadDashboard2DatePickerNotifier extends StateNotifier<LeadDashboard2DatePickerState> {
  LeadDashboard2DatePickerNotifier() : super(LeadDashboard2DatePickerState(currentMonth: DateTime.now()));

  void setStartDate(DateTime date) => state = state.copyWith(startDate: date);

  void setEndDate(DateTime date) => state = state.copyWith(endDate: date);

  void setCurrentMonth(DateTime month) => state = state.copyWith(currentMonth: month);

  void setDateRange(DateTime startDate, DateTime endDate) {
    state = LeadDashboard2DatePickerState(startDate: startDate, endDate: endDate, currentMonth: DateTime(startDate.year, startDate.month));
  }

  void reset() => state = LeadDashboard2DatePickerState(currentMonth: DateTime.now());
}

final leadDashboard2DatePickerProvider = StateNotifierProvider<LeadDashboard2DatePickerNotifier, LeadDashboard2DatePickerState>((ref) {
  return LeadDashboard2DatePickerNotifier();
});

final leadDashboard2SelectedDateRangeProvider = StateProvider<({DateTime? start, DateTime? end})>((ref) {
  return (start: null, end: null);
});
