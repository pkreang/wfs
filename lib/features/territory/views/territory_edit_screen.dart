import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/features/territory/models/territory_model.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/utility/appdialogs.dart';
import 'package:wfs/utility/validator.dart';
import 'package:wfs/widgets/app_sheet.dart';
import 'package:wfs/widgets/app_text_form_field.dart';
import 'package:wfs/widgets/form_info_tile.dart';

class TerritoryEditScreen extends ConsumerStatefulWidget {
  final String territoryID;

  const TerritoryEditScreen({super.key, required this.territoryID});

  @override
  ConsumerState<TerritoryEditScreen> createState() => _TerritoryEditScreenState();
}

class _TerritoryEditScreenState extends ConsumerState<TerritoryEditScreen> {
  bool isInit = false;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (Validator.required(_nameController.text) != null) {
      AppDialogs.error(context, message: 'กรุณากรอก Territory Name');
      return;
    }

    final result = await ref.read(territoryEditProvider(widget.territoryID).notifier).updateTerritory();
    if (!result) {
      final errMsg = ref.read(territoryEditProvider(widget.territoryID)).errorMessage;
      if (errMsg != null && errMsg.isNotEmpty) {
        AppDialogs.alert(context, title: 'ไม่สามารถดำเนินการได้', message: errMsg);
      }
      return;
    }

    AppDialogs.success(context, btnOkOnPress: () => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(territoryEditProvider(widget.territoryID));

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
              title: const AppText(label: 'Edit Territory', fontSize: 17, fontWeight: FontWeight.w600),
              actions: [
                TextButton(
                  onPressed: _handleSave,
                  style: TextButton.styleFrom(foregroundColor: AppUtility.colorPrimary),
                  child: const AppText(label: 'Done', textColor: AppUtility.colorPrimary),
                ),
              ],
            ),
            body: state.data.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary)),
              error: (e, _) => Center(
                child: AppText(label: 'Territory Not Found', textColor: Colors.red),
              ),
              data: (territory) => buildContent(territory),
            ),
          ),
        ),
        if (state.isLoading) ...[const ModalBarrier(color: Color(0x66000000), dismissible: false), const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary))],
      ],
    );
  }

  Widget buildContent(TerritoryModel territory) {
    if (!isInit) {
      _nameController.text = territory.salesTerritoryName;
      _descriptionController.text = territory.salesTerritoryDescription;
      isInit = true;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        spacing: 24,
        children: [
          Column(
            spacing: 16,
            children: [
              Column(
                children: [
                  FormInfoTile(
                    label: 'Name',
                    value: AppTextFormField(controller: _nameController, onChanged: (value) => ref.read(territoryEditProvider(widget.territoryID).notifier).setName(value)),
                    isHideIcon: true,
                  ),
                  FormInfoTile(
                    label: 'Description',
                    value: AppTextFormField(controller: _descriptionController, maxLines: 4, onChanged: (value) => ref.read(territoryEditProvider(widget.territoryID).notifier).setDescription(value)),
                    isHideIcon: true,
                    height: 110,
                  ),
                  FormInfoTile(
                    label: 'Status',
                    value: AppText(label: territory.isActive ? 'Active' : 'Inactive'),
                    onTap: () => AppSheet.openStatusActiveSheet(
                      context: context,
                      value: territory.isActive,
                      title: 'Status',
                      onSelected: (value) => ref.read(territoryEditProvider(widget.territoryID).notifier).setIsActive(value),
                    ),
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
