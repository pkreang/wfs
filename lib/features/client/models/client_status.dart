class ClientStatus {
  final String clientStatusID;
  final String clientStatusName;

  ClientStatus({required this.clientStatusID, required this.clientStatusName});

  factory ClientStatus.fromJson(Map<String, dynamic> json) {
    return ClientStatus(clientStatusID: json['ClientStatusID'] as String, clientStatusName: json['ClientStatusName'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'ClientStatusID': clientStatusID, 'ClientStatusName': clientStatusName};
  }

  static List<ClientStatus> listFromJson(List<dynamic> jsonList) => jsonList.map((e) => ClientStatus.fromJson(e as Map<String, dynamic>)).toList();
}
