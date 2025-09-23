import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/models/address.dart';
import 'package:wfs/widgets/app_sheet.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/features/company/models/company.dart';
import 'package:wfs/features/company/widgets/company_status_capsule.dart';
import 'package:wfs/widgets/form_address.dart';
import 'package:wfs/widgets/form_info_tile.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/utility/appdialogs.dart';
import 'package:wfs/utility/validator.dart';
import 'package:wfs/widgets/app_text_form_field.dart';

class CompanyEditPage extends ConsumerStatefulWidget {
  final String companyID;
  const CompanyEditPage({required this.companyID, super.key});

  @override
  ConsumerState<CompanyEditPage> createState() => _CompanyEditPageState();
}

class _CompanyEditPageState extends ConsumerState<CompanyEditPage> {
  bool isInit = false;
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController taxIDController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  void handleSave() async {
    final asyncCompany = ref.read(companyEditProvider(widget.companyID)).data;
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

    final result = await ref.read(companyEditProvider(widget.companyID).notifier).updateCompany();
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
  void dispose() {
    companyNameController.dispose();
    taxIDController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(companyEditProvider(widget.companyID));
    final isDisabled = (state.isDirty && !state.isLoading);

    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            backgroundColor: Color(0xFFEEEEEE),
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Color(0xFFEEEEEE),
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
                    AppText(label: 'Back', textColor: AppUtility.colorPrimary),
                  ],
                ),
              ),
              title: AppText(label: 'Edit Company', fontSize: 17, fontWeight: FontWeight.w600),
              actions: [
                TextButton(
                  onPressed: isDisabled ? () => handleSave() : null,
                  style: TextButton.styleFrom(foregroundColor: isDisabled ? AppUtility.colorPrimary : Colors.grey),
                  child: AppText(label: 'Done', textColor: isDisabled ? AppUtility.colorPrimary : Colors.grey),
                ),
              ],
            ),
            body: state.data.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary)),
              error: (e, _) => Center(
                child: AppText(label: "Company Not Found", textColor: Colors.red),
              ),
              data: (company) => buildContent(company, state.companies),
            ),
          ),
        ),

        if (state.isLoading) ...[const ModalBarrier(color: Color(0x66000000), dismissible: false), const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary))],
      ],
    );
  }

  Widget buildContent(Company company, List<Company> companies) {
    final address = company.addresses.isNotEmpty ? Address.fromJson(company.addresses.first.toJson()) : Address();

    if (!isInit) {
      companyNameController.text = company.companyName ?? '';
      taxIDController.text = company.taxID ?? '';

      if (company.addresses.isNotEmpty) {
        latitudeController.text = (company.addresses.first.latitude ?? 0.0).toString();
        longitudeController.text = (company.addresses.first.longitude ?? 0.0).toString();
        addressController.text = company.addresses.first.address ?? '';
      }

      isInit = false;
    }

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
                    value: AppTextFormField(controller: companyNameController, onChanged: (value) => ref.read(companyEditProvider(widget.companyID).notifier).setCompanyName(value)),
                    isHideIcon: true,
                  ),
                  FormInfoTile(
                    label: 'Tax ID',
                    value: AppTextFormField(controller: taxIDController, isNumberOnly: true, onChanged: (value) => ref.read(companyEditProvider(widget.companyID).notifier).setTaxID(value)),
                    isHideIcon: true,
                  ),
                  FormInfoTile(
                    label: 'status',
                    value: CompanyStatusCapsule(isActive: company.isActive ?? false),
                    onTap: () => AppSheet.openCompanyStatusSheet(
                      context: context,
                      isActive: company.isActive ?? false,
                      onSelected: (value) => ref.read(companyEditProvider(widget.companyID).notifier).setIsActive(value),
                    ),
                  ),
                  FormInfoTile(
                    label: 'territory',
                    value: AppText(label: company.salesTerritoryName ?? ''),
                    onTap: () => AppSheet.openTerritorySheet(
                      context: context,
                      territoryID: company.salesTerritoryID ?? '',
                      onSelected: (value) => ref.read(companyEditProvider(widget.companyID).notifier).setTerritory(value),
                    ),
                    isShowBorderBottom: true,
                  ),
                ],
              ),
              Column(
                children: [
                  FormInfoTile(
                    label: 'latitude',
                    value: AppTextFormField(
                      controller: latitudeController,
                      isNumberOnly: true,
                      allowDecimal: true,
                      onChanged: (value) => ref.read(companyEditProvider(widget.companyID).notifier).setLatitude(double.tryParse(value)),
                    ),
                    isHideIcon: true,
                  ),
                  FormInfoTile(
                    label: 'longitude',
                    value: AppTextFormField(
                      controller: longitudeController,
                      isNumberOnly: true,
                      allowDecimal: true,
                      onChanged: (value) => ref.read(companyEditProvider(widget.companyID).notifier).setLongitude(double.tryParse(value)),
                    ),
                    isHideIcon: true,
                  ),
                  FormAddress(addressController: addressController, address: address, onSelected: (value) => ref.read(companyEditProvider(widget.companyID).notifier).setAddress(value)),
                ],
              ),

              // SizedBox(
              //   child: FormInfoTile(
              //     label: 'clients',
              //     value: company.clients.isEmpty
              //         ? GestureDetector(
              //             behavior: HitTestBehavior.opaque,
              //             onTap: () => AppSheet.openCompanyWithDataSheet(context: context, companyID: companyID, companyies: companies, onSelected: onSelected),
              //             child: const SizedBox(
              //               height: 44,
              //               child: Row(
              //                 spacing: 16,
              //                 children: [
              //                   Icon(Icons.add_circle, color: Color(0xFF31C859), size: 24),
              //                   AppText(label: 'add company'),
              //                 ],
              //               ),
              //             ),
              //           )
              //         : Row(
              //             children: [
              //               GestureDetector(
              //                 // onTap: () => onRemove(companyID),
              //                 child: Icon(Icons.remove_circle, color: Color(0xFFFF382B), size: 24),
              //               ),
              //               Expanded(
              //                 child: GestureDetector(
              //                   onTap: () => AppSheet.openCompanyWithDataSheet(context: context, companyID: companyID, companyies: companies, onSelected: onSelected),
              //                   child: Padding(
              //                     padding: const EdgeInsets.only(left: 16),
              //                     child: AppText(label: companyName),
              //                   ),
              //                 ),
              //               ),
              //             ],
              //           ),
              //     isShowBorderBottom: true,
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
