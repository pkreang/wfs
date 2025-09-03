import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wfs/models/clientstatus_model.dart';
import 'package:wfs/models/company_model.dart';
import 'package:wfs/models/companyaddress.dart';
import 'package:wfs/models/district_model.dart';
import 'package:wfs/models/product_model.dart';
import 'package:wfs/models/province_model.dart';
import 'package:wfs/models/subdistrict_model.dart';
import 'package:wfs/models/territory_model.dart';
import 'package:wfs/providers/auth_provider.dart';
import 'package:wfs/providers/clientstatus_provider.dart';
import 'package:wfs/providers/company_provider.dart';
import 'package:wfs/providers/district_provider.dart';
import 'package:wfs/providers/province_provider.dart';
import 'package:wfs/providers/saleterritorie_provider.dart';
import 'package:wfs/providers/subdistrict_provider.dart';
import 'package:wfs/services/company_service.dart';
import 'package:wfs/utility/appdialogs.dart';
import 'package:wfs/utility/validator.dart';
import 'package:wfs/widgets/app_cupertino_option.dart';
import 'package:wfs/widgets/app_text.dart';
import 'package:wfs/widgets/app_text_form_field.dart';

class Item {
  final String id;
  final String name;

  Item({required this.id, required this.name});
}

class CreateCompanyScreen extends ConsumerStatefulWidget {
  const CreateCompanyScreen({super.key});

  @override
  ConsumerState<CreateCompanyScreen> createState() =>
      _CreateCompanyScreenState();
}

