import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wfs/models/company_model.dart';
import 'package:wfs/models/companyaddress.dart';
import 'package:wfs/models/district_model.dart';
import 'package:wfs/models/product_model.dart';
import 'package:wfs/models/province_model.dart';
import 'package:wfs/models/subdistrict_model.dart';
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
  Province? selectedProvince;
  District? selectedDistrict;
  Subdistrict? selectedSubdistrict;
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

  List<Product> selectedProduct = [];
  List<Company> selectedCompany = [];

  @override
  Widget build(BuildContext context) {
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
              String? error;
              error = Validator.required(txtCompanyName.text);
              if (error != null) {
                AppDialogs.error(context, message: error + " Company Name");
                return;
              }

              error = Validator.required(txtTaxID.text);
              if (error != null) {
                AppDialogs.error(context, message: error + " Tax ID");
                return;
              }

              error = Validator.required(selectStatus);
              if (error != null) {
                AppDialogs.error(context, message: "กรุณาเลือก Status");
                return;
              }

              error = Validator.required(salesTerritory);
              if (error != null) {
                AppDialogs.error(context, message: "กรุณาเลือก Territory");
                return;
              }

              error = Validator.required(txtAddress.text);
              if (error != null) {
                AppDialogs.error(context, message: error + "Address");
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

              error = Validator.required(txtPostCode.text);
              if (error != null) {
                AppDialogs.error(context, message: error + "PostCode");
                return;
              }
              final authState = ref.watch(authProvider);
              Company company = Company(
                companyName: txtCompanyName.text,
                taxID: txtTaxID.text,
                salesTerritoryID: "09A69122-4BE0-4201-8B53-3AEF1C24EBDC",
                noted: "xxxxxxxxxxxxxxx",
                isActive: true,
                createdDate: DateTime.now().toIso8601String(),
                modifiedDate: DateTime.now().toIso8601String(),
                createdBy: authState.userID,
                modifiedBy: authState.userID,
                CompanyAddresses: [
                  CompanyAddress(
                    address: txtAddress.text, //"123 ABC Rd.",
                    provinceID: selectedProvince?.provinceID ?? null, //1,
                    districtID: selectedDistrict?.districtID ?? null, // 13,
                    latitude: null,
                    isPrimary: true,
                    createdBy: "9E0DC5F7-1FD6-41F3-9137-14711FC510F6",
                    modifiedBy: "9E0DC5F7-1FD6-41F3-9137-14711FC510F6",
                    countryID: 1,
                    subDistrictID:
                        selectedSubdistrict?.subDistrictID ?? null, // 2583,
                    longitude: null,
                    isActive: true,
                  ),
                ],
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
            child: Column(
              children: [
                _buildInfoRowClientCompany('Company Name', ''),
                _buildInfoRowClientTaxID('Tax ID', ''),
              ],
            ),
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
                _buildTappableRowSaleTerritory('Territory', ''),
                _buildInfoRowAddress('Address', ''),
                _buildTappableRowProvince('Province', ''),
                _buildTappableRowDistrict('Distric', ''),
                _buildTappableRowSubDistrict('SubDistric', ''),
                _buildInfoRowPostCode('PostCode', ''),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // Padding(
          //   padding: const EdgeInsets.only(left: 16.0),
          //   child: Text("LINKED CLIENTS"),
          // ),
          // Container(
          //   color: Colors.white,
          //   child: Column(
          //     children: [
          //       SizedBox(height: 20),
          //       _buildTappableRowProduct(
          //         'add clients',
          //         '',
          //         ProductGetListState,
          //       ),
          //       SizedBox(height: 20),
          //       Center(
          //         child: selectedCompany.length > 0
          //             ? Text(
          //                 "clients ที่เลือก:",
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
  Widget _buildInfoRowClientCompany(String label, String value) {
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
                  controller: txtCompanyName,
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

  Widget _buildInfoRowClientTaxID(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 16, right: 16),
      child: Column(
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 16)),
              const Spacer(),
              SizedBox(
                width: 250,
                child: TextField(
                  controller: txtTaxID,
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

  Widget _buildInfoRowPostCode(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 16, right: 16),
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
                  controller: txtPostCode,
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
        padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
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
                  Text(
                    label,
                    style: const TextStyle(fontSize: 16, color: Colors.blue),
                  ),
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
                                  txtPostCode.text = "";
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
                  Text(
                    label,
                    style: const TextStyle(fontSize: 16, color: Colors.blue),
                  ),
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
                                  txtPostCode.text = "";
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
                  Text(
                    label,
                    style: const TextStyle(fontSize: 16, color: Colors.blue),
                  ),
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
                            width: 300,
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
                                  txtPostCode.text = value?.postCode ?? "";
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
                              value: selectStatus,
                              items: clientStatus.map((p) {
                                return DropdownMenuItem<String>(
                                  value: p.clientStatusID,
                                  child: Text(p.clientStatusName.toString()),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectStatus = value;
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
