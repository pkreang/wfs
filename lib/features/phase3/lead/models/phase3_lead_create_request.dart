class Phase3LeadCreateRequest {
  final String leadName;
  final String? companyName;
  final String? phone;
  final String? email;
  final String? source;
  final String? interestedProduct;
  final double? dealValue;
  final String? note;

  const Phase3LeadCreateRequest({
    required this.leadName,
    this.companyName,
    this.phone,
    this.email,
    this.source,
    this.interestedProduct,
    this.dealValue,
    this.note,
  });
}
