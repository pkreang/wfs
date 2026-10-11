import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/client/views/client_detail_page.dart';
import 'package:wfs/features/lead/models/lead.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/features/lead/views/lead_detail_page.dart';
import 'package:wfs/features/lead/widgets/close_probability_dialog.dart';
import 'package:wfs/features/lead/widgets/deal_value_dialog.dart';
import 'package:wfs/features/phase3/lead_workflow/models/lead_workflow_stage_model.dart';
import 'package:wfs/features/salepepeline/viewmodels/sales_pipeline_viewmodel.dart';
import 'package:wfs/features/salepepeline/widgets/sales_pipeline_column.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/utility/validator.dart';
import 'package:wfs/widgets/app_sheet.dart';
import 'package:wfs/widgets/app_text_form_field.dart';

class SalesPipelinePage extends ConsumerStatefulWidget {
  const SalesPipelinePage({super.key});

  @override
  ConsumerState<SalesPipelinePage> createState() => _SalesPipelinePageState();
}

class _SalesPipelinePageState extends ConsumerState<SalesPipelinePage> {
  final ScrollController _boardScrollController = ScrollController();
  Timer? _autoScrollTimer;
  double _autoScrollVelocity = 0;
  bool _isDraggingDeal = false;

  @override
  void dispose() {
    _handleDragEnd();
    _boardScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(salesPipelineProvider);
    ref.listen<SalesPipelineState>(salesPipelineProvider, (previous, next) {
      final message = next.errorMessage;
      if (message == null || message.isEmpty || previous?.errorMessage == message) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: AppText(label: message)));
    });
    final countText = state.leads.when(data: (leads) => '${leads.length} Entry', loading: () => 'Loading...', error: (_, _) => 'Error');

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: [
            const AppText(label: 'Sales Pipeline', fontSize: 17, fontWeight: FontWeight.w600),
            AppText(label: countText, fontSize: 12, textColor: Colors.grey),
          ],
        ),
        shape: const Border(bottom: BorderSide(color: Color.fromRGBO(60, 60, 67, 0.36), width: 0.5)),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(salesPipelineProvider.notifier).fetch(),
          child: Stack(
            children: [
              state.leads.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary)),
                error: (error, stack) => Center(child: Text('Error: $error')),
                data: (leads) {
                  if (leads.isEmpty) {
                    return const Center(child: AppText(label: 'No leads found.'));
                  }

                  return CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [SliverFillRemaining(child: _buildBoard(context, state))],
                  );
                },
              ),
              if (state.isUpdating)
                const Positioned(
                  top: 8,
                  right: 16,
                  child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppUtility.colorPrimary)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoard(BuildContext context, SalesPipelineState state) {
    return Listener(
      onPointerMove: (event) {
        if (!_isDraggingDeal) return;
        _handleDragPosition(event.position.dx);
      },
      child: ListView.separated(
        controller: _boardScrollController,
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
        scrollDirection: Axis.horizontal,
        itemCount: state.stages.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final stage = state.stages[index];
          final stageId = stage.stageId.trim().isNotEmpty ? stage.stageId.trim() : stage.id.toString();
          final leads = state.groupedLeads[stageId] ?? const [];

          return SalesPipelineColumn(
            stage: stage,
            leads: leads,
            isDragEnabled: index < state.stages.length - 1,
            onMoveLead: _moveLeadToStage,
            onDragStarted: _handleDragStarted,
            onDragUpdate: _handleDragUpdate,
            onDragEnd: _handleDragEnd,
            onTapLead: (lead) {
              if (stage.displayName.toLowerCase() == "closed") {
                if ((lead.closeLostReason ?? '').isNotEmpty) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => LeadDetailPage(leadID: lead.leadID ?? '')));
                  return;
                }

                Navigator.of(context).push(MaterialPageRoute(builder: (context) => ClientDetailPage(clientID: lead.leadID ?? '')));
                return;
              }

              Navigator.of(context).push(MaterialPageRoute(builder: (context) => LeadDetailPage(leadID: lead.leadID ?? '')));
            },
          );
        },
      ),
    );
  }

  void _handleDragStarted() {
    _isDraggingDeal = true;
  }

  Future<bool> _moveLeadToStage(Lead lead, LeadWorkflowStageModel stage) async {
    int? closeProbability;
    final targetStageId = stage.stageId.trim().isNotEmpty ? stage.stageId.trim() : stage.id.toString();
    final currentPipelineStageId = (lead.pipelineStageID ?? '').trim();
    final currentLeadStatusId = (lead.leadStatusID ?? '').trim();
    final currentStatusName = (lead.leadStatusName ?? lead.leadStatus ?? '').trim();
    if (currentPipelineStageId == targetStageId || currentLeadStatusId == targetStageId || currentStatusName == stage.displayName.trim()) {
      return false;
    }

    if (lead.leadStatus?.toLowerCase() == "closed") {
      return false;
    }
    if (_isMovingBackward(lead, stage)) {
      return false;
    }

    String? qualificationStatusId;
    await AppSheet.openLeadQualificationSheet(context: context, leadStatusID: lead.leadStatusID ?? '', onSelected: (status) => qualificationStatusId = status.leadStatusID);
    if (!mounted || qualificationStatusId == null) return false;

    var targetStage = stage;
    String? closeResult;

    if (qualificationStatusId == 'Qualify') {
      if (stage.systemStage != SystemLeadStage.closed) {
        return ref.read(salesPipelineProvider.notifier).moveLeadToStage(lead, stage);
      }

      await AppSheet.openCloseDealSheet(context: context, onSelected: (value) => closeResult = value);
      if (closeResult == 'Yes, Close Won') {
        closeProbability = await showCloseProbabilityDialog(context: context, initialCloseProbability: 100);
        if (closeProbability == null) return false;

        final result = await showDealValueDialog(context: context, ref: ref, leadID: lead.leadID ?? '', isRefresh: false);
        print('result Deal: ${result}');
        if (!result) return false;
      }

      if (!mounted) return false;
    } else if (qualificationStatusId == 'UnQualify') {
      var noteValue = '';
      var completed = false;
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

                    completed = await ref.read(salesPipelineProvider.notifier).unQualify(lead, note);
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

      return completed;
    } else {
      return false;
    }

    // if (closeResult == null) return false;

    String? closeLostReason;
    if (closeResult == 'No, Close Lost') {
      closeLostReason = await _showCloseLostReasonDialog();
      if (closeLostReason == null) return false;
    }

    if (!mounted) return false;
    return ref.read(salesPipelineProvider.notifier).moveLeadToStage(lead, targetStage, closeLostReason: closeLostReason, closeProbability: closeProbability);
  }

  bool _isMovingBackward(Lead lead, LeadWorkflowStageModel targetStage) {
    final stages = ref.read(salesPipelineProvider).stages;
    final currentStageId = (lead.pipelineStageID ?? lead.leadStatusID ?? '').trim();
    final currentStatusName = (lead.leadStatusName ?? lead.leadStatus ?? '').trim();
    LeadWorkflowStageModel? currentStage;

    for (final stage in stages) {
      final stageId = stage.stageId.trim().isNotEmpty ? stage.stageId.trim() : stage.id.toString();
      if (stageId == currentStageId || stage.displayName.trim() == currentStatusName) {
        currentStage = stage;
        break;
      }
    }

    return currentStage != null && targetStage.orderbyNo < currentStage.orderbyNo;
  }

  Future<String?> _showCloseLostReasonDialog() async {
    final reasonController = TextEditingController();
    String? validationError;

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Close Lost Reason'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextFormField(
                  controller: reasonController,
                  hintText: 'Reason',
                  isShowBorder: true,
                  maxLines: 2,
                  onChanged: (_) {
                    if (validationError != null) {
                      setState(() => validationError = null);
                    }
                  },
                ),
                if (validationError != null) ...[const SizedBox(height: 8), const Text('Please enter close lost reason', style: TextStyle(color: Colors.red, fontSize: 12))],
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  final reason = reasonController.text.trim();
                  if (reason.isEmpty) {
                    setState(() => validationError = 'required');
                    return;
                  }
                  Navigator.of(dialogContext).pop(reason);
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
        );
      },
    ).whenComplete(reasonController.dispose);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isDraggingDeal) return;
    _handleDragPosition(details.globalPosition.dx);
  }

  void _handleDragPosition(double dx) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    const edgeThreshold = 72.0;
    const maxVelocity = 18.0;

    if (dx < edgeThreshold) {
      final ratio = (edgeThreshold - dx).clamp(0, edgeThreshold) / edgeThreshold;
      _startAutoScroll(-maxVelocity * ratio);
      return;
    }

    if (dx > screenWidth - edgeThreshold) {
      final ratio = (dx - (screenWidth - edgeThreshold)).clamp(0, edgeThreshold) / edgeThreshold;
      _startAutoScroll(maxVelocity * ratio);
      return;
    }

    _stopAutoScrollTimer();
  }

  void _startAutoScroll(double velocity) {
    _autoScrollVelocity = velocity;
    if (_autoScrollTimer != null) return;

    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!_boardScrollController.hasClients) return;

      final position = _boardScrollController.position;
      final nextOffset = (_boardScrollController.offset + _autoScrollVelocity).clamp(position.minScrollExtent, position.maxScrollExtent);

      if (nextOffset == _boardScrollController.offset) return;
      _boardScrollController.jumpTo(nextOffset);
    });
  }

  void _stopAutoScrollTimer() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
    _autoScrollVelocity = 0;
  }

  void _handleDragEnd() {
    _isDraggingDeal = false;
    _stopAutoScrollTimer();
  }
}
