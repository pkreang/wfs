import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/client/models/client.dart';
import 'package:wfs/features/client/widgets/client_level_capsule.dart';
import 'package:wfs/features/client/widgets/client_status_capsule.dart';
import 'package:wfs/features/tag/views/widgets/form_tag_with_data_tile.dart';
import 'package:wfs/providers/auth_provider.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/utility/appdialogs.dart';
import 'package:wfs/utility/validator.dart';
import 'package:wfs/widgets/app_sheet.dart';
import 'package:wfs/widgets/form_company_tile.dart';
import 'package:wfs/widgets/form_datetime_range_picker.dart';
import 'package:wfs/widgets/app_text.dart';
import 'package:wfs/widgets/app_text_form_field.dart';
import 'package:wfs/widgets/form_info_tile.dart';

class Item {
  final String id;
  final String name;

  Item({required this.id, required this.name});
}

class CreateClientScreen extends ConsumerStatefulWidget {
  const CreateClientScreen({super.key});

  @override
  ConsumerState<CreateClientScreen> createState() => _CreateClientScreenState();
}

class _CreateClientScreenState extends ConsumerState<CreateClientScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  DateTime _todayWithTime(String hhmmOrHhmmss) {
    final now = DateTime.now();

    final parts = hhmmOrHhmmss.split(':');
    final h = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0;
    final m = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
    final s = int.tryParse(parts.length > 2 ? parts[2] : '') ?? 0;

