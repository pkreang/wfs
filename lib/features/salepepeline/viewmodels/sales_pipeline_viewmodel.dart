import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/lead/models/lead.dart';
import 'package:wfs/features/lead/services/lead_service.dart';
import 'package:wfs/features/phase3/lead_workflow/models/lead_workflow_stage_model.dart';
import 'package:wfs/features/phase3/lead_workflow/services/lead_workflow_service.dart';

@immutable
class SalesPipelineSummary {
  final int totalDeals;
  final double totalBudget;
  final int openDeals;
  final int closedDeals;
  final double averageCloseProbability;

  const SalesPipelineSummary({this.totalDeals = 0, this.totalBudget = 0, this.openDeals = 0, this.closedDeals = 0, this.averageCloseProbability = 0});
}

@immutable
class SalesPipelineState {
  final AsyncValue<List<Lead>> leads;
  final List<LeadWorkflowStageModel> stages;
  final Map<String, List<Lead>> groupedLeads;
  final SalesPipelineSummary summary;
  final bool isUpdating;
  final String? errorMessage;

  const SalesPipelineState({required this.leads, required this.stages, this.groupedLeads = const {}, this.summary = const SalesPipelineSummary(), this.isUpdating = false, this.errorMessage});

  SalesPipelineState copyWith({
    AsyncValue<List<Lead>>? leads,
    List<LeadWorkflowStageModel>? stages,
    Map<String, List<Lead>>? groupedLeads,
    SalesPipelineSummary? summary,
    bool? isUpdating,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return SalesPipelineState(
      leads: leads ?? this.leads,
      stages: stages ?? this.stages,
      groupedLeads: groupedLeads ?? this.groupedLeads,
      summary: summary ?? this.summary,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class SalesPipelineViewModel extends StateNotifier<SalesPipelineState> {
  SalesPipelineViewModel(this.ref, {required this.service, required this.workflowService}) : super(const SalesPipelineState(leads: AsyncValue.loading(), stages: [])) {
    fetch();
  }

  final Ref ref;
  final LeadService service;
  final LeadWorkflowService workflowService;

  Future<void> fetch() async {
    state = state.copyWith(leads: const AsyncValue.loading(), clearErrorMessage: true);
    final result = await AsyncValue.guard(() => service.fetchLeads(ref));
    final workflowResult = await AsyncValue.guard(() => workflowService.getDefaultWorkflow(ref));

    if (workflowResult.hasError) {
      state = state.copyWith(leads: AsyncValue.error(workflowResult.error!, workflowResult.stackTrace!));
      return;
    }

    final stages = (workflowResult.value?.stages ?? const <LeadWorkflowStageModel>[]).where((stage) => stage.isActive).toList();

    result.when(
      data: (leads) {
        final groupedLeads = _groupByStage(leads, stages);
        state = state.copyWith(leads: AsyncValue.data(leads), stages: stages, groupedLeads: groupedLeads, summary: _buildSummary(leads, stages));
      },
      error: (error, stack) => state = state.copyWith(leads: AsyncValue.error(error, stack)),
      loading: () {},
    );
  }

  Future<bool> moveLeadToStage(Lead lead, LeadWorkflowStageModel stage, {String? closeLostReason, int? closeProbability}) async {
    print('moveLeadToStage');
    final leadID = lead.leadID;
    if (leadID == null || leadID.isEmpty) return false;
    final targetStageId = _stageIdFor(stage);
    final targetStageName = stage.displayName;
    if (targetStageId.isEmpty) return false;
    if (_stageIdForLead(lead) == targetStageId) return true;

    final currentLeads = state.leads.value ?? const <Lead>[];
    final updatedLead = lead.copyWith(pipelineStageID: targetStageId, leadStatusID: targetStageId, leadStatus: targetStageName, leadStatusName: targetStageName, closeLostReason: closeLostReason);

    final updatedLeads = currentLeads.map((item) => item.leadID == leadID ? updatedLead : item).toList();

    final groupedLeads = _groupByStage(updatedLeads, state.stages);

    state = state.copyWith(leads: AsyncValue.data(updatedLeads), groupedLeads: groupedLeads, summary: _buildSummary(updatedLeads, state.stages), isUpdating: true, clearErrorMessage: true);

    try {
      final leadToPersist = await service.getById(ref, leadID);
      final result = await service.updateLead(
        ref: ref,
        lead: leadToPersist.copyWith(
          pipelineStageID: targetStageId,
          leadStatusID: targetStageId,
          leadStatus: targetStageName,
          leadStatusName: targetStageName,
          closeLostReason: closeLostReason,
          closeProbability: closeProbability ?? leadToPersist.closeProbability,
        ),
      );
      if (result) {
        ref.invalidate(leadListProvider);
        // ref.invalidate(salesPipelineProvider);
        ref.invalidate(leadDetailProvider(leadID));
        ref.invalidate(salesConversionFunnelProvider);
        return true;
      }

      _restoreLeads(currentLeads, errorMessage: 'Unable to update lead status');
      return false;
    } catch (e) {
      _restoreLeads(currentLeads, errorMessage: 'Unable to update lead status');
      return false;
    } finally {
      state = state.copyWith(isUpdating: false);
    }
  }

  Future<bool> unQualify(Lead lead, String note) async {
    if ((lead.leadID ?? '').isEmpty) return false;
    final currentLeads = state.leads.value ?? const <Lead>[];

    try {
      final result = await service.unQualify(lead.leadID!, note, ref);
      if (result) {
        ref.invalidate(leadListProvider);
        // ref.invalidate(salesPipelineProvider);
        ref.invalidate(leadDetailProvider(lead.leadID!));
        ref.invalidate(salesConversionFunnelProvider);
        return true;
      }

      _restoreLeads(currentLeads, errorMessage: 'Unable to update lead status');
      return false;
    } catch (e) {
      _restoreLeads(currentLeads, errorMessage: 'Unable to update lead status');
      return false;
    } finally {
      state = state.copyWith(isUpdating: false);
    }
  }

  Map<String, List<Lead>> _groupByStage(List<Lead> leads, List<LeadWorkflowStageModel> stages) {
    final groups = {for (final stage in stages.where((stage) => stage.isActive)) _stageIdFor(stage): <Lead>[]};

    for (final lead in leads) {
      final stageId = _stageIdForLead(lead, stages: stages);
      groups[stageId]?.add(lead);
    }

    return groups;
  }

  SalesPipelineSummary _buildSummary(List<Lead> leads, List<LeadWorkflowStageModel> stages) {
    final stageById = {for (final stage in stages) _stageIdFor(stage): stage};
    final totalBudget = leads.fold<double>(0, (sum, lead) => sum + (lead.budget ?? 0));
    final probabilityValues = leads.map((lead) => lead.closeProbability).whereType<int>().toList();
    final averageProbability = probabilityValues.isEmpty ? 0.0 : probabilityValues.reduce((a, b) => a + b) / probabilityValues.length;
    final closedDeals = leads.where((lead) => stageById[_stageIdForLead(lead, stages: stages)]?.systemStage == SystemLeadStage.closed).length;

    return SalesPipelineSummary(totalDeals: leads.length, totalBudget: totalBudget, openDeals: leads.length - closedDeals, closedDeals: closedDeals, averageCloseProbability: averageProbability);
  }

  String _stageIdForLead(Lead lead, {List<LeadWorkflowStageModel>? stages}) {
    final availableStages = stages ?? state.stages;
    final pipelineStageID = (lead.pipelineStageID ?? '').trim();
    final statusID = (lead.leadStatusID ?? '').trim();
    final statusName = (lead.leadStatusName ?? lead.leadStatus ?? '').trim();
    final stageIds = availableStages.map(_stageIdFor).toSet();
    final stageNames = availableStages.map((stage) => stage.displayName.trim()).toSet();

    if (stageIds.contains(pipelineStageID)) return pipelineStageID;
    if (stageIds.contains(statusID)) return statusID;
    if (stageNames.contains(statusName)) {
      return _stageIdFor(availableStages.firstWhere((stage) => stage.displayName.trim() == statusName));
    }
    if (pipelineStageID.isNotEmpty) return pipelineStageID;
    return availableStages.isEmpty ? statusID : _stageIdFor(availableStages.first);
  }

  String _stageIdFor(LeadWorkflowStageModel stage) {
    final stageId = stage.stageId.trim();
    if (stageId.isNotEmpty) return stageId;
    return stage.id.toString();
  }

  void _restoreLeads(List<Lead> leads, {required String errorMessage}) {
    state = state.copyWith(leads: AsyncValue.data(leads), groupedLeads: _groupByStage(leads, state.stages), summary: _buildSummary(leads, state.stages), errorMessage: errorMessage);
  }
}
