import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeadFilterState {
  const LeadFilterState({this.startDate, this.endDate, this.status = 'all', required this.initialFilter, this.searchedFilter, this.isSearch = false});

  /// Values being edited in the filter sheet.
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;

  /// Lead results continue to use this until Search is pressed.
  final LeadSearchFilter initialFilter;
  final LeadSearchFilter? searchedFilter;
  final bool isSearch;

  LeadSearchFilter get activeFilter => isSearch ? searchedFilter! : initialFilter;
}

class LeadSearchFilter {
  const LeadSearchFilter({this.startDate, this.endDate, this.status = 'all'});

  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
}

class LeadFilterNotifier extends StateNotifier<LeadFilterState> {
  LeadFilterNotifier() : super(_initialState());

  static LeadFilterState _initialState() {
    return const LeadFilterState(initialFilter: LeadSearchFilter());
  }

  void setStartDate(DateTime date) {
    state = LeadFilterState(startDate: date, endDate: state.endDate, status: state.status, initialFilter: state.initialFilter, searchedFilter: state.searchedFilter, isSearch: state.isSearch);
  }

  void setEndDate(DateTime? date) {
    state = LeadFilterState(startDate: state.startDate, endDate: date, status: state.status, initialFilter: state.initialFilter, searchedFilter: state.searchedFilter, isSearch: state.isSearch);
  }

  void setStatus(String status) {
    state = LeadFilterState(startDate: state.startDate, endDate: state.endDate, status: status, initialFilter: state.initialFilter, searchedFilter: state.searchedFilter, isSearch: state.isSearch);
  }

  void applyDashboardFilter({DateTime? startDate, DateTime? endDate, required String status}) {
    state = LeadFilterState(
      startDate: startDate,
      endDate: endDate,
      status: status,
      initialFilter: state.initialFilter,
      searchedFilter: LeadSearchFilter(startDate: startDate, endDate: endDate, status: status),
      isSearch: true,
    );
  }

  void search() {
    state = LeadFilterState(
      startDate: state.startDate,
      endDate: state.endDate,
      status: state.status,
      initialFilter: state.initialFilter,
      searchedFilter: LeadSearchFilter(startDate: state.startDate, endDate: state.endDate, status: state.status),
      isSearch: true,
    );
  }

  /// Reset only the values being edited; it must not change lead results.
  void reset() {
    final initial = _initialState();
    state = LeadFilterState(startDate: initial.startDate, status: initial.status, initialFilter: state.initialFilter, searchedFilter: state.searchedFilter, isSearch: state.isSearch);
  }

  /// Discard unsearched edits when the filter sheet is closed.
  void discardChanges() {
    final active = state.activeFilter;
    state = LeadFilterState(
      startDate: active.startDate,
      endDate: active.endDate,
      status: active.status,
      initialFilter: state.initialFilter,
      searchedFilter: state.searchedFilter,
      isSearch: state.isSearch,
    );
  }
}

final leadFilterProvider = StateNotifierProvider<LeadFilterNotifier, LeadFilterState>((ref) {
  return LeadFilterNotifier();
});

/// Only changes after Search is pressed. Lead widgets should watch this,
/// while the filter sheet watches [leadFilterProvider] for draft values.
final leadAppliedFilterProvider = Provider<LeadSearchFilter>((ref) {
  final filter = ref.watch(leadFilterProvider);
  return filter.activeFilter;
});
