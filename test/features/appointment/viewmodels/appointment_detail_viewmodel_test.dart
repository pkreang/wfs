import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/models/appointment_detail.dart';
import 'package:wfs/features/appointment/services/appointment_service.dart';
import 'package:wfs/features/client/models/client.dart';
import 'package:wfs/features/client/services/client_service.dart';
import 'package:wfs/features/tag/models/tag.dart';

void main() {
  test('routes to lead only when the client lookup returns null', () async {
    final appointment = await _load(_ClientService());
    expect(appointment.isLeadClient, isTrue);
    expect(appointment.copyWith(tags: []).isLeadClient, isTrue);
  });

  test(
    'keeps client navigation and enriches tags for an existing client',
    () async {
    final tag = Tag(tagId: 'tag-id', tagName: 'Client tag');
      final appointment = await _load(
        _ClientService(client: Client(tags: [tag])),
      );
      expect(appointment.isLeadClient, isFalse);
      expect(appointment.tags.single, same(tag));
    },
  );

  test('does not treat a failed client request as a lead', () async {
    final appointment = await _load(
      _ClientService(error: Exception('Request failed')),
    );
    expect(appointment.isLeadClient, isFalse);
  });
}

Future<AppointmentDetail> _load(_ClientService clientService) async {
  final container = ProviderContainer(
    overrides: [
      appointmentServiceProvider.overrideWithValue(_AppointmentService()),
      clientServiceProvider.overrideWithValue(clientService),
    ],
  );
  addTearDown(container.dispose);
  final loaded = Completer<AppointmentDetail>();
  container.listen(appointmentDetailProvider('appointment-id'), (_, next) {
    if (next.hasValue && !loaded.isCompleted) {
      loaded.complete(next.requireValue);
    }
  }, fireImmediately: true);
  final appointment = await loaded.future.timeout(const Duration(seconds: 5));
  expect(clientService.requestedID, appointment.clientID);
  return appointment;
}

class _AppointmentService extends AppointmentService {
  @override
  Future<AppointmentDetail> fetchAppointmentById(
    Ref ref,
    String appointmentID,
  ) async {
    final json =
        jsonDecode(
              File(
                'test/features/appointment/models/fixtures/appointment_detail_response.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    return AppointmentDetail.fromJson(
      (json['appointment'] as List).single as Map<String, dynamic>,
    );
  }
}

class _ClientService extends ClientService {
  _ClientService({this.client, this.error});

  final Client? client;
  final Exception? error;
  String? requestedID;

  @override
  Future<Client?> findById(Ref ref, String clientId) async {
    requestedID = clientId;
    if (error != null) throw error!;
    return client;
  }
}
