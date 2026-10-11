class LeadStatus {
  final String leadStatusID;
  final String leadStatusName;

  const LeadStatus({required this.leadStatusID, required this.leadStatusName});

  factory LeadStatus.fromJson(Map<String, dynamic> json) {
    final id =
        json['LeadStatusID'] ??
        json['leadStatusID'] ??
        json['StatusID'] ??
        json['statusID'] ??
        json['id'];
    final name =
        json['LeadStatusName'] ??
        json['leadStatusName'] ??
        json['StatusName'] ??
        json['statusName'] ??
        json['name'];

    return LeadStatus(
      leadStatusID: id?.toString() ?? '',
      leadStatusName: name?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'LeadStatusID': leadStatusID,
    'LeadStatusName': leadStatusName,
  };

  static List<LeadStatus> listFromJson(List<dynamic> jsonList) => jsonList
      .map((e) => LeadStatus.fromJson(e as Map<String, dynamic>))
      .toList();

  static const defaults = [
    LeadStatus(leadStatusID: 'Prospecting', leadStatusName: 'Prospecting'),
    LeadStatus(leadStatusID: 'Qualification', leadStatusName: 'Qualification'),
    LeadStatus(leadStatusID: 'Proposal', leadStatusName: 'Proposal'),
    LeadStatus(leadStatusID: 'Closed', leadStatusName: 'Closed'),
  ];
}
