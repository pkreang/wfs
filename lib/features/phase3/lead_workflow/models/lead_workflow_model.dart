import 'package:wfs/features/phase3/lead_workflow/models/lead_workflow_stage_model.dart';

class LeadWorkflowModel {
  final int id;
  final String name;
  final bool isDefault;
  final List<LeadWorkflowStageModel> stages;

  const LeadWorkflowModel({
    required this.id,
    required this.name,
    required this.isDefault,
    required this.stages,
  });

  factory LeadWorkflowModel.fromStages(List<LeadWorkflowStageModel> stages) {
    return LeadWorkflowModel(
      id: 1,
      name: 'Default Lead Workflow',
      isDefault: true,
      stages: stages,
    );
  }

  LeadWorkflowModel copyWith({
    int? id,
    String? name,
    bool? isDefault,
    List<LeadWorkflowStageModel>? stages,
  }) {
    return LeadWorkflowModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isDefault: isDefault ?? this.isDefault,
      stages: stages ?? this.stages,
    );
  }
}
