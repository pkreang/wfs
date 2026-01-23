import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/features/sales/views/sales_create_screen.dart';
import 'package:wfs/features/sales/views/sales_detail_page.dart';
import 'package:wfs/models/user_model.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/image_picker_widget.dart';

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(salesListProvider);
    final usersList = state.users;
    final countText = usersList.when(data: (users) => '${users.length} User', loading: () => 'Loading...', error: (err, stack) => 'Error');

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leadingWidth: 98,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CreateSalesScreen(), fullscreenDialog: true)),
          child: Row(
            children: [
              IconButton(
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
            const AppText(label: 'User', fontSize: 17, fontWeight: FontWeight.w600),
            AppText(label: countText, fontSize: 12, textColor: Colors.grey),
          ],
        ),
        shape: const Border(bottom: BorderSide(color: Color.fromRGBO(60, 60, 67, 0.36), width: 0.5)),
      ),
      body: SafeArea(
        child: usersList.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
          data: (users) {
            if (users.isEmpty) {
              return const Center(child: AppText(label: 'No users found.'));
            }
            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return _buildSalesCard(user);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSalesCard(User user) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => SalesDetailPage(userID: user.userID ?? ''))),
      child: Container(
        color: const Color(0xFFFFFFFF),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ImagePickerWidget(userID: user.userID ?? ''),
                  const SizedBox(width: 12),
                  // Sales Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(label: user.fullname, fontSize: 17),
                        const SizedBox(height: 8),
                        Row(
                          children: [AppText(label: 'Role: ${user.userRole?.userRoleName ?? ''}', textColor: Colors.grey.shade600, fontSize: 14)],
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
    );
  }
}