class _CreateCompanyScreenState extends ConsumerState<CreateCompanyScreen> {
  static const colorPrimary = Color(0xFF007AFF);
  static const colorGrey = Color(0xFFC7C7CC);
  static const borderWidth = 0.33;
  static const borderSide = BorderSide(color: colorGrey, width: borderWidth);
  String? selectStatus;
  String? product;
  String? commany;
  String? salesTerritory;
  DateTime? dateTimeFrom;
  DateTime? dateTimeTo;
  final TextEditingController txtAddress = TextEditingController();
  final TextEditingController txtClientName = TextEditingController();
  final TextEditingController txtPhone = TextEditingController();
  final TextEditingController txtEmail = TextEditingController();
  final TextEditingController txtCompanyName = TextEditingController();
  final TextEditingController txtTaxID = TextEditingController();
  final TextEditingController txtPostCode = TextEditingController();
  String? postCode;
  List<Product> selectedProduct = [];
  List<Company> selectedCompany = [];
  String? selectedProvince;
  String? selectedProvinceName;
  String? selectedDistrict;
  String? selectedDistrictName;
  String? selectedSubdistrict;
  String? selectedSubdistrictName;
  String? selectClientStatusName;
  String? selectClientStatus;
  String? selectSalesTerritorysName;
  String? selectSalesTerritorys;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                style: ButtonStyle(
                  iconColor: WidgetStateProperty.all(colorPrimary),
                ),
              ),
              const AppText(label: 'Back', textColor: colorPrimary),
            ],
          ),
        ),
        title: const AppText(
          label: 'Create Company',
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          TextButton(
            onPressed: () {
              String? error;
              error = Validator.required(txtCompanyName.text);
              if (error != null) {
                AppDialogs.error(context, message: error + " Name");
                return;
              }

              error = Validator.required(txtTaxID.text);
              if (error != null) {
                AppDialogs.error(context, message: error + " Tax ID");
                return;
              }

              error = Validator.required(selectClientStatus);
              if (error != null) {
                AppDialogs.error(context, message: "กรุณาเลือก Status");
                return;
              }

              error = Validator.required(selectSalesTerritorys);
              if (error != null) {
                AppDialogs.error(context, message: "กรุณาเลือก Territory");
                return;
              }

              error = Validator.required(txtAddress.text);
              if (error != null) {
                AppDialogs.error(context, message: error + " Address");
                return;
              }

              if (selectedProvince == null) {
                AppDialogs.error(context, message: "กรุณาเลือก Province");
                return;
              }

              if (selectedDistrict == null) {
                AppDialogs.error(context, message: "กรุณาเลือก District");
                return;
              }

              if (selectedSubdistrict == null) {
                AppDialogs.error(context, message: "กรุณาเลือก SubDistrict");
                return;
              }

              error = Validator.required(postCode);
              if (error != null) {
                AppDialogs.error(context, message: error + "PostCode");
                return;
              }
              final authState = ref.watch(authProvider);
              Company company = Company(
                companyName: txtCompanyName.text,
                taxID: txtTaxID.text,
                salesTerritoryID: selectSalesTerritorys,
                noted: "xxxxxxxxxxxxxxx",
                isActive: true,
                createdDate: DateTime.now().toIso8601String(),
                modifiedDate: DateTime.now().toIso8601String(),
                createdBy: authState.userID,
                modifiedBy: authState.userID,
                CompanyAddresses: [
                  CompanyAddress(
                    address: txtAddress.text, //"123 ABC Rd.",
                    provinceID: int.parse(selectedProvince!), //1,
                    districtID: int.parse(selectedDistrict!), // 13,
                    latitude: null,
                    isPrimary: true,
                    createdBy: authState.userID,
                    modifiedBy: authState.userID,
                    countryID: 1,
                    subDistrictID: int.parse(selectedSubdistrict!), // 2583
                    longitude: null,
                    isActive: true,
                  ),
                ],
                Clients: null,
              );
              CompanyService companyService = new CompanyService();
              final accessToken = authState.accessToken;
              try {
                companyService.Add(accessToken.toString(), company);
                // ignore: unused_result
                ref.refresh(filteredCompaniesProvider);
                // ignore: unused_result
                ref.refresh(companiesProvider);
                // ignore: unused_result
                ref.refresh(companySectionsProvider);

                AppDialogs.success(context);
                Future.delayed(const Duration(seconds: 3), () {
                  context.push('/company');
                });
              } catch (ex) {
                AppDialogs.error(context, message: ex.toString());
              }
            },
            style: TextButton.styleFrom(foregroundColor: colorPrimary),
            child: const AppText(label: 'Done', textColor: colorPrimary),
          ),
        ],
      ),
      body: ListView(children: [buildContent()]),
    );
  }

  Widget infoTile({
    required String label,
    required Widget value,
    VoidCallback? onTap,
    double height = 44,
    bool isShowBorderMiddle = true,
    bool isShowBorderBottom = false,
    bool isHideIcon = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          border: Border(
            top: borderSide,
            bottom: isShowBorderBottom ? borderSide : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Container(
              width: 100,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: BorderDirectional(
                  end: isShowBorderMiddle
                      ? const BorderSide(color: colorGrey, width: borderWidth)
                      : BorderSide.none,
                ),
              ),
              child: AppText(label: label, textColor: const Color(0xFF007AFF)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Align(alignment: Alignment.centerLeft, child: value),
            ),
            if (!isHideIcon) ...[
              const Icon(Icons.chevron_right, size: 24, color: colorGrey),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget infoTileDropdown({
    required String label,
    required Widget value,
    VoidCallback? onTap,
    double height = 44,
    bool isShowBorderMiddle = true,
    bool isShowBorderBottom = false,
    bool isHideIcon = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          border: Border(
            top: borderSide,
            bottom: isShowBorderBottom ? borderSide : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Align(alignment: Alignment.centerLeft, child: value),
            ),
            if (!isHideIcon) ...[
              const Icon(Icons.chevron_right, size: 24, color: colorGrey),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildContent() {
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
                  infoTile(
                    label: 'Name',
                    value: AppTextFormField(controller: txtCompanyName),
                    isShowBorderBottom: true,
                    isHideIcon: true,
                  ),
                  infoTile(
                    label: 'Tax ID',
                    value: AppTextFormField(controller: txtTaxID),
                    isShowBorderBottom: true,
                    isHideIcon: true,
                  ),
                  Container(color: Color(0xFFEEEEEE), height: 30),
                  infoTile(
                    label: 'status',
                    value: AppText(label: selectClientStatusName ?? ''),
                    onTap: () =>
                        openStatusSheet(context, selectClientStatusName ?? ""),
                    isShowBorderBottom: true,
                  ),
                  infoTile(
                    label: 'territory',
                    value: AppText(label: selectSalesTerritorysName ?? ''),
                    onTap: () => openTerritorySheet(
                      context,
                      selectSalesTerritorysName ?? '',
                    ),
                    isShowBorderBottom: true,
                  ),
                ],
              ),
              Container(color: Color(0xFFEEEEEE), height: 5),
              addressWidget(),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> openTerritorySheet(
    BuildContext context,
    String territoryID,
  ) async {
    final selected = await CupertinoOptionsPicker.show<Territory>(
      context: context,
      title: 'Territory',
      provider: territoryGetListProvider,
      label: (p) => p.salesTerritoryName,
      initialKey: (p) => p.salesTerritoryID,
      initialValue: territoryID,
    );

    if (selected == null) return;
    setState(() {
      selectSalesTerritorysName = selected.salesTerritoryName;
      selectSalesTerritorys = selected.salesTerritoryID;
    });
  }

  Future<void> openStatusSheet(BuildContext context, String statusID) async {
    final selected = await CupertinoOptionsPicker.show<ClientStatus>(
      context: context,
      title: 'Status',
      provider: ClientStatusGetList,
      label: (p) => p.clientStatusName.toString(),
      initialKey: (p) => p.clientStatusID.toString(),
      initialValue: statusID,
    );

    if (selected == null) return;
    setState(() {
      selectClientStatus = selected.clientStatusID;
      selectClientStatusName = selected.clientStatusName;
    });
  }

  Widget addressWidget() {
    Widget addressField({
      required Widget child,
      bool hasRightBorder = false,
      bool hasBottomBorder = true,
    }) {
      return Container(
        height: 44,
        decoration: BoxDecoration(
          border: Border(
            right: hasRightBorder ? borderSide : BorderSide.none,
            bottom: hasBottomBorder ? borderSide : BorderSide.none,
          ),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        child: child,
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: borderSide, bottom: borderSide),
      ),
      child: Stack(
        children: [
          const Positioned(
            left: 16 + 100,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: borderWidth,
              child: ColoredBox(color: colorGrey),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 16),
              const SizedBox(
                width: 100,
                child: Center(
                  child: AppText(
                    label: 'address',
                    textColor: Color(0xFF007AFF),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    addressField(
                      child: AppTextFormField(controller: txtAddress),
                    ),
                    addressField(
                      hasRightBorder: false,
                      child: infoTileDropdown(
                        label: selectedSubdistrictName ?? '',
                        value: AppText(label: selectedSubdistrictName ?? ''),
                        onTap: () => openSubDistrictSheet(
                          context,
                          selectedSubdistrictName ?? "",
                        ),
                        isShowBorderBottom: true,
                        isHideIcon: true,
                      ),
                    ),
                    addressField(
                      child: infoTileDropdown(
                        label: selectedDistrictName ?? '',
                        value: AppText(label: selectedDistrictName ?? ''),
                        onTap: () => openDistrictSheet(
                          context,
                          selectedDistrictName ?? "",
                        ),
                        isShowBorderBottom: true,
                        isHideIcon: true,
                      ),
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: addressField(
                            hasRightBorder: true,
                            child: infoTileDropdown(
                              label: selectedProvinceName ?? '',
                              value: AppText(label: selectedProvinceName ?? ''),
                              onTap: () => openProvinceSheet(
                                context,
                                selectedProvinceName ?? "",
                              ),
                              isShowBorderBottom: true,
                              isHideIcon: true,
                            ),
                          ),
                        ),
                        Expanded(
                          child: addressField(child: AppText(label: "ไทย")),
                        ),
                      ],
                    ),
                    addressField(
                      child: AppText(label: postCode ?? ""),
                      hasBottomBorder: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> openProvinceSheet(
    BuildContext context,
    String subdistrictID,
  ) async {
    final selected = await CupertinoOptionsPicker.show<Province>(
      context: context,
      title: 'Province',
      provider: provincesProvider,
      label: (p) => p.provinceName.toString(),
      initialKey: (p) => p.provinceID.toString(),
      initialValue: subdistrictID,
    );

    if (selected == null) return;
    setState(() {
      selectedProvince = selected.provinceID.toString();
      selectedProvinceName = selected.provinceName;
      selectedDistrict = null;
      selectedSubdistrict = null;
      txtPostCode.text = "";
      postCode = "";
    });
  }

  Future<void> openDistrictSheet(
    BuildContext context,
    String subdistrictID,
  ) async {
    final selected = await CupertinoOptionsPicker.show<District>(
      context: context,
      title: 'District',
      provider: districtsProvider(selectedProvince ?? ""),
      label: (p) => p.districtName.toString(),
      initialKey: (p) => p.districtID.toString(),
      initialValue: subdistrictID,
    );

    if (selected == null) return;
    setState(() {
      selectedDistrict = selected.districtID.toString();
      selectedDistrictName = selected.districtName;
      selectedSubdistrict = null;
      txtPostCode.text = "";
      postCode = "";
    });
  }

  Future<void> openSubDistrictSheet(
    BuildContext context,
    String subdistrictID,
  ) async {
    final selected = await CupertinoOptionsPicker.show<Subdistrict>(
      context: context,
      title: 'SubDistrict',
      provider: subdistrictsProvider(selectedDistrict ?? ""),
      label: (p) => p.subDistrictName.toString(),
      initialKey: (p) => p.subDistrictID.toString(),
      initialValue: subdistrictID,
    );

    if (selected == null) return;
    setState(() {
      selectedSubdistrict = selected.subDistrictID.toString();
      selectedSubdistrictName = selected.subDistrictName;
      txtPostCode.text = selected.postCode ?? "";
      postCode = selected.postCode ?? "";
    });
  }
}
