import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/features/company/models/company.dart';
import 'package:wfs/main.dart'; // ตรวจสอบว่า selectedItemProvider อยู่ใน main.dart หรือไม่
import 'package:wfs/models/client_model.dart';
import 'package:wfs/providers/client_provider.dart';
import 'package:wfs/features/appointment/views/appointment_create_page.dart';
// import '../providers/company_provider.dart'; // ไม่ได้ใช้สำหรับ ClientAddAppointmentScreen

// --- Providers เฉพาะสำหรับหน้านี้หรือนำมาจากไฟล์ client_screen.dart ที่แก้ไขไปแล้ว ---
// ถ้า ClientScreen และ ClientAddAppointmentScreen ใช้ Providers เดียวกัน
// ให้เก็บ providers เหล่านี้ไว้ในไฟล์ client_provider.dart
// และนำเข้าที่นี่ แทนการสร้างซ้ำ
// แต่เพื่อความสมบูรณ์ของโค้ดที่ให้มา ผมจะรวมไว้ในไฟล์นี้ชั่วคราว
// แต่แนะนำให้ย้ายไป client_provider.dart หากมีการใช้ซ้ำ

// เพิ่ม provider สำหรับจัดการการค้นหา Client
final clientSearchProvider = StateProvider<String>((ref) => '');

