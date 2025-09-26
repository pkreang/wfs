import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/features/client/models/client.dart';
import 'package:wfs/features/client/widgets/client_list_item.dart';
// import 'package:wfs/models/client_model.dart';
// import 'package:wfs/providers/client_provider.dart';
import 'package:wfs/features/appointment/views/appointment_create_page.dart';
// import '../providers/company_provider.dart'; // ไม่ได้ใช้สำหรับ ClientAddAppointmentScreen

// --- Providers เฉพาะสำหรับหน้านี้หรือนำมาจากไฟล์ client_screen.dart ที่แก้ไขไปแล้ว ---
// ถ้า ClientScreen และ ClientAddAppointmentScreen ใช้ Providers เดียวกัน
// ให้เก็บ providers เหล่านี้ไว้ในไฟล์ client_provider.dart
// และนำเข้าที่นี่ แทนการสร้างซ้ำ
// แต่เพื่อความสมบูรณ์ของโค้ดที่ให้มา ผมจะรวมไว้ในไฟล์นี้ชั่วคราว
// แต่แนะนำให้ย้ายไป client_provider.dart หากมีการใช้ซ้ำ

// การค้นหาจะส่งตรงไปยัง ClientListViewModel
// final clientSearchProvider = StateProvider<String>((ref) => '');

// เพิ่ม provider สำหรับกรอง Client
// final filteredClientsProvider = Provider<AsyncValue<List<Client>>>((ref) {
//   final allClientsAsync = ref.watch(clientProvider); // ใช้ clientProvider
//   final searchQuery = ref.watch(clientSearchProvider).toLowerCase();

//   return allClientsAsync.when(
//     data: (clients) {
//       if (searchQuery.isEmpty) {
//         return AsyncValue.data(clients);
//       }
//       final filteredList = clients.where((client) {
//         // ตรวจสอบ firstName, lastName, phone, address, product name
//         final fullName = '${client.firstName ?? ''} ${client.lastName ?? ''}'.toLowerCase();
//         final nameMatch = fullName.contains(searchQuery);

//         final phoneMatch = client.phone?.toLowerCase().contains(searchQuery) ?? false;

//         bool addressMatch = false;
//         if (client.clientAddresses != null) {
//           addressMatch = client.clientAddresses!.any((address) => address.address?.toLowerCase().contains(searchQuery) ?? false);
//         }

//         bool productMatch = false;
//         if (client.products != null) {
//           productMatch = client.products!.any((product) => product.productName?.toLowerCase().contains(searchQuery) ?? false);
//         }

//         // เพิ่มการค้นหาแบบเฉพาะเจาะจง
//         if (searchQuery.startsWith('status:')) {
//           final statusQuery = searchQuery.substring(7).trim();
//           final isActive = client.isActive ?? false;
//           if (statusQuery == 'active' && isActive) {
//             return true;
//           }
//           if (statusQuery == 'inactive' && !isActive) {
//             return true;
//           }
//           return false;
//         } else if (searchQuery.startsWith('name:')) {
//           final nameQuery = searchQuery.substring(5).trim();
//           return fullName.contains(nameQuery.toLowerCase());
//         } else if (searchQuery.startsWith('phone:')) {
//           final phoneQuery = searchQuery.substring(6).trim();
//           return client.phone?.toLowerCase().contains(phoneQuery.toLowerCase()) ?? false;
//         } else if (searchQuery.startsWith('address:')) {
//           final addressQuery = searchQuery.substring(8).trim();
//           return client.clientAddresses?.any((addr) => addr.address?.toLowerCase().contains(addressQuery.toLowerCase()) ?? false) ?? false;
//         } else if (searchQuery.startsWith('product:')) {
//           final productQuery = searchQuery.substring(8).trim();
//           return client.products?.any((prod) => prod.productName?.toLowerCase().contains(productQuery.toLowerCase()) ?? false) ?? false;
//         }

//         return nameMatch || phoneMatch || addressMatch || productMatch;
//       }).toList();
//       return AsyncValue.data(filteredList);
//     },
//     loading: () => const AsyncValue.loading(),
//     error: (error, stack) => AsyncValue.error(error, stack),
//   );
// });

// เพิ่ม provider สำหรับจัดกลุ่ม Client ตามตัวอักษรแรกของ firstName
// final clientSectionsProvider = Provider<Map<String, List<Client>>>((ref) {
//   final clientsAsync = ref.watch(filteredClientsProvider);

//   return clientsAsync.when(
//     data: (clients) {
//       final Map<String, List<Client>> sections = {};
//       for (var client in clients) {
//         if (client.firstName != null && client.firstName!.isNotEmpty) {
//           final firstChar = client.firstName![0].toUpperCase();
//           sections.putIfAbsent(firstChar, () => []).add(client);
//         }
//       }
//       return sections;
//     },
//     loading: () => {},
//     error: (error, stack) => {},
//   );
// });

// เพิ่มฟังก์ชันสำหรับ refresh client list
Future<void> refreshClients(WidgetRef ref) async {
  ref.invalidate(clientListProvider(const ['Active', 'Lead']));
}

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
    ref.read(clientListProvider(const ['Active', 'Lead']).notifier).setSearchQuery(_searchController.text);
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
    final state = ref.watch(clientListProvider(const ['Active', 'Lead']));

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
            const Divider(height: 1, thickness: 1, color: Color(0xFFEFEFEF)),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => refreshClients(ref), // ใช้ refreshClients
                child: state.clients.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                  data: (clients) {
                    if (clients.isEmpty && !_showSearchOptions) {
                      return const Center(child: AppText(label: 'No clients found.'));
                    }

                    return _buildClientList(state.sections); // เปลี่ยนเป็น _buildClientList
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

  Widget _buildClientList(Map<String, List<Client>> sections) {
    if (_showSearchOptions) {
      return Container(); // ไม่แสดงรายการ Client เมื่อ search options เปิดอยู่
    }

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

                return ClientListItem(
                  client: client,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAppointmentScreen(clientId: client.clientID ?? ''))),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
