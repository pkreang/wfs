import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/models/appointment_detail.dart';
import 'package:wfs/features/appointment/services/appointment_service.dart';
import 'package:wfs/features/appointment/viewmodels/appointment_edit_viewmodel.dart';
import 'package:wfs/features/client/models/client.dart';
import 'package:wfs/features/client/services/client_service.dart';
import 'package:wfs/features/tag/models/tag.dart';

void main() {
  test(
    'loads edit fields and company address from the reported response',
    () async {
      final appointment = _reportedAppointment();
      final state = await _load(
        _AppointmentService(appointment: appointment),
        _ClientService(Future.value(Client())),
      );
      final detail = state.data.requireValue;

      expect(detail.appointmentTypeName, 'Visit');
      expect(detail.appointmentStatusName, 'Scheduled');
      expect(detail.purposeTypeName, 'Schedule Meeting');
      expect(detail.client.salesTerritory?.salesTerritoryName, 'T2');
      expect(
        DateTime.parse(detail.appointmentDateTimeFrom),
        DateTime(2026, 10, 11, 14, 5),
      );
      expect(
        DateTime.parse(detail.appointmentDateTimeTo),
        DateTime(2026, 10, 11, 14, 35),
      );
      expect(detail.phone, '0884162467');
      expect(detail.email, 'newlead@gmail.com');
      expect(detail.noted, 'note');
      expect(detail.address.address, '88/8');
      expect(detail.address.provinceName, 'กรุงเทพมหานคร');
      expect(detail.address.districtName, 'คลองเตย');
      expect(detail.address.subDistrictName, 'คลองตัน');
      expect(detail.address.postCode, '10110');
      expect(state.companies.single.companyID, detail.companyID);
      expect(state.companies.single.addresses.single.address, '88/8');
      expect(state.isDirty, isFalse);
    },
  );

  test(
    'publishes appointment load errors instead of staying loading',
    () async {
      final error = Exception('Appointment request failed');
      final state = await _load(
        _AppointmentService(error: error),
        _ClientService(Future.value(Client())),
      );

      expect(state.data.error, same(error));
      expect(state.data.isLoading, isFalse);
    },
  );

  test(
    'shows appointment data while optional client tags are still loading',
    () async {
      final clientResult = Completer<Client>();
      final clientService = _ClientService(clientResult.future);
      final container = ProviderContainer(
        overrides: [
          appointmentServiceProvider.overrideWithValue(
            _AppointmentService(appointment: _reportedAppointment()),
          ),
          clientServiceProvider.overrideWithValue(clientService),
        ],
      );
      final subscription = container.listen(
        appointmentEditProvider('appointment-id'),
        (_, _) {},
      );

      try {
        await clientService.requested.future;
        final state = container.read(appointmentEditProvider('appointment-id'));
        expect(state.data.hasValue, isTrue);
        expect(state.companies.single.companyName, 'New Company 2026-10-10');

        clientResult.completeError(Exception('Lead has no client record'));
        await Future<void>.delayed(Duration.zero);
        expect(
          container
              .read(appointmentEditProvider('appointment-id'))
              .data
              .hasValue,
          isTrue,
        );
      } finally {
        if (!clientResult.isCompleted) {
          clientResult.complete(Client());
          await Future<void>.delayed(Duration.zero);
        }
        subscription.close();
        container.dispose();
      }
    },
  );
  test(
    'enriches tags without overwriting edits made while client loads',
    () async {
      final clientResult = Completer<Client>();
      final clientService = _ClientService(clientResult.future);
      final container = ProviderContainer(
        overrides: [
          appointmentServiceProvider.overrideWithValue(
            _AppointmentService(appointment: _reportedAppointment()),
          ),
          clientServiceProvider.overrideWithValue(clientService),
        ],
      );
      final subscription = container.listen(
        appointmentEditProvider('appointment-id'),
        (_, _) {},
      );

      try {
        await clientService.requested.future;
        container
            .read(appointmentEditProvider('appointment-id').notifier)
            .setMobile('0123456789');
        clientResult.complete(
          Client(
            tags: [Tag(tagId: 'tag-id', tagName: 'Follow up')],
          ),
        );
        await Future<void>.delayed(Duration.zero);

        final state = container.read(appointmentEditProvider('appointment-id'));
        expect(state.data.requireValue.phone, '0123456789');
        expect(state.data.requireValue.tags.single.tagName, 'Follow up');
        expect(state.isDirty, isTrue);
      } finally {
        if (!clientResult.isCompleted) {
          clientResult.complete(Client());
          await Future<void>.delayed(Duration.zero);
        }
        subscription.close();
        container.dispose();
      }
    },
  );
}

AppointmentDetail _reportedAppointment() {
  final json =
      jsonDecode(
            File(
              'test/features/appointment/models/fixtures/appointment_detail_response.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  return AppointmentDetail.fromJson(json['appointment'][0]);
}

Future<AppointmentEditState> _load(
  AppointmentService appointmentService,
  ClientService clientService,
) async {
  final container = ProviderContainer(
    overrides: [
      appointmentServiceProvider.overrideWithValue(appointmentService),
      clientServiceProvider.overrideWithValue(clientService),
    ],
  );
  final loaded = Completer<AppointmentEditState>();
  final subscription = container.listen(
    appointmentEditProvider('appointment-id'),
    (_, next) {
      if (!next.data.isLoading && !loaded.isCompleted) {
        loaded.complete(next);
      }
    },
    fireImmediately: true,
  );
  try {
    return await loaded.future.timeout(const Duration(seconds: 1));
  } finally {
    subscription.close();
    container.dispose();
  }
}

class _AppointmentService extends AppointmentService {
  _AppointmentService({this.appointment, this.error});
  final AppointmentDetail? appointment;
  final Exception? error;

  @override
  Future<AppointmentDetail> fetchAppointmentById(
    Ref ref,
    String appointmentID,
  ) async {
    if (error != null) throw error!;
    return appointment!;
  }
}

class _ClientService extends ClientService {
  _ClientService(this.result);
  final Future<Client> result;
  final requested = Completer<void>();

  @override
  Future<Client> getById(Ref ref, String clientId) {
    if (!requested.isCompleted) requested.complete();
    return result;
  }
}
