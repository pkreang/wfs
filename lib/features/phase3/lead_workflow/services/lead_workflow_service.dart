import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/http/api_client.dart';
import 'package:wfs/features/phase3/lead_workflow/models/lead_workflow_model.dart';
import 'package:wfs/features/phase3/lead_workflow/models/lead_workflow_stage_model.dart';
import 'package:wfs/providers/auth_provider.dart';

class LeadWorkflowService {
  final apiClient = ApiClient('https://sfe-api.appnormalthink.com');

  Future<LeadWorkflowModel> getDefaultWorkflow(Ref ref) async {
    final accessToken = ref.read(authProvider).accessToken;

    final workflow = await apiClient.get<LeadWorkflowModel>(
      path: "/workflow",
      decode: (json) {
        final list = switch (json) {
          List<dynamic> value => value,
          Map<String, dynamic> value => value['workflow'] as List<dynamic>? ?? value['workflows'] as List<dynamic>? ?? const [],
          _ => const [],
        };

        final stages = list.map((e) => LeadWorkflowStageModel.fromJson(e as Map<String, dynamic>)).toList();
        return LeadWorkflowModel.fromStages(stages);
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );

    return workflow;
  }

  Future<void> createCustomStage(String name, Ref ref) async {
    final accessToken = ref.read(authProvider).accessToken;
    final workflow = await getDefaultWorkflow(ref);
    final customStages = workflow.stages.where((stage) => stage.isCustom).toList()..sort((a, b) => a.orderbyNo.compareTo(b.orderbyNo));
    final orderingNo = customStages.isEmpty ? 1 : customStages.last.id + 1;

    await apiClient.post<void>(path: "/workflow/", body: {"display_name": name.trim(), "ordering_no": orderingNo}, decode: (_) {}, headers: {"Authorization": "Bearer $accessToken"});
  }

  Future<void> updateWorkflow(Ref ref, String stageId, String name, int orderingNo) async {
    final accessToken = ref.read(authProvider).accessToken;

    await apiClient.put(path: "/workflow/", body: {"stage_id": stageId, "display_name": name.trim(), "ordering_no": orderingNo}, headers: {"Authorization": "Bearer $accessToken"});
  }

  Future<void> inactiveWorkflowStage(Ref ref, String stageId) async {
    final accessToken = ref.read(authProvider).accessToken;

    await apiClient.put(path: '/workflow/$stageId/inactive', body: const {}, headers: {'Authorization': 'Bearer $accessToken'});
  }

  Future<void> activeWorkflowStage(Ref ref, String stageId) async {
    final accessToken = ref.read(authProvider).accessToken;

    await apiClient.put(path: '/workflow/$stageId/active', body: const {}, headers: {'Authorization': 'Bearer $accessToken'});
  }

  // Future<void> updateCustomStage(int stageId, String name) async {
  //   final stage = _workflow.stages.firstWhere((stage) => stage.id == stageId);
  //   if (stage.isSystem) {
  //     throw StateError('System stages can only be renamed through renameStage.');
  //   }

  //   _workflow = _workflow.copyWith(stages: _workflow.stages.map((stage) => stage.id == stageId ? stage.copyWith(displayName: name) : stage).toList());
  // }

  // Future<void> deleteCustomStage(int stageId) async {
  //   final stage = _workflow.stages.firstWhere((stage) => stage.id == stageId);
  //   if (stage.isSystem) {
  //     throw StateError('System stages cannot be deleted.');
  //   }

  //   // TODO: If this stage has active leads, backend should block delete or require lead migration before delete.
  //   final stages = _workflow.stages.map((stage) => stage.id == stageId ? stage.copyWith(isDeleted: true, isActive: false) : stage).toList();
  //   _workflow = _workflow.copyWith(stages: _withRecalculatedCustomSortOrder(stages));
  // }

  // Future<void> updateStageActive(int stageId, bool isActive) async {
  //   final stage = _workflow.stages.firstWhere((stage) => stage.id == stageId);
  //   if (stage.isSystem) {
  //     throw StateError('System stages cannot be disabled.');
  //   }

  //   _workflow = _workflow.copyWith(stages: _workflow.stages.map((stage) => stage.id == stageId ? stage.copyWith(isActive: isActive) : stage).toList());
  // }

  // Future<void> reorderCustomStages(List<LeadWorkflowStageModel> customStages) async {
  //   final customStageIds = customStages.map((stage) => stage.id).toSet();
  //   final existingCustomIds = _workflow.stages.where((stage) => stage.isCustom && !stage.isDeleted).map((stage) => stage.id).toSet();

  //   if (customStageIds.length != existingCustomIds.length || !customStageIds.containsAll(existingCustomIds)) {
  //     throw StateError('Only active custom workflow stages can be reordered.');
  //   }

  //   final reorderedCustomStages = customStages.indexed.map((entry) {
  //     final index = entry.$1;
  //     final stage = entry.$2;
  //     return stage.copyWith(sortOrder: 2100 + (index * 100));
  //   }).toList();

  //   _workflow = _workflow.copyWith(stages: [..._workflow.stages.where((stage) => stage.isSystem || stage.isDeleted), ...reorderedCustomStages]);
  // }

  // Future<List<LeadWorkflowStageModel>> getWorkflowStagesForFunnel() async {
  //   return _orderedStages(_workflow.stages).where((stage) => stage.isActive && !stage.isDeleted).toList();
  // }

  // List<LeadWorkflowStageModel> _withRecalculatedCustomSortOrder(List<LeadWorkflowStageModel> stages) {
  //   final activeCustomStages = stages.where((stage) => stage.isCustom && !stage.isDeleted).toList()..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  //   final recalculatedCustomStages = activeCustomStages.indexed.map((entry) {
  //     final index = entry.$1;
  //     final stage = entry.$2;
  //     return stage.copyWith(sortOrder: 2100 + (index * 100));
  //   }).toList();
  //   final recalculatedIds = recalculatedCustomStages.map((stage) => stage.id).toSet();

  //   return [...stages.where((stage) => stage.isSystem || stage.isDeleted || !recalculatedIds.contains(stage.id)), ...recalculatedCustomStages];
  // }

  // List<LeadWorkflowStageModel> _orderedStages(List<LeadWorkflowStageModel> stages) {
  //   final prospecting = _systemStage(stages, SystemLeadStage.prospecting);
  //   final qualification = _systemStage(stages, SystemLeadStage.qualification);
  //   final proposal = _systemStage(stages, SystemLeadStage.proposal);
  //   final closed = _systemStage(stages, SystemLeadStage.closed);
  //   final customStages = stages.where((stage) => stage.isCustom && !stage.isDeleted).toList()..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  //   return [prospecting, qualification, ...customStages, proposal, closed];
  // }

  // LeadWorkflowStageModel _systemStage(List<LeadWorkflowStageModel> stages, SystemLeadStage systemStage) {
  //   return stages.firstWhere((stage) => stage.systemStage == systemStage);
  // }
}
