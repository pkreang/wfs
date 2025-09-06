import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wfs/main.dart';
import 'package:wfs/models/appointmentaddresss_model.dart';
import 'package:wfs/models/appointments_model.dart';
import 'package:wfs/models/district_model.dart';
import 'package:wfs/models/product_model.dart';
import 'package:wfs/models/province_model.dart';
import 'package:wfs/models/subdistrict_model.dart';
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
import 'package:wfs/utility/validator.dart';

class CreateAppointmentScreen extends ConsumerStatefulWidget {
  const CreateAppointmentScreen({super.key});

  @override
  ConsumerState<CreateAppointmentScreen> createState() =>
      _CreateAppointmentScreenState();
}

class _CreateAppointmentScreenState
    extends ConsumerState<CreateAppointmentScreen> {
  String? selectedPurpose;
  String? salesTerritory;
  String? appointmentStatus;
  String? company;
  DateTime? dateTimeFrom;
  DateTime? dateTimeTo;
  Province? selectedProvince;
  District? selectedDistrict;
  Subdistrict? selectedSubdistrict;
  final TextEditingController txtAddress = TextEditingController();
  final TextEditingController txtClientName = TextEditingController();
  final TextEditingController txtNote = TextEditingController();
  final TextEditingController txtPostCode = TextEditingController();
  List<Product> selectedProduct = [];
  Future<void> _pickDateTime(bool isFrom) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      // TimeOfDay? pickedTime = await showTimePicker(
      //   context: context,
      //   initialTime: const TimeOfDay(hour: 9, minute: 0),
      //   initialEntryMode: TimePickerEntryMode.input,
      // );
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );
      if (pickedTime != null) {
        DateTime fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          if (isFrom) {
            dateTimeFrom = fullDateTime;
          } else {
            dateTimeTo = fullDateTime;
          }
        });
      }
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
    final selectedItem = ref.watch(selectedItemProvider);
    final clientGetByIdProviderState = ref.watch(
      clientGetByIdProvider(selectedItem.toString()),
    );
    String? clientName = clientGetByIdProviderState.when(
      data: (client) => client.firstName!,
      loading: () => "Loading",
      error: (err, stack) => err.toString(),
    );
    String? phone = clientGetByIdProviderState.when(
      data: (client) => client.phone!,
      loading: () => "Loading",
      error: (err, stack) => err.toString(),
    );

    String? email = clientGetByIdProviderState.when(
      data: (client) => client.email!,
      loading: () => "Loading",
      error: (err, stack) => err.toString(),
    );
    // clientGetByIdProviderState.when(
    //   data: (value) {
    //     if (txtAddress.text.isEmpty) {
    //       txtAddress.text = value.address ?? "";
    //     }
    //     if (selectedProvince == null) {
    //       selectedProvince = value.;
    //     }
    //     // District? selectedDistrict;
    //     // Subdistrict? selectedSubdistrict;
    //   },
    //   loading: () {},
    //   error: (err, stack) {},
    // );

    //String? selectedProvinceId;
    return Scaffold(
      // ใช้สีพื้นหลังที่ใกล้เคียงกับ iOS Form
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
          'Create Appointment',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,

        actions: [
          TextButton(
            onPressed: () {
              String? error;
              error = Validator.required(clientName);
              if (error != null) {
                AppDialogs.error(context, message: error + " Client Name");
                return;
              }

              error = Validator.required(selectedPurpose);
              if (error != null) {
                AppDialogs.error(context, message: "กรุณาเลือก Purpose");
                return;
              }

              error = Validator.required(selectedPurpose);
              if (error != null) {
                AppDialogs.error(context, message: error + "Purpose");
                return;
              }

              error = Validator.required(salesTerritory);
              if (error != null) {
                AppDialogs.error(context, message: "กรุณาเลือก Territory");
                return;
              }

              error = Validator.required(appointmentStatus);
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

              error = Validator.required(txtPostCode.text);
              if (error != null) {
                AppDialogs.error(context, message: error + " PostCode");
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

              error = Validator.required(company);
              if (error != null) {
                AppDialogs.error(context, message: "กรุณาเลือก Company");
                return;
              }

              if (selectedProduct.length == 0) {
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
                companyID: company,
                appointmentDateTimeFrom: dateTimeFrom,
                appointmentDateTimeTo: dateTimeTo,
                appointmentStatusID: appointmentStatus, //
                purposeTypeID: selectedPurpose,
                noted: txtNote.text, //
                assignedBy: null, //
                appointmentAddress: AppointmentAddresss(
                  address: txtAddress.text,
                  countryID: 1, //
                  provinceID: selectedProvince?.provinceID ?? null, //1
                  districtID: selectedDistrict?.districtID ?? null, //13
                  subDistrictID: selectedSubdistrict?.subDistrictID ?? null, //
                  latitude: null,
                  longitude: null,
                  isPrimary: true,
                  isActive: true,
                ),
                appointmentProducts: selectedProduct
                    .map((p) => p.productID!)
                    .toList(),
                // [
                //   "0DB167F6-8AC9-4D31-A4BD-F3784F2489AD",
                // ], //
                isActive: true,
                createdBy: authState.userID, //
                modifiedBy: authState.userID,
              );
              AppointmentService appointmentService = new AppointmentService();

              try {
                appointmentService.Add(accessToken.toString(), appointment);
                // ignore: unused_result
                
                AppDialogs.success(context);
                Future.delayed(const Duration(seconds: 3), () {
                  context.push('/dashboard');
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
          // Section: CLIENT INFO
          _buildSectionHeader('CLIENT INFO'),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                _buildInfoRow('Client Name', clientName ?? ""),
                _buildTappableRowPurpose('Purpose', 'Initial Visit'),
                _buildTappableRowTerritory(
                  'Territory',
                  'North East US',
                  showDivider: false,
                ),
                _buildTappableRowStatus('Status', '', showDivider: false),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Section: Date & Time
          Container(
            color: Colors.white,
            child: Column(
              children: [
                ListTile(
                  title: Row(
                    children: [
                      Text("Starts", style: const TextStyle(fontSize: 16)),
                      const Spacer(),
                      _buildDateTimeChip(
                        DateFormat(
                          'MMM dd,yyyy',
                        ).format(dateTimeFrom ?? DateTime.now()),
                      ),
                      _buildDateTimeChip(
                        DateFormat(
                          'HH:mm',
                        ).format(dateTimeFrom ?? DateTime.now()),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _pickDateTime(true),
                ),
                ListTile(
                  title: Row(
                    children: [
                      Text("Ends", style: const TextStyle(fontSize: 16)),
                      const Spacer(),
                      _buildDateTimeChip(
                        DateFormat(
                          'MMM dd,yyyy',
                        ).format(dateTimeTo ?? DateTime.now()),
                      ),
                      _buildDateTimeChip(
                        DateFormat(
                          'HH:mm',
                        ).format(dateTimeTo ?? DateTime.now()),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _pickDateTime(false),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Section: Address
          Container(
            color: Colors.white,
            child: Column(
              children: [
                _buildNote(),
                _buildAddressSection(),
                _buildTappableRowProvince("Province", ""),
                _buildTappableRowDistrict("District", ""),
                _buildTappableRowSubDistrict("SubDistrict", ""),
                _buildPostCodeSection(),
              ],
            ),
          ),

          // Section: CONTACT
          _buildSectionHeader('CONTACT'),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                _buildContactRowMobile('Mobile', phone ?? ""),
                _buildContactRow('Email', email ?? ""),
                _buildContactRowCompany(
                  'Company',
                  'Happy Happy',
                  showDivider: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                _buildTappableRowProduct(
                  'Add Product',
                  '',
                  ProductGetListState,
                ),
                SizedBox(height: 20),
                Center(
                  child: selectedProduct.length > 0
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
        ],
      ),
    );
  }

  // --- Helper Widgets for building UI sections ---
  Widget _buildTappableRowProduct(
    String label,
    String value,
    AsyncValue<List<Product>> productGetList, {
    bool showDivider = true,
  }) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, bottom: 16, top: 16),
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

  // Widget สำหรับแถวข้อมูลธรรมดา (Label: Value)
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 16),
      child: Column(
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 16)),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  value,
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

  Widget _buildTappableRowTerritory(
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
                  Text(label, style: const TextStyle(fontSize: 16)),
                  const Spacer(),

                  Consumer(
                    builder: (context, ref, _) {
                      final saleTerritorieGetListState = ref.watch(
                        saleTerritorieGetList,
                      );
                      return saleTerritorieGetListState.when(
                        data: (saleTerritorie) {
                          return SizedBox(
                            width: 300,
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: const Text('เลือก'),
                              value: salesTerritory,
                              items: saleTerritorie.map((p) {
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
                  Text(label, style: const TextStyle(fontSize: 16)),
                  const Spacer(),

                  Consumer(
                    builder: (context, ref, _) {
                      final appointmentStatusGetListState = ref.watch(
                        appointmentStatusGetList,
                      );
                      return appointmentStatusGetListState.when(
                        data: (statuss) {
                          return SizedBox(
                            width: 300,
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: const Text('เลือก'),
                              value: appointmentStatus,
                              items: statuss.map((p) {
                                return DropdownMenuItem<String>(
                                  value: p.appointmentStatusID,
                                  child: Text(
                                    p.appointmentStatusName.toString(),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  appointmentStatus = value;
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
  Widget _buildTappableRowPurpose(
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
                  Text(label, style: const TextStyle(fontSize: 16)),
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

  // Chip แสดงวันที่/เวลา
  Widget _buildDateTimeChip(String text) {
    return GestureDetector(
      onTap: () {
        // TODO: Implement date/time picker logic
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text, style: const TextStyle(fontSize: 15)),
      ),
    );
  }

  // Widget สำหรับ Section ที่อยู่
  Widget _buildAddressSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16.0, top: 12),
          child: Text('Address', style: TextStyle(fontSize: 16)),
        ),
        Expanded(child: Column(children: [_buildAddressTextField('')])),
      ],
    );
  }

  Widget _buildPostCodeSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16.0, top: 12),
          child: Text('PostCode', style: TextStyle(fontSize: 16)),
        ),
        Expanded(child: Column(children: [_buildPostCodeTextField('')])),
      ],
    );
  }

  Widget _buildNote() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16.0, top: 12),
          child: Text('Note', style: TextStyle(fontSize: 16)),
        ),
        Expanded(child: Column(children: [_buildNoteTextField('')])),
      ],
    );
  }

  // TextField สำหรับกรอกที่อยู่
  Widget _buildAddressTextField(String hint) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0, right: 16),
      child: SizedBox(
        height: 44,
        child: TextField(
          controller: txtAddress,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            //border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildPostCodeTextField(String hint) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0, right: 16),
      child: SizedBox(
        height: 44,
        child: TextField(
          controller: txtPostCode,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            //border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildNoteTextField(String hint) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0, right: 16),
      child: SizedBox(
        height: 44,
        child: TextField(
          controller: txtNote,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            //border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  // Widget สำหรับแถวข้อมูล Contact (มีปุ่ม x)
  Widget _buildContactRow(
    String label,
    String value, {
    bool showDivider = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16),
      child: Column(
        children: [
          SizedBox(
            height: 44,
            child: Row(
              children: [
                Text(label, style: const TextStyle(fontSize: 16)),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          if (showDivider) const Divider(height: 1, indent: 0, thickness: 0.5),
        ],
      ),
    );
  }

  Widget _buildContactRowMobile(
    String label,
    String value, {
    bool showDivider = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16),
      child: Column(
        children: [
          SizedBox(
            height: 44,
            child: Row(
              children: [
                Text(label, style: const TextStyle(fontSize: 16)),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          if (showDivider) const Divider(height: 1, indent: 0, thickness: 0.5),
        ],
      ),
    );
  }

  Widget _buildContactRowCompany(
    String label,
    String value, {
    bool showDivider = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16),
      child: Column(
        children: [
          SizedBox(
            height: 44,
            child: Row(
              children: [
                Text(label, style: const TextStyle(fontSize: 16)),
                const Spacer(),
                Consumer(
                  builder: (context, ref, _) {
                    final companyGetListProviderState = ref.watch(
                      companyGetListProvider,
                    );
                    return companyGetListProviderState.when(
                      data: (companys) {
                        return SizedBox(
                          width: 300,
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text('เลือก'),
                            value: company,
                            items: companys.map((p) {
                              return DropdownMenuItem<String>(
                                value: p.companyID,
                                child: Text(p.companyName.toString()),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                company = value;
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
          if (showDivider) const Divider(height: 1, indent: 0, thickness: 0.5),
        ],
      ),
    );
  }
}
