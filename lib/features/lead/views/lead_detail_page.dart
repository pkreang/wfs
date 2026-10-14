import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/lead/models/lead.dart';
import 'package:wfs/features/lead/models/lead_history.dart';
import 'package:wfs/features/lead/models/lead_status.dart';
import 'package:wfs/features/lead/views/lead_edit_page.dart';
import 'package:wfs/features/lead/widgets/close_probability_dialog.dart';
import 'package:wfs/features/lead/widgets/deal_value_dialog.dart';
import 'package:wfs/features/lead/widgets/lead_status_capsule.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/utility/appdialogs.dart';
import 'package:wfs/utility/validator.dart';
import 'package:wfs/widgets/app_action_tile.dart';
import 'package:wfs/widgets/app_detail_section_card.dart';
import 'package:wfs/widgets/app_multiline_text.dart';
import 'package:wfs/widgets/app_sheet.dart';
import 'package:wfs/widgets/app_text.dart';
import 'package:wfs/widgets/app_text_form_field.dart';
import 'package:wfs/widgets/form_info_tile.dart';

class LeadDetailPage extends ConsumerStatefulWidget {
  final String leadID;
  final bool isDetailOnly;

  const LeadDetailPage({required this.leadID, this.isDetailOnly = false, super.key});

  @override
  ConsumerState<LeadDetailPage> createState() => _LeadDetailPageState();
}

class _LeadDetailPageState extends ConsumerState<LeadDetailPage> {
  bool _attachmentInitialized = false;
  String? _attachFilePath;
  String? _attachFileName;

  void _initializeAttachment(Lead lead) {
    if (_attachmentInitialized) return;
    _attachFilePath = lead.attachFilePath;
    _attachFileName = lead.attachFileName;
    _attachmentInitialized = true;
  }

  Future<void> _pickAttachFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    final file = result?.files.single;
    if (file == null) return;