// เพิ่ม provider สำหรับกรอง Client
final filteredClientsProvider = Provider<AsyncValue<List<Client>>>((ref) {
  final allClientsAsync = ref.watch(clientProvider); // ใช้ clientProvider
  final searchQuery = ref.watch(clientSearchProvider).toLowerCase();

  return allClientsAsync.when(
    data: (clients) {
      if (searchQuery.isEmpty) {
        return AsyncValue.data(clients);
      }
      final filteredList = clients.where((client) {
        // ตรวจสอบ firstName, lastName, phone, address, product name
        final fullName = '${client.firstName ?? ''} ${client.lastName ?? ''}'.toLowerCase();
        final nameMatch = fullName.contains(searchQuery);

        final phoneMatch = client.phone?.toLowerCase().contains(searchQuery) ?? false;

        bool addressMatch = false;
        if (client.clientAddresses != null) {
          addressMatch = client.clientAddresses!.any((address) => address.address?.toLowerCase().contains(searchQuery) ?? false);
        }

        bool productMatch = false;
        if (client.products != null) {
          productMatch = client.products!.any((product) => product.productName?.toLowerCase().contains(searchQuery) ?? false);
        }

        // เพิ่มการค้นหาแบบเฉพาะเจาะจง
        if (searchQuery.startsWith('status:')) {
          final statusQuery = searchQuery.substring(7).trim();
          final isActive = client.isActive ?? false;
          if (statusQuery == 'active' && isActive) {
            return true;
          }
          if (statusQuery == 'inactive' && !isActive) {
            return true;
          }
          return false;
        } else if (searchQuery.startsWith('name:')) {
          final nameQuery = searchQuery.substring(5).trim();
          return fullName.contains(nameQuery.toLowerCase());
        } else if (searchQuery.startsWith('phone:')) {
          final phoneQuery = searchQuery.substring(6).trim();
          return client.phone?.toLowerCase().contains(phoneQuery.toLowerCase()) ?? false;
        } else if (searchQuery.startsWith('address:')) {
          final addressQuery = searchQuery.substring(8).trim();
          return client.clientAddresses?.any((addr) => addr.address?.toLowerCase().contains(addressQuery.toLowerCase()) ?? false) ?? false;
        } else if (searchQuery.startsWith('product:')) {
          final productQuery = searchQuery.substring(8).trim();
          return client.products?.any((prod) => prod.productName?.toLowerCase().contains(productQuery.toLowerCase()) ?? false) ?? false;
        }

        return nameMatch || phoneMatch || addressMatch || productMatch;
      }).toList();
      return AsyncValue.data(filteredList);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// เพิ่ม provider สำหรับจัดกลุ่ม Client ตามตัวอักษรแรกของ firstName
final clientSectionsProvider = Provider<Map<String, List<Client>>>((ref) {
  final clientsAsync = ref.watch(filteredClientsProvider);

  return clientsAsync.when(
    data: (clients) {
      final Map<String, List<Client>> sections = {};
      for (var client in clients) {
        if (client.firstName != null && client.firstName!.isNotEmpty) {
          final firstChar = client.firstName![0].toUpperCase();
          sections.putIfAbsent(firstChar, () => []).add(client);
        }
      }
      return sections;
    },
    loading: () => {},
    error: (error, stack) => {},
  );
});

// เพิ่มฟังก์ชันสำหรับ refresh client list
Future<void> refreshClients(WidgetRef ref) async {
  ref.invalidate(clientProvider); // Invalidate the main client provider
}
// --- สิ้นสุด Providers ที่อาจต้องย้ายไป client_provider.dart ---

class ClientAddAppointmentScreen extends ConsumerStatefulWidget {
  const ClientAddAppointmentScreen({super.key});

  @override
  ConsumerState<ClientAddAppointmentScreen> createState() => _ClientAddAppointmentScreenState();
}

class _ClientAddAppointmentScreenState extends ConsumerState<ClientAddAppointmentScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSearchOptions = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchFocusNode.removeListener(_onFocusChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(clientSearchProvider.notifier).state = _searchController.text; // ใช้ clientSearchProvider
    setState(() {
      _showSearchOptions = _searchFocusNode.hasFocus && _searchController.text.isNotEmpty;
    });
  }

  void _onFocusChanged() {
    if (!_searchFocusNode.hasFocus) {
      setState(() {
        _showSearchOptions = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(filteredClientsProvider); // ใช้ filteredClientsProvider

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // เพิ่ม AppBar เพื่อให้มีปุ่มย้อนกลับและชื่อหน้าจอ
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const AppText(label: 'Select Client', fontSize: 17, fontWeight: FontWeight.bold),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.blue),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // _buildHeader() ถูกย้ายไปอยู่ใน AppBar แล้ว หรือสามารถปรับใช้ได้หากต้องการ
            _buildSearchBar(),
            if (_showSearchOptions) _buildSearchOptions(),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEFEFEF)),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => refreshClients(ref), // ใช้ refreshClients
                child: clientsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                  data: (clients) {
                    if (clients.isEmpty && !_showSearchOptions) {
                      return const Center(child: AppText(label: 'No clients found.'));
                    }
                    return _buildClientList(); // เปลี่ยนเป็น _buildClientList
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- ส่วนที่แก้ไข ---
  // _buildHeader() ถูกนำออกไปเพราะ AppBar ทำหน้าที่คล้ายกันแล้ว
  // หากยังต้องการแสดงจำนวน Client สามารถนำ countText ไปแสดงใน AppBar ได้

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
          filled: true,
          fillColor: const Color(0xFFF2F2F7),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildSearchOptions() {
    final options = {'name:': 'client name', 'status:': 'status (active/inactive)', 'phone:': 'phone number', 'address:': 'client address', 'product:': 'product name'};

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final key = options.keys.elementAt(index);
          return ListTile(
            onTap: () {
              setState(() {
                _searchController.text = '$key ';
                _searchController.selection = TextSelection.fromPosition(TextPosition(offset: _searchController.text.length));
                _showSearchOptions = false;
              });
            },
            title: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 17, color: Colors.black, fontFamily: 'System'),
                children: <TextSpan>[
                  TextSpan(
                    text: key,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' ${options[key]}'),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, indent: 16),
      ),
    );
  }

  Widget _buildClientList() {
    if (_showSearchOptions) {
      return Container(); // ไม่แสดงรายการ Client เมื่อ search options เปิดอยู่
    }
    final sections = ref.watch(clientSectionsProvider);
    final sectionKeys = sections.keys.toList()..sort();

    if (sectionKeys.isEmpty) {
      return const Center(child: AppText(label: 'No clients found.'));
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: sectionKeys.length,
      itemBuilder: (context, index) {
        final sectionKey = sectionKeys[index];
        final sectionClients = sections[sectionKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: AppText(label: sectionKey, textColor: Color(0xFF6E6E73), fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEFEFEF)),
            ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sectionClients.length,
              itemBuilder: (context, itemIndex) {
                final client = sectionClients[itemIndex];
                return _buildClientItem(client);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildClientItem(Client client) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            // เมื่อเลือก client ให้ส่ง clientID ไปยัง selectedItemProvider
            ref.read(selectedItemProvider.notifier).state = client.clientID;

            // List<Company> companies = [];
            // if ((client.clientAddresses ?? []).isNotEmpty) {
            //   for (var company in client.clientAddresses!) {
            //     companies.add(Company.fromJson(company.toJson()));
            //   }
            // }

            // ref.read(companiesOfClentProvider.notifier).state = companies;
            Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAppointmentScreen(clientId: client.clientID ?? '')));
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppText(label: '${client.firstName ?? ''} ${client.lastName ?? ''}', fontSize: 17),
                          const SizedBox(width: 8),
                          _buildStatusTag(client.isActive ?? false), // จัดการ null
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Phone
                      if (client.phone != null && client.phone!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Icon(Icons.phone, color: Colors.grey.shade600, size: 20),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: AppText(label: client.phone.toString(), fontSize: 14, textColor: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      // Address
                      if (client.clientAddresses?.isNotEmpty == true && client.clientAddresses!.first.address != null && client.clientAddresses!.first.address!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Icon(Icons.location_on, color: Colors.grey.shade600, size: 20),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: AppText(label: client.clientAddresses!.first.address!, fontSize: 14, textColor: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      // Product (ถ้ามี)
                      if (client.products?.isNotEmpty == true && client.products!.first.productName != null && client.products!.first.productName!.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Icon(Icons.production_quantity_limits, color: Colors.grey.shade600, size: 20),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AppText(label: client.products!.first.productName!, fontSize: 14, textColor: Colors.grey.shade600),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade300),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1, indent: 16, color: Color(0xFFEFEFEF)),
      ],
    );
  }

  Widget _buildStatusTag(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: isActive ? const Color(0xFFD7F5E4) : const Color(0xFFF1F1F1), borderRadius: BorderRadius.circular(12)),
      child: AppText(label: isActive ? 'Active' : 'Inactive', fontSize: 12, fontWeight: FontWeight.w500, textColor: isActive ? const Color(0xFF2B8C43) : const Color(0xFF6A6A6A)),
    );
  }
}
