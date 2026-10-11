import 'package:flutter_test/flutter_test.dart';
import 'package:wfs/features/company/models/company_address.dart';
import 'package:wfs/features/lead/models/lead.dart';
import 'package:wfs/models/auth_model.dart';

const _companyID = '942464E0-B705-4E0A-BBE9-45DB1768560B';
const _companyName = 'New Company 2026-10-10';
const _address = {
  'CompanyAddressID': '2652DCEA-2103-4893-BD45-E6A0209E36EC',
  'CompanyID': _companyID,
  'Address': '88/8',
  'ProvinceID': 1,
  'ProvinceName': 'กรุงเทพมหานคร',
  'DistrictID': 13,
  'DistrictName': 'คลองเตย',
  'SubDistrictID': 2583,
  'SubDistrictName': 'คลองตัน',
  'PostCode': '10110',
  'Latitude': '0.000000',
  'Longitude': '0.000000',
  'IsPrimary': false,
  'IsActive': false,
  'CountryID': 1,
  'CountryName': 'ไทย',
};
const _companyLink = {
  'ClientCompanyID': 'A40F93F6-94B7-4AC0-A600-7EB1F3B3487C',
  'ClientID': '62F113FF-E60E-4211-9749-693B463F3B9B',
  'CompanyID': _companyID,
  'Position': null,
  'Noted': null,
  'AvailableTimeStart': null,
  'AvailableTimeEnd': null,
  'IsActive': true,
  'Company': {
    'CompanyID': _companyID,
    'CompanyName': _companyName,
    'TaxID': '0888888888',
    'Noted': '',
    'SalesTerritoryID': 'C72CD6FD-0E5B-4A67-92FA-08CCB0C2FF30',
    'IsActive': true,
    'addresses': [_address],
  },
};
const _response = {
  'lead_id': '62F113FF-E60E-4211-9749-693B463F3B9B',
  'company_id': _companyID,
  'company_name': _companyName,
  'company_address': null,
  'companies': [_companyLink],
  'SalesTerritoryID': 'C72CD6FD-0E5B-4A67-92FA-08CCB0C2FF30',
  'SalesTerritoryName': 'T2',
};

void main() {
  group('Lead company responses', () {
    test('reads nested company, relationship and string coordinates', () {
      final lead = Lead.fromJson(_response);

      expect(lead.companyID, _companyID);
      expect(lead.companyName, _companyName);
      expect(lead.company?.companyID, _companyID);
      expect(lead.company?.taxID, '0888888888');
      expect(
        lead.companies.single.clientCompanyID,
        _companyLink['ClientCompanyID'],
      );
      expect(lead.companies.single.clientID, _response['lead_id']);
      expect(lead.companies.single.position, isNull);
      expect(lead.companies.single.isActive, isTrue);
      final address = lead.company!.addresses.single;
      expect(address.latitude, 0.0);
      expect(address.longitude, 0.0);
      expect(
        address.fullAddress,
        '88/8 คลองตัน คลองเตย กรุงเทพมหานคร 10110 ไทย',
      );
      expect(address.isActive, isFalse);
    });

    test('keeps legacy company_address responses working', () {
      final lead = Lead.fromJson({
        'company_id': _companyID,
        'company_name': _companyName,
        'company_address': {..._address, 'Latitude': 13.75, 'Longitude': 100},
      });

      expect(lead.companies, isEmpty);
      expect(lead.company?.companyID, _companyID);
      expect(lead.company?.companyName, _companyName);
      expect(lead.company?.addresses.single.latitude, 13.75);
      expect(lead.company?.addresses.single.longitude, 100.0);
    });

    test('prefers legacy address when both formats are provided', () {
      final lead = Lead.fromJson({
        ..._response,
        'company_address': {..._address, 'Address': 'Legacy address'},
      });

      expect(lead.company?.addresses.single.address, 'Legacy address');
      expect(lead.companies.single.company?.addresses.single.address, '88/8');
    });

    test('selects the matching company instead of the first entry', () {
      final lead = Lead.fromJson({
        ..._response,
        'companies': [
          {
            'CompanyID': 'other-company',
            'Company': {'CompanyID': 'other-company', 'CompanyName': 'Other'},
          },
          _companyLink,
        ],
      });

      expect(lead.companies, hasLength(2));
      expect(lead.company?.companyID, _companyID);
    });

    test('does not select an unrelated company when ID is unmatched', () {
      final lead = Lead.fromJson({
        ..._response,
        'company_id': 'missing-company',
      });

      expect(lead.company, isNull);
      expect(lead.companies, hasLength(1));
    });

    test('uses first nested company when top-level ID is absent', () {
      final lead = Lead.fromJson({..._response, 'company_id': null});

      expect(lead.company?.companyID, _companyID);
    });

    test('accepts absent, null and empty companies', () {
      for (final response in <Map<String, dynamic>>[
        {},
        {'companies': null},
        {'companies': []},
      ]) {
        final lead = Lead.fromJson(response);
        expect(lead.companies, isEmpty);
        expect(lead.company, isNull);
      }
    });

    test('preserves company data and territory when updating other fields', () {
      final original = Lead.fromJson(_response);
      final updated = original.copyWith(note: 'Updated');

      expect(updated.note, 'Updated');
      expect(updated.company, same(original.company));
      expect(updated.companies, same(original.companies));
      expect(updated.salesTerritoryID, original.salesTerritoryID);
      expect(updated.salesTerritoryName, 'T2');
    });

    test('keeps create payload company fields unchanged', () {
      final payload = Lead.fromJson(
        _response,
      ).toJsonCreate('user-id', AuthState());

      expect(payload['company_id'], _companyID);
      expect(payload['company_name'], _companyName);
      expect(payload.containsKey('companies'), isFalse);
      expect(payload.containsKey('company'), isFalse);
    });
  });

  test('address accepts null or invalid coordinates without throwing', () {
    final address = CompanyAddress.fromJson({
      'Latitude': null,
      'Longitude': 'invalid',
    });

    expect(address.latitude, isNull);
    expect(address.longitude, isNull);
  });
}
