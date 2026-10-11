import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/task/viewmodels/task_create_viewmodel.dart';
import 'package:wfs/features/lead/models/lead.dart';
import 'package:wfs/features/lead/services/lead_service.dart';

void main() {
  test('initializes a lead task with its company address', () async {
    final state = await _loadLead(_leadJson());
    final task = state.data.requireValue;
    final company = state.companies.single;
    final address = task.taskAddress!;

    expect(task.companyID, 'company-id');
    expect(task.companyName, 'RIS');
    expect(company.companyID, 'company-id');
    expect(company.companyName, 'RIS');
    expect(company.addresses.single.companyAddressID, 'company-address-id');
    expect(address.address, '1');
    expect(address.provinceID, 1);
    expect(address.provinceName, 'กรุงเทพมหานคร');
    expect(address.districtID, 13);
    expect(address.districtName, 'คลองเตย');
    expect(address.subDistrictID, 2583);
    expect(address.subDistrictName, 'คลองตัน');
    expect(address.postCode, '10110');
    expect(address.countryID, 1);
    expect(address.countryName, 'ไทย');
    expect(address.latitude, isNull);
    expect(address.longitude, isNull);
    expect(state.isDirty, isFalse);
  });

  test('preserves company address coordinates when supplied', () async {
    final json = _leadJson();
    final addressJson = json['company_address'] as Map<String, dynamic>;
    addressJson['Latitude'] = 13.7563;
    addressJson['Longitude'] = 100.5018;

    final state = await _loadLead(json);
    final address = state.data.requireValue.taskAddress!;

    expect(address.latitude, 13.7563);
    expect(address.longitude, 100.5018);
  });

  for (final omitAddress in [false, true]) {
    test(
      'handles ${omitAddress ? 'missing' : 'null'} company_address',
      () async {
        final json = _leadJson();
        if (omitAddress) {
          json.remove('company_address');
        } else {
          json['company_address'] = null;
        }

        final state = await _loadLead(json);

        expect(state.companies.single.companyID, 'company-id');
        expect(state.companies.single.addresses, isEmpty);
        expect(state.data.requireValue.taskAddress, isNull);
        expect(state.isDirty, isFalse);
      },
    );
  }
}

Future<TaskCreateState> _loadLead(Map<String, dynamic> json) async {
  final container = ProviderContainer(
    overrides: [leadServiceProvider.overrideWithValue(_LeadService(json))],
  );
  addTearDown(container.dispose);
  final loaded = Completer<TaskCreateState>();
  container.listen(
    taskCreateProvider((clientID: 'lead-id', clientType: 'LEAD')),
    (previous, next) {
      if (!next.data.isLoading && !loaded.isCompleted) {
        loaded.complete(next);
      }
    },
    fireImmediately: true,
  );
  return loaded.future.timeout(const Duration(seconds: 5));
}

class _LeadService extends LeadService {
  _LeadService(this.json);

  final Map<String, dynamic> json;

  @override
  Future<Lead> getById(Ref ref, String leadID) async => Lead.fromJson(json);
}

Map<String, dynamic> _leadJson() => {
  'lead_id': 'lead-id',
  'first_name': 'ซูปาคาบรา',
  'last_name': 'PurpleKiss',
  'company_id': 'company-id',
  'company_name': 'RIS',
  'company_address': {
    'CompanyID': 'company-id',
    'CompanyAddressID': 'company-address-id',
    'Address': '1',
    'ProvinceID': 1,
    'ProvinceName': 'กรุงเทพมหานคร',
    'DistrictID': 13,
    'DistrictName': 'คลองเตย',
    'SubDistrictID': 2583,
    'SubDistrictName': 'คลองตัน',
    'PostCode': '10110',
    'CountryID': 1,
    'CountryName': 'ไทย',
    'Latitude': null,
    'Longitude': null,
    'IsPrimary': true,
    'IsActive': true,
  },
};
