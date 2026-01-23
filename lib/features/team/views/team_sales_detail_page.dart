import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/features/team/views/team_client_detail_page.dart';
import 'package:wfs/models/user_model.dart';
import 'package:wfs/widgets/image_picker_widget.dart';

class TeamSalesDetailPage extends ConsumerStatefulWidget {
  final String managerName;
  final String managerID;

  const TeamSalesDetailPage({super.key, required this.managerName, required this.managerID});
  @override
  ConsumerState<TeamSalesDetailPage> createState() => _TeamSalesDetailPageState();
}

class _TeamSalesDetailPageState extends ConsumerState<TeamSalesDetailPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teamSalesDetailProvider(widget.managerID));
    final userList = state;
    final countText = userList.when(
      data: (sales) => '${sales.length} sales',
      loading: () => 'Loading...',
      error: (err, stack) {
        print('error: $err');
        return 'Error';
      },
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: [
            AppText(label: widget.managerName, fontSize: 17, fontWeight: FontWeight.w600),
            AppText(label: countText, fontSize: 12, textColor: Colors.grey),
          ],
        ),
        shape: const Border(bottom: BorderSide(color: Color.fromRGBO(60, 60, 67, 0.36), width: 0.5)),
      ),
      body: SafeArea(
        child: userList.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
          data: (sales) {
            if (sales.isEmpty) {
              return const Center(child: AppText(label: 'No sales found.'));
            }

            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: sales.length,
              itemBuilder: (context, index) {
                final user = sales[index];

                return _buildUserList(user);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserList(User user) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TeamClientDetailPage(saleName: user.fullname, clientIDs: user.clientIDs ?? []),
        ),
      ),
      child: Container(
        color: const Color(0xFFFFFFFF),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ImagePickerWidget(userID: user.userID ?? '', width: 60, height: 60, allowCamera: false, isDisableUpload: true),
                  const SizedBox(width: 12),
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
