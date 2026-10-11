import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/features/survey/models/survey_model.dart';
import 'package:wfs/features/survey/models/survey_question_type_model.dart';
import 'package:wfs/features/survey/services/survey_service.dart';

@immutable
class SurveyListState {
  final AsyncValue<List<Survey>> surveys;
  final AsyncValue<List<SurveyQuestionType>> questionTypes;
  final String searchQuery;
  final bool? isActive;

  const SurveyListState({required this.surveys, required this.questionTypes, this.searchQuery = '', this.isActive});

  SurveyListState copyWith({
    AsyncValue<List<Survey>>? surveys,
    AsyncValue<List<SurveyQuestionType>>? questionTypes,
    String? searchQuery,
    bool? isActive,
    bool clearIsActive = false,
  }) {
    return SurveyListState(
      surveys: surveys ?? this.surveys,
      questionTypes: questionTypes ?? this.questionTypes,
      searchQuery: searchQuery ?? this.searchQuery,
      isActive: clearIsActive ? null : (isActive ?? this.isActive),
    );
  }
}

class SurveyListViewModel extends StateNotifier<SurveyListState> {
  SurveyListViewModel(this.ref, {required this.service}) : super(const SurveyListState(surveys: AsyncValue.loading(), questionTypes: AsyncValue.loading())) {
    fetch();
    getQuestionTypes();
  }

  final Ref ref;
  final SurveyService service;
  int _requestId = 0;
  bool _isFetchingQuestionTypes = false;

  Future<void> setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query.trim());
    return fetch();
  }

  Future<void> setStatusFilter(bool? isActive) {
    state = state.copyWith(isActive: isActive, clearIsActive: isActive == null);
    return fetch();
  }

  Future<void> fetch() async {
    if (!mounted) return;
    final requestId = ++_requestId;
    final searchQuery = state.searchQuery;
    final isActive = state.isActive;
    state = state.copyWith(surveys: const AsyncValue.loading());

    final surveys = await AsyncValue.guard(() => service.fetchSurveys(ref, sText: searchQuery, isActive: isActive));
    if (!mounted || requestId != _requestId) return;
    state = state.copyWith(surveys: surveys);
  }

  Future<void> getQuestionTypes() async {
    if (_isFetchingQuestionTypes) return;
    _isFetchingQuestionTypes = true;

    try {
      final questionTypes = await AsyncValue.guard(() => service.getQuestionTypes(ref));
      if (!mounted) return;
      state = state.copyWith(questionTypes: questionTypes);
    } finally {
      _isFetchingQuestionTypes = false;
    }
  }

  String surveyLink(String refCode) => service.surveyLink(refCode);
}
