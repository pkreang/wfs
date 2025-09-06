class Purpose {
  final String purposeTypeID;
  final String purposeTypeName;

  Purpose({required this.purposeTypeID, required this.purposeTypeName});

  factory Purpose.fromJson(Map<String, dynamic> json) {
    return Purpose(purposeTypeID: json['PurposeTypeID'] as String, purposeTypeName: json['PurposeTypeName'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'PurposeTypeID': purposeTypeID, 'PurposeTypeName': purposeTypeName};
  }

  static List<Purpose> listFromJson(List<dynamic> jsonList) => jsonList.map((e) => Purpose.fromJson(e as Map<String, dynamic>)).toList();
}
