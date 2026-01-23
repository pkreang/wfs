import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/widgets/app_text_form_field.dart';
import 'package:wfs/models/user_model.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/utility/appdialogs.dart';
import 'package:wfs/utility/validator.dart';
import 'package:wfs/widgets/app_sheet.dart';
import 'package:wfs/widgets/form_info_tile.dart';

class CreateSalesScreen extends ConsumerStatefulWidget {
  const CreateSalesScreen({super.key});

  @override
  ConsumerState<CreateSalesScreen> createState() => _CreateSalesScreenState();
}

class _CreateSalesScreenState extends ConsumerState<CreateSalesScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (Validator.required(_firstNameController.text) != null) {
      AppDialogs.error(context, message: "กรุณากรอก FirstName");
      return;
    }

    if (Validator.required(_lastNameController.text) != null) {
      AppDialogs.error(context, message: "กรุณากรอก LastName");
      return;
    }

    if (Validator.required(_emailController.text) != null) {
      AppDialogs.error(context, message: "กรุณากรอก Email");
      return;
    }

    if (Validator.required(_phoneNumberController.text) != null) {
      AppDialogs.error(context, message: "กรุณากรอก PhoneNumber");
      return;
    }

    final result = await ref.read(salesCreateProvider.notifier).createSales();
    if (!result) {
      final errMsg = ref.read(salesCreateProvider).errorMessage;
      if (errMsg != null && errMsg.isNotEmpty) {
        AppDialogs.alert(context, title: 'ไม่สามารถดำเนินการได้', message: errMsg);
      }

      return;
    }

    AppDialogs.success(context, btnOkOnPress: () => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(salesCreateProvider);

    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            backgroundColor: const Color(0xFFEEEEEE),
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: const Color(0xFFEEEEEE),
              leadingWidth: 100,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: null,
                      style: ButtonStyle(iconColor: WidgetStateProperty.all(AppUtility.colorPrimary)),
                    ),
                    const AppText(label: 'Back', textColor: AppUtility.colorPrimary),
                  ],
                ),
              ),
              title: const AppText(label: 'Create User', fontSize: 17, fontWeight: FontWeight.w600),
              actions: [
                TextButton(
                  onPressed: () => _handleSave(),
                  style: TextButton.styleFrom(foregroundColor: AppUtility.colorPrimary),
                  child: const AppText(label: 'Done', textColor: AppUtility.colorPrimary),
                ),
              ],
            ),
            body: state.data.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary)),
              error: (e, _) => Center(
                child: AppText(label: "User Not Found", textColor: Colors.red),
              ),
              data: (user) => buildContent(user),
            ),
          ),
        ),

        if (state.isLoading) ...[const ModalBarrier(color: Color(0x66000000), dismissible: false), const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary))],
      ],
    );
  }

  Widget buildContent(User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 24,
        children: [
          Column(
            spacing: 16,
            children: [
              Column(
                children: [
                  FormInfoTile(
                    label: 'FirstName',
                    value: AppTextFormField(controller: _firstNameController, onChanged: (value) => ref.read(salesCreateProvider.notifier).setFirstName(value)),
                    isHideIcon: true,
                  ),
                  FormInfoTile(
                    label: 'LastName',
                    value: AppTextFormField(controller: _lastNameController, onChanged: (value) => ref.read(salesCreateProvider.notifier).setLastName(value)),
                    isHideIcon: true,
                  ),
                  FormInfoTile(
                    label: 'Email',
                    value: AppTextFormField(controller: _emailController, onChanged: (value) => ref.read(salesCreateProvider.notifier).setEmail(value)),
                    isHideIcon: true,
                  ),
                  FormInfoTile(
                    label: 'Phone',
                    value: AppTextFormField(controller: _phoneNumberController, isNumberOnly: true, onChanged: (value) => ref.read(salesCreateProvider.notifier).setPhoneNumber(value)),
                    isHideIcon: true,
                  ),
                  FormInfoTile(
                    label: 'Role',
                    value: AppText(label: user.userRole?.userRoleName ?? ''),
                    onTap: () => AppSheet.openRoleSheet(context: context, userRoleID: user.userRoleID ?? '', onSelected: (value) => ref.read(salesCreateProvider.notifier).setUserRole(value)),
                    isShowBorderBottom: user.userRole?.isSale ?? false ? false : true,
                  ),
                  if (user.userRole?.isSale ?? false)
                    FormInfoTile(
                      label: 'Supervisor',
                      value: AppText(label: user.managerName ?? ''),
                      onTap: () => AppSheet.openSupervisorSheet(context: context, userID: user.managerID ?? '', onSelected: (value) => ref.read(salesCreateProvider.notifier).setManager(value)),
                      isShowBorderBottom: true,
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
