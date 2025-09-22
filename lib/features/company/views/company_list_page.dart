import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/features/company/models/company.dart';
import 'package:wfs/features/company/views/company_detail_page.dart';
import 'package:wfs/features/company/views/company_create_page.dart';
import 'package:wfs/features/company/widgets/company_status_capsule.dart';
import 'package:wfs/utility/app_utility.dart';

final companySearchProvider = StateProvider<String>((ref) => '');

// เพิ่มฟังก์ชันสำหรับ refresh company list
Future<void> refreshCompanies(WidgetRef ref) async {
  ref.invalidate(companyListProvider);
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

  void handelDeleteCompany(String companyID) {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: const Text("Delete Company", textScaler: TextScaler.noScaling),
          content: Text("Are you sure you want to delete this company ?", textScaler: TextScaler.noScaling),
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
                ref.read(companyListProvider.notifier).onRemoveCompany(companyID);
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
    final state = ref.watch(companyListProvider);
    final countText = state.companies.when(data: (companies) => '${companies.length} Entry', loading: () => 'Loading...', error: (err, stack) => 'Error');

    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      appBar: AppBar(
        centerTitle: true,
        leadingWidth: 98,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CreateCompanyPage(), fullscreenDialog: true)),
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
            AppText(label: 'Company', fontSize: 17, fontWeight: FontWeight.w600),
            AppText(label: countText, fontSize: 12, textColor: Colors.grey),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => ref.read(companyListProvider.notifier).setEditMode(),
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
                onRefresh: () async => refreshCompanies(ref),
                child: state.companies.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                  data: (companies) {
                    if (companies.isEmpty && !_showSearchOptions) {
                      return const Center(child: AppText(label: 'No companies found.'));
                    }
                    return _buildCompanyList(companies, state.sections, state.isEdit);
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

  Widget _buildCompanyList(List<Company> companies, Map<String, List<Company>> sections, bool isEdit) {
    if (_showSearchOptions) return SizedBox.shrink();

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
            Container(
              // color: Color(0xFFF6F6F6),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: AppText(label: sectionKey, textColor: Color(0xFF6E6E73), fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEFEFEF)),
            ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sectionCompanies.length,
              itemBuilder: (context, itemIndex) {
                final company = sectionCompanies[itemIndex];
                return _buildCompanyItem(company, isEdit);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCompanyItem(Company company, bool isEdit) {
    return Container(
      color: Color(0xFFFFFFFF),
      child: Row(
        children: [
          if (isEdit)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: GestureDetector(
                onTap: () => handelDeleteCompany(company.companyID ?? ''),
                child: Icon(Icons.remove_circle, color: Color(0xFFFF382B), size: 24),
              ),
            ),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => CompanyDetailPage(companyID: company.companyID ?? ''))),
              child: Column(
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
                                spacing: 8,
                                children: [
                                  AppText(label: company.companyName.toString(), fontSize: 17),
                                  CompanyStatusCapsule(isActive: company.isActive ?? false),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Icon(Icons.location_on, color: Colors.grey.shade600, size: 20),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: AppText(
                                      label: company.addresses.isNotEmpty == true ? company.addresses.first.address ?? "ไม่มีที่อยู่" : "ไม่มีที่อยู่",
                                      textColor: Colors.grey.shade600,
                                      fontSize: 14,
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
                          child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade300),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 0.33, thickness: 0.33, indent: 1, color: Color(0xFFCBCBCB)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
