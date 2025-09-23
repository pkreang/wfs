class ClientLevel {
  final String clientLevelID;
  final String clientLevelName;

  ClientLevel({required this.clientLevelID, required this.clientLevelName});

  factory ClientLevel.fromJson(Map<String, dynamic> json) {
    return ClientLevel(clientLevelID: json['ClientLevelID'] as String, clientLevelName: json['ClientLevelName'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'ClientLevelID': clientLevelID, 'ClientLevelName': clientLevelName};
  }

  static List<ClientLevel> listFromJson(List<dynamic> jsonList) => jsonList.map((e) => ClientLevel.fromJson(e as Map<String, dynamic>)).toList();
}
