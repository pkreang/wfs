class Phase3LeadUpdateStageRequest {
  final int leadId;
  final int toStageId;
  final String? note;

  const Phase3LeadUpdateStageRequest({
    required this.leadId,
    required this.toStageId,
    this.note,
  });
}
