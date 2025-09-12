import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wfs/models/appointmentstatus_model.dart';
import 'package:wfs/models/client_model.dart';
import 'package:wfs/models/clientaddresses_model.dart';
import 'package:wfs/models/clientcompanies_model.dart';
import 'package:wfs/models/clientlevel_model.dart';
import 'package:wfs/models/clientstatus_model.dart';
import 'package:wfs/models/company_model.dart';
import 'package:wfs/models/district_model.dart';
import 'package:wfs/models/product_model.dart';
import 'package:wfs/models/province_model.dart';
import 'package:wfs/models/sales_territory.dart';
import 'package:wfs/models/subdistrict_model.dart';
import 'package:wfs/models/territory_model.dart';
import 'package:wfs/providers/auth_provider.dart';
import 'package:wfs/providers/client_provider.dart';
import 'package:wfs/providers/clientlevel_provider.dart';
import 'package:wfs/providers/clientstatus_provider.dart';
import 'package:wfs/providers/company_provider.dart';
import 'package:wfs/providers/district_provider.dart';
import 'package:wfs/providers/product_provider.dart';
import 'package:wfs/providers/province_provider.dart';
import 'package:wfs/providers/saleterritorie_provider.dart';
import 'package:wfs/providers/subdistrict_provider.dart';
import 'package:wfs/services/client_service.dart';
import 'package:wfs/utility/appdialogs.dart';
import 'package:wfs/utility/date_picker_helper.dart';
import 'package:wfs/utility/time_picker_helper.dart';
import 'package:wfs/utility/validator.dart';
import 'package:wfs/widgets/app_cupertino_option.dart';
import 'package:wfs/widgets/app_text.dart';
import 'package:wfs/widgets/app_text_form_field.dart';

class Item {
  final String id;
  final String name;

  Item({required this.id, required this.name});
}

class CreateClientScreen extends ConsumerStatefulWidget {
  const CreateClientScreen({super.key});

  @override
  ConsumerState<CreateClientScreen> createState() => _CreateClientScreenState();
}

class _CreateClientScreenState extends ConsumerState<CreateClientScreen> {
  String? selectedPurpose;
  String? product;
  String? commany;
  String? selectSalesTerritorys;
  String? selectSalesTerritorysName;
  String? selectClientStatus;
  String? selectClientStatusName;
  String? selectClientLevel;
  String? selectClientLevelName;
  DateTime? dateTimeFrom = DateTime.now();
  DateTime? dateTimeFromTemp = DateTime.now();
  TimeOfDay? timeFrom;
  DateTime? dateTimeTo = DateTime.now();
  DateTime? dateTimeToTemp = DateTime.now();
  String? selectedDistrict;
  String? selectedDistrictName;
  String? selectedProvince;
  String? selectedProvinceName;
  String? selectedSubdistrict;
  String? selectedSubdistrictName;
  String? postCode;
  SalesTerritory? salesTerritory;
  AppointmentStatus? appointmentStatus;
  ClientLevel? clientLevel;
  bool isCanEdit = true;
  Client? client;
  final TextEditingController txtAddress = TextEditingController();
  final TextEditingController txtClientName = TextEditingController();
  final TextEditingController txtPhone = TextEditingController();
  final TextEditingController txtEmail = TextEditingController();
  final TextEditingController txtPostcode = TextEditingController();
  final TextEditingController txtLastName = TextEditingController();
  static const colorPrimary = Color(0xFF007AFF);
  static const colorGrey = Color(0xFFC7C7CC);
  static const borderWidth = 0.33;
  static const borderSide = BorderSide(color: colorGrey, width: borderWidth);

  List<Product> selectedProduct = [];
  List<Company> selectedCompany = [];
  List<Product> products = [];
  List<Company> companys = [];

