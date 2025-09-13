import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/screens/createcompany_screen.dart';
import '../models/company_model.dart';
import '../providers/company_provider.dart';


final companySearchProvider = StateProvider<String>((ref) => '');

final filteredCompaniesProvider = Provider<AsyncValue<List<Company>>>((ref) {
  final allCompaniesAsync = ref.watch(companiesProvider);
  final searchQuery = ref.watch(companySearchProvider).toLowerCase();

  return allCompaniesAsync.when(
    data: (companies) {
      if (searchQuery.isEmpty) {
        return AsyncValue.data(companies);
      }
      final filteredList = companies.where((company) {
        final companyNameMatch =
            company.companyName?.toLowerCase().contains(searchQuery) ?? false;

        bool addressMatch = false;
        if (searchQuery.startsWith('status:')) {
          final statusQuery = searchQuery.substring(7).trim();
          final isActive = company.isActive ?? false;
          if (statusQuery == 'active' && isActive) {
            return true;
          }
          if (statusQuery == 'inactive' && !isActive) {
            return true;
          }
          return false;
        } else if (searchQuery.startsWith('name:')) {
          final nameQuery = searchQuery.substring(5).trim();
          return company.companyName
                  ?.toLowerCase()
                  .contains(nameQuery.toLowerCase()) ??
              false;
        }

        if (company.CompanyAddresses != null) {
          addressMatch = company.CompanyAddresses!.any((address) =>
              address.address?.toLowerCase().contains(searchQuery) ?? false);
        }

        return companyNameMatch || addressMatch;
      }).toList();
      return AsyncValue.data(filteredList);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// เพิ่ม provider สำหรับจัดกลุ่มบริษัทตามตัวอักษรแรกของ companyName
final companySectionsProvider =
    Provider<Map<String, List<Company>>>((ref) {
  final companiesAsync = ref.watch(filteredCompaniesProvider);

  return companiesAsync.when(
    data: (companies) {
      final Map<String, List<Company>> sections = {};
      for (var company in companies) {
        if (company.companyName != null && company.companyName!.isNotEmpty) {
          final firstChar = company.companyName![0].toUpperCase();
          sections.putIfAbsent(firstChar, () => []).add(company);
        }
      }
      return sections;
    },
    loading: () => {},
    error: (error, stack) => {},
  );
});

// เพิ่มฟังก์ชันสำหรับ refresh company list
Future<void> refreshCompanies(WidgetRef ref) async {
  ref.invalidate(companiesProvider); // Invalidate the main company provider
}

class CompanyScreen extends ConsumerStatefulWidget {
  const CompanyScreen({super.key});

  @override
  ConsumerState<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends ConsumerState<CompanyScreen> {
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
    final companiesAsync = ref.watch(filteredCompaniesProvider);

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

  Widget _buildHeader() {
    final allCompaniesAsync = ref.watch(companiesProvider);

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
          TextButton(
            onPressed: () {},
            child: const Text(
              '',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.normal,
                fontSize: 17,
              ),
            ),
          ),
          Column(
            children: [
              const Text(
                'Company',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                countText,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateCompanyScreen()),
              );
            },
            child: const Text(
              'Add',
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
      'client:': 'name', // ไม่แน่ใจว่า 'client' จะใช้ field ไหนใน Company model
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
      return Container(); // ไม่แสดงรายการบริษัทเมื่อ search options เปิดอยู่
    }
    final sections = ref.watch(companySectionsProvider);
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

  Widget _buildCompanyItem(Company company) {
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
                        Text(
                          company.companyName.toString(),
                          style: const TextStyle(fontSize: 17),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusTag(company.isActive!),
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
                            company.CompanyAddresses?.isNotEmpty == true
                                ? company.CompanyAddresses!.first.address ??
                                    "ไม่มีที่อยู่"
                                : "ไม่มีที่อยู่",
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