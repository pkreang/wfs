import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/models/client_model.dart';
import 'package:wfs/models/clientaddresses.dart';
import 'package:wfs/models/clientcompanies_model.dart';
import 'package:wfs/models/company_model.dart';
import 'package:wfs/models/district_model.dart';
import 'package:wfs/models/product_model.dart';
import 'package:wfs/models/province_model.dart';
import 'package:wfs/models/subdistrict_model.dart';
import 'package:wfs/providers/auth_provider.dart';
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
  String? salesTerritory;
  String? selectClientStatus;
  String? selectClientLevel;
  DateTime? dateTimeFrom;
  DateTime? dateTimeTo;
  Province? selectedProvince;
  District? selectedDistrict;
  Subdistrict? selectedSubdistrict;
  final TextEditingController txtAddress = TextEditingController();
  final TextEditingController txtClientName = TextEditingController();
  final TextEditingController txtPhone = TextEditingController();
  final TextEditingController txtEmail = TextEditingController();
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
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F7),
        elevation: 0,

        leading: TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.blue, fontSize: 16),
          ),
        ),
        leadingWidth: 80,

        title: const Text(
          'New Client',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
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

              error = Validator.required(salesTerritory);
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
                lastName: "TestLastName",
                address: "123 Bangkok",
                phone: txtPhone.text,
                email: txtEmail.text,
                salesTerritoryID: salesTerritory,
                clientStatusID: selectClientStatus,
                clientLevelID: selectClientLevel,
                noted: "xxxxxxxxxxxxxxx",
                availableTimeStart: "09:00",
                availableTimeEnd: "16:00",
                isActive: true,
                createdBy: authState.userID,
                modifiedBy: null,
                clientAddresses: [
                  ClientAddresses(
                    address: "123/4 Sukhumvit Road",
                    countryID: 1,
                    provinceID: 1,
                    districtID: 13,
                    subDistrictID: 2583,
                    latitude: null,
                    longitude: null,
                    isPrimary: true,
                    isActive: true,
                  ),
                ],
                clientID: "",
                createdDate: DateTime.now().toIso8601String(),
                modifiedDate: null,
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
                AppDialogs.success(context);
              } catch (ex) {
                AppDialogs.error(context, message: ex.toString());
              }
            },
            child: const Text(
              'Add',
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
          _buildSectionHeader('CLIENT INFO'),
          Container(
            color: Colors.white,
            child: Column(children: [_buildInfoRowClient('Client Name', '')]),
          ),
          const SizedBox(height: 30),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(height: 20),
                _buildTappableRowStatus('Status', ''),
                _buildTappableRowLevel('Level', '', showDivider: false),
                _buildTappableRowSaleTerritory('Territory', ''),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                _buildInfoRowAddress('Address', ''),
                _buildTappableRowProvince("Province", ""),
                _buildTappableRowDistrict("District", ""),
                _buildTappableRowSubDistrict("SubDistrict", ""),
              ],
            ),
          ),

          Container(
            color: Colors.white,
            child: Column(children: [_buildInfoRowPhone('Phone', '')]),
          ),
          Container(
            color: Colors.white,
            child: Column(children: [_buildInfoRowEmail('Email', '')]),
          ),
          const SizedBox(height: 30),
          const Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text("LINKED COMPANY"),
          ),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(height: 20),
                _buildTappableRowCompany(
                  'add company',
                  '',
                  companyGetListProviderState,
                ),
                SizedBox(height: 20),
                Center(
                  child: selectedCompany.length > 0
                      ? Text(
                          "Company ที่เลือก:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      : Text(""),
                ),
                SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: selectedCompany
                      .map(
                        (e) => Chip(
                          label: Text(e.companyName.toString()),
                          deleteIcon: Icon(Icons.close),
                          onDeleted: () {
                            setState(() {
                              selectedCompany.remove(e);
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text("LINKED PRODUCT"),
          ),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(height: 20),
                _buildTappableRowProduct(
                  'add product',
                  '',
                  ProductGetListState,
                ),
                SizedBox(height: 20),
                Center(
                  child: selectedCompany.length > 0
                      ? Text(
                          "Product ที่เลือก:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      : Text(""),
                ),
                SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: selectedProduct
                      .map(
                        (e) => Chip(
                          label: Text(e.productName.toString()),
                          deleteIcon: Icon(Icons.close),
                          onDeleted: () {
                            setState(() {
                              selectedProduct.remove(e);
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- Helper Widgets for building UI sections ---

  // Widget สำหรับหัวข้อของแต่ละ Section (เช่น CLIENT INFO)
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
    );
  }

  Widget _buildTappableRowProvince(
    String label,
    String value, {
    bool showDivider = true,
  }) {
    return InkWell(
      onTap: () {
        // TODO: Implement navigation or show picker for this row
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
        child: Column(
          children: [
            SizedBox(
              height: 44, // ความสูงมาตรฐานของ iOS list item
              child: Row(
                children: [
                  Text(label, style: const TextStyle(fontSize: 16)),
                  const Spacer(),
                  Consumer(
                    builder: (context, ref, _) {
                      final provincesProviderState = ref.watch(
                        provincesProvider,
                      );
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

  Widget _buildTappableRowDistrict(
    String label,
    String value, {
    bool showDivider = true,
  }) {
    return InkWell(
      onTap: () {
        // TODO: Implement navigation or show picker for this row
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
        child: Column(
          children: [
            SizedBox(
              height: 44, // ความสูงมาตรฐานของ iOS list item
              child: Row(
                children: [
                  Text(label, style: const TextStyle(fontSize: 16)),
                  const Spacer(),
                  Consumer(
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

  Widget _buildTappableRowSubDistrict(
    String label,
    String value, {
    bool showDivider = true,
  }) {
    return InkWell(
      onTap: () {
        // TODO: Implement navigation or show picker for this row
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
        child: Column(
          children: [
            SizedBox(
              height: 44, // ความสูงมาตรฐานของ iOS list item
              child: Row(
                children: [
                  Text(label, style: const TextStyle(fontSize: 16)),
                  const Spacer(),
                  Consumer(
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
                            width: 295,
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
              const Spacer(),
              SizedBox(
                width: 280,
                child: TextField(
                  controller: txtClientName,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
          const Divider(height: 1, indent: 0, thickness: 0.5),
        ],
      ),
    );
  }

  Widget _buildInfoRowPhone(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 16, right: 16),
      child: Column(
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 16)),
              const Spacer(),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: txtPhone,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
          const Divider(height: 1, indent: 0, thickness: 0.5),
        ],
      ),
    );
  }

  Widget _buildInfoRowEmail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 16, right: 16),
      child: Column(
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 16)),
              const Spacer(),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: txtEmail,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
          const Divider(height: 1, indent: 0, thickness: 0.5),
        ],
      ),
    );
  }

  Widget _buildInfoRowAddress(String label, String value) {
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
              const Spacer(),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: txtAddress,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
          const Divider(height: 1, indent: 0, thickness: 0.5),
        ],
      ),
    );
  }

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
                  const Spacer(),

                  Consumer(
                    builder: (context, ref, _) {
                      final clientLevelGetListState = ref.watch(
                        clientLevelGetList,
                      );
                      return clientLevelGetListState.when(
                        data: (clientLevel) {
                          return SizedBox(
                            width: 300,
                            child: DropdownButton<String>(
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
                            ),
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (err, _) => Text('Error: $err'),
                      );
                    },
                  ),
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
                  const Spacer(),
                  Consumer(
                    builder: (context, ref, _) {
                      final saleTerritorieGetListState = ref.watch(
                        saleTerritorieGetList,
                      );
                      return saleTerritorieGetListState.when(
                        data: (territory) {
                          return SizedBox(
                            width: 300,
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: const Text('เลือก'),
                              value: salesTerritory,
                              items: territory.map((p) {
                                return DropdownMenuItem<String>(
                                  value: p.salesTerritoryID,
                                  child: Text(p.salesTerritoryName.toString()),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  salesTerritory = value;
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
                  const Spacer(),

                  Consumer(
                    builder: (context, ref, _) {
                      final ClientStatusGetListState = ref.watch(
                        ClientStatusGetList,
                      );
                      return ClientStatusGetListState.when(
                        data: (clientStatus) {
                          return SizedBox(
                            width: 300,
                            child: DropdownButton<String>(
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
                            ),
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (err, _) => Text('Error: $err'),
                      );
                    },
                  ),
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
}
