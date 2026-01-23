import 'package:flutter/material.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/models/appointment_status.dart';
import 'package:wfs/features/appointment/models/appointment_type.dart';
import 'package:wfs/features/appointment/models/purpose.dart';
import 'package:wfs/features/appointment/models/territory.dart';
import 'package:wfs/features/appointment/widgets/app_cupertino_option.dart';
import 'package:wfs/features/client/models/client_level.dart';
import 'package:wfs/features/client/models/client_status.dart';
import 'package:wfs/features/company/models/company.dart';
import 'package:wfs/features/company/models/company_status.dart';
import 'package:wfs/models/district_model.dart';
import 'package:wfs/models/province_model.dart';
import 'package:wfs/models/subdistrict_model.dart';
import 'package:wfs/models/user_model.dart';
import 'package:wfs/models/userrole_model.dart';
import 'package:wfs/providers/district_provider.dart';
import 'package:wfs/providers/province_provider.dart';
import 'package:wfs/providers/subdistrict_provider.dart';

class AppSheet {
  static Future<void> openMeetingSheet({required BuildContext context, required String appointmentTypeID, required void Function(AppointmentType) onSelected}) async {
    final selected = await CupertinoOptionsPicker.show<AppointmentType>(
      context: context,
      title: 'Meeting',
      provider: appointmentTypeProvider,
      label: (p) => p.appointmentTypeName,
      initialKey: (p) => p.appointmentTypeID,
      initialValue: appointmentTypeID,
    );

    if (selected == null) return;

    onSelected(selected);
  }

  static Future<void> openAppointmentStatusSheet({required BuildContext context, required String appointmentStatusID, required void Function(AppointmentStatus) onSelected}) async {
    final selected = await CupertinoOptionsPicker.show<AppointmentStatus>(
      context: context,
      title: 'Status',
      provider: appointmentStatusProvider,
      label: (p) => p.appointmentStatusName,
      initialKey: (p) => p.appointmentStatusID,
      initialValue: appointmentStatusID,
    );

    if (selected == null) return;

    onSelected(selected);
  }

  static Future<void> openPurposeSheet({required BuildContext context, required String purposeTypeID, required void Function(Purpose) onSelected}) async {
    final selected = await CupertinoOptionsPicker.show<Purpose>(
      context: context,
      title: 'Purpose',
      provider: purposesProvider,
      label: (p) => p.purposeTypeName,
      initialKey: (p) => p.purposeTypeID,
      initialValue: purposeTypeID,
    );

    if (selected == null) return;

    onSelected(selected);
  }

  static Future<void> openTerritorySheet({required BuildContext context, required String territoryID, required void Function(Territory) onSelected}) async {
    final selected = await CupertinoOptionsPicker.show<Territory>(
      context: context,
      title: 'Territory',
      provider: territoryProvider,
      label: (p) => p.salesTerritoryName,
      initialKey: (p) => p.salesTerritoryID,
      initialValue: territoryID,
    );

    if (selected == null) return;

    onSelected(selected);
  }

  static Future<void> openCompanySheet({required BuildContext context, required String companyID, required void Function(Company) onSelected}) async {
    final selected = await CupertinoOptionsPicker.show<Company>(
      context: context,
      title: 'Company',
      provider: companysProvider,
      label: (p) => p.companyName ?? "",
      initialKey: (p) => p.companyID ?? "",
      initialValue: companyID,
    );

    if (selected == null) return;

    onSelected(selected);
  }

  static Future<void> openCompanyByIDSheet({required BuildContext context, required String companyID, required void Function(Company) onSelected}) async {
    final selected = await CupertinoOptionsPicker.show<Company>(
      context: context,
      title: 'Company',
      provider: companyByIDProvider(companyID),
      label: (p) => p.companyName ?? "",
      initialKey: (p) => p.companyID ?? "",
      initialValue: companyID,
    );

    if (selected == null) return;

    onSelected(selected);
  }

  static Future<void> openCompanyWithDataSheet({required BuildContext context, required String companyID, required List<Company> companyies, required void Function(Company) onSelected}) async {
    final selected = await CupertinoOptionsPicker.showWithData<Company, String>(
      context: context,
      title: 'Company',
      items: companyies,
      label: (p) => p.companyName ?? "",
      initialKey: (p) => p.companyID ?? "",
      initialValue: companyID,
    );

    if (selected == null) return;

    onSelected(selected);
  }

