import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/features/client/models/client.dart';
import 'package:wfs/features/client/views/client_detail_page.dart';
import 'package:wfs/features/client/widgets/client_list_item.dart';
import 'package:wfs/features/client/views/client_create_page.dart';
import 'package:wfs/utility/app_utility.dart';
// import '../providers/company_provider.dart'; // ไม่ได้ใช้แล้วสำหรับ ClientScreen

// เพิ่ม provider สำหรับจัดการการค้นหา Client
final clientSearchProvider = StateProvider<String>((ref) => '');

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

// // เพิ่ม provider สำหรับจัดกลุ่ม Client ตามตัวอักษรแรกของ firstName
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
//       // Sort each section by clientLevelName in order A..F, then by name
//       const levelOrder = {'A': 0, 'B': 1, 'C': 2, 'D': 3, 'E': 4, 'F': 5};
//       int levelRank(String? level) => levelOrder[level?.toUpperCase()] ?? 999;
//       int nameCompare(Client a, Client b) => ('${a.firstName ?? ''} ${a.lastName ?? ''}').compareTo('${b.firstName ?? ''} ${b.lastName ?? ''}');

//       for (final entry in sections.entries) {
//         entry.value.sort((a, b) {
//           final ra = levelRank(a.clientLevel?.clientLevelName);
//           final rb = levelRank(b.clientLevel?.clientLevelName);
//           final cmp = ra.compareTo(rb);
//           if (cmp != 0) return cmp;
//           return nameCompare(a, b);
//         });
//       }
//       return sections;
//     },
//     loading: () => {},
//     error: (error, stack) => {},
//   );
// });

Future<void> refreshClients(WidgetRef ref, {String? statusName}) async {
  ref.invalidate(clientListProvider(statusName));
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

  void handelDeleteClient(String clientID) {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: const Text("Delete Client", textScaler: TextScaler.noScaling),
          content: Text("Are you sure you want to delete this client ?", textScaler: TextScaler.noScaling),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: AppText(label: 'Cancel', textColor: Color(0xFF007BFE)),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () async {
                Navigator.pop(dialogContext);
                ref.read(clientListProvider(null).notifier).onRemoveClient(clientID);
              },
              child: AppText(label: 'Delete', textColor: Color(0xFFFF382B)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clientListProvider(null));
    final countText = state.clients.when(data: (clients) => '${clients.length} Entry', loading: () => 'Loading...', error: (err, stack) => 'Error');

    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      appBar: AppBar(
        centerTitle: true,
        leadingWidth: 98,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CreateClientScreen(), fullscreenDialog: true)),
          child: Row(
            children: [
              state.isEdit
                  ? SizedBox.shrink()
                  : IconButton(
                      icon: Row(
                        children: [
                          const Icon(Icons.add),
                          AppText(label: 'Create', textColor: AppUtility.colorPrimary, fontSize: 17, fontWeight: FontWeight.w500),
                        ],
                      ),
                      onPressed: null,
                      style: ButtonStyle(iconColor: WidgetStateProperty.all(AppUtility.colorPrimary)),
                    ),
            ],
          ),
        ),
        title: Column(
          children: [
            AppText(label: 'Client', fontSize: 17, fontWeight: FontWeight.w600),
            AppText(label: countText, fontSize: 12, textColor: Colors.grey),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => ref.read(clientListProvider(null).notifier).setEditMode(),
            child: AppText(label: state.isEdit ? 'Done' : 'Edit', textColor: AppUtility.colorPrimary, fontSize: 17, fontWeight: FontWeight.w500),
          ),
        ],
        shape: const Border(bottom: BorderSide(color: Color.fromRGBO(60, 60, 67, 0.36), width: 0.5)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            if (_showSearchOptions) _buildSearchOptions(),
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
                    return _buildClientList(clients, state.sections, state.isEdit);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Color(0xFFFFFFFF),
      child: Padding(
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

  Widget _buildClientList(List<Client> clients, Map<String, List<Client>> sections, bool isEdit) {
    if (_showSearchOptions) return SizedBox.shrink();

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
                  isEdit: isEdit,
                  onDelete: () => handelDeleteClient(client.clientID ?? ''),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ClientDetailPage(clientID: client.clientID ?? '', isCanEdit: true))),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
