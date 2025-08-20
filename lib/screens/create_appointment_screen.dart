import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wfs/main.dart';
import 'package:wfs/models/appointmentaddresss_model.dart';
import 'package:wfs/models/appointments_model.dart';
import 'package:wfs/models/district_model.dart';
import 'package:wfs/models/province_model.dart';
import 'package:wfs/models/subdistrict_model.dart';
import 'package:wfs/providers/appointment_provider.dart';
import 'package:wfs/providers/auth_provider.dart';
import 'package:wfs/providers/client_provider.dart';
import 'package:wfs/providers/company_provider.dart';
import 'package:wfs/providers/district_provider.dart';
import 'package:wfs/providers/province_provider.dart';
import 'package:wfs/providers/purposetype_provider.dart';
import 'package:wfs/providers/saleterritorie_provider.dart';
import 'package:wfs/providers/subdistrict_provider.dart';
import 'package:wfs/services/appointment_service.dart';

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
  String? commany;
  DateTime? dateTimeFrom;
  DateTime? dateTimeTo;
  Province? selectedProvince;
  District? selectedDistrict;
  Subdistrict? selectedSubdistrict;
  final TextEditingController txtAddress = TextEditingController();
  final TextEditingController txtClientName = TextEditingController();

  Future<void> _pickDateTime(bool isFrom) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 9, minute: 0),
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

  @override
  Widget build(BuildContext context) {
    final selectedItem = ref.watch(selectedItemProvider);
    final clientGetByIdProviderState = ref.watch(
      clientGetByIdProvider(selectedItem.toString()),
    );
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
              final authState = ref.watch(authProvider);
              final accessToken = authState.accessToken;
              Appointments appointment = Appointments(
                appointmentTitle: "นัดพบลูกค้า", //
                appointmentTypeID: "7DEEC491-A5AE-4856-B981-7E91870179FF", //
                userID: authState.userID, //
                clientID: selectedItem,
                companyID: commany,
                appointmentDateTimeFrom: dateTimeFrom?.toIso8601String(),
                appointmentDateTimeTo: dateTimeTo?.toIso8601String(),
                appointmentStatusID: "4E2DC36E-53E6-4E9B-BAC2-1F2629BD745B", //
                purposeTypeID: selectedPurpose,
                noted: null, //
                assignedBy: null, //
                appointmentAddress: AppointmentAddresss(
                  address: txtAddress.text,
                  countryID: 1, //
                  provinceID: 1, //
                  districtID: 13, //
                  subDistrictID: 2583, //
                  latitude: null,
                  longitude: null,
                  isPrimary: true,
                  isActive: true,
                ),
                appointmentProducts: null,
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
                final newValue = ref.refresh(appointmentsProvider);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
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
          // Section: CLIENT INFO
          _buildSectionHeader('CLIENT INFO'),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                _buildInfoRow(
                  'Client Name',
                  clientGetByIdProviderState.when(
                    data: (client) => client.firstName!,
                    loading: () => "Loading",
                    error: (err, stack) => err.toString(),
                  ),
                ),
                _buildTappableRowPurpose('Purpose', 'Initial Visit'),
                _buildTappableRowTerritory(
                  'Territory',
                  'North East US',
                  showDivider: false,
                ),
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
                          'h;mm a',
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
                      Text("Starts", style: const TextStyle(fontSize: 16)),
                      const Spacer(),
                      _buildDateTimeChip(
                        DateFormat(
                          'MMM dd,yyyy',
                        ).format(dateTimeTo ?? DateTime.now()),
                      ),
                      _buildDateTimeChip(
                        DateFormat(
                          'h:mm a',
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
                _buildAddressSection(),
                _buildTappableRowProvince("Province", ""),
                _buildTappableRowDistrict("District", ""),
                _buildTappableRowSubDistrict("SubDistrict", ""),
              ],
            ),
          ),

          // Section: CONTACT
          _buildSectionHeader('CONTACT'),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                _buildContactRow(
                  'Mobile',
                  clientGetByIdProviderState.when(
                    data: (client) => client.phone!,
                    loading: () => "Loading",
                    error: (err, stack) => err.toString(),
                  ),
                ),
                _buildContactRow(
                  'Email',
                  clientGetByIdProviderState.when(
                    data: (client) => client.email!,
                    loading: () => "Loading",
                    error: (err, stack) => err.toString(),
                  ),
                ),
                _buildContactRowCompany(
                  'Company',
                  'Happy Happy',
                  showDivider: false,
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

  // TextField สำหรับกรอกที่อยู่
  Widget _buildAddressTextField(String hint) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0),
      child: SizedBox(
        height: 44,
        child: TextField(
          controller: txtAddress,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            border: InputBorder.none,
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
      padding: const EdgeInsets.only(left: 16.0),
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
                IconButton(
                  onPressed: () {
                    // TODO: Implement remove contact logic
                  },
                  icon: Icon(Icons.cancel, color: Colors.grey.shade400),
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
                      data: (company) {
                        return SizedBox(
                          width: 300,
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text('เลือก'),
                            value: commany,
                            items: company.map((p) {
                              return DropdownMenuItem<String>(
                                value: p.companyID,
                                child: Text(p.companyName.toString()),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                commany = value;
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