    setState(() {
      _attachFilePath = file.path;
      _attachFileName = file.name;
    });
  }

  void _clearAttachFile() {
    setState(() {
      _attachFilePath = null;
      _attachFileName = null;
    });
  }

  // Future<void> _editDealValue(Lead lead, int index) async {
  //   final values = [...(lead.dealValues ?? const <DealValue>[])];
  //   if (index < 0 || index >= values.length) return;

  //   final item = await showDealValueDialog(context: context, initial: values[index]);
  //   if (item == null) return;

  //   values[index] = item;
  //   await _saveDealValues(values);
  // }

  Future<void> _removeDealValue(String dealValueID) async {
    await showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('Delete Deal Value', textScaler: TextScaler.noScaling),
          content: const Text('Are you sure you want to delete this deal value?', textScaler: TextScaler.noScaling),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: AppText(label: 'Cancel', textColor: AppUtility.textGray),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final result = await ref.read(leadDetailProvider(widget.leadID).notifier).removeDealValues(dealValueID);
                if (!mounted) return;

                if (!result) {
                  final errMsg = ref.read(leadDetailProvider(widget.leadID)).errorMessage;
                  AppDialogs.alert(context, title: 'ไม่สามารถดำเนินการได้', message: errMsg ?? 'Request failed');
                  return;
                }

                AppDialogs.success(context, title: "SUCCESS", message: "Data saved successfully", btnOkOnPress: () => {});
              },
              child: const AppText(label: 'Delete', textColor: AppUtility.colorRed),
            ),
          ],
        );
      },
    );
  }

  Future<void> onCloseDeal() async {
    await AppSheet.openCloseDealSheet(
      context: context,
      onSelected: (value) {
        if (value == 'Yes, Close Won') {
          onCloseWon();
        } else {
          onCloseLost();
        }
      },
    );
  }

  Future<void> onTransferToClient() async {
    await showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('Transfer To Client', textScaler: TextScaler.noScaling),
          content: const Text('Do you want to transfer this lead to client?', textScaler: TextScaler.noScaling),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: AppText(label: 'Cancel', textColor: AppUtility.textGray),
            ),
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: AppText(label: 'Confirm', textColor: AppUtility.colorPrimary),
            ),
          ],
        );
      },
    );
  }

  Future<void> onCloseWon() async {
    // final confirmed = await showCloseWonDialog(context: context);
    // if (!confirmed) return;

    await _closeDeal(closeResult: 'close_won');
  }

  Future<void> onCloseLost() async {
    final reason = await _showCloseLostReasonDialog();
    if (reason == null) return;

    await _closeDeal(closeResult: 'close_lost', closeLostReason: reason);
  }

  Future<String?> _showCloseLostReasonDialog() async {
    var reasonValue = '';
    String? validationError;

    return showCupertinoDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) => CupertinoAlertDialog(
            title: const Text('Close Lost Reason', textScaler: TextScaler.noScaling),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Material(
                  color: Colors.transparent,
                  child: AppTextFormField(
                    controller: null,
                    hintText: 'Reason',
                    isShowBorder: true,
                    maxLines: 2,
                    onChanged: (value) {
                      reasonValue = value;
                      if (validationError != null) {
                        setState(() => validationError = null);
                      }
                    },
                  ),
                ),
                if ((validationError ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Please enter close lost reason',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                    textScaler: TextScaler.noScaling,
                  ),
                ],
              ],
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: AppText(label: 'Cancel', textColor: AppUtility.textGray),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  final reason = reasonValue.trim();
                  if (reason.isEmpty) {
                    setState(() => validationError = 'required');
                    return;
                  }

                  Navigator.of(dialogContext).pop(reason);
                },
                child: AppText(label: 'Confirm', textColor: AppUtility.colorRed),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _closeDeal({required String closeResult, String? closeLostReason}) async {
    if (widget.leadID.isEmpty) return;

    int? closeProbability;
    if (closeResult == 'close_won') {
      closeProbability = await showCloseProbabilityDialog(context: context, initialCloseProbability: 100);
      if (!mounted) return;
      if (closeProbability == null) return;

      final result = await showDealValueDialog(context: context, ref: ref, leadID: widget.leadID, isRefresh: false);
      if (!result) {
        return;
      }
    }

    final stage = ref.read(leadDetailProvider(widget.leadID).notifier).filterWorkflowStage('054EFD6F-50FA-4E31-B3D8-7CEBD57F1CBA');
    if (stage == null) {
      return;
    }

    final result = await ref.read(leadDetailProvider(widget.leadID).notifier).updateLeadStatus(stage.stageId, stage.stageKey, closeLostReason, closeProbability: closeProbability);
    if (!mounted) return;

    if (!result) {
      final errMsg = ref.read(leadDetailProvider(widget.leadID)).errorMessage;
      if (errMsg != null && errMsg.isNotEmpty) {
        AppDialogs.alert(context, title: 'ไม่สามารถดำเนินการได้', message: errMsg);
      }
      return;
    }

    AppDialogs.success(context, title: "SUCCESS", message: "Data saved successfully", btnOkOnPress: () => {});
  }

  Future<void> onDelete() async {
    await showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('Delete Lead', textScaler: TextScaler.noScaling),
          content: const Text('Are you sure you want to delete this lead?', textScaler: TextScaler.noScaling),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: AppText(label: 'Cancel', textColor: AppUtility.textGray),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final result = await ref.read(leadDetailProvider(widget.leadID).notifier).deleteLead();
                if (!mounted) return;

                if (!result) {
                  final errMsg = ref.read(leadDetailProvider(widget.leadID)).errorMessage;
                  AppDialogs.alert(context, title: 'ไม่สามารถดำเนินการได้', message: errMsg ?? 'Request failed');
                  return;
                }

                AppDialogs.success(context, title: "SUCCESS", message: "Data saved successfully", btnOkOnPress: () => Navigator.pop(context));
              },
              child: const AppText(label: 'Delete', textColor: AppUtility.colorRed),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateStatus(Lead lead, LeadStatus status) async {
    if (widget.leadID.isEmpty) {
      return;
    }

    if (status.leadStatusID == "UnQualify") {
      // onCloseLost();
      var noteValue = '';
      String? validationError;

      await showCupertinoDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return StatefulBuilder(
            builder: (context, setState) => CupertinoAlertDialog(
              title: const Text('Unqualify Lead', textScaler: TextScaler.noScaling),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Please provide a note.', textScaler: TextScaler.noScaling),
                  const SizedBox(height: 12),
                  Material(
                    color: Colors.transparent,
                    child: AppTextFormField(
                      controller: null,
                      hintText: 'Note',
                      isShowBorder: true,
                      maxLines: 3,
                      inputFormatters: [LengthLimitingTextInputFormatter(1000)],
                      onChanged: (value) {
                        noteValue = value;
                        if (validationError != null) {
                          setState(() => validationError = null);
                        }
                      },
                    ),
                  ),
                  if ((validationError ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      validationError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                      textScaler: TextScaler.noScaling,
                    ),
                  ],
                ],
              ),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: AppText(label: 'Cancel', textColor: AppUtility.textGray),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  onPressed: () async {
                    final note = noteValue.trim();
                    final requiredError = Validator.required(note);
                    if (requiredError != null) {
                      setState(() => validationError = requiredError);
                      return;
                    }
                    if (note.length > 1000) {
                      setState(() => validationError = 'กรุณากรอกไม่เกิน 1,000 ตัวอักษร');
                      return;
                    }

                    await ref.read(salesPipelineProvider.notifier).unQualify(lead, note);
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: AppText(label: 'Confirm', textColor: AppUtility.colorRed),
                ),
              ],
            ),
          );
        },
      );
      return;
    }

    final nextStage = ref.read(leadDetailProvider(widget.leadID).notifier).filterWorkflowNextStage(lead.pipelineStageID ?? '');
    if (nextStage == null) {
      return;
    }

    // final isQualified = status.leadStatusName.toLowerCase() == 'qualify' || status.leadStatusName.toLowerCase() == 'qualified';
    // final nextQualifyRound = (lead.qualifyRound == null || lead.qualifyRound == 0) ? 1 : lead.qualifyRound! + 1;
    // final leadStatusName = nextQualifyRound == 1 ? 'qualified' : 'proposal';
    // final leadStatus = LeadStatus(leadStatusID: leadStatusName, leadStatusName: leadStatusName);

    final result = await ref.read(leadDetailProvider(widget.leadID).notifier).updateLeadStatus(nextStage.stageId, nextStage.stageKey, null);
    if (!mounted) return;

    if (!result) {
      final errMsg = ref.read(leadDetailProvider(widget.leadID)).errorMessage;
      if (errMsg != null && errMsg.isNotEmpty) {
        AppDialogs.alert(context, title: 'ไม่สามารถดำเนินการได้', message: errMsg);
      }
      return;
    }

    AppDialogs.success(context, title: "SUCCESS", message: "Data saved successfully", btnOkOnPress: () => {});
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leadDetailProvider(widget.leadID));

    final isCanEdit = !widget.isDetailOnly && state.lead.asData?.value.leadStatus?.toLowerCase() != 'closed';

    // (state.lead.asData?.value.closeLostReason?.trim().isEmpty ?? true) &&

    return Stack(
      children: [
        state.lead.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary)),
          error: (e, ee) => const Center(
            child: AppText(label: "Lead Not Found", textColor: Colors.red),
          ),
          data: (lead) {
            return Scaffold(
              backgroundColor: const Color(0xFFEEEEEE),
              appBar: AppBar(
                centerTitle: true,
                backgroundColor: const Color(0xFFEEEEEE),
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
                title: const AppText(label: 'Lead Info', fontSize: 17, fontWeight: FontWeight.w600),
                actions: [
                  if (isCanEdit)
                    TextButton(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => LeadEditPage(leadID: widget.leadID))),
                      child: AppText(label: 'Edit', textColor: AppUtility.colorPrimary),
                    ),
                ],
              ),
              body: buildContent(lead, state.histories),
            );
          },
        ),
        if (state.isLoading) ...[const ModalBarrier(color: Color(0x66000000), dismissible: false), const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary))],
      ],
    );
  }

  Widget buildContent(Lead lead, AsyncValue<List<LeadHistory>> histories) {
    _initializeAttachment(lead);

    final leadStatus = lead.leadStatus ?? '';
    final nextStage = ref.read(leadDetailProvider(widget.leadID).notifier).filterWorkflowNextStage(lead.pipelineStageID ?? '');

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        spacing: 16,
        children: [
          Column(
            spacing: 24,
            children: [
              Column(
                spacing: 6,
                children: [
                  AppText(label: '${lead.firstName} ${lead.lastName}', fontSize: 26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8,
                    children: [
                      if (leadStatus.toLowerCase() != "closed") LeadStatusCapsule(leadStatusName: leadStatus),
                      if (leadStatus.toLowerCase() == "closed" && lead.closeLostReason == null) LeadStatusCapsule(leadStatusName: "ClosedWon"),
                      if (leadStatus.toLowerCase() == "closed" && lead.closeLostReason != null) LeadStatusCapsule(leadStatusName: "ClosedLost"),
                      // if (leadStatus != "Prospecting") LeadStatusCapsule(leadStatusName: lead.isQualified == true ? 'Qualify' : 'UnQualify'),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  if (!widget.isDetailOnly && nextStage != null && nextStage.displayName != "Closed")
                    AppActionTile(
                      icon: Icons.fact_check_outlined,
                      title: nextStage.displayName,
                      onTap: () => AppSheet.openLeadQualificationSheet(context: context, leadStatusID: lead.leadStatusID ?? '', onSelected: (status) => updateStatus(lead, status)),
                    ),
                  if (nextStage?.displayName == "Closed") AppActionTile(icon: Icons.handshake_outlined, title: 'Close', onTap: onCloseDeal),
                  // if (leadStatus.toLowerCase() == "closed" && lead.closeLostReason == null)
                  //   AppActionTile(icon: Icons.swap_horiz, title: 'Transfer To Client', titleMaxLines: 1, onTap: onTransferToClient),
                ],
              ),
            ],
          ),
          AppDetailSectionCard(
            title: 'Close Probability',
            descWidget: AppText(label: lead.closeProbability == null ? '-' : '${lead.closeProbability}%'),
            fullWidth: true,
          ),
          AppDetailSectionCard(
            title: 'Purchasing Power',
            descWidget: AppText(label: lead.budget == null ? '-' : _formatBudget(lead.budget)),
            fullWidth: true,
          ),
          AppDetailSectionCard(
            title: 'Mobile',
            descWidget: AppText(label: lead.phone ?? ''),
            fullWidth: true,
          ),
          AppDetailSectionCard(
            title: 'Email',
            descWidget: AppText(label: lead.email ?? ''),
            fullWidth: true,
          ),
          AppDetailSectionCard(
            title: 'Company',
            descWidget: AppText(label: lead.companyName ?? ''),
            fullWidth: true,
          ),
          AppDetailSectionCard(
            title: 'Job Title',
            descWidget: AppText(label: lead.jobTitle ?? ''),
            fullWidth: true,
          ),
          AppDetailSectionCard(
            title: 'Line ID',
            descWidget: AppText(label: lead.lineID ?? ''),
            fullWidth: true,
          ),
          AppDetailSectionCard(
            title: 'Report Line',
            descWidget: AppText(label: lead.reportLine ?? ''),
            fullWidth: true,
          ),
          AppDetailSectionCard(
            title: 'No. of subordinate',
            descWidget: AppText(label: lead.noOfSubordinate == null ? '-' : '${lead.noOfSubordinate}'),
            fullWidth: true,
          ),
          AppDetailSectionCard(
            title: 'Sales',
            descWidget: AppText(label: lead.ownerName ?? ''),
            fullWidth: true,
          ),
          AppDetailSectionCard(
            title: 'Note',
            descWidget: AppMultilineText(label: lead.note ?? ''),
            fullWidth: true,
          ),
          if ((lead.isUnqualified ?? false) == true)
            AppDetailSectionCard(
              title: 'Unqualified Note',
              descWidget: AppMultilineText(label: lead.unqualifiedNote ?? ''),
              fullWidth: true,
            ),

          if (leadStatus.toLowerCase() == "closed" && lead.closeLostReason == null)
            AppDetailSectionCard(
              title: 'Deal Values',
              descWidget: Column(
                children: [
                  ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: (lead.dealValues ?? const []).length,
                    itemBuilder: (_, index) {
                      final dealValue = (lead.dealValues ?? const [])[index];

                      return Container(
                        alignment: Alignment.centerLeft,
                        height: 38,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(label: '${dealValue.detail} - ${dealValue.saleAmount}', textColor: AppUtility.colorPrimary),
                            GestureDetector(
                              onTap: () => _removeDealValue(dealValue.dealValueItemID ?? ''),
                              child: const Icon(Icons.remove_circle, color: Color(0xFFFF382B), size: 20),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (_, _) => const Divider(height: 0, thickness: 0.33, color: Color(0xFFC7C7CC)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => showDealValueDialog(context: context, ref: ref, leadID: widget.leadID),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 8,
                        children: [
                          Icon(Icons.add_circle, color: Color(0xFF31C859), size: 24),
                          AppText(label: 'Add Deal Value'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              fullWidth: true,
            ),
          // _DealValueSection(
          //   dealValues: lead.dealValues ?? const [],
          //   formatPrice: _formatDealValuePrice,
          //   onAdd: () => _addDealValue(lead),
          //   onEdit: (index) => _editDealValue(lead, index),
          //   onRemove: (index) => _removeDealValue(lead, index),
          // ),
          if (leadStatus.toLowerCase() == "closed" && lead.closeLostReason != null)
            AppDetailSectionCard(
              title: 'Close Lost Reason',
              descWidget: AppText(label: lead.closeLostReason ?? ''),
              fullWidth: true,
            ),
          if ((lead.qualifyRound ?? 0) > 1)
            AppDetailSectionCard(
              title: 'attach file',
              descWidget: _AttachFileInput(fileName: _attachFileName, onPick: _pickAttachFile, onClear: _clearAttachFile),
              fullWidth: true,
            ),

          // AppDetailSectionCard(
          //   title: 'tracking',
          //   descWidget: _LeadHistoryList(histories: histories),
          //   fullWidth: true,
          // ),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11)),
              alignment: Alignment.center,
              child: const AppText(label: 'Delete Lead', textColor: AppUtility.colorRed, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _formatBudget(double? budget) {
    if (budget == null) return '';

    final formatter = NumberFormat('#,##0.##');

    return formatter.format(budget);
  }

  String _formatDealValuePrice(num? price) {
    if (price == null) return '-';
    if (price == price.roundToDouble()) return price.toInt().toString();
    return price.toString();
  }
}

// class _DealValueSection extends StatelessWidget {
//   final List<DealValue> dealValues;
//   final String Function(num? price) formatPrice;
//   final VoidCallback onAdd;
//   final void Function(int index) onEdit;
//   final void Function(int index) onRemove;

//   const _DealValueSection({required this.dealValues, required this.formatPrice, required this.onAdd, required this.onEdit, required this.onRemove});

//   @override
//   Widget build(BuildContext context) {
//     final height = dealValues.isEmpty ? 44.0 : 44.0 * (dealValues.length + 1);

//     return FormInfoTile(
//       label: 'Deal Value',
//       value: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 6),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           spacing: 8,
//           children: [
//             if (dealValues.isNotEmpty)
//               ListView.separated(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: dealValues.length,
//                 separatorBuilder: (context, index) => const Divider(height: 1, thickness: AppUtility.borderWidth, color: AppUtility.colorGray),
//                 itemBuilder: (context, index) {
//                   final dealValue = dealValues[index];

//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     child: _DealValueChip(label: '${dealValue.detail} - ${formatPrice(dealValue.saleAmount)}', onTap: () => onEdit(index), onRemove: () => onRemove(index)),
//                   );
//                 },
//               ),
//             Padding(
//               padding: const EdgeInsets.only(top: 8),
//               child: GestureDetector(
//                 behavior: HitTestBehavior.opaque,
//                 onTap: onAdd,
//                 child: const Row(
//                   mainAxisSize: MainAxisSize.min,
//                   spacing: 8,
//                   children: [
//                     Icon(Icons.add_circle, color: Color(0xFF31C859), size: 24),
//                     AppText(label: 'add deal value'),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       height: height,
//       isShowBorderBottom: true,
//       isHideIcon: true,
//     );
//   }
// }

// class _DealValueChip extends StatelessWidget {
//   final String label;
//   final VoidCallback onTap;
//   final VoidCallback onRemove;

//   const _DealValueChip({required this.label, required this.onTap, required this.onRemove});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         GestureDetector(
//           behavior: HitTestBehavior.opaque,
//           onTap: onTap,
//           child: AppText(label: label),
//           // CapsuleWidget(label: label, capsuleStyle: CapsuleStyle(const Color(0xFF0689FF), const Color.fromRGBO(47, 128, 237, 0.2))),
//         ),
//         const SizedBox(width: 4),
//         GestureDetector(
//           onTap: onRemove,
//           child: const Icon(Icons.remove_circle, color: Color(0xFFFF382B), size: 20),
//         ),
//       ],
//     );
//   }
// }

class _AttachFileInput extends StatelessWidget {
  final String? fileName;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const _AttachFileInput({required this.fileName, required this.onPick, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final hasFile = (fileName ?? '').isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onPick,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(color: const Color(0xFFF7F7F7), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.attach_file, size: 18, color: AppUtility.textGray),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppText(label: hasFile ? fileName! : 'Attach File', textColor: hasFile ? Colors.black : AppUtility.textGray),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (hasFile) ...[const SizedBox(width: 8), IconButton(onPressed: onClear, icon: const Icon(Icons.close, size: 20), color: AppUtility.colorRed, tooltip: 'Remove file')],
      ],
    );
  }
}

// ignore: unused_element
class _LeadHistoryList extends StatelessWidget {
  final AsyncValue<List<LeadHistory>> histories;

  const _LeadHistoryList({required this.histories});

  @override
  Widget build(BuildContext context) {
    return histories.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary)),
      ),
      error: (e, _) => AppText(label: 'Unable to load tracking history', textColor: AppUtility.colorRed),
      data: (items) {
        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: AppText(label: 'No tracking history.'),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, _) => const Divider(height: 0, thickness: 0.33, color: Color(0xFFC7C7CC)),
          itemBuilder: (_, index) {
            final item = items[index];
            final dateText = item.updatedDateTime == null ? '' : DateFormat('dd/MM/yyyy HH:mm').format(item.updatedDateTime!.toLocal());

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppText(label: item.actionType ?? 'Status Update', fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      AppText(label: dateText, fontSize: 12, textColor: AppUtility.textLight),
                    ],
                  ),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      LeadStatusCapsule(leadStatusName: item.previousStatus ?? ''),
                      const Icon(Icons.arrow_forward, size: 14, color: Color(0xFF8E8E93)),
                      LeadStatusCapsule(leadStatusName: item.newStatus ?? ''),
                    ],
                  ),
                  if ((item.updatedBy ?? '').isNotEmpty) AppText(label: 'Updated by ${item.updatedBy}', fontSize: 13, textColor: AppUtility.textLight),
                  if ((item.remarks ?? '').isNotEmpty) AppText(label: item.remarks ?? '', fontSize: 13, textColor: AppUtility.textLight),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
