import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/widgets/app_cupertino_option.dart';
import 'package:wfs/features/company/models/company.dart';
import 'package:wfs/features/lead/models/lead.dart';
import 'package:wfs/features/lead/models/lead_status.dart';
import 'package:wfs/features/lead/widgets/close_won_dialog.dart';
import 'package:wfs/features/lead/widgets/deal_value_dialog.dart';
import 'package:wfs/features/lead/widgets/lead_status_capsule.dart';
import 'package:wfs/providers/auth_provider.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/utility/appdialogs.dart';
import 'package:wfs/utility/validator.dart';
import 'package:wfs/widgets/app_sheet.dart';
import 'package:wfs/widgets/app_text.dart';
import 'package:wfs/widgets/app_text_form_field.dart';
import 'package:wfs/widgets/form_company_with_data_tile.dart';
import 'package:wfs/widgets/form_info_tile.dart';

class LeadEditPage extends ConsumerStatefulWidget {
  final String leadID;

  const LeadEditPage({required this.leadID, super.key});

  @override
  ConsumerState<LeadEditPage> createState() => _LeadEditPageState();
}

class _LeadEditPageState extends ConsumerState<LeadEditPage> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final ownerNameController = TextEditingController();
  final closeProbabilityController = TextEditingController();
  final budgetController = TextEditingController();
  final jobTitleController = TextEditingController();
  final lineIDController = TextEditingController();
  final reportLineController = TextEditingController();
  final noOfSubordinateController = TextEditingController();
  final noteController = TextEditingController();
  bool _didBind = false;

  static const List<LeadStatus> _leadStatusOptions = [
    LeadStatus(leadStatusID: 'Prospecting', leadStatusName: 'Prospecting'),
    LeadStatus(leadStatusID: 'Qualification', leadStatusName: 'Qualification'),
    LeadStatus(leadStatusID: 'Proposal', leadStatusName: 'Proposal'),
    LeadStatus(leadStatusID: 'Closed', leadStatusName: 'Closed'),
  ];

  static final List<TextInputFormatter> _closeProbabilityInputFormatters = [
    FilteringTextInputFormatter.digitsOnly,
    TextInputFormatter.withFunction((oldValue, newValue) {
      final text = newValue.text;
      if (text.isEmpty) return newValue;
      if (text.length > 1 && text.startsWith('0')) return oldValue;

      final probability = int.tryParse(text);
      if (probability == null || probability > 100) return oldValue;

      return newValue;
    }),
  ];

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    ownerNameController.dispose();
    closeProbabilityController.dispose();
    budgetController.dispose();
    jobTitleController.dispose();
    lineIDController.dispose();
    reportLineController.dispose();
    noOfSubordinateController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void _bind(Lead lead) {
    if (_didBind) return;
    firstNameController.text = lead.firstName ?? '';
    lastNameController.text = lead.lastName ?? '';
    phoneController.text = lead.phone ?? '';
    emailController.text = lead.email ?? '';
    ownerNameController.text = lead.ownerName ?? '';
    closeProbabilityController.text = lead.closeProbability?.toString() ?? '';
    budgetController.text = _formatBudget(lead.budget);
    jobTitleController.text = lead.jobTitle ?? '';
    lineIDController.text = lead.lineID ?? '';
    reportLineController.text = lead.reportLine ?? '';
    noOfSubordinateController.text = lead.noOfSubordinate?.toString() ?? '';
    noteController.text = lead.note ?? '';
    _didBind = true;
  }

  Future<void> handleSave() async {
    final lead = ref.read(leadEditProvider(widget.leadID)).data.value;

    if (lead == null) {
      AppDialogs.error(context, message: 'ไม่พบข้อมูล Lead');
      return;
    }

    if (Validator.required(firstNameController.text) != null) {
      AppDialogs.error(context, message: 'กรุณากรอก First Name');
      return;
    }

    if (Validator.required(lastNameController.text) != null) {
      AppDialogs.error(context, message: 'กรุณากรอก First Name');
      return;
    }

    if (Validator.required(phoneController.text) != null) {
      AppDialogs.error(context, message: 'กรุณากรอก Phone');
      return;
    }

    if (Validator.required(emailController.text) != null) {
      AppDialogs.error(context, message: 'กรุณากรอก Email');
      return;
    }

    // if (Validator.required(lead.leadStatusID) != null) {
    //   AppDialogs.error(context, message: 'กรุณาเลือก Status');
    //   return;
    // }

    // if (Validator.required(closeProbabilityController.text) != null) {
    //   AppDialogs.error(context, message: 'กรุณากรอก Close Probability');
    //   return;
    // }

    final closeProbability = int.tryParse(closeProbabilityController.text);
    if (closeProbability == null || closeProbability < 0) {
      AppDialogs.error(context, message: 'กรุณากรอก Close Probability');
      return;
    }

    if (Validator.required(lead.companyID) != null) {
      AppDialogs.error(context, message: 'กรุณาเลือก Company');
      return;
    }

    if (Validator.required(jobTitleController.text) != null) {
      AppDialogs.error(context, message: 'กรุณากรอก Job Title');
      return;
    }

    if (Validator.required(lineIDController.text) != null) {
      AppDialogs.error(context, message: 'กรุณากรอก Line ID');
      return;
    }

    if (Validator.required(reportLineController.text) != null) {
      AppDialogs.error(context, message: 'กรุณากรอก Report Line');
      return;
    }

    if (Validator.required(noOfSubordinateController.text) != null) {
      AppDialogs.error(context, message: 'กรุณากรอก No. of subordinate');
      return;
    }

    if (Validator.required(ownerNameController.text) != null) {
      AppDialogs.error(context, message: 'กรุณากรอก Owner Name');
      return;
    }

    if (Validator.required(noteController.text) != null) {
      AppDialogs.error(context, message: 'กรุณากรอก Note');
      return;
    }

    final notifier = ref.read(leadEditProvider(widget.leadID).notifier);
    final isCloseWon = closeProbability == 100;
    if (isCloseWon) {
      final confirmed = await showCloseWonDialog(context: context);
      if (!confirmed) return;

      final statusUpdated = await notifier.updateCloseWonStatus();
      if (!mounted) return;
      if (!statusUpdated) {
        final errMsg = ref.read(leadEditProvider(widget.leadID)).errorMessage;
        AppDialogs.alert(context, title: 'ไม่สามารถดำเนินการได้', message: errMsg ?? 'Request failed');
        return;
      }

      final result = await showDealValueDialog(context: context, ref: ref, leadID: lead.leadID ?? '', isRefresh: false);
      if (!result) {
        return;
      }
    }

    final result = await notifier.updateLead();
    if (!mounted) return;
    if (!result) {
      final errMsg = ref.read(leadEditProvider(widget.leadID)).errorMessage;
      if (errMsg != null && errMsg.isNotEmpty) {
        AppDialogs.alert(context, title: 'ไม่สามารถดำเนินการได้', message: errMsg);
      }
      return;
    }

    AppDialogs.success(context, title: 'SUCCESS', message: 'Data saved successfully', btnOkOnPress: () => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leadEditProvider(widget.leadID));

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
                    AppText(label: 'Back', textColor: AppUtility.colorPrimary),
                  ],
                ),
              ),
              title: const AppText(label: 'Edit Lead', fontSize: 17, fontWeight: FontWeight.w600),
              actions: [
                TextButton(
                  onPressed: handleSave,
                  style: TextButton.styleFrom(foregroundColor: AppUtility.colorPrimary),
                  child: AppText(label: 'Done', textColor: AppUtility.colorPrimary),
                ),
              ],
            ),
            body: state.data.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary)),
              error: (_, _) => const Center(
                child: AppText(label: 'Lead Not Found', textColor: Colors.red),
              ),
              data: (lead) {
                _bind(lead);
                return buildContent(lead);
              },
            ),
          ),
        ),
        if (state.isLoading) ...[const ModalBarrier(color: Color(0x66000000), dismissible: false), const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary))],
      ],
    );
  }

  Widget buildContent(Lead lead) {
    final authState = ref.read(authProvider);
    final List<Company> companies = ref.watch(companysProvider).maybeWhen(data: (items) => items, orElse: () => const <Company>[]);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        spacing: 24,
        children: [
          Column(
            children: [
              FormInfoTile(
                label: 'First Name',
                value: AppTextFormField(controller: firstNameController, onChanged: (value) => ref.read(leadEditProvider(widget.leadID).notifier).setFirstName(value)),
                isHideIcon: true,
              ),
              FormInfoTile(
                label: 'Last Name',
                value: AppTextFormField(controller: lastNameController, onChanged: (value) => ref.read(leadEditProvider(widget.leadID).notifier).setLastName(value)),
                isHideIcon: true,
              ),
              FormInfoTile(
                label: 'Close Probability',
                value: AppTextFormField(
                  controller: closeProbabilityController,
                  isNumberOnly: true,
                  inputFormatters: _closeProbabilityInputFormatters,
                  textAlignVertical: TextAlignVertical.center,
                  contentPadding: EdgeInsets.zero,
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Center(
                      widthFactor: 1,
                      child: AppText(label: '%', textColor: AppUtility.textGray),
                    ),
                  ),
                  onChanged: (value) => ref.read(leadEditProvider(widget.leadID).notifier).setCloseProbability(value),
                ),
                isHideIcon: true,
              ),
              FormInfoTile(
                label: 'Purchasing Power',
                value: AppTextFormField(controller: budgetController, isNumberOnly: true, onChanged: (value) => ref.read(leadEditProvider(widget.leadID).notifier).setBudget(value)),
                isHideIcon: true,
              ),
              FormInfoTile(
                label: 'Mobile',
                value: AppTextFormField(controller: phoneController, isNumberOnly: true, onChanged: (value) => ref.read(leadEditProvider(widget.leadID).notifier).setPhoneNumber(value)),
                isHideIcon: true,
              ),
              FormInfoTile(
                label: 'Email',
                value: AppTextFormField(controller: emailController, onChanged: (value) => ref.read(leadEditProvider(widget.leadID).notifier).setEmail(value)),
                isHideIcon: true,
              ),

              // FormInfoTile(
              //   label: 'Status',
              //   value: LeadStatusCapsule(leadStatusName: lead.statusName),
              //   onTap: () => _openLeadStatusSheet(lead.leadStatusID ?? ''),
              // ),
              FormCompanyWithDataTile(
                companyID: lead.companyID ?? '',
                companyName: lead.companyName ?? '',
                companies: companies,
                onSelected: (value) => ref.read(leadEditProvider(widget.leadID).notifier).setCompany(value),
                onRemove: (companyID) => ref.read(leadEditProvider(widget.leadID).notifier).removeCompany(companyID),
                isShowBorderBottom: false,
              ),
              FormInfoTile(
                label: 'Job Title',
                value: AppTextFormField(controller: jobTitleController, onChanged: (value) => ref.read(leadEditProvider(widget.leadID).notifier).setJobTitle(value)),
                isHideIcon: true,
              ),
              FormInfoTile(
                label: 'Line ID',
                value: AppTextFormField(controller: lineIDController, onChanged: (value) => ref.read(leadEditProvider(widget.leadID).notifier).setLineID(value)),
                isHideIcon: true,
              ),
              FormInfoTile(
                label: 'Report Line',
                value: AppTextFormField(controller: reportLineController, onChanged: (value) => ref.read(leadEditProvider(widget.leadID).notifier).setReportLine(value)),
                isHideIcon: true,
              ),
              FormInfoTile(
                label: 'No. of subordinate',
                value: AppTextFormField(controller: noOfSubordinateController, onChanged: (value) => ref.read(leadEditProvider(widget.leadID).notifier).setNoOfSubordinate(int.tryParse(value))),
                isHideIcon: true,
              ),
              // FormInfoTile(
              //   label: 'Sales',
              //   value: AppText(label: lead.ownerName ?? ''),
              //   isHideIcon: true,
              // ),
              if (!authState.isSales)
                FormInfoTile(
                  label: 'Sales',
                  value: AppText(label: lead.saleName ?? ''),
                  onTap: () => AppSheet.openSaleSheet(context: context, salesID: lead.saleID ?? '', onSelected: (value) => ref.read(leadEditProvider(widget.leadID).notifier).setSales(value)),
                ),
              if (authState.isSales)
                FormInfoTile(
                  label: 'Sales',
                  value: AppText(label: '${authState.firstName ?? ''} ${authState.lastName ?? ''}'),
                  // isHideBorderTop: true,
                  // isShowBorderBottom: true,
                  isHideIcon: true,
                ),
              FormInfoTile(
                label: 'note',
                value: AppTextFormField(
                  controller: noteController,
                  onChanged: (value) => ref.read(leadEditProvider(widget.leadID).notifier).setNote(value),
                  minLines: 1,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                ),

                isShowBorderBottom: true,
                isHideIcon: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openLeadStatusSheet(String leadStatusID) async {
    final selected = await CupertinoOptionsPicker.showWithData<LeadStatus, String>(
      context: context,
      title: 'Status',
      items: _leadStatusOptions,
      label: (status) => status.leadStatusName,
      initialKey: (status) => status.leadStatusID,
      initialValue: leadStatusID,
    );

    if (selected == null) return;

    ref.read(leadEditProvider(widget.leadID).notifier).setLeadStatus(selected);
  }

  String _formatBudget(double? budget) {
    if (budget == null) return '';
    if (budget == budget.roundToDouble()) return budget.toInt().toString();
    return budget.toString();
  }
}
