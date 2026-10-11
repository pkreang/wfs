class Phase3LeadFunnelModel {
  final int stageId;
  final String stageName;
  final int sortOrder;
  final int leadCount;
  final double totalDealValue;
  final String? systemStage;
  final String stageType;
  final String? closeStatus;

  const Phase3LeadFunnelModel({
    required this.stageId,
    required this.stageName,
    required this.sortOrder,
    required this.leadCount,
    required this.totalDealValue,
    required this.stageType,
    this.systemStage,
    this.closeStatus,
  });
}
