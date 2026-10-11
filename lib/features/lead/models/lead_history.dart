class LeadHistory {
  final String? leadHistoryID;
  final String? actionType;
  final String? previousStatus;
  final String? newStatus;
  final String? updatedBy;
  final DateTime? updatedDateTime;
  final String? remarks;

  const LeadHistory({
    this.leadHistoryID,
    this.actionType,
    this.previousStatus,
    this.newStatus,
    this.updatedBy,
    this.updatedDateTime,
    this.remarks,
  });

  factory LeadHistory.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(Object? value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    return LeadHistory(
      leadHistoryID:
          (json['LeadHistoryID'] ??
                  json['leadHistoryID'] ??
                  json['HistoryID'] ??
                  json['id'])
              ?.toString(),
      actionType: (json['ActionType'] ?? json['actionType'])?.toString(),
      previousStatus:
          (json['PreviousStatus'] ??
                  json['previousStatus'] ??
                  json['PreviousStatusName'] ??
                  json['previousStatusName'])
              ?.toString(),
      newStatus:
          (json['NewStatus'] ??
                  json['newStatus'] ??
                  json['NewStatusName'] ??
                  json['newStatusName'])
              ?.toString(),
      updatedBy:
          (json['UpdatedBy'] ??
                  json['updatedBy'] ??
                  json['ModifiedByName'] ??
                  json['modifiedByName'])
              ?.toString(),
      updatedDateTime: parseDate(
        json['UpdatedDateTime'] ??
            json['updatedDateTime'] ??
            json['ModifiedDate'] ??
            json['modifiedDate'] ??
            json['CreatedDate'] ??
            json['createdDate'],
      ),
      remarks:
          (json['Remarks'] ??
                  json['remarks'] ??
                  json['Remark'] ??
                  json['remark'])
              ?.toString(),
    );
  }

  static List<LeadHistory> listFromJson(List<dynamic> jsonList) => jsonList
      .map((e) => LeadHistory.fromJson(e as Map<String, dynamic>))
      .toList();
}
