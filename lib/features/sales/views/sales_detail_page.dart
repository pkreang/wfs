import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/features/sales/views/sales_edit_screen.dart';
import 'package:wfs/models/user_model.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_detail_section_card.dart';

class SalesDetailPage extends ConsumerStatefulWidget {
  final String userID;

  const SalesDetailPage({required this.userID, super.key});

  @override
  ConsumerState<SalesDetailPage> createState() => _SalesDetailPageState();
}

class _SalesDetailPageState extends ConsumerState<SalesDetailPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(salesDetailProvider(widget.userID));

    return state.when(
      loading: () => Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary)),
      error: (e, _) {
        return Center(
          child: AppText(label: "User Not Found", textColor: Colors.red),
        );
      },
      data: (salesDetail) {
        return Scaffold(
          backgroundColor: Color(0xFFEEEEEE),
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Color(0xFFEEEEEE),
            leadingWidth: 80,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Row(
                children: [
                  IconButton(
                    icon: Row(
                      children: [
                        const Icon(Icons.chevron_left),
                        AppText(label: 'Back', textColor: AppUtility.colorPrimary),
                      ],
                    ),
                    onPressed: null,
                    style: ButtonStyle(iconColor: WidgetStateProperty.all(AppUtility.colorPrimary)),
                  ),
                ],
              ),
            ),
            title: AppText(label: 'User Info', fontSize: 17, fontWeight: FontWeight.w600),
            actions: [
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute<bool>(builder: (BuildContext context) => SalesEditScreen(userID: widget.userID))),
                child: AppText(label: 'Edit', textColor: AppUtility.colorPrimary),
              ),
            ],
          ),
          body: buildContent(salesDetail),
        );
      },
    );
  }

  Widget buildContent(User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        spacing: 16,
        children: [
          Column(
            spacing: 24,
            children: [
              Column(spacing: 6, children: [AppText(label: user.fullname, fontSize: 26)]),
            ],
          ),
          AppDetailSectionCard(
            title: 'Email',
            descWidget: AppText(label: user.email ?? ''),
            fullWidth: true,
          ),
          AppDetailSectionCard(
            title: 'Phone',
            descWidget: AppText(label: user.phoneNumber ?? ''),
            fullWidth: true,
          ),
          AppDetailSectionCard(
            title: 'Role',
            descWidget: AppText(label: user.userRole?.userRoleName ?? ''),
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}
