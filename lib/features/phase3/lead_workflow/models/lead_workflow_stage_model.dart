enum LeadStageType { system, custom }

enum SystemLeadStage { prospecting, qualification, proposal, closed }

class LeadWorkflowStageModel {
  final int id;
  final String stageId;
  final int workflowId;
  final String stageKey;
  final String displayName;
  final LeadStageType stageType;
  final SystemLeadStage? systemStage;
  final int orderbyNo;
  final bool isActive;
  final bool isDeleted;

  const LeadWorkflowStageModel({
    required this.id,
    required this.workflowId,
    required this.stageKey,
    required this.displayName,
    required this.stageType,
    required this.orderbyNo,
    this.stageId = '',
    this.systemStage,
    this.isActive = true,
    this.isDeleted = false,
  });

  bool get isSystem => stageType == LeadStageType.system;
  bool get isCustom => stageType == LeadStageType.custom;

  factory LeadWorkflowStageModel.fromJson(Map<String, dynamic> json, {int workflowId = 1}) {
    final displayName = (json['display_name'] ?? json['displayName'] ?? '').toString();
    final stageKey = (json['stage_key'] ?? json['stageKey'] ?? _keyFromDisplayName(displayName)).toString();
    final isSystemLock = json['is_systemlock'] == true || json['isSystemLock'] == true;
    final orderingNo = _intValue(json['ordering_no'] ?? json['ordering_no']) ?? 0;
    final systemStage = _systemStageFromKey(stageKey) ?? _systemStageFromKey(displayName);

    return LeadWorkflowStageModel(
      id: orderingNo,
      stageId: (json['stage_id'] ?? json['stageId'] ?? '').toString(),
      workflowId: workflowId,
      stageKey: stageKey,
      displayName: displayName.isEmpty ? stageKey : displayName,
      stageType: isSystemLock ? LeadStageType.system : LeadStageType.custom,
      systemStage: systemStage,
      orderbyNo: orderingNo,
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
      isDeleted: json['is_deleted'] as bool? ?? json['isDeleted'] as bool? ?? false,
    );
  }

  LeadWorkflowStageModel copyWith({
    int? id,
    String? stageId,
    int? workflowId,
    String? stageKey,
    String? displayName,
    LeadStageType? stageType,
    SystemLeadStage? systemStage,
    int? sortOrder,
    bool? isActive,
    bool? isDeleted,
  }) {
    return LeadWorkflowStageModel(
      id: id ?? this.id,
      stageId: stageId ?? this.stageId,
      workflowId: workflowId ?? this.workflowId,
      stageKey: stageKey ?? this.stageKey,
      displayName: displayName ?? this.displayName,
      stageType: stageType ?? this.stageType,
      systemStage: systemStage ?? this.systemStage,
      orderbyNo: sortOrder ?? this.orderbyNo,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  static int? _intValue(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static String _keyFromDisplayName(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'^_|_$'), '');
  }

  static SystemLeadStage? _systemStageFromKey(String value) {
    final normalized = _keyFromDisplayName(value);
    return switch (normalized) {
      'prospecting' => SystemLeadStage.prospecting,
      'qualification' => SystemLeadStage.qualification,
      'proposal' => SystemLeadStage.proposal,
      'closed' || 'closed_won' || 'closed_lost' => SystemLeadStage.closed,
      _ => null,
    };
  }
}
