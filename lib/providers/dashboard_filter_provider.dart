import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardFilterState {
  const DashboardFilterState({required this.startDate, this.endDate, this.status = 'all', required this.initialFilter, this.searchedFilter, this.isSearch = false});

  /// Values being edited in the filter sheet.
  final DateTime startDate;
  final DateTime? endDate;
  final String status;

  /// The dashboard must continue to use this until Search is pressed.
  final DashboardSearchFilter initialFilter;
  final DashboardSearchFilter? searchedFilter;
  final bool isSearch;

  DashboardSearchFilter get activeFilter => isSearch ? searchedFilter! : initialFilter;
}

class DashboardSearchFilter {
  const DashboardSearchFilter({required this.startDate, this.endDate, this.status = 'all'});

  final DateTime startDate;
  final DateTime? endDate;
  final String status;
}

class DashboardFilterNotifier extends StateNotifier<DashboardFilterState> {
  DashboardFilterNotifier() : super(_initialState());

  static DashboardFilterState _initialState() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return DashboardFilterState(
      startDate: today,
      initialFilter: DashboardSearchFilter(startDate: today),
    );
  }

  void setStartDate(DateTime date) {
    state = DashboardFilterState(startDate: date, endDate: state.endDate, status: state.status, initialFilter: state.initialFilter, searchedFilter: state.searchedFilter, isSearch: state.isSearch);
  }

  void setEndDate(DateTime? date) {
    state = DashboardFilterState(startDate: state.startDate, endDate: date, status: state.status, initialFilter: state.initialFilter, searchedFilter: state.searchedFilter, isSearch: state.isSearch);
  }

  void setStatus(String status) {
    state = DashboardFilterState(
      startDate: state.startDate,
      endDate: state.endDate,
      status: status,
      initialFilter: state.initialFilter,
      searchedFilter: state.searchedFilter,
      isSearch: state.isSearch,
    );
  }

  void search() {
    state = DashboardFilterState(
      startDate: state.startDate,
      endDate: state.endDate,
      status: state.status,
      initialFilter: state.initialFilter,
      searchedFilter: DashboardSearchFilter(startDate: state.startDate, endDate: state.endDate, status: state.status),
      isSearch: true,
    );
  }

  /// Reset only the values being edited; it must not change dashboard results.
  void reset() {
    final initial = _initialState();
    state = DashboardFilterState(startDate: initial.startDate, status: initial.status, initialFilter: state.initialFilter, searchedFilter: state.searchedFilter, isSearch: state.isSearch);
  }

  /// Discard unsearched edits when the filter sheet is closed.
  void discardChanges() {
    final active = state.activeFilter;
    state = DashboardFilterState(
      startDate: active.startDate,
      endDate: active.endDate,
      status: active.status,
      initialFilter: state.initialFilter,
      searchedFilter: state.searchedFilter,
      isSearch: state.isSearch,
    );
  }
}

final dashboardFilterProvider = StateNotifierProvider<DashboardFilterNotifier, DashboardFilterState>((ref) {
  return DashboardFilterNotifier();
});

/// Only changes after Search is pressed. Dashboard widgets should watch this,
/// while the filter sheet watches [dashboardFilterProvider] for draft values.
final dashboardAppliedFilterProvider = Provider<DashboardSearchFilter>((ref) {
  final filter = ref.watch(dashboardFilterProvider);
  return filter.activeFilter;
});
