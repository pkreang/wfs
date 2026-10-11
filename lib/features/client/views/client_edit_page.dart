import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/tag/views/widgets/form_tag_with_data_tile.dart';
import 'package:wfs/providers/auth_provider.dart';
import 'package:wfs/widgets/app_sheet.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';

import 'package:wfs/features/client/models/client.dart';
import 'package:wfs/features/client/widgets/client_level_capsule.dart';
import 'package:wfs/features/client/widgets/client_status_capsule.dart';
import 'package:wfs/features/company/models/company.dart';
import 'package:wfs/widgets/form_company_tile.dart';
import 'package:wfs/widgets/form_datetime_range_picker.dart';
import 'package:wfs/widgets/form_info_tile.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/utility/appdialogs.dart';
import 'package:wfs/utility/validator.dart';

import '../../../widgets/app_text_form_field.dart';

class ClientEditPage extends ConsumerStatefulWidget {
  final String clientID;
  const ClientEditPage({required this.clientID, super.key});

  @override
  ConsumerState<ClientEditPage> createState() => _ClientEditPageState();
}

class _ClientEditPageState extends ConsumerState<ClientEditPage> {
  bool isInit = false;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final closeProbabilityController = TextEditingController();
  final budgetController = TextEditingController();
  final jobTitleController = TextEditingController();
  final lineIDController = TextEditingController();
  final reportLineController = TextEditingController();
  final noOfSubordinateController = TextEditingController();

  static final List<TextInputFormatter> _closeProbabilityInputFormatters = [
    FilteringTextInputFormatter.digitsOnly,
    TextInputFormatter.withFunction((oldValue, newValue) {
      final text = newValue.text;
      if (text.isEmpty) return newValue;
      if (text.length > 1 && text.startsWith('0')) {
        return oldValue;
      }

      final probability = int.tryParse(text);
      if (probability == null || probability > 100) {
        return oldValue;
      }

      return newValue;
    }),
  ];

  DateTime _todayWithTime(String hhmmOrHhmmss) {
    final now = DateTime.now();

    final parts = hhmmOrHhmmss.split(':');
    final h = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0;
    final m = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
    final s = int.tryParse(parts.length > 2 ? parts[2] : '') ?? 0;

    return DateTime(now.year, now.month, now.day, h, m, s);
  }

