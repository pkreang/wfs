import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/utility/appdialogs.dart';
import 'package:wfs/widgets/app_text_form_field.dart';
import 'package:wfs/providers/auth_provider.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';
import 'package:wfs/widgets/image_picker_widget.dart';
import 'package:wfs/widgets/auth_checker.dart';

class PasswordValidation {
  final bool lengthOk;
  final bool hasUpper;
  final bool hasLower;
  final bool hasDigit;
  final bool hasSpecial;
  final bool atLeast3Of4;
  final bool confirmMatch;
  final bool differentFromOld;

  PasswordValidation({
    required this.lengthOk,
    required this.hasUpper,
    required this.hasLower,
    required this.hasDigit,
    required this.hasSpecial,
    required this.atLeast3Of4,
    required this.confirmMatch,
    required this.differentFromOld,
  });

  bool get allPassed => lengthOk && hasUpper && hasLower && hasDigit && hasSpecial && atLeast3Of4 && confirmMatch && differentFromOld;
}

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  @override
  ConsumerState<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
  final _changePwdFormKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  PasswordValidation _validatePasswordComplexity(String oldPassword, String newPassword) {
    final hasUpper = RegExp(r'[A-Z]').hasMatch(newPassword);
    final hasLower = RegExp(r'[a-z]').hasMatch(newPassword);
    final hasDigit = RegExp(r'[0-9]').hasMatch(newPassword);
    final hasSpecial = RegExp(r'[^A-Za-z0-9]').hasMatch(newPassword);
    final classesMet = [hasUpper, hasLower, hasDigit, hasSpecial].where((e) => e).length;

    return PasswordValidation(
      lengthOk: newPassword.length >= 6,
      hasUpper: hasUpper,
      hasLower: hasLower,
      hasDigit: hasDigit,
      hasSpecial: hasSpecial,
      atLeast3Of4: classesMet >= 3,
      confirmMatch: newPassword.isNotEmpty && confirmNewPasswordController.text.isNotEmpty && newPassword == confirmNewPasswordController.text,
      differentFromOld: oldPassword.isNotEmpty && newPassword.isNotEmpty && oldPassword != newPassword,
    );
  }

  void handleClickChangePassword(BuildContext context) {
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    final bottomSheet = showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final v = _validatePasswordComplexity(currentPasswordController.text, newPasswordController.text);

            Color msgColor(bool ok) {
              final bool isInit = newPasswordController.text.isEmpty;
              return isInit ? const Color(0xFF595959) : (ok ? Colors.green : AppUtility.colorRed);
            }

            return Consumer(
              builder: (context, refLocal, _) {
                final state = refLocal.watch(authProvider);
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: 0.9,
                        widthFactor: 1,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 27),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 20),
                                IconButton(
                                  icon: AppText(label: 'Cancel', textColor: AppUtility.colorPrimary, fontSize: 17, fontWeight: FontWeight.w500),
                                  onPressed: () => Navigator.pop(context),
                                  style: ButtonStyle(iconColor: WidgetStateProperty.all(AppUtility.colorPrimary)),
                                ),
                                Expanded(
                                  child: SingleChildScrollView(
                                    padding: EdgeInsets.fromLTRB(24, 40, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      spacing: 24,
                                      children: [
                                        const AppText(label: 'Change Password', fontSize: 24, fontWeight: FontWeight.bold),
                                        Form(
                                          key: _changePwdFormKey,
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            spacing: 24,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                spacing: 6,
                                                children: [
                                                  const AppText(label: 'Current password', fontSize: 15),
                                                  AppTextFormField(
                                                    controller: currentPasswordController,
                                                    hintText: 'Password',
                                                    isShowBorder: true,
                                                    obscureText: obscureCurrent,
                                                    suffixIcon: IconButton(
                                                      icon: Icon(obscureCurrent ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                                                      onPressed: () => setSheetState(() => obscureCurrent = !obscureCurrent),
                                                    ),
                                                    isValidate: true,
                                                    requiredMessage: "Please enter your current password",
                                                    onChanged: (_) => setSheetState(() {}),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                spacing: 6,
                                                children: [
                                                  const AppText(label: 'New password', fontSize: 15),
                                                  AppTextFormField(
                                                    controller: newPasswordController,
                                                    hintText: 'Password',
                                                    isShowBorder: true,
                                                    obscureText: obscureNew,
                                                    suffixIcon: IconButton(
                                                      icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                                                      onPressed: () => setSheetState(() => obscureNew = !obscureNew),
                                                    ),
                                                    isValidate: true,
                                                    requiredMessage: "Please enter your new password",
                                                    onChanged: (_) => setSheetState(() {}),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                spacing: 6,
                                                children: [
                                                  const AppText(label: 'Confirm new password', fontSize: 15),
                                                  AppTextFormField(
                                                    controller: confirmNewPasswordController,
                                                    hintText: 'Password',
                                                    isShowBorder: true,
                                                    obscureText: obscureConfirm,
                                                    suffixIcon: IconButton(
                                                      icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                                                      onPressed: () => setSheetState(() => obscureConfirm = !obscureConfirm),
                                                    ),
                                                    requiredMessage: "Please enter your confirm new password",
                                                    isValidate: true,
                                                    onChanged: (_) => setSheetState(() {}),
                                                  ),
                                                ],
                                              ),

                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const AppText(label: 'Password must meet the following complexity requirements:', textColor: Color(0xFF595959), maxLines: null),
                                                  AppText(label: '• Be at least six characters in length.', textColor: msgColor(v.lengthOk), maxLines: null),
                                                  AppText(label: '• Contain characters from three of the following four', textColor: msgColor(v.atLeast3Of4), maxLines: null),
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 16.0),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      spacing: 6,
                                                      children: [
                                                        AppText(label: "• Nonalphanumeric characters (e.g., !,@,%,\$,...)", textColor: msgColor(v.hasSpecial), maxLines: null),
                                                        AppText(label: '• Base 10 digits (0-9)', textColor: msgColor(v.hasDigit), maxLines: null),
                                                        AppText(label: '• English uppercase characters (A-Z)', textColor: msgColor(v.hasUpper), maxLines: null),
                                                        AppText(label: '• English lowercase characters (a-z)', textColor: msgColor(v.hasLower), maxLines: null),
                                                      ],
                                                    ),
                                                  ),
                                                  AppText(label: '• New password not match with confirm new password.', textColor: msgColor(v.confirmMatch), maxLines: null),
                                                  AppText(label: '• New password is difference with old password.', textColor: msgColor(v.differentFromOld), maxLines: null),
                                                ],
                                              ),

                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: v.allPassed ? handleResetPassword : null,
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFFE42226),
                                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                                    elevation: 2,
                                                  ),
                                                  child: AppText(label: 'Reset Password', textColor: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (state.isLoading) ...[const ModalBarrier(color: Color(0x66000000), dismissible: false), const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary))],
                  ],
                );
              },
            );
          },
        );
      },
    );

    bottomSheet.whenComplete(() {
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmNewPasswordController.clear();
    });
  }

  void handleResetPassword() async {
    final valid = _changePwdFormKey.currentState?.validate() ?? false;
    if (!valid) return;

    final oldPwd = currentPasswordController.text.trim();
    final newPwd = newPasswordController.text.trim();
    final confirmPwd = confirmNewPasswordController.text.trim();

    final v = _validatePasswordComplexity(oldPwd, newPwd);

    if (newPwd != confirmPwd) {
      AppDialogs.alert(context, title: 'Unable to process', message: 'New password and confirmation do not match');
      return;
    }

    if (!(v.lengthOk && v.atLeast3Of4 && v.differentFromOld)) {
      AppDialogs.alert(context, title: 'Unable to process', message: 'Please satisfy all password requirements');
      return;
    }

    final result = await ref.read(authProvider.notifier).changePassword(ref, oldPwd, newPwd);
    if (!result) {
      final errMsg = ref.read(authProvider).errorMessage;
      if (errMsg != null && errMsg.isNotEmpty) {
        AppDialogs.alert(context, title: 'ไม่สามารถดำเนินการได้', message: errMsg);
      }

      return;
    }

    AppDialogs.success(
      context,
      btnOkOnPress: () async {
        await ref.read(authProvider.notifier).logout();
        ref.invalidate(userPinCheckProvider);
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const AuthChecker()), (route) => false);
        }
      },
    );
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.read(authProvider);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          titleSpacing: 16,
          title: AppText(label: 'Settings', fontSize: 28, fontWeight: FontWeight.w600),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            spacing: 36,
            children: [
              ImagePickerWidget(userID: authState.userID ?? '', width: 120, height: 120),
              Container(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                decoration: BoxDecoration(color: Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(14)),
                child: Row(
                  spacing: 13,
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: Center(child: AppText(label: authState.email ?? '', fontSize: 22)),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => handleClickChangePassword(context),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 11, horizontal: 16),
                  decoration: BoxDecoration(color: Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    spacing: 13,
                    children: [
                      Expanded(child: AppText(label: 'Change password', fontSize: 17)),
                      const Icon(Icons.chevron_right, size: 24, color: AppUtility.colorGray),
                    ],
                  ),
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () async {
                  await ref.read(authProvider.notifier).logout();
                  ref.invalidate(userPinCheckProvider);
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const AuthChecker()), (route) => false);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 83),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: AppText(label: 'Logout', textColor: AppUtility.colorRed, fontSize: 17),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
