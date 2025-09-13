import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wfs/main.dart';
import 'package:wfs/models/appointmentaddress_model.dart' show AppointmentAddress;
import 'package:wfs/models/appointments_model.dart';
import 'package:wfs/models/appointmentstatus_model.dart';
import 'package:wfs/models/company_model.dart';
import 'package:wfs/models/district_model.dart';
import 'package:wfs/models/product_model.dart';
import 'package:wfs/models/province_model.dart';
import 'package:wfs/models/purposetype_model.dart';
import 'package:wfs/models/subdistrict_model.dart';
import 'package:wfs/models/territory_model.dart';
import 'package:wfs/providers/appointment_provider.dart';
import 'package:wfs/providers/appointmentstatus_provider.dart';
import 'package:wfs/providers/auth_provider.dart';
import 'package:wfs/providers/client_provider.dart';
import 'package:wfs/providers/company_provider.dart';
import 'package:wfs/providers/district_provider.dart';
import 'package:wfs/providers/product_provider.dart';
import 'package:wfs/providers/province_provider.dart';
import 'package:wfs/providers/purposetype_provider.dart';
import 'package:wfs/providers/saleterritorie_provider.dart';
import 'package:wfs/providers/subdistrict_provider.dart';
import 'package:wfs/services/appointment_service.dart';
import 'package:wfs/utility/appdialogs.dart';
import 'package:wfs/utility/date_picker_helper.dart';
import 'package:wfs/utility/time_picker_helper.dart';
import 'package:wfs/utility/validator.dart';
import 'package:wfs/widgets/app_cupertino_option.dart';
import 'package:wfs/widgets/app_text.dart';
import 'package:wfs/widgets/app_text_form_field.dart';

class CreateAppointmentScreen extends ConsumerStatefulWidget {
  const CreateAppointmentScreen({super.key});

  @override
  ConsumerState<CreateAppointmentScreen> createState() => _CreateAppointmentScreenState();
}

class _CreateAppointmentScreenState extends ConsumerState<CreateAppointmentScreen> {
  String? selectedPurpose;
  String? salesTerritory;
  String? appointmentStatus;
  String? company;
  DateTime? dateTimeFrom = DateTime.now();
  DateTime? dateTimeTo = DateTime.now();
  String? selectedSubdistrictName;
  String? selectTerritoryName;
  String? selectPurposeName;
  String? selectPurposeID;
  String? selectTerritoryID;
  String? selectStatusName;
  String? selectStatusID;
  bool isCanEdit = true;
  String? selectedDistrictName;
  String? selectedProvinceName;
  String? selectedDistrict;
  String? postCode;
  String? selectedProvince;
  String? selectedSubdistrict;
  List<Company> companys = [];
  List<Product> products = [];
  static const colorPrimary = Color(0xFF007AFF);
  static const colorGrey = Color(0xFFC7C7CC);
  static const borderWidth = 0.33;
  static const borderSide = BorderSide(color: colorGrey, width: borderWidth);
  final TextEditingController txtAddress = TextEditingController();
  final TextEditingController txtClientName = TextEditingController();
  final TextEditingController txtNote = TextEditingController();
  final TextEditingController txtPostCode = TextEditingController();
  List<Product> selectedProduct = [];

