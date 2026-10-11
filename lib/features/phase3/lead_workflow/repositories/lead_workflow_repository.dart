import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/http/api_client.dart';
import 'package:wfs/features/phase3/lead_workflow/models/lead_workflow_model.dart';
import 'package:wfs/features/phase3/lead_workflow/services/lead_workflow_service.dart';

class LeadWorkflowRepositoryState {
  final bool isLoading;
  final String? errorMessage;

  const LeadWorkflowRepositoryState({
    this.isLoading = false,
    this.errorMessage,
  });

  LeadWorkflowRepositoryState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return LeadWorkflowRepositoryState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

class LeadWorkflowRepository
    extends StateNotifier<LeadWorkflowRepositoryState> {
  final Ref ref;
  final LeadWorkflowService service;

  LeadWorkflowRepository({required this.ref, required this.service})
    : super(const LeadWorkflowRepositoryState());

  Future<LeadWorkflowModel> getDefaultWorkflow() =>
      service.getDefaultWorkflow(ref);

  Future<bool> createCustomStage(String name) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      await service.createCustomStage(name, ref);
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: e is ApiException ? e.message : 'Request failed',
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }

    return false;
  }

  Future<bool> updateWorkflow(
    String stageId,
    String name,
    int orderingNo,
  ) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      await service.updateWorkflow(ref, stageId, name, orderingNo);
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: e is ApiException ? e.message : 'Request failed',
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }

    return false;
  }

  Future<bool> inactiveWorkflowStage(String stageId) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      await service.inactiveWorkflowStage(ref, stageId);
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: e is ApiException ? e.message : 'Request failed',
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }

    return false;
  }

  Future<bool> activeWorkflowStage(String stageId) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      await service.activeWorkflowStage(ref, stageId);
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: e is ApiException ? e.message : 'Request failed',
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }

    return false;
  }

  // Future<void> updateCustomStage(int stageId, String name) => service.updateCustomStage(stageId, name);

  // Future<void> deleteCustomStage(int stageId) => service.deleteCustomStage(stageId);

  // Future<void> updateStageActive(int stageId, bool isActive) => service.updateStageActive(stageId, isActive);

  // Future<void> reorderCustomStages(List<LeadWorkflowStageModel> customStages) => service.reorderCustomStages(customStages);

  // Future<List<LeadWorkflowStageModel>> getWorkflowStagesForFunnel() => service.getWorkflowStagesForFunnel();
}