  @override
  Widget build(BuildContext context) {
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
                      style: ButtonStyle(
                        iconColor: WidgetStateProperty.all(colorPrimary),
                      ),
                    ),
                    AppText(label: 'Back', textColor: colorPrimary),
                  ],
                ),
              ),
              title: const AppText(
                label: 'Create Client',
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    String? error;
                    error = Validator.required(txtClientName.text);
                    if (error != null) {
                      AppDialogs.error(
                        context,
                        message: error + " Client Name",
                      );
                      return;
                    }

                    error = Validator.required(selectClientStatus);
                    if (error != null) {
                      AppDialogs.error(context, message: "กรุณาเลือก Status");
                      return;
                    }

                    error = Validator.required(selectClientLevel);
                    if (error != null) {
                      AppDialogs.error(context, message: "กรุณาเลือก Level");
                      return;
                    }

                    error = Validator.required(selectSalesTerritorys);
                    if (error != null) {
                      AppDialogs.error(
                        context,
                        message: "กรุณาเลือก Territory",
                      );
                      return;
                    }

                    error = Validator.required(txtPhone.text);
                    if (error != null) {
                      AppDialogs.error(context, message: error + " Mobile");
                      return;
                    }

                    error = Validator.required(txtEmail.text);
                    if (error != null) {
                      AppDialogs.error(context, message: error + " Email");
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
                      AppDialogs.error(
                        context,
                        message: "กรุณาเลือก SubDistrict",
                      );
                      return;
                    }

                    if (companys.length == 0) {
                      AppDialogs.error(context, message: "กรุณาเลือก company");
                      return;
                    }

                    if (products.length == 0) {
                      AppDialogs.error(context, message: "กรุณาเลือก product");
                      return;
                    }
                    final authState = ref.watch(authProvider);

                    Client client = Client(
                      firstName: txtClientName.text,
                      lastName: txtLastName.text,
                      address: txtAddress.text,
                      phone: txtPhone.text,
                      email: txtEmail.text,
                      salesTerritoryID: selectSalesTerritorys,
                      clientStatusID: selectClientStatus,
                      clientLevelID: selectClientLevel,
                      noted: "xxxxxxxxxxxxxxx",
                      availableTimeStart: DateFormat(
                        'HH:mm',
                      ).format(dateTimeFrom!), //"09:00",
                      availableTimeEnd: DateFormat(
                        'HH:mm',
                      ).format(dateTimeTo!), //"16:00",
                      isActive: true,
                      createdBy: authState.userID,
                      modifiedBy: authState.userID,
                      clientAddresses: [
                        ClientAddresses(
                          address: txtAddress.text, //"123/4 Sukhumvit Road",
                          countryID: 1,
                          provinceID: int.parse(selectedProvince!), // 1,
                          districtID: int.parse(selectedDistrict!), //13,
                          subDistrictID: int.parse(
                            selectedSubdistrict!,
                          ), // 2583,
                          latitude: null,
                          longitude: null,
                          isPrimary: true,
                          isActive: true,
                        ),
                      ],
                      clientID: "",
                      createdDate: DateTime.now().toIso8601String(),
                      modifiedDate: DateTime.now().toIso8601String(),
                      clientProducts: products
                          .map((f) => f.productID!)
                          .toList(),
                      clientCompanies: companys
                          .map(
                            (c) => ClientCompanies(
                              companyID: c.companyID,
                              position: "Staff",
                              noted: c.noted,
                              availableTimeStart: null,
                              availableTimeEnd: null,
                              createdBy: "9E0DC5F7-1FD6-41F3-9137-14711FC510F6",
                              modifiedBy:
                                  "9E0DC5F7-1FD6-41F3-9137-14711FC510F6",
                            ),
                          )
                          .toList(),
                    );
                    ClientService clientService = new ClientService();
                    final accessToken = authState.accessToken;
                    try {
                      clientService.Add(accessToken.toString(), client);
                      // ignore: unused_result
                      ref.refresh(clientCompaniesProvider);
                      // ignore: unused_result
                      ref.refresh(clientProvider);
                      // ignore: unused_result
                      ref.refresh(clientSectionsProvider);

                      AppDialogs.success(context);
                      Future.delayed(const Duration(seconds: 3), () {
                        context.push('/clients');
                      });
                    } catch (ex) {
                      AppDialogs.error(context, message: ex.toString());
                    }
                  },
                  style: TextButton.styleFrom(foregroundColor: colorPrimary),
                  child: AppText(label: 'Done', textColor: colorPrimary),
                ),
              ],
            ),
            body: ListView(
              children: [
                Container(
                  color: Colors.white,
                  child: Column(children: [buildContent()]),
                ),
              ],
            ),
          ),
        ),
      ],
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
                    label: 'Client Name',
                    value: AppTextFormField(controller: txtClientName),
                    isShowBorderBottom: true,
                    isHideIcon: true,
                  ),
                  infoTile(
                    label: 'status',
                    value: AppText(label: selectClientStatusName ?? ''),
                    onTap: () =>
                        openStatusSheet(context, selectClientStatusName ?? ""),
                    isShowBorderBottom: true,
                  ),
                  infoTile(
                    label: 'level',
                    value: AppText(label: selectClientLevelName ?? ''),
                    onTap: () =>
                        openLevelSheet(context, selectClientLevelName ?? ""),
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
              Container(color: Color(0xFFEEEEEE), height: 30),
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
                              dateTimeFrom = DateTime(
                                dateTimeFrom!.year,
                                dateTimeFrom!.month,
                                dateTimeFrom!.day,
                                value.hour,
                                value.minute,
                              );
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
                              dateTimeTo = DateTime(
                                dateTimeTo!.year,
                                dateTimeTo!.month,
                                dateTimeTo!.day,
                                value.hour,
                                value.minute,
                              );
                            }),
                          )
                        : null,
                  ),
                ],
              ),
              Container(color: Color(0xFFEEEEEE), height: 30),
              Column(
                children: [
                  infoTile(
                    label: 'mobile',
                    value: AppTextFormField(controller: txtPhone),
                    isShowBorderBottom: true,
                    isHideIcon: true,
                  ),
                  infoTile(
                    label: 'email',
                    value: AppTextFormField(controller: txtEmail),
                    isShowBorderBottom: true,
                    isHideIcon: true,
                  ),
                ],
              ),
              Container(color: Color(0xFFEEEEEE), height: 30),
              addressWidget(),
              Container(color: Color(0xFFEEEEEE), height: 30),
              companyTile(companys: companys),
              Container(color: Color(0xFFEEEEEE), height: 30),
              productTile(products: products),
            ],
          ),
        ],
      ),
    );
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
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: borderSide, bottom: borderSide),
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

  void openTimePicker({
    required String datetime,
    required Function(TimeOfDay) onSelected,
    String? limitFirstDate,
  }) async {
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
              content: AppText(
                label: 'Please select a time after the appointment start time.',
                textColor: Colors.white,
                maxLines: 2,
              ),
            ),
          );
          return;
        }
      }

      onSelected(picked);
    }
  }

  void openDatePicker({
    required String datetime,
    required Function(DateTime) onSelected,
    String? limitFirstDate,
  }) async {
    final picked = await DatePickerHelper.pickDate(
      context,
      initialDate: DateTime.parse(datetime),
      limitFirstDate: limitFirstDate == null
          ? null
          : DateTime.parse(limitFirstDate),
    );
    if (picked != null) onSelected(picked);
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget datetime({
    required String label,
    required String datetime,
    bool isShowBorderBottom = false,
    VoidCallback? dateOnTap,
    timeOnTap,
  }) {
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
            decoration: const BoxDecoration(
              color: Color.fromRGBO(118, 118, 128, 0.12),
              borderRadius: BorderRadius.all(Radius.circular(7)),
            ),
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

  Widget companyTile({
    required List<Company> companys,
    bool isShowBorderBottom = false,
  }) {
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
                    label: 'companys',
                    textColor: Color(0xFF007AFF),
                  ),
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
                              bottom: BorderSide(
                                color: colorGrey,
                                width: borderWidth,
                              ),
                            ),
                          ),
                          height: 44,
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => removeCompany(company, companys),
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 16),
                                  child: Icon(
                                    Icons.remove_circle,
                                    color: Color(0xFFFF382B),
                                    size: 24,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => openCompanySheet(
                                    context: context,
                                    companyID: company.companyID ?? "",
                                    isUpdate: true,
                                    companys: companys,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: AppText(
                                      label: company.companyName ?? "",
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    GestureDetector(
                      onTap: () => openCompanySheet(
                        context: context,
                        companyID: "",
                        companys: companys,
                      ),
                      child: const SizedBox(
                        height: 44,
                        child: Row(
                          children: [
                            SizedBox(width: 16),
                            Icon(
                              Icons.add_circle,
                              color: Color(0xFF31C859),
                              size: 24,
                            ),
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

  Widget productTile({
    required List<Product> products,
    bool isShowBorderBottom = false,
  }) {
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
                    label: 'products',
                    textColor: Color(0xFF007AFF),
                  ),
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
                              bottom: BorderSide(
                                color: colorGrey,
                                width: borderWidth,
                              ),
                            ),
                          ),
                          height: 44,
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => removeProduct(product, products),
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 16),
                                  child: Icon(
                                    Icons.remove_circle,
                                    color: Color(0xFFFF382B),
                                    size: 24,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => openProdctSheet(
                                    context: context,
                                    productID: product.productID ?? "",
                                    isUpdate: true,
                                    products: products,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: AppText(
                                      label: product.productName ?? "",
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    GestureDetector(
                      onTap: () => openProdctSheet(
                        context: context,
                        productID: "",
                        products: products,
                      ),
                      child: const SizedBox(
                        height: 44,
                        child: Row(
                          children: [
                            SizedBox(width: 16),
                            Icon(
                              Icons.add_circle,
                              color: Color(0xFF31C859),
                              size: 24,
                            ),
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

  void removeProduct(Product product, List<Product> products) {
    setState(() {
      products.remove(product);
    });
  }

  void removeCompany(Company company, List<Company> companys) {
    setState(() {
      companys.remove(company);
    });
  }

  Future<void> openCompanySheet({
    required BuildContext context,
    required String companyID,
    bool isUpdate = false,
    required List<Company>? companys,
  }) async {
    final selected = await CupertinoOptionsPicker.show<Company>(
      context: context,
      title: 'Company',
      provider: companyGetListProvider,
      label: (p) => p.companyName ?? "",
      initialKey: (p) => p.companyID ?? "",
      initialValue: companyID,
    );

    if (selected == null) return;

    if (isUpdate) {
      setState(() {
        companys?.remove(selected);
      });
    } else {
      setState(() {
        companys?.add(selected);
      });
    }
  }

  Future<void> openProdctSheet({
    required BuildContext context,
    required String productID,
    bool isUpdate = false,
    required List<Product>? products,
  }) async {
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
              Icon(Icons.chevron_right, size: 24, color: colorGrey),
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
              Icon(Icons.chevron_right, size: 24, color: colorGrey),
              const SizedBox(width: 8),
            ],
          ],
        ),
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

  Future<void> openLevelSheet(BuildContext context, String levelID) async {
    final selected = await CupertinoOptionsPicker.show<ClientLevel>(
      context: context,
      title: 'Level',
      provider: clientLevelGetList,
      label: (p) => p.clientLevelName.toString(),
      initialKey: (p) => p.clientLevelID.toString(),
      initialValue: levelID,
    );

    if (selected == null) return;
    setState(() {
      selectClientLevel = selected.clientLevelID;
      selectClientLevelName = selected.clientLevelName;
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
      txtPostcode.text = selected.postCode ?? "";
      postCode = selected.postCode ?? "";
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
      txtPostcode.text = "";
      postCode = "";
    });
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
      txtPostcode.text = "";
      postCode = "";
    });
  }
}