  @override
  Widget build(BuildContext context) {
    final selectedItem = ref.watch(selectedItemProvider);
    final clientGetByIdProviderState = ref.watch(clientGetByIdProvider(selectedItem.toString()));
    String? clientName = clientGetByIdProviderState.when(data: (client) => client.firstName!, loading: () => "Loading", error: (err, stack) => err.toString());

    clientGetByIdProviderState.when(
      data: (client) {
        selectTerritoryID = client.salesTerritoryID;
        selectTerritoryName = client.salesTerritoryName;
      },
      loading: () => "Loading",
      error: (err, stack) => err.toString(),
    );

    String? phone = clientGetByIdProviderState.when(data: (client) => client.phone!, loading: () => "Loading", error: (err, stack) => err.toString());

    String? email = clientGetByIdProviderState.when(data: (client) => client.email!, loading: () => "Loading", error: (err, stack) => err.toString());

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
                style: ButtonStyle(iconColor: WidgetStateProperty.all(colorPrimary)),
              ),
              const AppText(label: 'Back', textColor: colorPrimary),
            ],
          ),
        ),
        title: const AppText(label: 'Create Appointment', fontSize: 17, fontWeight: FontWeight.w600),

        actions: [
          TextButton(
            onPressed: () {
              String? error;
              error = Validator.required(clientName);
              if (error != null) {
                AppDialogs.error(context, message: error + " Client Name");
                return;
              }

              error = Validator.required(selectPurposeID);
              if (error != null) {
                AppDialogs.error(context, message: "กรุณาเลือก Purpose");
                return;
              }

              error = Validator.required(selectTerritoryID);
              if (error != null) {
                AppDialogs.error(context, message: "กรุณาเลือก Territory");
                return;
              }

              error = Validator.required(selectStatusID);
              if (error != null) {
                AppDialogs.error(context, message: "กรุณาเลือก Status");
                return;
              }

              if (dateTimeFrom == null) {
                AppDialogs.error(context, message: "กรุณาเลือก Starts");
                return;
              }

              if (dateTimeTo == null) {
                AppDialogs.error(context, message: "กรุณาเลือก Ends");
                return;
              }

              error = Validator.required(phone);
              if (error != null) {
                AppDialogs.error(context, message: error + " Mobile");
                return;
              }

              error = Validator.required(email);
              if (error != null) {
                AppDialogs.error(context, message: error + " Email");
                return;
              }

              error = Validator.required(txtNote.text);
              if (error != null) {
                AppDialogs.error(context, message: error + " Note");
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
                AppDialogs.error(context, message: error + " PostCode");
                return;
              }

              if (companys.isEmpty) {
                AppDialogs.error(context, message: "กรุณาเลือก Company");
                return;
              }

              if (products.isEmpty) {
                AppDialogs.error(context, message: "กรุณาเลือก Product");
                return;
              }
              final authState = ref.watch(authProvider);
              final accessToken = authState.accessToken;
              Appointments appointment = Appointments(
                appointmentTitle: "นัดพบลูกค้า", //
                appointmentTypeID: "7DEEC491-A5AE-4856-B981-7E91870179FF", //
                userID: authState.userID, //
                clientID: selectedItem,
                companyID: companys[0].companyID,
                appointmentDateTimeFrom: dateTimeFrom,
                appointmentDateTimeTo: dateTimeTo,
                appointmentStatusID: selectStatusID, //
                purposeTypeID: selectPurposeID,
                noted: txtNote.text, //
                assignedBy: null, //
                appointmentAddress: [
                  AppointmentAddress(
                    address: txtAddress.text,
                    countryID: 1, //
                    provinceID: int.parse(selectedProvince!), //1
                    districtID: int.parse(selectedDistrict!), //13
                    subDistrictID: int.parse(selectedSubdistrict!), //
                    latitude: null,
                    longitude: null,
                    isPrimary: true,
                    isActive: true,
                  ),
                ],
                appointmentProducts: products.map((p) => p.productID!).toList(),
                // [
                //   "0DB167F6-8AC9-4D31-A4BD-F3784F2489AD",
                // ], //
                isActive: true,
                createdBy: authState.userID, //
                modifiedBy: authState.userID,
                Phone: phone,
                Email: email,
                PurposeOther: "Buy",
              );
              AppointmentService appointmentService = new AppointmentService();

              try {
                appointmentService.Add(accessToken.toString(), appointment);
                // ignore: unused_result
                // ref.refresh(appointmentsProvider);
                AppDialogs.success(context);
                Future.delayed(const Duration(seconds: 3), () {
                  // context.push('/dashboard');
                  Navigator.of(context).popUntil((route) => route.isFirst);
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
      body: ListView(children: [buildContent(clientName, phone, email)]),
    );
  }

  Widget buildContent(String? clientName, String? phone, String? email) {
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
                    label: 'Client Name',
                    value: AppText(label: clientName ?? ""),
                    isShowBorderBottom: true,
                    isHideIcon: true,
                  ),
                  infoTile(
                    label: 'purpose',
                    value: AppText(label: selectPurposeName ?? ''),
                    onTap: () => openPurposeSheet(context, selectPurposeName ?? ''),
                    isShowBorderBottom: true,
                  ),
                  infoTile(
                    label: 'territory',
                    value: AppText(label: selectTerritoryName ?? ''),
                    // onTap: () => openTerritorySheet(context, selectTerritoryName ?? ''),
                    isShowBorderBottom: true,
                    isHideIcon: true,
                  ),
                  infoTile(
                    label: 'status',
                    value: AppText(label: selectStatusName ?? ''),
                    onTap: () => openStatusSheet(context, selectStatusName ?? ''),
                    isShowBorderBottom: true,
                  ),
                ],
              ),
              Column(
                children: [
                  datetime(
                    label: 'Starts',
                    datetime: dateTimeFrom!.toIso8601String(),
                    dateOnTap: isCanEdit
                        ? () => openDatePicker(
                            datetime: dateTimeFrom!.toIso8601String(),
                            onSelected: (value) => setState(() {
                              dateTimeFrom = value;
                            }),
                          )
                        : null,
                    timeOnTap: isCanEdit
                        ? () => openTimePicker(
                            datetime: dateTimeFrom!.toIso8601String(),
                            onSelected: (value) => setState(() {
                              dateTimeFrom = DateTime(dateTimeFrom!.year, dateTimeFrom!.month, dateTimeFrom!.day, value.hour, value.minute);
                            }),
                          )
                        : null,
                  ),
                  datetime(
                    label: 'Ends',
                    datetime: dateTimeTo!.toIso8601String(),
                    dateOnTap: isCanEdit
                        ? () => openDatePicker(
                            datetime: dateTimeTo!.toIso8601String(),
                            onSelected: (value) => setState(() {
                              dateTimeTo = value;
                            }),
                          )
                        : null,
                    timeOnTap: isCanEdit
                        ? () => openTimePicker(
                            datetime: dateTimeTo!.toIso8601String(),
                            onSelected: (value) => setState(() {
                              dateTimeTo = DateTime(dateTimeTo!.year, dateTimeTo!.month, dateTimeTo!.day, value.hour, value.minute);
                            }),
                          )
                        : null,
                  ),
                ],
              ),
              Column(
                children: [
                  infoTile(
                    label: 'mobile',
                    value: AppText(label: phone ?? ""),
                    isShowBorderBottom: true,
                    isHideIcon: true,
                  ),
                  infoTile(
                    label: 'email',
                    value: AppText(label: email ?? ""),
                    isShowBorderBottom: true,
                    isHideIcon: true,
                  ),
                ],
              ),
              infoTile(
                label: 'note',
                value: AppTextFormField(controller: txtNote, onChanged: (value) {}, maxLines: 5),
                height: 126,
                isShowBorderBottom: true,
                isHideIcon: true,
              ),
              companyTile(companys: companys),
              addressWidget(),
              productTile(products: products),
            ],
          ),
        ],
      ),
    );
  }

  Widget productTile({required List<Product> products, bool isShowBorderBottom = false}) {
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
                  child: AppText(label: 'products', textColor: Color(0xFF007AFF)),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      itemBuilder: (_, index) {
                        final product = products[index];

                        return Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: colorGrey, width: borderWidth),
                            ),
                          ),
                          height: 44,
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => removeProduct(product, products),
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 16),
                                  child: Icon(Icons.remove_circle, color: Color(0xFFFF382B), size: 24),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => openProdctSheet(context: context, productID: product.productID ?? "", isUpdate: true, products: products),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: AppText(label: product.productName ?? ""),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    GestureDetector(
                      onTap: () => openProdctSheet(context: context, productID: "", products: products),
                      child: const SizedBox(
                        height: 44,
                        child: Row(
                          children: [
                            SizedBox(width: 16),
                            Icon(Icons.add_circle, color: Color(0xFF31C859), size: 24),
                            SizedBox(width: 16),
                            AppText(label: 'add product'),
                          ],
                        ),
                      ),
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

  Future<void> openProdctSheet({required BuildContext context, required String productID, bool isUpdate = false, required List<Product>? products}) async {
    final selected = await CupertinoOptionsPicker.show<Product>(
      context: context,
      title: 'Product',
      provider: productGetList,
      label: (p) => p.productName ?? "",
      initialKey: (p) => p.productID ?? "",
      initialValue: productID,
    );

    if (selected == null) return;

    if (isUpdate) {
      setState(() {
        products?.remove(selected);
      });
    } else {
      setState(() {
        products?.add(selected);
      });
    }
  }

  Widget companyTile({required List<Company> companys, bool isShowBorderBottom = false}) {
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
                  child: AppText(label: 'companys', textColor: Color(0xFF007AFF)),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: companys.length,
                      itemBuilder: (_, index) {
                        final company = companys[index];

                        return Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: colorGrey, width: borderWidth),
                            ),
                          ),
                          height: 44,
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => removeCompany(company, companys),
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 16),
                                  child: Icon(Icons.remove_circle, color: Color(0xFFFF382B), size: 24),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => openCompanySheet(context: context, companyID: company.companyID ?? "", isUpdate: true, companys: companys),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: AppText(label: company.companyName ?? ""),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    if (companys.isEmpty)
                      GestureDetector(
                        onTap: () => openCompanySheet(context: context, companyID: "", companys: companys),
                        child: const SizedBox(
                          height: 44,
                          child: Row(
                            children: [
                              SizedBox(width: 16),
                              Icon(Icons.add_circle, color: Color(0xFF31C859), size: 24),
                              SizedBox(width: 16),
                              AppText(label: 'add company'),
                            ],
                          ),
                        ),
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

  Future<void> openCompanySheet({required BuildContext context, required String companyID, bool isUpdate = false, required List<Company>? companys}) async {
    final selected = await CupertinoOptionsPicker.show<Company>(
      context: context,
      title: 'Company',
      provider: companyGetListProvider,
      label: (p) => p.companyName ?? "",
      initialKey: (p) => p.companyID ?? "",
      initialValue: companyID,
    );

    if (selected == null) return;
    final companyAddress = (selected.CompanyAddresses ?? []).isNotEmpty ? selected.CompanyAddresses?.first : null;

    setState(() {
      if (isUpdate) {
        companys?.removeAt(0);
      }

      companys?.add(selected);

      if (companyAddress != null) {
        txtAddress.text = companyAddress.address ?? '';

        selectedSubdistrictName = companyAddress.subDistrictName;
        selectedSubdistrict = companyAddress.subDistrictID.toString();

        selectedDistrictName = companyAddress.districtName;
        selectedDistrict = companyAddress.districtID.toString();

        selectedProvinceName = companyAddress.provinceName;
        selectedProvince = companyAddress.provinceID.toString();
        postCode = companyAddress.postCode;
      }
    });
  }

  void removeProduct(Product product, List<Product> products) {
    setState(() {
      products.remove(product);
    });
  }

  void removeCompany(Company company, List<Company> companys) {
    setState(() {
      final companyAddress = (company.CompanyAddresses ?? []).isNotEmpty ? company.CompanyAddresses?.first : null;
      if (companyAddress != null) {
        txtAddress.clear();

        selectedSubdistrictName = null;
        selectedSubdistrict = null;

        selectedDistrictName = null;
        selectedDistrict = null;

        selectedProvinceName = null;
        selectedProvince = null;
        postCode = null;
      }

      companys.remove(company);
    });
  }

  Widget addressWidget() {
    Widget addressField({required Widget child, bool hasRightBorder = false, bool hasBottomBorder = true}) {
      return Container(
        height: 44,
        decoration: BoxDecoration(
          border: Border(right: hasRightBorder ? borderSide : BorderSide.none, bottom: hasBottomBorder ? borderSide : BorderSide.none),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        child: child,
      );
    }

    Widget textHint({required String label}) {
      return AppText(label: label, textColor: Colors.grey.shade400);
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
                  child: AppText(label: 'address', textColor: Color(0xFF007AFF)),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    addressField(
                      child: AppTextFormField(controller: txtAddress, hintText: 'ที่อยู่'),
                    ),
                    addressField(
                      hasRightBorder: true,
                      child: infoTileDropdown(
                        label: selectedProvinceName ?? '',
                        value: selectedProvinceName == null ? textHint(label: 'จังหวัด') : AppText(label: selectedProvinceName ?? ''),
                        onTap: () => openProvinceSheet(context, selectedProvinceName ?? ""),
                        // isShowBorderBottom: true,
                        isHideIcon: true,
                      ),
                    ),
                    addressField(
                      child: infoTileDropdown(
                        label: selectedDistrictName ?? '',
                        value: selectedDistrictName == null ? textHint(label: 'อําเภอ') : AppText(label: selectedDistrictName ?? ''),
                        onTap: () => openDistrictSheet(context, selectedDistrictName ?? ""),
                        // isShowBorderBottom: true,
                        isHideIcon: true,
                      ),
                    ),
                    addressField(
                      hasRightBorder: false,
                      child: infoTileDropdown(
                        label: selectedSubdistrictName ?? '',
                        value: selectedSubdistrictName == null ? textHint(label: 'ตำบล') : AppText(label: selectedSubdistrictName ?? ''),
                        onTap: () => openSubDistrictSheet(context, selectedSubdistrictName ?? ""),
                        // isShowBorderBottom: true,
                        isHideIcon: true,
                      ),
                    ),
                    addressField(
                      child: postCode == null ? textHint(label: 'รหัสไปรษณีย์') : AppText(label: postCode ?? ""),
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

  Future<void> openProvinceSheet(BuildContext context, String subdistrictID) async {
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
      selectedDistrictName = null;
      selectedSubdistrict = null;
      selectedSubdistrictName = null;
      postCode = "";
    });
  }

  Future<void> openDistrictSheet(BuildContext context, String subdistrictID) async {
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
      selectedSubdistrictName = null;
      postCode = "";
    });
  }

  Future<void> openSubDistrictSheet(BuildContext context, String subdistrictID) async {
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
      postCode = selected.postCode ?? "";
    });
  }

  void openTimePicker({required String datetime, required Function(TimeOfDay) onSelected, String? limitFirstDate}) async {
    final picked = await showCupertinoTimeDialog(initial: datetime, context);

    if (picked != null) {
      if (limitFirstDate != null) {
        final current = DateTime.parse(datetime);
        final limit = DateTime.parse(limitFirstDate);
        final limitTime = TimeOfDay(hour: limit.hour, minute: limit.minute);

        if (isSameDay(limit, current) && picked.isBefore(limitTime)) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: AppText(label: 'Please select a time after the appointment start time.', textColor: Colors.white, maxLines: 2),
            ),
          );
          return;
        }
      }

      onSelected(picked);
    }
  }

  void openDatePicker({required String datetime, required Function(DateTime) onSelected, String? limitFirstDate}) async {
    final picked = await DatePickerHelper.pickDate(context, initialDate: DateTime.parse(datetime), limitFirstDate: limitFirstDate == null ? null : DateTime.parse(limitFirstDate));
    if (picked != null) onSelected(picked);
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget datetime({required String label, required String datetime, bool isShowBorderBottom = false, VoidCallback? dateOnTap, timeOnTap}) {
    final dt = DateTime.parse(datetime);
    final date = DateFormat("MMM d, yyyy").format(dt);
    final time = DateFormat("h:mm a").format(dt);

    Widget datetimeField({required String value, VoidCallback? onTap}) {
      return GestureDetector(
        onTap: onTap,
        child: IntrinsicWidth(
          child: Container(
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Color.fromRGBO(118, 118, 128, 0.12), borderRadius: BorderRadius.all(Radius.circular(7))),
            child: AppText(label: value, fontSize: 17),
          ),
        ),
      );
    }

    return infoTile(
      label: label,
      value: Container(
        margin: const EdgeInsets.only(right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: 4,
          children: [
            datetimeField(value: date, onTap: dateOnTap),
            datetimeField(value: time, onTap: timeOnTap),
          ],
        ),
      ),
      isShowBorderMiddle: false,
      isShowBorderBottom: isShowBorderBottom,
      isHideIcon: true,
    );
  }

  Future<void> openPurposeSheet(BuildContext context, String purposeID) async {
    final selected = await CupertinoOptionsPicker.show<PurposeType>(
      context: context,
      title: 'Purpose',
      provider: perposeTypeGetList,
      label: (p) => p.purposeTypeName ?? "",
      initialKey: (p) => p.purposeTypeID ?? "",
      initialValue: purposeID,
    );

    if (selected == null) return;
    setState(() {
      selectPurposeName = selected.purposeTypeName;
      selectPurposeID = selected.purposeTypeID;
    });
  }

  Future<void> openTerritorySheet(BuildContext context, String territoryID) async {
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
      selectTerritoryName = selected.salesTerritoryName;
      selectTerritoryID = selected.salesTerritoryID;
    });
  }

  Future<void> openStatusSheet(BuildContext context, String statusID) async {
    final selected = await CupertinoOptionsPicker.show<AppointmentStatus>(
      context: context,
      title: 'status',
      provider: appointmentStatusGetList,
      label: (p) => p.appointmentStatusName ?? "",
      initialKey: (p) => p.appointmentStatusID ?? "",
      initialValue: statusID,
    );

    if (selected == null) return;
    setState(() {
      selectStatusName = selected.appointmentStatusName;
      selectStatusID = selected.appointmentStatusID;
    });
  }

  Widget infoTile({required String label, required Widget value, VoidCallback? onTap, double height = 44, bool isShowBorderMiddle = true, bool isShowBorderBottom = false, bool isHideIcon = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          border: Border(top: borderSide, bottom: isShowBorderBottom ? borderSide : BorderSide.none),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Container(
              width: 100,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: BorderDirectional(
                  end: isShowBorderMiddle ? const BorderSide(color: colorGrey, width: borderWidth) : BorderSide.none,
                ),
              ),
              child: AppText(label: label, textColor: const Color(0xFF007AFF)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Align(alignment: Alignment.centerLeft, child: value),
            ),
            if (!isHideIcon) ...[const Icon(Icons.chevron_right, size: 24, color: colorGrey), const SizedBox(width: 8)],
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
          border: Border(top: borderSide, bottom: isShowBorderBottom ? borderSide : BorderSide.none),
        ),
        child: Row(
          children: [
            Expanded(
              child: Align(alignment: Alignment.centerLeft, child: value),
            ),
            if (!isHideIcon) ...[const Icon(Icons.chevron_right, size: 24, color: colorGrey), const SizedBox(width: 8)],
          ],
        ),
      ),
    );
  }
}
