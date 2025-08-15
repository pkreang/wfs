import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/main.dart';
import 'package:wfs/models/client_model.dart';
import 'package:wfs/providers/client_provider.dart';
import 'package:wfs/screens/create_appointment_screen.dart';
import '../providers/company_provider.dart';

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
    ref.read(companySearchProvider.notifier).state = _searchController.text;
    setState(() {
      _showSearchOptions =
          _searchFocusNode.hasFocus && _searchController.text.isNotEmpty;
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
    final companiesAsync = ref.watch(clientCompaniesProvider);

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
                onRefresh: () async => refreshCompanies(ref),
                child: companiesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                  data: (companies) {
                    if (companies.isEmpty && !_showSearchOptions) {
                      return const Center(child: Text('No companies found.'));
                    }
                    return _buildCompanyList();
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
  Widget _buildHeader() {
    // Watch provider ที่เก็บข้อมูลบริษัททั้งหมดจาก API เพื่อนำจำนวนมาแสดง
    // **หมายเหตุ**: โค้ดนี้สันนิษฐานว่า provider ของคุณชื่อ `companyProvider`
    // หากใช้ชื่ออื่น กรุณาแก้ไขตามความเหมาะสม
    final allCompaniesAsync = ref.watch(clientProvider);

    // สร้างข้อความจำนวนจากสถานะของ AsyncValue
    final countText = allCompaniesAsync.when(
      data: (companies) => '${companies.length} Entry',
      loading: () => 'Loading...',
      error: (err, stack) => 'Error',
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add, color: Colors.blue, size: 32),
          ),
          Column(
            children: [
              const Text(
                'Client',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                countText, // แสดงจำนวนที่ได้จาก provider
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              'Edit',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.normal,
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }
  // --- สิ้นสุดส่วนที่แก้ไข ---

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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildSearchOptions() {
    final options = {
      'name:': 'company',
      'status:': 'status',
      'client:': 'name',
    };

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
                _searchController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _searchController.text.length),
                );
                _showSearchOptions = false;
              });
            },
            title: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 17,
                  color: Colors.black,
                  fontFamily: 'System',
                ),
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
        separatorBuilder: (context, index) =>
            const Divider(height: 1, thickness: 1, indent: 16),
      ),
    );
  }

  Widget _buildCompanyList() {
    if (_showSearchOptions) {
      return Container();
    }
    final sections = ref.watch(clientSectionsProvider);
    final sectionKeys = sections.keys.toList()..sort();

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: sectionKeys.length,
      itemBuilder: (context, index) {
        final sectionKey = sectionKeys[index];
        final sectionCompanies = sections[sectionKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                sectionKey,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6E6E73),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEFEFEF)),
            ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sectionCompanies.length,
              itemBuilder: (context, itemIndex) {
                final company = sectionCompanies[itemIndex];
                return _buildCompanyItem(company);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCompanyItem(Client client) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            ref.read(selectedItemProvider.notifier).state = "Item 1";
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateAppointmentScreen(),
              ),
            );
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
                          Text(
                            client.firstName.toString() +
                                ' ' +
                                client.lastName.toString(),
                            style: const TextStyle(fontSize: 17),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusTag(client.isActive as bool),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Icon(
                              Icons.location_on,
                              color: Colors.grey.shade600,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              client.firstName.toString(),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(
          height: 1,
          thickness: 1,
          indent: 16,
          color: Color(0xFFEFEFEF),
        ),
      ],
    );
  }

  Widget _buildStatusTag(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFD7F5E4) : const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isActive ? const Color(0xFF2B8C43) : const Color(0xFF6A6A6A),
        ),
      ),
    );
  }
}
