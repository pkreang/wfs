import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/core/http/api_client.dart';
import 'package:wfs/features/lead/models/lead.dart';
import 'package:wfs/features/lead/models/lead_history.dart';
import 'package:wfs/features/lead/services/lead_service.dart';
import 'package:wfs/features/phase3/lead_workflow/models/lead_workflow_stage_model.dart';
import 'package:wfs/features/phase3/lead_workflow/services/lead_workflow_service.dart';

@immutable
class LeadDetailState {
  final AsyncValue<Lead> lead;
  final AsyncValue<List<LeadHistory>> histories;
  final List<LeadWorkflowStageModel> stages;
  final bool isLoading;
  final String? errorMessage;

  const LeadDetailState({required this.lead, this.histories = const AsyncValue.loading(), required this.stages, this.isLoading = false, this.errorMessage});

  LeadDetailState copyWith({
    AsyncValue<Lead>? lead,
    AsyncValue<List<LeadHistory>>? histories,
    List<LeadWorkflowStageModel>? stages,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return LeadDetailState(
      lead: lead ?? this.lead,
      histories: histories ?? this.histories,
      stages: stages ?? this.stages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class LeadDetailViewModel extends StateNotifier<LeadDetailState> {
  LeadDetailViewModel(this.ref, this.id, {required this.workflowService}) : super(const LeadDetailState(lead: AsyncValue.loading(), stages: [])) {
    fetch();
  }

  //   SalesPipelineViewModel(this.ref, {required this.service, required this.workflowService}) : super(const SalesPipelineState(leads: AsyncValue.loading(), stages: [])) {
  //   fetch();
  // }

  final Ref ref;
  final String id;
  final LeadWorkflowService workflowService;

  LeadService get _leadService => ref.read(leadServiceProvider);

  Future<void> fetch() async {
    state = state.copyWith(lead: const AsyncLoading(), histories: const AsyncLoading(), clearErrorMessage: true);

    final leadAsync = await AsyncValue.guard(() => _leadService.getById(ref, id));
    final workflowResult = await AsyncValue.guard(() => workflowService.getDefaultWorkflow(ref));
    if (workflowResult.hasError) {
      state = state.copyWith(lead: AsyncValue.error(workflowResult.error!, workflowResult.stackTrace!));
      return;
    }

    final stages = workflowResult.value?.stages ?? const <LeadWorkflowStageModel>[];

    state = state.copyWith(lead: leadAsync, stages: stages);

    final historyAsync = await AsyncValue.guard(() => _leadService.fetchLeadHistory(ref, id));
    final AsyncValue<List<LeadHistory>> histories = historyAsync.when<AsyncValue<List<LeadHistory>>>(
      data: (items) => AsyncValue.data(items),
      error: (_, error) {
        return leadAsync.maybeWhen<AsyncValue<List<LeadHistory>>>(data: (lead) => AsyncValue.data(lead.histories ?? const []), orElse: () => const AsyncValue.data([]));
      },
      loading: () => const AsyncValue.loading(),
    );
    state = state.copyWith(histories: histories);
  }

  Future<bool> updateLeadStatus(String leadStatusID, leadStatusName, String? closeLostReason, {int? closeProbability}) async {
    if (state.lead.value == null) return false;

    state = state.copyWith(
      isLoading: true,
      lead: state.lead.whenData(
        (v) => v.copyWith(
          pipelineStageID: leadStatusID,
          leadStatusID: leadStatusID,
          leadStatusName: leadStatusName,
          closeLostReason: closeLostReason,
          closeProbability: closeProbability ?? v.closeProbability,
        ),
      ),
      clearErrorMessage: true,
    );

    try {
      final result = await _leadService.updateLead(ref: ref, lead: state.lead.value!);
      if (result) {
        ref.invalidate(leadListProvider);
        ref.invalidate(salesPipelineProvider);
        ref.invalidate(salesConversionFunnelProvider);
        await fetch();
        return true;
      }
      return result;
    } catch (e) {
      state = state.copyWith(errorMessage: e is ApiException ? e.message : 'Request failed');
    } finally {
      state = state.copyWith(isLoading: false);
    }

    return false;
  }

  Future<bool> updateLead() async {
    final lead = state.lead.value;
    if (lead == null) {
      return false;
    }

    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final result = await _leadService.updateLead(ref: ref, lead: lead);
      if (result) {
        ref.invalidate(leadListProvider);
        ref.invalidate(salesPipelineProvider);
        ref.invalidate(salesConversionFunnelProvider);
        await fetch();
      }
      return result;
    } catch (e) {
      state = state.copyWith(errorMessage: e is ApiException ? e.message : 'Request failed');
    } finally {
      state = state.copyWith(isLoading: false);
    }

    return false;
  }

  Future<bool> addDealValues(DealValue dealValue, bool isRefresh) async {
    if (id.isEmpty) {
      return false;
    }

    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final result = await _leadService.addDealValue(ref: ref, leadID: id, dealValue: dealValue);
      if (result && isRefresh) {
        ref.invalidate(leadListProvider);
        ref.invalidate(salesPipelineProvider);
        ref.invalidate(salesConversionFunnelProvider);
      }
      return result;
    } catch (e) {
      state = state.copyWith(errorMessage: e is ApiException ? e.message : 'Request failed');
    } finally {
      state = state.copyWith(isLoading: false);
    }

    return false;
  }

  Future<bool> removeDealValues(String dealValueItemID) async {
    final lead = state.lead.value;
    if (lead == null) {
      return false;
    }

    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final result = await _leadService.removeDealValue(ref: ref, leadID: dealValueItemID);
      if (result) {
        ref.invalidate(leadDetailProvider);
      }
      return result;
    } catch (e) {
      state = state.copyWith(errorMessage: e is ApiException ? e.message : 'Request failed');
    } finally {
      state = state.copyWith(isLoading: false);
    }

    return false;
  }

  Future<bool> deleteLead() async {
    final lead = state.lead.value;
    if (lead == null) {
      return false;
    }

    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final result = await _leadService.deleteLead(lead.leadID ?? '', ref);
      if (result) {
        ref.invalidate(leadListProvider);
        ref.invalidate(salesPipelineProvider);
        ref.invalidate(salesConversionFunnelProvider);
      }
      return result;
    } catch (e) {
      state = state.copyWith(errorMessage: e is ApiException ? e.message : 'Request failed');
    } finally {
      state = state.copyWith(isLoading: false);
    }

    return false;
  }

  List<LeadWorkflowStageModel> getSystemWorkflowStages() => state.stages.where((x) => x.isSystem).toList();
  List<LeadWorkflowStageModel> getCustomWorkflowStages() => state.stages.where((x) => !x.isSystem).toList();

  LeadWorkflowStageModel? filterWorkflowNextStage(String stageID) {
    final index = state.stages.indexWhere((x) => x.stageId == stageID);

    // หา stage ไม่เจอ หรือ stage ปัจจุบันเป็นตัวสุดท้ายแล้ว
    if (index == -1 || index + 1 >= state.stages.length) {
      return null;
    }

    return state.stages.skip(index + 1).where((stage) => stage.isActive).firstOrNull;
  }

  LeadWorkflowStageModel? filterWorkflowStage(String stageID) {
    return state.stages.where((x) => x.stageId == stageID).firstOrNull;
  }
}
