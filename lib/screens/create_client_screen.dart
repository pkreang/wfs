import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wfs/main.dart';
import 'package:wfs/models/client_model.dart';
import 'package:wfs/models/clientaddresses_model.dart';
import 'package:wfs/models/clientcompanies_model.dart';
import 'package:wfs/models/company_model.dart';
import 'package:wfs/models/district_model.dart';
import 'package:wfs/models/product_model.dart';
import 'package:wfs/models/province_model.dart';
import 'package:wfs/models/sales_territory.dart';
import 'package:wfs/models/subdistrict_model.dart';
import 'package:wfs/models/territory_model.dart';
import 'package:wfs/providers/appointment_provider.dart';
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
import 'package:wfs/utility/validator.dart';
import 'package:wfs/widgets/app_cupertino_option.dart';
import 'package:wfs/widgets/app_text.dart';

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
  String? salesTerritorys;
  String? selectClientStatus;
  String? selectClientLevel;
  DateTime? dateTimeFrom;
  DateTime? dateTimeTo;
  Province? selectedProvince;
  District? selectedDistrict;
  Subdistrict? selectedSubdistrict;
  String? postCode;
  SalesTerritory? salesTerritory;
  bool isCanEdit = true;
  final TextEditingController txtAddress = TextEditingController();
  final TextEditingController txtClientName = TextEditingController();
  final TextEditingController txtPhone = TextEditingController();
  final TextEditingController txtEmail = TextEditingController();
  final TextEditingController txtPostcode = TextEditingController();
  final TextEditingController txtLastName = TextEditingController();

  static const colorGrey = Color(0xFFC7C7CC);
  static const borderWidth = 0.33;
  static const borderSide = BorderSide(color: colorGrey, width: borderWidth);

  List<Product> selectedProduct = [];
  List<Company> selectedCompany = [];
  void _showPopupCompany(AsyncValue<List<Company>> companyGetList) async {
    final result = await showDialog<List<Company>>(
      context: context,
      builder: (context) {
        List<Company> tempSelected = List.from(selectedCompany);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text("เลือก Company"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: double.maxFinite,
                height: 250,
                child: companyGetList.when(
                  data: (companys) => ListView.builder(
                    itemCount: companys.length,
                    itemBuilder: (context, index) {
                      final Company = companys[index];
                      final isSelected = tempSelected.contains(Company);

                      return CheckboxListTile(
                        title: Text(Company.companyName.toString()),
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              tempSelected.add(Company);
                            } else {
                              tempSelected.remove(Company);
                            }
                          });
                        },
                      );
                    },
                  ),
                  loading: () => Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text("Error: $e")),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("ยกเลิก"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, tempSelected),
              child: Text("ตกลง"),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        selectedCompany = result;
      });
    }
  }

  void _showPopupProduct(AsyncValue<List<Product>> productGetList) async {
    final result = await showDialog<List<Product>>(
      context: context,
      builder: (context) {
        List<Product> tempSelected = List.from(selectedProduct);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text("เลือก Product"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: double.maxFinite,
                height: 250,
                child: productGetList.when(
                  data: (Products) => ListView.builder(
                    itemCount: Products.length,
                    itemBuilder: (context, index) {
                      final Product = Products[index];
                      final isSelected = tempSelected.contains(Product);

                      return CheckboxListTile(
                        title: Text(Product.productName.toString()),
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              tempSelected.add(Product);
                            } else {
                              tempSelected.remove(Product);
                            }
                          });
                        },
                      );
                    },
                  ),
                  loading: () => Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text("Error: $e")),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("ยกเลิก"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, tempSelected),
              child: Text("ตกลง"),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        selectedProduct = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProductGetListState = ref.watch(ProductGetList);
    final companyGetListProviderState = ref.watch(companyGetListProvider);
    final selectedItem = ref.watch(selectedItemProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F7),
        elevation: 0,
        title: Text("Create Client"),
        leading: TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            '< Back',
            style: TextStyle(color: Colors.blue, fontSize: 16),
          ),
        ),
        leadingWidth: 80,
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              String? error;
              error = Validator.required(txtClientName.text);
              if (error != null) {
                AppDialogs.error(context, message: error + " Client Name");
                return;
              }

              error = Validator.required(txtLastName.text);
              if (error != null) {
                AppDialogs.error(context, message: error + "Last Name");
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

              // error = Validator.required(salesTerritory);
              // if (error != null) {
              //   AppDialogs.error(context, message: "กรุณาเลือก Territory");
              //   return;
              // }

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

              error = Validator.required(txtPhone.text);
              if (error != null) {
                AppDialogs.error(context, message: error + " Phone");
                return;
              }

              error = Validator.required(txtEmail.text);
              if (error != null) {
                AppDialogs.error(context, message: error + " Email");
                return;
              }

              if (selectedCompany.length == 0) {
                AppDialogs.error(context, message: "กรุณาเลือก add company");
                return;
              }

              if (selectedProduct.length == 0) {
                AppDialogs.error(context, message: "กรุณาเลือก add product");
                return;
              }
              final authState = ref.watch(authProvider);

              Client client = Client(
                firstName: txtClientName.text,
                lastName: txtLastName.text,
                address: "123 Bangkok",
                phone: txtPhone.text,
                email: txtEmail.text,
                // salesTerritoryID: salesTerritory,
                clientStatusID: selectClientStatus,
                clientLevelID: selectClientLevel,
                noted: "xxxxxxxxxxxxxxx",
                availableTimeStart: "09:00",
                availableTimeEnd: "16:00",
                isActive: true,
                createdBy: authState.userID,
                modifiedBy: authState.userID,
                clientAddresses: [
                  ClientAddresses(
                    address: txtAddress.text, //"123/4 Sukhumvit Road",
                    countryID: 1,
                    provinceID: selectedProvince?.provinceID ?? null, // 1,
                    districtID: selectedDistrict?.districtID ?? null, //13,
                    subDistrictID:
                        selectedSubdistrict?.subDistrictID ?? null, // 2583,
                    latitude: null,
                    longitude: null,
                    isPrimary: true,
                    isActive: true,
                  ),
                ],
                clientID: "",
                createdDate: DateTime.now().toIso8601String(),
                modifiedDate: DateTime.now().toIso8601String(),
                clientProducts: selectedProduct
                    .map((f) => f.productID!)
                    .toList(),
                clientCompanies: selectedCompany
                    .map(
                      (c) => ClientCompanies(
                        companyID: c.companyID,
                        position: "Staff",
                        noted: c.noted,
                        availableTimeStart: null,
                        availableTimeEnd: null,
                        createdBy: "9E0DC5F7-1FD6-41F3-9137-14711FC510F6",
                        modifiedBy: "9E0DC5F7-1FD6-41F3-9137-14711FC510F6",
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
            child: const Text(
              'Create',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          Container(
            color: Colors.white,
            child: Column(
              children: [
                infoTile(
                  label: 'territory',
                  value: AppText(
                    label: salesTerritory?.salesTerritoryName ?? '',
                  ),
                  onTap: isCanEdit
                      ? () => openTerritorySheet(
                          context,
                          salesTerritory?.salesTerritoryID ?? '',
                        )
                      : null,
                  isHideIcon: !isCanEdit,
                  isShowBorderBottom: true,
                ),

                // _buildInfoRowClient("Client Name", selectedItem.toString()),
                // const Divider(height: 1, indent: 0, thickness: 0.5),
                // _buildInfoRowLastName('Last Name', ''),
                // const Divider(height: 1, indent: 0, thickness: 0.5),
                // _buildTappableRowStatus('status', ''),
                // const Divider(height: 1, indent: 0, thickness: 0.5),
                // _buildTappableRowLevel('level', '', showDivider: false),
                // const Divider(height: 1, indent: 0, thickness: 0.5),
                // _buildTappableRowSaleTerritory('territory', ''),
                // const Divider(height: 1, indent: 0, thickness: 0.5),
              ],
            ),
          ),

          // Container(
          //   color: Colors.white,
          //   child: Column(children: [SizedBox(height: 20)]),
          // ),
          // const SizedBox(height: 30),
          // Container(
          //   color: Colors.white,
          //   child: Column(children: [_buildInfoRowPhone('Mobile', '')]),
          // ),
          // const Divider(height: 1, indent: 0, thickness: 0.5),
          // Container(
          //   color: Colors.white,
          //   child: Column(children: [_buildInfoRowEmail('Email', '')]),
          // ),
          // const Divider(height: 1, indent: 0, thickness: 0.5),
          // const SizedBox(height: 30),
          // Container(color: Colors.white, child: _buildAddressSection()),
          // Container(
          // color: Colors.white,
          // child: Column(
          //   children: [
          //_buildInfoRowAddress('Address', ''),
          // _buildTappableRowProvince("Province", ""),
          // _buildTappableRowDistrict("District", ""),
          // _buildTappableRowSubDistrict("SubDistrict", ""),
          // _buildInfoRowPostcode('Post Code', ''),
          //     ],
          //   ),
          // ),
          // const SizedBox(height: 30),
          // const Padding(
          //   padding: const EdgeInsets.only(left: 16.0),
          //   child: Text("LINKED COMPANY"),
          // ),
          // Container(
          //   color: Colors.white,
          //   child: Column(
          //     children: [
          //       SizedBox(height: 20),
          //       _buildTappableRowCompany(
          //         'add company',
          //         '',
          //         companyGetListProviderState,
          //       ),
          //       SizedBox(height: 20),
          //       Center(
          //         child: selectedCompany.length > 0
          //             ? Text(
          //                 "Company ที่เลือก:",
          //                 style: TextStyle(fontWeight: FontWeight.bold),
          //               )
          //             : Text(""),
          //       ),
          //       SizedBox(height: 10),
          //       Wrap(
          //         spacing: 8,
          //         runSpacing: 8,
          //         children: selectedCompany
          //             .map(
          //               (e) => Chip(
          //                 label: Text(e.companyName.toString()),
          //                 deleteIcon: Icon(Icons.close),
          //                 onDeleted: () {
          //                   setState(() {
          //                     selectedCompany.remove(e);
          //                   });
          //                 },
          //               ),
          //             )
          //             .toList(),
          //       ),
          //     ],
          //   ),
          // ),
          // const SizedBox(height: 30),
          // Padding(
          //   padding: const EdgeInsets.only(left: 16.0),
          //   child: Text("LINKED PRODUCT"),
          // ),
          // Container(
          //   color: Colors.white,
          //   child: Column(
          //     children: [
          //       SizedBox(height: 20),
          //       _buildTappableRowProduct(
          //         'add product',
          //         '',
          //         ProductGetListState,
          //       ),
          //       SizedBox(height: 20),
          //       Center(
          //         child: selectedCompany.length > 0
          //             ? Text(
          //                 "Product ที่เลือก:",
          //                 style: TextStyle(fontWeight: FontWeight.bold),
          //               )
          //             : Text(""),
          //       ),
          //       SizedBox(height: 10),
          //       Wrap(
          //         spacing: 8,
          //         runSpacing: 8,
          //         children: selectedProduct
          //             .map(
          //               (e) => Chip(
          //                 label: Text(e.productName.toString()),
          //                 deleteIcon: Icon(Icons.close),
          //                 onDeleted: () {
          //                   setState(() {
          //                     selectedProduct.remove(e);
          //                   });
          //                 },
          //               ),
          //             )
          //             .toList(),
          //       ),
          //     ],
          //   ),
          // ),
          // const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16.0, top: 12.0, right: 16),
          child: Text(
            'Address',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              _buildAddressTextField(''),
              const Divider(height: 1, indent: 0, thickness: 0.5),
              _buildAddressProvince('Street'),
              const Divider(height: 1, indent: 0, thickness: 0.5),
              _buildAddressDistrict('Cir. Syracuse'),
              const Divider(height: 1, indent: 0, thickness: 0.5),
              Row(
                children: [
                  Expanded(child: _buildAddressSubDistrict('Connecticut')),
                  Container(
                    width: 0.5,
                    height: 44,
                    color: Colors.grey.shade300,
                  ),
                  SizedBox(
                    width: 100,
                    child: _buildAddressTextField(postCode ?? ""),
                  ),
                ],
              ),
              const Divider(height: 1, indent: 0, thickness: 0.5),
              _buildAddressTextField('THAILAND'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressTextField(String hint) {
    return SizedBox(
      height: 44,
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.black),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
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
          color: Color(0xFFFFFFFF),
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
                      ? BorderSide(color: colorGrey, width: borderWidth)
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

  Widget _buildAddressDistrict(String hint) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 36),
      child: SizedBox(
        height: 44,
        child: Consumer(
          builder: (context, ref, _) {
            final districtGetListState = ref.watch(
              districtsProvider(
                selectedProvince == null
                    ? ""
                    : selectedProvince!.provinceID.toString(),
              ),
            );
            return districtGetListState.when(
              data: (district) {
                return SizedBox(
                  width: 300,
                  child: DropdownButton<District>(
                    isExpanded: true,
                    hint: const Text('เลือก'),
                    value: selectedDistrict,
                    items: district.map((p) {
                      return DropdownMenuItem<District>(
                        value: p,
                        child: Text(p.districtName.toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDistrict = value;
                        selectedSubdistrict = null;
                        txtPostcode.text = "";
                        postCode = "";
                      });
                    },
                  ),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (err, _) => Text('Error: $err'),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAddressSubDistrict(String hint) {
    return Padding(
      padding: const EdgeInsets.only(left: 18),
      child: SizedBox(
        height: 44,
        child: Consumer(
          builder: (context, ref, _) {
            final districtGetListState = ref.watch(
              subdistrictsProvider(
                selectedDistrict == null
                    ? ""
                    : selectedDistrict!.districtID.toString(),
              ),
            );
            return districtGetListState.when(
              data: (district) {
                return SizedBox(
                  width: 200,
                  child: DropdownButton<Subdistrict>(
                    isExpanded: true,
                    hint: const Text('เลือก'),
                    value: selectedSubdistrict,
                    items: district.map((p) {
                      return DropdownMenuItem<Subdistrict>(
                        value: p,
                        child: Text(p.subDistrictName.toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSubdistrict = value;
                        txtPostcode.text = value?.postCode ?? "";
                        postCode = value?.postCode ?? "";
                      });
                    },
                  ),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (err, _) => Text('Error: $err'),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAddressProvince(String hint) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 36),
      child: SizedBox(
        height: 44,
        child: Consumer(
          builder: (context, ref, _) {
            final provincesProviderState = ref.watch(provincesProvider);
            return provincesProviderState.when(
              data: (provinces) {
                return SizedBox(
                  width: 300,
                  child: DropdownButton<Province>(
                    isExpanded: true,
                    hint: const Text('เลือก'),
                    value: selectedProvince,
                    items: provinces.map((p) {
                      return DropdownMenuItem<Province>(
                        value: p,
                        child: Text(p.provinceName.toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedProvince = value;
                        selectedDistrict = null;
                        selectedSubdistrict = null;
                        txtPostcode.text = "";
                        postCode = "";
                      });
                    },
                  ),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (err, _) => Text('Error: $err'),
            );
          },
        ),
      ),
    );
  }
  // --- Helper Widgets for building UI sections ---

  // Widget สำหรับหัวข้อของแต่ละ Section (เช่น CLIENT INFO)
  // Widget _buildSectionHeader(String title) {
  //   return Padding(
  //     padding: const EdgeInsets.all(16.0),
  //     child: Center(
  //       child: Text(title, style: TextStyle(color: Colors.black, fontSize: 20)),
  //     ),
  //   );
  // }

  // Widget _buildTappableRowProvince(
  //   String label,
  //   String value, {
  //   bool showDivider = true,
  // }) {
  //   return InkWell(
  //     onTap: () {
  //       // TODO: Implement navigation or show picker for this row
  //     },
  //     child: Padding(
  //       padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
  //       child: Column(
  //         children: [
  //           SizedBox(
  //             height: 44, // ความสูงมาตรฐานของ iOS list item
  //             child: Row(
  //               children: [
  //                 Text(label, style: const TextStyle(fontSize: 16)),
  //                 const Spacer(),
  //                 Consumer(
  //                   builder: (context, ref, _) {
  //                     final provincesProviderState = ref.watch(
  //                       provincesProvider,
  //                     );
  //                     return provincesProviderState.when(
  //                       data: (provinces) {
  //                         return SizedBox(
  //                           width: 300,
  //                           child: DropdownButton<Province>(
  //                             isExpanded: true,
  //                             hint: const Text('เลือก'),
  //                             value: selectedProvince,
  //                             items: provinces.map((p) {
  //                               return DropdownMenuItem<Province>(
  //                                 value: p,
  //                                 child: Text(p.provinceName.toString()),
  //                               );
  //                             }).toList(),
  //                             onChanged: (value) {
  //                               setState(() {
  //                                 selectedProvince = value;
  //                                 selectedDistrict = null;
  //                                 selectedSubdistrict = null;
  //                                 txtPostcode.text = "";
  //                               });
  //                             },
  //                           ),
  //                         );
  //                       },
  //                       loading: () => const CircularProgressIndicator(),
  //                       error: (err, _) => Text('Error: $err'),
  //                     );
  //                   },
  //                 ),
  //               ],
  //             ),
  //           ),
  //           if (showDivider)
  //             const Divider(height: 1, indent: 0, thickness: 0.5),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildTappableRowDistrict(
  //   String label,
  //   String value, {
  //   bool showDivider = true,
  // }) {
  //   return InkWell(
  //     onTap: () {
  //       // TODO: Implement navigation or show picker for this row
  //     },
  //     child: Padding(
  //       padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
  //       child: Column(
  //         children: [
  //           SizedBox(
  //             height: 44, // ความสูงมาตรฐานของ iOS list item
  //             child: Row(
  //               children: [
  //                 Text(label, style: const TextStyle(fontSize: 16)),
  //                 const Spacer(),
  //                 Consumer(
  //                   builder: (context, ref, _) {
  //                     final districtGetListState = ref.watch(
  //                       districtsProvider(
  //                         selectedProvince == null
  //                             ? ""
  //                             : selectedProvince!.provinceID.toString(),
  //                       ),
  //                     );
  //                     return districtGetListState.when(
  //                       data: (district) {
  //                         return SizedBox(
  //                           width: 300,
  //                           child: DropdownButton<District>(
  //                             isExpanded: true,
  //                             hint: const Text('เลือก'),
  //                             value: selectedDistrict,
  //                             items: district.map((p) {
  //                               return DropdownMenuItem<District>(
  //                                 value: p,
  //                                 child: Text(p.districtName.toString()),
  //                               );
  //                             }).toList(),
  //                             onChanged: (value) {
  //                               setState(() {
  //                                 selectedDistrict = value;
  //                                 selectedSubdistrict = null;
  //                                 txtPostcode.text = "";
  //                               });
  //                             },
  //                           ),
  //                         );
  //                       },
  //                       loading: () => const CircularProgressIndicator(),
  //                       error: (err, _) => Text('Error: $err'),
  //                     );
  //                   },
  //                 ),
  //               ],
  //             ),
  //           ),
  //           if (showDivider)
  //             const Divider(height: 1, indent: 0, thickness: 0.5),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildTappableRowSubDistrict(
  //   String label,
  //   String value, {
  //   bool showDivider = true,
  // }) {
  //   return InkWell(
  //     onTap: () {
  //       // TODO: Implement navigation or show picker for this row
  //     },
  //     child: Padding(
  //       padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
  //       child: Column(
  //         children: [
  //           SizedBox(
  //             height: 44, // ความสูงมาตรฐานของ iOS list item
  //             child: Row(
  //               children: [
  //                 Text(label, style: const TextStyle(fontSize: 16)),
  //                 const Spacer(),
  //                 Consumer(
  //                   builder: (context, ref, _) {
  //                     final districtGetListState = ref.watch(
  //                       subdistrictsProvider(
  //                         selectedDistrict == null
  //                             ? ""
  //                             : selectedDistrict!.districtID.toString(),
  //                       ),
  //                     );
  //                     return districtGetListState.when(
  //                       data: (district) {
  //                         return SizedBox(
  //                           width: 295,
  //                           child: DropdownButton<Subdistrict>(
  //                             isExpanded: true,
  //                             hint: const Text('เลือก'),
  //                             value: selectedSubdistrict,
  //                             items: district.map((p) {
  //                               return DropdownMenuItem<Subdistrict>(
  //                                 value: p,
  //                                 child: Text(p.subDistrictName.toString()),
  //                               );
  //                             }).toList(),
  //                             onChanged: (value) {
  //                               setState(() {
  //                                 selectedSubdistrict = value;
  //                                 txtPostcode.text = value?.postCode ?? "";
  //                               });
  //                             },
  //                           ),
  //                         );
  //                       },
  //                       loading: () => const CircularProgressIndicator(),
  //                       error: (err, _) => Text('Error: $err'),
  //                     );
  //                   },
  //                 ),
  //               ],
  //             ),
  //           ),
  //           if (showDivider)
  //             const Divider(height: 1, indent: 0, thickness: 0.5),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget สำหรับแถวข้อมูลธรรมดา (Label: Value)
  Widget _buildInfoRowClient(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        top: 16,
        bottom: 16,
        right: 16,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 16)),
              SizedBox(width: 40),
              Padding(
                padding: const EdgeInsets.only(left: 0),
                child: SizedBox(
                  width: 170,
                  child: Text("John Doe", style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowLastName(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16),
      child: Column(
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 16)),
              SizedBox(width: 35),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: txtLastName,
                  decoration: const InputDecoration(
                    hintStyle: TextStyle(color: Colors.black),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowPhone(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        bottom: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 16)),
              SizedBox(width: 65),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: txtPhone,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.black),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowEmail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        bottom: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 16)),
              SizedBox(width: 75),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: txtEmail,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.black),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _buildInfoRowAddress(String label, String value) {
  //   return Padding(
  //     padding: const EdgeInsets.only(
  //       left: 16.0,
  //       top: 16,
  //       bottom: 16,
  //       right: 16,
  //     ),
  //     child: Column(
  //       children: [
  //         Row(
  //           children: [
  //             Text(label, style: const TextStyle(fontSize: 16)),
  //             const Spacer(),
  //             SizedBox(
  //               width: 300,
  //               child: TextField(
  //                 controller: txtAddress,
  //                 style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
  //               ),
  //             ),
  //           ],
  //         ),
  //         const Divider(height: 1, indent: 0, thickness: 0.5),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildInfoRowPostcode(String label, String value) {
  //   return Padding(
  //     padding: const EdgeInsets.only(left: 16.0, bottom: 16, right: 16),
  //     child: Column(
  //       children: [
  //         Row(
  //           children: [
  //             Text(label, style: const TextStyle(fontSize: 16)),
  //             const Spacer(),
  //             SizedBox(
  //               width: 300,
  //               child: TextField(
  //                 controller: txtPostcode,
  //                 style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
  //               ),
  //             ),
  //           ],
  //         ),
  //         const Divider(height: 1, indent: 0, thickness: 0.5),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildTappableRowProduct(
    String label,
    String value,
    AsyncValue<List<Product>> productGetList, {
    bool showDivider = true,
  }) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, bottom: 16),
        child: Column(
          children: [
            SizedBox(
              height: 44, // ความสูงมาตรฐานของ iOS list item
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _showPopupProduct(productGetList);
                    },
                    icon: Icon(Icons.add),
                    iconSize: 20,
                    color: Colors.white,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.green),
                      shape: MaterialStateProperty.all(CircleBorder()),
                    ),
                  ),
                  Text(label, style: const TextStyle(fontSize: 16)),
                  const Spacer(),
                ],
              ),
            ),
            if (showDivider)
              const Divider(height: 1, indent: 0, thickness: 0.5),
          ],
        ),
      ),
    );
  }

  Widget _buildTappableRowCompany(
    String label,
    String value,
    AsyncValue<List<Company>> companyGetList, {
    bool showDivider = true,
  }) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, bottom: 16),
        child: Column(
          children: [
            SizedBox(
              height: 44, // ความสูงมาตรฐานของ iOS list item
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _showPopupCompany(companyGetList);
                    },
                    icon: Icon(Icons.add),
                    iconSize: 20,
                    color: Colors.white,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.green),
                      shape: MaterialStateProperty.all(CircleBorder()),
                    ),
                  ),
                  Text(label, style: const TextStyle(fontSize: 16)),
                  const Spacer(),
                ],
              ),
            ),
            if (showDivider)
              const Divider(height: 1, indent: 0, thickness: 0.5),
          ],
        ),
      ),
    );
  }

  // Widget _buildTappableRowLevel(
  //   String label,
  //   String value, {
  //   bool showDivider = true,
  // }) {
  //   return InkWell(
  //     onTap: () {
  //       // TODO: Implement navigation or show picker for this row
  //     },
  //     child: Padding(
  //       padding: const EdgeInsets.only(left: 16.0, right: 16),
  //       child: Column(
  //         children: [
  //           SizedBox(
  //             height: 44, // ความสูงมาตรฐานของ iOS list item
  //             child: Row(
  //               children: [
  //                 Text(
  //                   label,
  //                   style: const TextStyle(fontSize: 16, color: Colors.blue),
  //                 ),
  //                 const VerticalDivider(
  //                   color: Colors.grey,
  //                   thickness: 0.5,
  //                   width: 87,
  //                 ),

  //                 Consumer(
  //                   builder: (context, ref, _) {
  //                     final clientLevelGetListState = ref.watch(
  //                       clientLevelGetList,
  //                     );
  //                     return clientLevelGetListState.when(
  //                       data: (clientLevel) {
  //                         return SizedBox(
  //                           width: 260,
  //                           child: DropdownButton<String>(
  //                             isExpanded: true,
  //                             hint: const Text('เลือก'),
  //                             value: selectClientLevel,
  //                             items: clientLevel.map((p) {
  //                               return DropdownMenuItem<String>(
  //                                 value: p.clientLevelID,
  //                                 child: Text(p.clientLevelName.toString()),
  //                               );
  //                             }).toList(),
  //                             onChanged: (value) {
  //                               setState(() {
  //                                 selectClientLevel = value;
  //                               });
  //                             },
  //                           ),
  //                         );
  //                       },
  //                       loading: () => const CircularProgressIndicator(),
  //                       error: (err, _) => Text('Error: $err'),
  //                     );
  //                   },
  //                 ),
  //               ],
  //             ),
  //           ),
  //           if (showDivider)
  //             const Divider(height: 1, indent: 0, thickness: 0.5),
  //         ],
  //       ),
  //     ),
  //   );
  // }

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

    // ref
    //     .read(clienAddProvider(widget.appointmentID).notifier)
    //     .setTerritory(selected);
  }

  Widget _buildTappableRowLevel(
    String label,
    String value, {
    bool showDivider = true,
  }) {
    return InkWell(
      onTap: () {
        // TODO: Implement navigation or show picker for this row
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16),
        child: Column(
          children: [
            SizedBox(
              height: 44, // ความสูงมาตรฐานของ iOS list item
              child: Row(
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                  const SizedBox(width: 36),
                  const VerticalDivider(color: Colors.grey, thickness: 0.5),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 210,
                    child: Consumer(
                      builder: (context, ref, _) {
                        final clientLevelGetListState = ref.watch(
                          clientLevelGetList,
                        );
                        return clientLevelGetListState.when(
                          data: (clientLevel) {
                            return DropdownButton<String>(
                              isExpanded: true,
                              hint: const Text('เลือก'),
                              value: selectClientLevel,
                              items: clientLevel.map((p) {
                                return DropdownMenuItem<String>(
                                  value: p.clientLevelID,
                                  child: Text(p.clientLevelName.toString()),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectClientLevel = value;
                                });
                              },
                            );
                          },
                          loading: () => const CircularProgressIndicator(),
                          error: (err, _) => Text('Error: $err'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTappableRowSaleTerritory(
    String label,
    String value, {
    bool showDivider = true,
  }) {
    return InkWell(
      onTap: () {
        // TODO: Implement navigation or show picker for this row
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16),
        child: Column(
          children: [
            SizedBox(
              height: 44, // ความสูงมาตรฐานของ iOS list item
              child: Row(
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  const VerticalDivider(color: Colors.grey, thickness: 0.5),
                  const SizedBox(width: 10),
                  // Consumer(
                  //   builder: (context, ref, _) {
                  //     final saleTerritorieGetListState = ref.watch(
                  //       saleTerritorieGetList,
                  //     );
                  //     return saleTerritorieGetListState.when(
                  //       data: (territory) {
                  //         return SizedBox(
                  //           width: 210,
                  //           child: DropdownButton<String>(
                  //             isExpanded: true,
                  //             hint: const Text('เลือก'),
                  //             value: salesTerritory,
                  //             items: territory.map((p) {
                  //               return DropdownMenuItem<String>(
                  //                 value: p.salesTerritoryID,
                  //                 child: Text(p.salesTerritoryName.toString()),
                  //               );
                  //             }).toList(),
                  //             onChanged: (value) {
                  //               setState(() {
                  //                 salesTerritory = value;
                  //               });
                  //             },
                  //           ),
                  //         );
                  //       },
                  //       loading: () => const CircularProgressIndicator(),
                  //       error: (err, _) => Text('Error: $err'),
                  //     );
                  //   },
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget สำหรับแถวที่กดได้ (มีลูกศร >)
  Widget _buildTappableRowStatus(
    String label,
    String value, {
    bool showDivider = true,
  }) {
    return InkWell(
      onTap: () {
        // TODO: Implement navigation or show picker for this row
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16),
        child: Column(
          children: [
            SizedBox(
              height: 44, // ความสูงมาตรฐานของ iOS list item
              child: Row(
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                  const SizedBox(width: 24),
                  const VerticalDivider(color: Colors.grey, thickness: 0.5),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 210,
                    child: Consumer(
                      builder: (context, ref, _) {
                        final clientStatusGetListState = ref.watch(
                          ClientStatusGetList,
                        );
                        return clientStatusGetListState.when(
                          data: (clientStatus) {
                            return DropdownButton<String>(
                              isExpanded: true,
                              hint: const Text('เลือก'),
                              value: selectClientStatus,
                              items: clientStatus.map((p) {
                                return DropdownMenuItem<String>(
                                  value: p.clientStatusID,
                                  child: Text(p.clientStatusName.toString()),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectClientStatus = value;
                                });
                              },
                            );
                          },
                          loading: () => const CircularProgressIndicator(),
                          error: (err, _) => Text('Error: $err'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
