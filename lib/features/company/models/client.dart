class Client {
  final String clientID;
  final String clientName;

  Client({required this.clientID, required this.clientName});

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(clientID: json['ClientID'] as String, clientName: json['ClientName'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'ClientID': clientID, 'ClientName': clientName};
  }

  static List<Client> listFromJson(List<dynamic> jsonList) => jsonList.map((e) => Client.fromJson(e as Map<String, dynamic>)).toList();
}
