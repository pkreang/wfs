import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/http/api_client.dart';
import 'package:wfs/features/company/models/company.dart';
import 'package:wfs/providers/auth_provider.dart';

class CompanyService {
  final apiClient = ApiClient('https://sfe-api.appnormalthink.com');

  Future<List<Company>> fetchCompanies(Ref ref) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    final companies = await apiClient.get(
      path: "/company/?IsActive=true",
      decode: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['companies'] as List? ?? const [];

        return list.map((e) => Company.fromJson(e as Map<String, dynamic>)).toList();
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );

    return companies;
  }

  Future<Company> getById(Ref ref, String companyID) async {
    final authState = ref.read(authProvider);
    final accessToken = authState.accessToken;

    final company = await apiClient.get(
      path: "/company/?CompanyID=${companyID.toString()}/",
      decode: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['companies'] as List? ?? const [];
        if (list.isEmpty) {
          throw Exception('Company not found');
        }

        return Company.fromJson(list.first as Map<String, dynamic>);
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );

    return company;
  }

  Future<bool> createCompany(Company company, Ref ref) async {
    final authState = ref.watch(authProvider);
    final accessToken = authState.accessToken;
    final userID = authState.userID ?? '';

    return await apiClient.post(
      path: "/company/",
      body: company.toJsonCreate(userID, userID),
      decode: (json) {
        final map = json as Map<String, dynamic>;
        return (map['status'] as String?)?.toLowerCase() == "success";
      },
      headers: {"Authorization": "Bearer $accessToken"},
    );
  }

  Future<bool> updateCompany(Company company, Ref ref) async {
    final authState = ref.watch(authProvider);
    final accessToken = authState.accessToken;

    try {
      return await apiClient.put(path: "/company/${company.companyID.toString()}", body: company.toJsonUpdate(authState.userID ?? ''), headers: {"Authorization": "Bearer $accessToken"});
    } catch (e) {
      print('updateCompany catch: $e');
    }

    return false;
  }

  Future<bool> deleteCompany(String companyID, Ref ref) async {
    final authState = ref.watch(authProvider);
    final accessToken = authState.accessToken;

    try {
      return await apiClient.delete(path: "/company/${companyID.toString()}", headers: {"Authorization": "Bearer $accessToken"});
    } catch (e) {
      print('deleteCompany catch: $e');
      return false;
    }
  }
}