  void handleSave() async {
    final asyncClient = ref.read(clientEditProvider(widget.clientID)).data;
    final client = asyncClient.value;

    if (client == null) {
      AppDialogs.error(context, message: "ไม่พบข้อมูล Client");
      return;
    }

    final companies = client.companies ?? [];

    if (Validator.required(firstNameController.text) != null) {
      AppDialogs.error(context, message: "กรุณากรอก FirstName");
      return;
    }

    if (Validator.required(lastNameController.text) != null) {
      AppDialogs.error(context, message: "กรุณากรอก LastName");
      return;
    }

    final closeProbability = int.tryParse(closeProbabilityController.text);
    if (closeProbability == null || closeProbability < 0) {
      AppDialogs.error(context, message: "กรุณากรอก Close Probability");
      return;
    }

    if (Validator.required(mobileController.text) != null) {
      AppDialogs.error(context, message: "กรุณากรอก Mobile");
      return;
    }

    if (Validator.required(emailController.text) != null) {
      AppDialogs.error(context, message: "กรุณากรอก Email");
      return;
    }

    if (companies.isEmpty) {
      AppDialogs.error(context, message: "กรุณาเลือก Company");
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

    if (Validator.required(asyncClient.value?.saleID) != null) {
      AppDialogs.error(context, message: "กรุณาเลือก Sales");
      return;
    }

    // if ((asyncClient.value?.tags ?? []).isEmpty) {
    //   AppDialogs.error(context, message: "กรุณาเลือก Tag");
    //   return;
    // }

    final result = await ref.read(clientEditProvider(widget.clientID).notifier).updateClient();
    if (!result) {
      final errMsg = ref.read(clientEditProvider(widget.clientID)).errorMessage;
      if (errMsg != null && errMsg.isNotEmpty) {
        AppDialogs.alert(context, title: 'ไม่สามารถดำเนินการได้', message: errMsg);
      }

      return;
    }

    AppDialogs.success(context, btnOkOnPress: () => Navigator.pop(context));
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    closeProbabilityController.dispose();
    budgetController.dispose();
    jobTitleController.dispose();
    lineIDController.dispose();
    reportLineController.dispose();
    noOfSubordinateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clientEditProvider(widget.clientID));
    final isDisabled = (state.isDirty && !state.isLoading);

    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            backgroundColor: Color(0xFFEEEEEE),
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Color(0xFFEEEEEE),
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
              title: AppText(label: 'Edit Client', fontSize: 17, fontWeight: FontWeight.w600),
              actions: [
                TextButton(
                  onPressed: isDisabled ? () => handleSave() : null,
                  style: TextButton.styleFrom(foregroundColor: isDisabled ? AppUtility.colorPrimary : Colors.grey),
                  child: AppText(label: 'Done', textColor: isDisabled ? AppUtility.colorPrimary : Colors.grey),
                ),
              ],
            ),
            body: state.data.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary)),
              error: (e, _) => Center(
                child: AppText(label: "Client Not Found", textColor: Colors.red),
              ),
              data: (client) => buildContent(client, state.companies),
            ),
          ),
        ),

        if (state.isLoading) ...[const ModalBarrier(color: Color(0x66000000), dismissible: false), const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary))],
      ],
    );
  }

  Widget buildContent(Client client, List<Company> companies) {
    final authState = ref.read(authProvider);
    if (!isInit) {
      firstNameController.text = client.firstName ?? '';
      lastNameController.text = client.lastName ?? '';
      mobileController.text = client.phone ?? '';
      emailController.text = client.email ?? '';
      closeProbabilityController.text = (client.closeProbability ?? 0).toString();
      budgetController.text = (client.budget ?? 0).toString();
      jobTitleController.text = client.jobTitle ?? '';
      lineIDController.text = client.lineID ?? '';
      reportLineController.text = client.reportLine ?? '';
      noOfSubordinateController.text = (client.noOfSubordinate ?? 0).toString();
      isInit = true;
    }

    String companyID = '';
    String companyName = '';
    if ((client.companies ?? []).isNotEmpty) {
      final company = (client.companies ?? []).first.company;
      if (company != null) {
        companyID = company.companyID ?? '';
        companyName = company.companyName ?? '';
      }
    }

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
                    label: 'First Name',
                    value: AppTextFormField(controller: firstNameController, onChanged: (value) => ref.read(clientEditProvider(widget.clientID).notifier).setFirstName(value)),
                    isHideIcon: true,
                  ),
                  FormInfoTile(
                    label: 'Last Name',
                    value: AppTextFormField(controller: lastNameController, onChanged: (value) => ref.read(clientEditProvider(widget.clientID).notifier).setLastName(value)),
                    isHideIcon: true,
                  ),
                  FormInfoTile(
                    label: 'Status',
                    value: ClientStatusCapsule(clientStatusName: client.clientStatus?.clientStatusName ?? ''),
                    onTap: () => AppSheet.openClientStatusSheet(
                      context: context,
                      clientStatusID: client.clientStatusID ?? '',
                      onSelected: (value) => ref.read(clientEditProvider(widget.clientID).notifier).setClientStatus(value),
                    ),
                  ),
                  FormInfoTile(
                    label: 'Level',
                    value: ClientLevelCapsule(clientLevelName: client.clientLevel?.clientLevelName ?? ''),
                    onTap: () => AppSheet.openClientLevelSheet(
                      context: context,
                      clientLevelID: client.clientLevelID ?? '',
                      onSelected: (value) => ref.read(clientEditProvider(widget.clientID).notifier).setClientLevel(value),
                    ),
                  ),
                  if (authState.isSales)
                    FormInfoTile(
                      label: 'Territory',
                      value: AppText(label: authState.territoryName ?? ''),
                      isShowBorderBottom: true,
                      isHideIcon: true,
                    ),
                  if (!authState.isSales)
                    FormInfoTile(
                      label: 'Territory',
                      value: AppText(label: client.salesTerritoryName ?? ''),
                      onTap: () => AppSheet.openTerritorySheet(
                        context: context,
                        territoryID: client.salesTerritoryID ?? '',
                        onSelected: (value) => ref.read(clientEditProvider(widget.clientID).notifier).setTerritory(value),
                      ),
                      isShowBorderBottom: true,
                    ),
                ],
              ),
              FormDatetimeRangePicker(
                start: _todayWithTime(client.availableTimeStart ?? ''),
                end: _todayWithTime(client.availableTimeEnd ?? ''),
                isTimeOnly: true,
                onStartTimeSelected: (value) => ref.read(clientEditProvider(widget.clientID).notifier).setAvailableTimeStart(value),
                onEndTimeSelected: (value) => ref.read(clientEditProvider(widget.clientID).notifier).setAvailableTimeEnd(value),
              ),
              Column(
                children: [
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
                      onChanged: (value) => ref.read(clientEditProvider(widget.clientID).notifier).setCloseProbability(value),
                    ),
                    isHideIcon: true,
                  ),
                  FormInfoTile(
                    label: 'Purchasing Power',
                    value: AppTextFormField(controller: budgetController, isNumberOnly: true, onChanged: (value) => ref.read(clientEditProvider(widget.clientID).notifier).setBudget(value)),
                    isHideIcon: true,
                  ),
                  FormInfoTile(
                    label: 'Mobile',
                    value: AppTextFormField(controller: mobileController, onChanged: (value) => ref.read(clientEditProvider(widget.clientID).notifier).setMobile(value)),
                    isHideIcon: true,
                  ),
                  FormInfoTile(
                    label: 'Email',
                    value: AppTextFormField(controller: emailController, onChanged: (value) => ref.read(clientEditProvider(widget.clientID).notifier).setEmail(value)),
                    isHideIcon: true,
                  ),
                ],
              ),
              Column(
                children: [
                  FormCompanyTile(
                    companyID: companyID,
                    companyName: companyName,
                    onSelected: (value) => ref.read(clientEditProvider(widget.clientID).notifier).setCompany(value),
                    onRemove: (companyID) => ref.read(clientEditProvider(widget.clientID).notifier).removeCompany(companyID),
                    isShowBorderBottom: false,
                  ),
                  FormInfoTile(
                    label: 'Job Title',
                    value: AppTextFormField(controller: jobTitleController, onChanged: (value) => ref.read(clientEditProvider(widget.clientID).notifier).setJobTitle(value)),
                    isHideIcon: true,
                  ),
                  FormInfoTile(
                    label: 'Line ID',
                    value: AppTextFormField(controller: lineIDController, onChanged: (value) => ref.read(clientEditProvider(widget.clientID).notifier).setLineID(value)),
                    isHideIcon: true,
                  ),
                  FormInfoTile(
                    label: 'Report Line',
                    value: AppTextFormField(controller: reportLineController, onChanged: (value) => ref.read(clientEditProvider(widget.clientID).notifier).setReportLine(value)),
                    isHideIcon: true,
                  ),
                  FormInfoTile(
                    label: 'No. of subordinate',
                    value: AppTextFormField(
                      controller: noOfSubordinateController,
                      isNumberOnly: true,
                      onChanged: (value) => ref.read(clientEditProvider(widget.clientID).notifier).setNoOfSubordinate(int.tryParse(value)),
                    ),
                    isHideIcon: true,
                  ),
                ],
              ),

              if (authState.isSales)
                FormInfoTile(
                  label: 'sales',
                  value: AppText(label: '${authState.firstName ?? ''} ${authState.lastName ?? ''}'),
                  isShowBorderBottom: true,
                  isHideIcon: true,
                ),
              if (!authState.isSales)
                FormInfoTile(
                  label: 'sales',
                  value: AppText(label: client.saleName ?? ''),
                  onTap: () => AppSheet.openSaleSheet(context: context, salesID: client.saleID ?? '', onSelected: (value) => ref.read(clientEditProvider(widget.clientID).notifier).setSales(value)),
                  isShowBorderBottom: true,
                ),
              FormTagWithDataTile(selectedTags: client.tags ?? [], onSelected: (tags) => ref.read(clientEditProvider(widget.clientID).notifier).setTags(tags)),
            ],
          ),
        ],
      ),
    );
  }
}
