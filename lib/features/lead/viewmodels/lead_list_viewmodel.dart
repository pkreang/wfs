import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wfs/features/lead/models/lead.dart';
import 'package:wfs/features/lead/services/lead_service.dart';
import 'package:wfs/providers/lead_filter_provider.dart';

@immutable
class LeadListState {
  final AsyncValue<List<Lead>> leads;
  final Map<String, List<Lead>> sections;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;

  const LeadListState({
    required this.leads,
    this.sections = const {},
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
  });

  LeadListState copyWith({
    AsyncValue<List<Lead>>? leads,
    Map<String, List<Lead>>? sections,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    bool clearErrorMessage = false,
  }) {
    return LeadListState(
      leads: leads ?? this.leads,
      sections: sections ?? this.sections,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class LeadListViewModel extends StateNotifier<LeadListState> {
  LeadListViewModel(this.ref, {required this.service})
    : super(const LeadListState(leads: AsyncValue.loading())) {
    fetch();
  }

  final Ref ref;
  final LeadService service;
  bool _isFetching = false;
  List<Lead> _allLeads = const [];

  Future<void> fetch() async {
    if (_isFetching) return;
    _isFetching = true;

    final leadFilter = ref.read(leadAppliedFilterProvider);
    final pipelineStatus = {'Active', 'Win', 'Lose'}.contains(leadFilter.status)
        ? leadFilter.status
        : null;
    final stage = leadFilter.status != 'all' && pipelineStatus == null
        ? leadFilter.status
        : null;
    final leadsAsync = await AsyncValue.guard(
      () => service.fetchLeads(
        ref,
        startDate: leadFilter.startDate == null
            ? null
            : DateFormat('yyyy-MM-dd').format(leadFilter.startDate!),
        endDate: leadFilter.endDate == null
            ? null
            : DateFormat('yyyy-MM-dd').format(leadFilter.endDate!),
        // status: pipelineStatus,
        status: leadFilter.status == 'all' ? null : leadFilter.status,
      ),
    );
    leadsAsync.when(
      data: (leads) {
        _allLeads = leadFilter.status == 'UnQualify'
            ? leads.where((lead) => lead.isUnqualified == true).toList()
            : stage == null
            ? leads
            : leads
                  .where(
                    (lead) =>
                        lead.pipelineStageID == stage ||
                        lead.leadStatusName == stage,
                  )
                  .toList();
        _applyFilters();
      },
      error: (err, st) => state = state.copyWith(leads: AsyncError(err, st)),
      loading: () {},
    );

    _isFetching = false;
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void _applyFilters() {
    final search = state.searchQuery.toLowerCase().trim();
    Iterable<Lead> stream = _allLeads;

    if (search.isNotEmpty) {
      stream = stream.where((lead) {
        final fields = [
          lead.leadName,
          lead.firstName,
          lead.lastName,
          lead.contactPerson,
          lead.phone,
          lead.email,
          lead.companyName,
          lead.ownerName,
          lead.closeProbability?.toString(),
          lead.budget?.toString(),
          lead.isQualified == null
              ? null
              : (lead.isQualified == true ? 'qualified' : 'unqualified'),
          lead.source,
          lead.interest,
          // lead.statusName,
        ];
        return fields.any(
          (value) => (value ?? '').toLowerCase().contains(search),
        );
      });
    }

    final filtered = stream.toList()
      ..sort((a, b) {
        final aName = _leadSectionName(a).toLowerCase();
        final bName = _leadSectionName(b).toLowerCase();
        return aName.compareTo(bName);
      });

    final Map<String, List<Lead>> sections = {};
    for (final lead in filtered) {
      final name = _leadSectionName(lead);
      final firstChar = name[0].toUpperCase();
      sections.putIfAbsent(firstChar, () => []).add(lead);
    }

    state = state.copyWith(
      leads: AsyncValue.data(filtered),
      sections: sections,
    );
  }

  String _leadSectionName(Lead lead) {
    final leadName = (lead.leadName ?? '').trim();
    if (leadName.isNotEmpty) return leadName;

    final name = [
      lead.firstName,
      lead.lastName,
    ].where((value) => (value ?? '').trim().isNotEmpty).join(' ').trim();

    if (name.isNotEmpty) return name;
    if ((lead.companyName ?? '').trim().isNotEmpty) {
      return lead.companyName!.trim();
    }
    if ((lead.leadID ?? '').trim().isNotEmpty) return lead.leadID!.trim();
    return '#';
  }
}