  static Future<void> openProvinceSheet({required BuildContext context, required String provinceID, required void Function(Province) onSelected}) async {
    final selected = await CupertinoOptionsPicker.show<Province>(
      context: context,
      title: 'Province',
      provider: provincesProvider,
      label: (p) => p.provinceName.toString(),
      initialKey: (p) => p.provinceID.toString(),
      initialValue: provinceID,
    );

    if (selected == null) return;

    onSelected(selected);
  }

  static Future<void> openDistrictSheet({required BuildContext context, required String provinceID, required String districtID, required void Function(District) onSelected}) async {
    final selected = await CupertinoOptionsPicker.show<District>(
      context: context,
      title: 'District',
      provider: districtsProvider(provinceID),
      label: (p) => p.districtName.toString(),
      initialKey: (p) => p.districtID.toString(),
      initialValue: districtID,
    );

    if (selected == null) return;

    onSelected(selected);
  }

  static Future<void> openSubDistrictSheet({required BuildContext context, required String districtID, required String subdistrictID, required void Function(Subdistrict) onSelected}) async {
    final selected = await CupertinoOptionsPicker.show<Subdistrict>(
      context: context,
      title: 'SubDistrict',
      provider: subdistrictsProvider(districtID),
      label: (p) => p.subDistrictName.toString(),
      initialKey: (p) => p.subDistrictID.toString(),
      initialValue: subdistrictID,
    );

    if (selected == null) return;

    onSelected(selected);
  }

  static Future<void> openClientStatusSheet({required BuildContext context, required String clientStatusID, required void Function(ClientStatus) onSelected}) async {
    final selected = await CupertinoOptionsPicker.show<ClientStatus>(
      context: context,
      title: 'Status',
      provider: clientStatusProvider,
      label: (p) => p.clientStatusName,
      initialKey: (p) => p.clientStatusID,
      initialValue: clientStatusID,
    );

    if (selected == null) return;

    onSelected(selected);
  }

  static Future<void> openClientLevelSheet({required BuildContext context, required String clientLevelID, required void Function(ClientLevel) onSelected}) async {
    final selected = await CupertinoOptionsPicker.show<ClientLevel>(
      context: context,
      title: 'Level',
      provider: clientLevelProvider,
      label: (p) => p.clientLevelName,
      initialKey: (p) => p.clientLevelID,
      initialValue: clientLevelID,
    );

    if (selected == null) return;

    onSelected(selected);
  }

  static Future<void> openCompanyStatusSheet({required BuildContext context, required bool isActive, required void Function(CompanyStatus) onSelected}) async {
    final selected = await CupertinoOptionsPicker.showWithData<CompanyStatus, bool>(
      context: context,
      title: 'Status',
      items: [
        CompanyStatus(isActive: true, statusName: "Active"),
        CompanyStatus(isActive: false, statusName: "Inactive"),
      ],
      label: (p) => p.statusName,
      initialKey: (p) => p.isActive,
      initialValue: isActive,
    );

    if (selected == null) return;

    onSelected(selected);
  }

  static Future<void> openSaleSheet({required BuildContext context, required String salesID, required void Function(User) onSelected}) async {
    final selected = await CupertinoOptionsPicker.show<User>(
      context: context,
      title: 'Sales',
      provider: saleProvider,
      label: (p) => p.firstName ?? '',
      initialKey: (p) => p.userID ?? '',
      initialValue: salesID,
    );

    if (selected == null) return;

    onSelected(selected);
  }

  static Future<void> openRoleSheet({required BuildContext context, required String userRoleID, required void Function(UserRole) onSelected}) async {
    final selected = await CupertinoOptionsPicker.show<UserRole>(
      context: context,
      title: 'Role',
      provider: userRoleProvider,
      label: (p) => p.userRoleName ?? '',
      initialKey: (p) => p.userRoleID ?? '',
      initialValue: userRoleID,
    );

    if (selected == null) return;

    onSelected(selected);
  }

  static Future<void> openSupervisorSheet({required BuildContext context, required String userID, required void Function(User) onSelected}) async {
    final selected = await CupertinoOptionsPicker.show<User>(
      context: context,
      title: 'Supervisor',
      provider: supervisorProvider,
      label: (p) => p.fullname,
      initialKey: (p) => p.userID ?? '',
      initialValue: userID,
    );

    if (selected == null) return;

    onSelected(selected);
  }
}
