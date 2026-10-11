import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/phase3/lead_workflow/models/lead_workflow_model.dart';
import 'package:wfs/features/phase3/lead_workflow/models/lead_workflow_stage_model.dart';
import 'package:wfs/features/phase3/lead_workflow/widgets/add_custom_stage_button.dart';
import 'package:wfs/features/phase3/lead_workflow/widgets/custom_stage_tile.dart';
import 'package:wfs/features/phase3/lead_workflow/widgets/delete_stage_confirm_dialog.dart';
import 'package:wfs/features/phase3/lead_workflow/widgets/edit_stage_name_dialog.dart';
import 'package:wfs/features/phase3/lead_workflow/widgets/system_stage_tile.dart';
import 'package:wfs/models/auth_model.dart';
import 'package:wfs/providers/auth_provider.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/utility/appdialogs.dart';
import 'package:wfs/widgets/app_text.dart';

class LeadWorkflowPage extends ConsumerStatefulWidget {
  const LeadWorkflowPage({super.key});

  @override
  ConsumerState<LeadWorkflowPage> createState() => _LeadWorkflowPageState();
}

class _LeadWorkflowPageState extends ConsumerState<LeadWorkflowPage> {
  Future<void> _refresh() async {
    ref.invalidate(leadWorkflowProvider);
    await ref.read(leadWorkflowProvider.future);
  }

  Future<void> _addCustomStage(LeadWorkflowModel workflow) async {
    final name = await EditStageNameDialog.show(context: context, title: 'Add Custom State', isDuplicateName: (name) => _isDuplicateName(workflow, name));
    if (name == null) return;

    final created = await ref.read(leadWorkflowRepositoryProvider.notifier).createCustomStage(name);
    if (!mounted) return;

    if (created) {
      await _refresh();
      return;
    }

    final errMsg = ref.read(leadWorkflowRepositoryProvider).errorMessage;
    if (errMsg != null && errMsg.isNotEmpty) {
      AppDialogs.alert(context, title: 'ไม่สามารถดำเนินการได้', message: errMsg);
    }
  }

  Future<void> _editStage(LeadWorkflowModel workflow, LeadWorkflowStageModel stage) async {
    final name = await EditStageNameDialog.show(
      context: context,
      title: 'Edit State Name',
      initialValue: stage.displayName,
      isDuplicateName: (name) => _isDuplicateName(workflow, name, editingStageId: stage.id),
    );
    if (name == null) return;

    if (stage.isSystem) {
    } else {
      await ref.read(leadWorkflowRepositoryProvider.notifier).updateWorkflow(stage.stageId, name, stage.orderbyNo);
    }
    await _refresh();
  }

