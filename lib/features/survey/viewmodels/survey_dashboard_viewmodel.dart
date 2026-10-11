import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/features/survey/models/survey_dashboard_analytics.dart';
import 'package:wfs/features/survey/services/survey_dashboard_service.dart';

@immutable
class SurveyDashboardState {
  final AsyncValue<SurveyDashboardAnalytics> dashboard;

  const SurveyDashboardState({required this.dashboard});

  SurveyDashboardState copyWith({
    AsyncValue<SurveyDashboardAnalytics>? dashboard,
  }) {
    return SurveyDashboardState(dashboard: dashboard ?? this.dashboard);
  }
}

class SurveyDashboardViewModel extends StateNotifier<SurveyDashboardState> {
  SurveyDashboardViewModel(this.ref, this.surveyID, {required this.service})
    : super(const SurveyDashboardState(dashboard: AsyncValue.loading())) {
    fetch();
  }

  final Ref ref;
  final String surveyID;
  final SurveyDashboardService service;
  bool _isFetching = false;

  Future<void> fetch() async {
    if (_isFetching) return;
    _isFetching = true;
    state = state.copyWith(dashboard: const AsyncValue.loading());

    try {
      final dashboard = await AsyncValue.guard(
        () => service.fetchAnalytics(ref, surveyID),
      );
      if (mounted) state = state.copyWith(dashboard: dashboard);
    } finally {
      _isFetching = false;
    }
  }
}
