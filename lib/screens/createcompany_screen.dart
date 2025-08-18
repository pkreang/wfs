import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/models/client_model.dart';
import 'package:wfs/models/clientaddresses.dart';
import 'package:wfs/models/clientcompanies_model.dart';
import 'package:wfs/models/company_model.dart';
import 'package:wfs/models/product_model.dart';
import 'package:wfs/providers/auth_provider.dart';
import 'package:wfs/providers/purposetype_provider.dart';
import 'package:wfs/providers/product_provider.dart';
import 'package:wfs/providers/saleterritorie_provider.dart';
import 'package:wfs/services/client_service.dart';

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
  String? selectedPurpose;
  String? product;
  String? commany;
  String? salesTerritory;
  DateTime? dateTimeFrom;
  DateTime? dateTimeTo;
  final TextEditingController txtAddress = TextEditingController();
  final TextEditingController txtClientName = TextEditingController();
  final TextEditingController txtPhone = TextEditingController();
  final TextEditingController txtEmail = TextEditingController();
  List<Product> selectedProduct = [];
  List<Company> selectedCompany = [];

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
          'New Company',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,

        actions: [
          TextButton(
            onPressed: () {
              Client client = Client(
                firstName: txtClientName.text,
                lastName: "TestLastName",
                address: "123 Bangkok",
                phone: txtPhone.text,
                email: txtEmail.text,
                salesTerritoryID: salesTerritory,
                clientStatusID: salesTerritory,
                clientLevelID: salesTerritory,
                noted: "xxxxxxxxxxxxxxx",
                availableTimeStart: "09:00",
                availableTimeEnd: "16:00",
                isActive: true,
                createdBy: "9E0DC5F7-1FD6-41F3-9137-14711FC510F6",
                modifiedBy: "9E0DC5F7-1FD6-41F3-9137-14711FC510F6",
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
                createdDate: "2025-08-17T09:15:41.557000",
                modifiedDate: "2025-08-17T09:15:41.557000",
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
              final authState = ref.watch(authProvider);
              final accessToken = authState.accessToken;
              try {
                clientService.Add(accessToken.toString(), client);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('บันทึกข้อมูลเรียบร้อยแล้ว'),
                    duration: Duration(seconds: 3),
                    // action: SnackBarAction(label: 'ปิด', onPressed: () {}),
                  ),
                );
              } catch (ex) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ex.toString()),
                    duration: Duration(seconds: 3),
                    // action: SnackBarAction(label: 'ปิด', onPressed: () {}),
                  ),
                );
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
            child: Column(children: [_buildInfoRowClient('Company Name', '')]),
          ),
          const SizedBox(height: 30),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(height: 20),
                _buildTappableRowStatus('Status', ''),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                _buildInfoRowAddress('Address', ''),
                _buildTappableRowSaleTerritory('Territory', ''),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text("LINKED CLIENTS"),
          ),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(height: 20),
                _buildTappableRowProduct(
                  'add clients',
                  '',
                  ProductGetListState,
                ),
                SizedBox(height: 20),
                Center(
                  child: selectedCompany.length > 0
                      ? Text(
                          "clients ที่เลือก:",
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
                width: 250,
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
              Text(
                label,
                style: const TextStyle(fontSize: 16, color: Colors.blue),
              ),
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
                      final perposeTypeGetListState = ref.watch(
                        perposeTypeGetList,
                      );
                      return perposeTypeGetListState.when(
                        data: (perposeType) {
                          return SizedBox(
                            width: 300,
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: const Text('เลือก'),
                              value: selectedPurpose,
                              items: perposeType.map((p) {
                                return DropdownMenuItem<String>(
                                  value: p.purposeTypeID,
                                  child: Text(p.purposeTypeName.toString()),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedPurpose = value;
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
