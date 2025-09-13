import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/models/client_model.dart';
import 'package:wfs/providers/client_provider.dart';
import 'package:wfs/screens/create_client_screen.dart';
// import '../providers/company_provider.dart'; // ไม่ได้ใช้แล้วสำหรับ ClientScreen

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

class ClientScreen extends ConsumerStatefulWidget {
  const ClientScreen({super.key});

  @override
  ConsumerState<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends ConsumerState<ClientScreen> {
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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
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

  Widget _buildHeader() {
    final allClientAsync = ref.watch(clientProvider); // ใช้ clientProvider

    final countText = allClientAsync.when(data: (clients) => '${clients.length} Entry', loading: () => 'Loading...', error: (err, stack) => 'Error');

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CreateClientScreen()));
            },
            child: const AppText(label: 'Create', fontSize: 17, fontWeight: FontWeight.normal, textColor: Colors.blue),
          ),
          Column(
            children: [
              const AppText(label: 'Client', fontSize: 17, fontWeight: FontWeight.bold),
              const SizedBox(height: 2),
              AppText(label: countText, fontSize: 12, textColor: Colors.grey),
            ],
          ),
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CreateClientScreen()));
            },
            child: const AppText(label: 'Add', fontSize: 17, fontWeight: FontWeight.normal, textColor: Colors.blue),
          ),
        ],
      ),
    );
  }

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
        Padding(
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
                        _buildStatusTag(client.isActive ?? false), // Handle null with default false
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
                    // Product
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