    return DateTime(now.year, now.month, now.day, h, m, s);
  }

  void handleSave() async {
    final authState = ref.watch(authProvider);
    final asyncClient = ref.read(clientCreateProvider).data;
    final client = asyncClient.value;

    if (client == null) {
      AppDialogs.error(context, message: "ไม่พบข้อมูล Client");
      return;
    }

    final companies = client.companies ?? [];
    final tags = client.tags ?? [];

    if (Validator.required(firstNameController.text) != null) {
      AppDialogs.error(context, message: "กรุณากรอก FirstName");
      return;
    }

    if (Validator.required(lastNameController.text) != null) {
      AppDialogs.error(context, message: "กรุณากรอก LastName");
      return;
    }

    if (Validator.required(client.clientStatusID) != null) {
      AppDialogs.error(context, message: "กรุณาเลือก Status");
      return;
    }

    if (Validator.required(client.clientLevelID) != null) {
      AppDialogs.error(context, message: "กรุณาเลือก Level");
      return;
    }

    if (!authState.isSales) {
      if (Validator.required(client.salesTerritoryID) != null) {
        AppDialogs.error(context, message: "กรุณาเลือก Territory");
        return;
      }
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

    if (!authState.isSales) {
      if (Validator.required(asyncClient.value?.saleID) != null) {
        AppDialogs.error(context, message: "กรุณาเลือก Sales");
        return;
      }
    }

    // if (tags.isEmpty) {
    //   AppDialogs.error(context, message: "กรุณาเลือก Tag");
    //   return;
    // }

    final result = await ref.read(clientCreateProvider.notifier).createClient();
    if (!result) {
      final errMsg = ref.read(clientCreateProvider).errorMessage;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clientCreateProvider);

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
              title: const AppText(label: 'Create Client', fontSize: 17, fontWeight: FontWeight.w600),
              actions: [
                TextButton(
                  onPressed: () => handleSave(),
                  style: TextButton.styleFrom(foregroundColor: AppUtility.colorPrimary),
                  child: AppText(label: 'Done', textColor: AppUtility.colorPrimary),
                ),
              ],
            ),
            body: state.data.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary)),
              error: (e, _) => Center(
                child: AppText(label: "Client Not Found", textColor: Colors.red),
              ),
              data: (client) => buildContent(client),
            ),
          ),
        ),

        if (state.isLoading) ...[const ModalBarrier(color: Color(0x66000000), dismissible: false), const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary))],
      ],
    );
  }

  Widget buildContent(Client client) {
    final authState = ref.read(authProvider);
    String companyID = '';
    String companyName = '';
    if ((client.companies ?? []).isNotEmpty) {
      final company = (client.companies ?? []).first.company;

      companyID = company?.companyID ?? '';
      companyName = company?.companyName ?? '';
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
                    value: AppTextFormField(controller: firstNameController, onChanged: (value) => ref.read(clientCreateProvider.notifier).setFirstName(value)),
                    isHideIcon: true,
                  ),
                  FormInfoTile(
                    label: 'Last Name',
                    value: AppTextFormField(controller: lastNameController, onChanged: (value) => ref.read(clientCreateProvider.notifier).setLastName(value)),
                    isHideIcon: true,
                  ),
                  FormInfoTile(
                    label: 'status',
                    value: ClientStatusCapsule(clientStatusName: client.clientStatus?.clientStatusName ?? ''),
                    onTap: () => AppSheet.openClientStatusSheet(
                      context: context,
                      clientStatusID: client.clientStatusID ?? '',
                      onSelected: (value) => ref.read(clientCreateProvider.notifier).setClientStatus(value),
                    ),
                  ),
                  FormInfoTile(
                    label: 'level',
                    value: ClientLevelCapsule(clientLevelName: client.clientLevel?.clientLevelName ?? ''),
                    onTap: () => AppSheet.openClientLevelSheet(
                      context: context,
                      clientLevelID: client.clientLevelID ?? '',
                      onSelected: (value) => ref.read(clientCreateProvider.notifier).setClientLevel(value),
                    ),
                  ),
                  if (authState.isSales)
                    FormInfoTile(
                      label: 'territory',
                      value: AppText(label: authState.territoryName ?? ''),
                      isShowBorderBottom: true,
                      isHideIcon: true,
                    ),
                  if (!authState.isSales)
                    FormInfoTile(
                      label: 'territory',
                      value: AppText(label: client.salesTerritoryName ?? ''),
                      onTap: () =>
                          AppSheet.openTerritorySheet(context: context, territoryID: client.salesTerritoryID ?? '', onSelected: (value) => ref.read(clientCreateProvider.notifier).setTerritory(value)),
                      isShowBorderBottom: true,
                    ),
                ],
              ),
              FormDatetimeRangePicker(
                start: _todayWithTime(client.availableTimeStart ?? ''),
                end: _todayWithTime(client.availableTimeEnd ?? ''),
                isTimeOnly: true,
                onStartTimeSelected: (value) => ref.read(clientCreateProvider.notifier).setAvailableTimeStart(value),
                onEndTimeSelected: (value) => ref.read(clientCreateProvider.notifier).setAvailableTimeEnd(value),
              ),

              Column(
                children: [
                  FormInfoTile(
                    label: 'mobile',
                    value: AppTextFormField(controller: mobileController, onChanged: (value) => ref.read(clientCreateProvider.notifier).setMobile(value)),
                    isHideIcon: true,
                  ),
                  FormInfoTile(
                    label: 'email',
                    value: AppTextFormField(controller: emailController, onChanged: (value) => ref.read(clientCreateProvider.notifier).setEmail(value)),
                    isHideIcon: true,
                  ),
                ],
              ),
              FormCompanyTile(
                companyID: companyID,
                companyName: companyName,
                onSelected: (value) => ref.read(clientCreateProvider.notifier).setCompany(value),
                onRemove: (companyID) => ref.read(clientCreateProvider.notifier).removeCompany(companyID),
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
                  onTap: () => AppSheet.openSaleSheet(context: context, salesID: client.saleID ?? '', onSelected: (value) => ref.read(clientCreateProvider.notifier).setSales(value)),
                  isShowBorderBottom: true,
                ),
              FormTagWithDataTile(selectedTags: client.tags ?? [], onSelected: (tags) => ref.read(clientCreateProvider.notifier).setTags(tags)),
            ],
          ),
        ],
      ),
    );
  }
}
