import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/models/address.dart';
import 'package:wfs/widgets/app_sheet.dart';
import 'package:wfs/features/company/models/company.dart';
import 'package:wfs/features/company/widgets/company_status_capsule.dart';
import 'package:wfs/widgets/form_address.dart';
import 'package:wfs/widgets/form_info_tile.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/utility/appdialogs.dart';
import 'package:wfs/utility/validator.dart';
import 'package:wfs/widgets/app_text.dart';
import 'package:wfs/widgets/app_text_form_field.dart';

class Item {
  final String id;
  final String name;

  Item({required this.id, required this.name});
}

class CreateCompanyPage extends ConsumerStatefulWidget {
  const CreateCompanyPage({super.key});

  @override
  ConsumerState<CreateCompanyPage> createState() => _CreateCompanyPageState();
}

class _CreateCompanyPageState extends ConsumerState<CreateCompanyPage> {
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController taxIDController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  void handleSave() async {
    final asyncCompany = ref.read(companyCreateProvider).data;
    final company = asyncCompany.value;

    if (company == null) {
      AppDialogs.error(context, message: "ไม่พบข้อมูล Comapny");
      return;
    }

    final companyAddress = company.addresses.isNotEmpty ? company.addresses.first : null;
    if (companyAddress == null) {
      AppDialogs.error(context, message: "ไม่พบข้อมูล Address");
      return;
    }

    if (Validator.required(companyNameController.text) != null) {
      AppDialogs.error(context, message: "กรุณากรอก CompanyName");
      return;
    }

    if (Validator.required(taxIDController.text) != null) {
      AppDialogs.error(context, message: "กรุณากรอก Tax ID");
      return;
    }

    if (Validator.required(company.salesTerritoryID) != null) {
      AppDialogs.error(context, message: "กรุณาเลือก Territory");
      return;
    }

    if (Validator.required(latitudeController.text) != null) {
      AppDialogs.error(context, message: "กรุณากรอกข้อมูล Latitude");
      return;
    }

    if (Validator.required(longitudeController.text) != null) {
      AppDialogs.error(context, message: "กรุณากรอกข้อมูล Longitude");
      return;
    }

    if (Validator.required(addressController.text) != null) {
      AppDialogs.error(context, message: "กรุณากรอกข้อมูล Address");
      return;
    }

    if (Validator.required((companyAddress.provinceID ?? '').toString()) != null) {
      AppDialogs.error(context, message: "กรุณาเลือก Province");
      return;
    }

    if (Validator.required((companyAddress.districtID ?? '').toString()) != null) {
      AppDialogs.error(context, message: "กรุณาเลือก District");
      return;
    }

    if (Validator.required((companyAddress.subDistrictID ?? '').toString()) != null) {
      AppDialogs.error(context, message: "กรุณาเลือก SubDistrict");
      return;
    }

    if (Validator.required(companyAddress.postCode) != null) {
      AppDialogs.error(context, message: "ไม่มีข้อมูล PostCode");
      return;
    }

    final result = await ref.read(companyCreateProvider.notifier).createCompany();
    if (!result) {
      final errMsg = ref.read(companyCreateProvider).errorMessage;
      if (errMsg != null && errMsg.isNotEmpty) {
        AppDialogs.alert(context, title: 'ไม่สามารถดำเนินการได้', message: errMsg);
      }

      return;
    }

    AppDialogs.success(context, btnOkOnPress: () => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(companyCreateProvider);

    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            backgroundColor: const Color(0xFFEEEEEE),
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: const Color(0xFFEEEEEE),
              leadingWidth: 100,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: null,
                      style: ButtonStyle(iconColor: WidgetStateProperty.all(AppUtility.colorPrimary)),
                    ),
                    const AppText(label: 'Back', textColor: AppUtility.colorPrimary),
                  ],
                ),
              ),
              title: const AppText(label: 'Create Company', fontSize: 17, fontWeight: FontWeight.w600),
              actions: [
                TextButton(
                  onPressed: () => handleSave(),
                  style: TextButton.styleFrom(foregroundColor: AppUtility.colorPrimary),
                  child: const AppText(label: 'Done', textColor: AppUtility.colorPrimary),
                ),
              ],
            ),
            body: state.data.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary)),
              error: (e, _) => Center(
                child: AppText(label: "Company Not Found", textColor: Colors.red),
              ),
              data: (company) => buildContent(company),
            ),
          ),
        ),

        if (state.isLoading) ...[const ModalBarrier(color: Color(0x66000000), dismissible: false), const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary))],
      ],
    );
  }

  Widget buildContent(Company company) {
    final address = company.addresses.isNotEmpty ? Address.fromJson(company.addresses.first.toJson()) : Address();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 24,
        children: [
          Column(
            spacing: 16,
            children: [
              Column(
                children: [
                  FormInfoTile(
                    label: 'Name',
                    value: AppTextFormField(controller: companyNameController, onChanged: (value) => ref.read(companyCreateProvider.notifier).setCompanyName(value)),
                    isHideIcon: true,
                  ),
                  FormInfoTile(
                    label: 'Tax ID',
                    value: AppTextFormField(controller: taxIDController, isNumberOnly: true, onChanged: (value) => ref.read(companyCreateProvider.notifier).setTaxID(value)),
                    isHideIcon: true,
                  ),
                  FormInfoTile(
                    label: 'status',
                    value: CompanyStatusCapsule(isActive: company.isActive ?? false),
                    onTap: () =>
                        AppSheet.openCompanyStatusSheet(context: context, isActive: company.isActive ?? false, onSelected: (value) => ref.read(companyCreateProvider.notifier).setIsActive(value)),
                  ),
                  FormInfoTile(
                    label: 'territory',
                    value: AppText(label: company.salesTerritoryName ?? ''),
                    onTap: () =>
                        AppSheet.openTerritorySheet(context: context, territoryID: company.salesTerritoryID ?? '', onSelected: (value) => ref.read(companyCreateProvider.notifier).setTerritory(value)),
                    isShowBorderBottom: true,
                  ),
                ],
              ),
              Container(color: Color(0xFFEEEEEE), height: 5),
              Column(
                children: [
                  FormInfoTile(
                    label: 'latitude',
                    value: AppTextFormField(
                      controller: latitudeController,
                      isNumberOnly: true,
                      allowDecimal: true,
                      onChanged: (value) => ref.read(companyCreateProvider.notifier).setLatitude(double.tryParse(value)),
                    ),
                    isHideIcon: true,
                  ),
                  FormInfoTile(
                    label: 'longitude',
                    value: AppTextFormField(
                      controller: longitudeController,
                      isNumberOnly: true,
                      allowDecimal: true,
                      onChanged: (value) => ref.read(companyCreateProvider.notifier).setLongitude(double.tryParse(value)),
                    ),
                    isHideIcon: true,
                  ),
                  FormAddress(addressController: addressController, address: address, onSelected: (value) => ref.read(companyCreateProvider.notifier).setAddress(value)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
