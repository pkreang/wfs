class Phase3LeadModel {
  final int id;
  final String leadName;
  final String? companyName;
  final String? phone;
  final String? email;
  final String? source;
  final String? interestedProduct;
  final double? dealValue;
  final String? note;
  final int workflowId;
  final int currentStageId;
  final String closeStatus;
  final String? lostReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Phase3LeadModel({
    required this.id,
    required this.leadName,
    required this.workflowId,
    required this.currentStageId,
    required this.closeStatus,
    required this.createdAt,
    required this.updatedAt,
    this.companyName,
    this.phone,
    this.email,
    this.source,
    this.interestedProduct,
    this.dealValue,
    this.note,
    this.lostReason,
  });

  bool get isClosed => closeStatus == 'WON' || closeStatus == 'LOST';

  Phase3LeadModel copyWith({
    int? id,
    String? leadName,
    String? companyName,
    String? phone,
    String? email,
    String? source,
    String? interestedProduct,
    double? dealValue,
    String? note,
    int? workflowId,
    int? currentStageId,
    String? closeStatus,
    String? lostReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearLostReason = false,
  }) {
    return Phase3LeadModel(
      id: id ?? this.id,
      leadName: leadName ?? this.leadName,
      companyName: companyName ?? this.companyName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      source: source ?? this.source,
      interestedProduct: interestedProduct ?? this.interestedProduct,
      dealValue: dealValue ?? this.dealValue,
      note: note ?? this.note,
      workflowId: workflowId ?? this.workflowId,
      currentStageId: currentStageId ?? this.currentStageId,
      closeStatus: closeStatus ?? this.closeStatus,
      lostReason: clearLostReason ? null : lostReason ?? this.lostReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
