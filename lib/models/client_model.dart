import 'package:wfs/models/clients_model.dart';

class Client {
  String? status;
  List<Clients>? clients;

  Client({this.status, this.clients});

  Client.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['clients'] != null) {
      clients = <Clients>[];
      json['clients'].forEach((v) {
        clients!.add(new Clients.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.clients != null) {
      data['clients'] = this.clients!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
