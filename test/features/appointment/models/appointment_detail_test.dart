import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wfs/features/appointment/models/appointment_detail.dart';

void main() {
  group('AppointmentDetail action visibility', () {
    for (final checkIn in [false, true]) {
      for (final complete in [false, true]) {
        test(
          'preserves check-in=$checkIn and complete=$complete when enriching tags',
          () {
            final json =
                _appointmentJson(addresses: const [], clientEmail: null)
                  ..['isShowIconCheckIn'] = checkIn
                  ..['isShowIconComplete'] = complete;
            final appointment = AppointmentDetail.fromJson(json);
            final enriched = appointment.copyWith(tags: []);

            expect(enriched.isShowIconCheckIn, checkIn);
            expect(enriched.isShowIconComplete, complete);
          },
        );
      }
    }

    test('defaults missing visibility flags to false', () {
      final appointment = AppointmentDetail.fromJson(
        _appointmentJson(addresses: const [], clientEmail: null),
      );

      expect(appointment.isShowIconCheckIn, isFalse);
      expect(appointment.isShowIconComplete, isFalse);
    });

    test('allows explicitly clearing visibility flags', () {
      final json = _appointmentJson(addresses: const [], clientEmail: null)
        ..['isShowIconCheckIn'] = true
        ..['isShowIconComplete'] = true;
      final appointment = AppointmentDetail.fromJson(
        json,
      ).copyWith(isShowIconCheckIn: false, isShowIconComplete: false);

      expect(appointment.isShowIconCheckIn, isFalse);
      expect(appointment.isShowIconComplete, isFalse);
    });
  });

  group('AppointmentDetail.fromJson', () {
    test('parses the reported appointment detail response', () {
      final response =
          jsonDecode(
                File(
                  'test/features/appointment/models/fixtures/appointment_detail_response.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      final appointment = AppointmentDetail.fromJson(
        response['appointment'][0],
      );

      expect(response['status'], 'success');
      expect(appointment.appointmentID, '3300A23A-ED86-471C-B2F9-8B7C61C55747');
      expect(appointment.appointmentTitle, 'นัดพบลูกค้า');
      expect(appointment.address.address, '88/8');
      expect(appointment.address.latitude, 0.0);
      expect(appointment.address.longitude, 0.0);
      expect(appointment.client.clientStatusName, 'Lead');
      expect(appointment.client.salesTerritory?.salesTerritoryName, 'T2');
      expect(
        appointment.client.companies.single.company?.addresses.single.address,
        '88/8',
      );
      expect(appointment.client.availableTimeStart, isEmpty);
      expect(appointment.client.availableTimeEnd, isEmpty);
      expect(appointment.tags, isEmpty);
      expect(appointment.products, isEmpty);
      expect(appointment.visitActivities, isEmpty);
      expect(appointment.isShowIconCheckIn, isTrue);
      expect(appointment.isShowIconComplete, isFalse);
    });

    test(
      'keeps parsing an existing appointment with address and client data',
      () {
        final appointment = AppointmentDetail.fromJson(
          _appointmentJson(
            addresses: [
              {
                'Latitude': 13.7563,
                'Longitude': 100.5018,
                'Address': 'Bangkok',
                'SubDistrictID': 1,
                'DistrictID': 2,
                'ProvinceID': 3,
                'CountryID': 1,
              },
            ],
            clientEmail: 'client@example.com',
          ),
        );

        expect(appointment.appointmentID, 'appointment-id');
        expect(appointment.address.address, 'Bangkok');
        expect(appointment.address.latitude, 13.7563);
        expect(appointment.client.email, 'client@example.com');
        expect(appointment.client.firstName, 'Existing');
      },
    );

    test(
      'parses a task-created appointment with no address and null email',
      () {
        final appointment = AppointmentDetail.fromJson(
          _appointmentJson(addresses: const [], clientEmail: null),
        );

        expect(appointment.appointmentID, 'appointment-id');
        expect(appointment.address.address, isNull);
        expect(appointment.address.latitude, isNull);
        expect(appointment.client.email, isEmpty);
        expect(appointment.products, isEmpty);
        expect(appointment.visitActivities, isEmpty);
      },
    );
  });
}

Map<String, dynamic> _appointmentJson({
  required List<Map<String, dynamic>> addresses,
  required String? clientEmail,
}) {
  return {
    'UserID': 'user-id',
    'ClientID': 'client-id',
    'ClientName': 'Existing Client',
    'Noted': 'Appointment note',
    'AssignedBy': null,
    'AppointmentTitle': 'Appointment title',
    'AppointmentTypeID': 'type-id',
    'AppointmentTypeName': 'Client Visit',
    'AppointmentStatusID': 'status-id',
    'AppointmentStatusName': 'Scheduled',
    'AppointmentID': 'appointment-id',
    'PurposeTypeID': 'purpose-id',
    'PurposeTypeName': 'Product Demonstration',
    'CompanyID': 'company-id',
    'CompanyName': 'Company',
    'AppointmentDateTimeFrom': '2026-08-24T02:34:00',
    'AppointmentDateTimeTo': '2026-08-24T02:39:00',
    'PurposeOther': null,
    'addresses': addresses,
    'Phone': null,
    'Email': null,
    'products': <Map<String, dynamic>>[],
    'VisitActivities': <Map<String, dynamic>>[],
    'Client': {
      'ClientID': 'client-id',
      'ClientLevelID': 'level-id',
      'ClientLevelName': 'A',
      'ClientStatusID': 'status-id',
      'ClientStatusName': 'Active',
      'FirstName': 'Existing',
      'LastName': 'Client',
      'Noted': null,
      'Phone': '-',
      'Email': clientEmail,
      'AvailableTimeStart': null,
      'AvailableTimeEnd': null,
      'SalesTerritory': null,
      'SalesTerritoryID': null,
      'SalesTerritoryName': null,
      'companies': <Map<String, dynamic>>[],
    },
    'ModifiedBy': 'user-id',
    'CreatedBy': 'user-id',
    'IsActive': true,
    'SaleName': 'Sales User',
    'tags': <Map<String, dynamic>>[],
  };
}