  Future<void> _showStageActions(LeadWorkflowModel workflow, LeadWorkflowStageModel stage) async {
    final action = await showCupertinoModalPopup<_StageAction>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          // title: Text(stage.displayName),
          actions: [
            CupertinoActionSheetAction(onPressed: () => Navigator.of(context).pop(_StageAction.rename), child: const Text('Rename')),
            if (stage.isActive)
              CupertinoActionSheetAction(isDestructiveAction: true, onPressed: () => Navigator.of(context).pop(_StageAction.inactive), child: const Text('Inactive'))
            else
              CupertinoActionSheetAction(isDestructiveAction: true, onPressed: () => Navigator.of(context).pop(_StageAction.active), child: const Text('Active')),
          ],
          cancelButton: CupertinoActionSheetAction(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        );
      },
    );

    if (!mounted || action == null) return;

    switch (action) {
      case _StageAction.rename:
        await _editStage(workflow, stage);
        return;
      case _StageAction.inactive:
        await _updateStageActive(stage, false);
        return;
      case _StageAction.active:
        await _updateStageActive(stage, true);
        return;
    }
  }

  Future<void> _deleteStage(LeadWorkflowStageModel stage) async {
    final confirmed = await DeleteStageConfirmDialog.show(context: context, stageName: stage.displayName);
    if (!confirmed) return;

    // await _repository.deleteCustomStage(stage.id);
    await _refresh();
  }

  Future<void> _updateStageActive(LeadWorkflowStageModel stage, bool isActive) async {
    final repository = ref.read(leadWorkflowRepositoryProvider.notifier);
    final updated = isActive ? await repository.activeWorkflowStage(stage.stageId) : await repository.inactiveWorkflowStage(stage.stageId);
    if (updated) await _refresh();
  }

  Future<void> _reorderCustomStages(int systemLength, List<LeadWorkflowStageModel> customStages, int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    if (newIndex == oldIndex) return;

    final stage = customStages[oldIndex];
    // `newIndex` is zero-based within custom stages; workflow ordering is one-based.
    final orderingNo = systemLength + newIndex + 1;

    final updated = await ref.read(leadWorkflowRepositoryProvider.notifier).updateWorkflow(stage.stageId, stage.displayName, orderingNo);
    if (updated) await _refresh();
  }

  bool _isDuplicateName(LeadWorkflowModel workflow, String name, {int? editingStageId}) {
    final target = name.trim().toLowerCase();
    return workflow.stages.any((stage) {
      if (stage.id == editingStageId || stage.isDeleted) return false;
      return stage.displayName.toLowerCase() == target;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leadWorkflowRepositoryProvider);
    final workflow = ref.watch(leadWorkflowProvider);
    final auth = ref.read(authProvider);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF6F6F6),
          appBar: AppBar(
            centerTitle: true,
            title: const AppText(label: 'Lead Workflow', fontSize: 17, fontWeight: FontWeight.w600),
            shape: const Border(bottom: BorderSide(color: Color.fromRGBO(60, 60, 67, 0.36), width: 0.5)),
          ),
          body: SafeArea(
            child: workflow.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary)),
              error: (e, _) => Center(
                child: AppText(label: e.toString(), textColor: AppUtility.colorRed),
              ),
              data: (workflow) => _buildContent(workflow, auth),
            ),
          ),
        ),

        if (state.isLoading) ...[const ModalBarrier(color: Color(0x66000000), dismissible: false), const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary))],
      ],
    );
  }

  Widget _buildContent(LeadWorkflowModel workflow, AuthState auth) {
    final systemStartStages = _systemStartStages(workflow.stages);
    final customStages = _customStages(workflow.stages);
    final systemEndStages = _systemEndStages(workflow.stages);
    final orderedStages = [...systemStartStages, ...customStages, ...systemEndStages];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const AppText(label: 'Sales Pipeline lead stages', fontSize: 16, fontWeight: FontWeight.w600),
          // const SizedBox(height: 4),
          // const AppText(
          //   label: 'System stages are fixed workflow anchors. Add custom stages only between Qualification and Proposal.',
          //   fontSize: 12,
          //   textColor: AppUtility.textGray,
          //   lineHeight: 16,
          //   maxLines: 3,
          // ),
          // const SizedBox(height: 12),
          // _WarningCard(),
          // const SizedBox(height: 14),
          // const _SectionTitle(label: 'System Workflow'),
          // const SizedBox(height: 8),
          _StageSection(
            children: [
              for (var index = 0; index < systemStartStages.length; index++) ...[
                SystemStageTile(
                  stage: systemStartStages[index],
                  position: orderedStages.indexWhere((item) => item.id == systemStartStages[index].id) + 1,
                  onEdit: () => _editStage(workflow, systemStartStages[index]),
                ),
                if (index != systemStartStages.length - 1) const _TileDivider(),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(child: _SectionTitle(label: 'Custom workflow')),
              if ((auth.isAdmin || auth.isSuperAdmin)) AddCustomStageButton(onPressed: () => _addCustomStage(workflow)),
            ],
          ),
          const SizedBox(height: 8),
          _StageSection(
            emptyChild: const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: AppText(label: 'No custom stages yet.', textColor: AppUtility.textGray),
              ),
            ),
            children: customStages.isEmpty
                ? const []
                : [
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      buildDefaultDragHandles: false,
                      itemCount: customStages.length,
                      onReorder: (oldIndex, newIndex) => _reorderCustomStages(systemStartStages.length, customStages, oldIndex, newIndex),
                      itemBuilder: (context, index) {
                        final stage = customStages[index];
                        final position = orderedStages.indexWhere((item) => item.id == stage.id) + 1;

                        return Column(
                          key: ValueKey(stage.id),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomStageTile(
                              stage: stage,
                              position: position,
                              onEdit: () => _showStageActions(workflow, stage),
                              onDelete: () => _deleteStage(stage),
                              onActiveChanged: (value) => _updateStageActive(stage, value),
                              dragHandle: ReorderableDragStartListener(
                                index: index,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6),
                                  child: Icon(Icons.drag_handle_rounded, color: AppUtility.textGray),
                                ),
                              ),
                            ),
                            if (index != customStages.length - 1) const _TileDivider(),
                          ],
                        );
                      },
                    ),
                  ],
          ),
          const SizedBox(height: 14),
          // const _SectionTitle(label: 'System Workflow'),
          const SizedBox(height: 8),
          _StageSection(
            children: [
              for (var index = 0; index < systemEndStages.length; index++) ...[
                SystemStageTile(
                  stage: systemEndStages[index],
                  position: orderedStages.indexWhere((item) => item.id == systemEndStages[index].id) + 1,
                  onEdit: () => _editStage(workflow, systemEndStages[index]),
                ),
                if (index != systemEndStages.length - 1) const _TileDivider(),
              ],
            ],
          ),
        ],
      ),
    );
  }

  List<LeadWorkflowStageModel> _systemStartStages(List<LeadWorkflowStageModel> stages) {
    final systemStages = stages.where((stage) => stage.isSystem && !stage.isDeleted).toList()..sort((a, b) => a.orderbyNo.compareTo(b.orderbyNo));
    return systemStages.where((stage) => stage.systemStage == SystemLeadStage.prospecting || stage.systemStage == SystemLeadStage.qualification).toList();
  }

  List<LeadWorkflowStageModel> _customStages(List<LeadWorkflowStageModel> stages) {
    return stages.where((stage) => stage.isCustom && !stage.isDeleted).toList()..sort((a, b) => a.orderbyNo.compareTo(b.orderbyNo));
  }

  List<LeadWorkflowStageModel> _systemEndStages(List<LeadWorkflowStageModel> stages) {
    final systemStages = stages.where((stage) => stage.isSystem && !stage.isDeleted).toList()..sort((a, b) => a.orderbyNo.compareTo(b.orderbyNo));
    return systemStages.where((stage) => stage.systemStage == SystemLeadStage.proposal || stage.systemStage == SystemLeadStage.closed).toList();
  }
}

enum _StageAction { rename, active, inactive }

class _SectionTitle extends StatelessWidget {
  final String label;

  const _SectionTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    return AppText(label: label, fontSize: 16, fontWeight: FontWeight.w600, lineHeight: 20);
  }
}

class _StageSection extends StatelessWidget {
  final List<Widget> children;
  final Widget? emptyChild;

  const _StageSection({required this.children, this.emptyChild});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11)),
      child: children.isEmpty ? emptyChild : Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: AppUtility.borderWidth, color: AppUtility.colorGray, indent: 62);
  }
}
