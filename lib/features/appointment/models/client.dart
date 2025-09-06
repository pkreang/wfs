import 'package:wfs/features/appointment/models/sales_territory.dart';

extension TimeFormat on String {
  String toHHmm() {
    final parts = split(":");
    return (parts.length >= 2) ? "${parts[0]}:${parts[1]}" : this;
  }
}

class Client {
  final String clientID;
  final String clientLevelID;
  final String clientLevelName;
  final String clientStatusID;
  final String clientStatusName;
  final String firstName;
  final String lastName;
  final String noted;
  final String phone;
  final String email;
  final String availableTimeStart;
  final String availableTimeEnd;
  final SalesTerritory? salesTerritory;

  Client({
    required this.clientID,
    required this.clientLevelID,
    required this.clientLevelName,
    required this.clientStatusID,
    required this.clientStatusName,
    required this.firstName,
    required this.lastName,
    required this.noted,
    required this.phone,
    required this.email,
    required this.availableTimeStart,
    required this.availableTimeEnd,
    required this.salesTerritory,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      clientID: json['ClientID'],
      clientLevelID: json['ClientLevelID'],
      clientLevelName: json['ClientLevelName'] ?? '',
      clientStatusID: json['ClientStatusID'],
      clientStatusName: json['ClientStatusName'] ?? '',
      firstName: json['FirstName'],
      lastName: json['LastName'],
      noted: json['Noted'],
      phone: json['Phone'],
      email: json['Email'],
      availableTimeStart: (json['AvailableTimeStart'] ?? "").toString().toHHmm(),
      availableTimeEnd: (json['AvailableTimeEnd'] ?? "").toString().toHHmm(),
      salesTerritory: (json['SalesTerritory'] != null) ? SalesTerritory.fromJson(json['SalesTerritory'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ClientID': clientID,
      'ClientLevelID': clientLevelID,
      'ClientLevelName': clientLevelName,
      'ClientStatusID': clientStatusID,
      'ClientStatusName': clientStatusName,
      'FirstName': firstName,
      'LastName': lastName,
      'Noted': noted,
      'Phone': phone,
      'Email': email,
      'AvailableTimeStart': availableTimeStart,
      'AvailableTimeEnd': availableTimeEnd,
      'SalesTerritory': salesTerritory?.toJson(),
    };
  }

  Client copyWith({
    String? clientID,
    String? clientLevelID,
    String? clientLevelName,
    String? clientStatusID,
    String? clientStatusName,
    String? firstName,
    String? lastName,
    String? noted,
    String? phone,
    String? email,
    String? availableTimeStart,
    String? availableTimeEnd,
    SalesTerritory? salesTerritory,
  }) {
    return Client(
      clientID: clientID ?? this.clientID,
      clientLevelID: clientLevelID ?? this.clientLevelID,
      clientLevelName: clientLevelName ?? this.clientLevelName,
      clientStatusID: clientStatusID ?? this.clientStatusID,
      clientStatusName: clientStatusName ?? this.clientStatusName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      noted: noted ?? this.noted,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      availableTimeStart: availableTimeStart ?? this.availableTimeStart,
      availableTimeEnd: availableTimeEnd ?? this.availableTimeEnd,
      salesTerritory: salesTerritory ?? this.salesTerritory,
    );
  }
}
