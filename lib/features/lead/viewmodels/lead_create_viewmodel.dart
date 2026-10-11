import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/core/http/api_client.dart';
import 'package:wfs/features/company/models/company.dart';
import 'package:wfs/features/lead/models/lead.dart';
import 'package:wfs/features/lead/models/lead_status.dart';
import 'package:wfs/features/lead/services/lead_service.dart';
import 'package:wfs/features/phase3/lead_workflow/services/lead_workflow_service.dart';
import 'package:wfs/models/user_model.dart';

@immutable
class LeadCreateState {
  final AsyncValue<Lead> data;
  final bool isDirty;
  final bool isLoading;
  final String? errorMessage;

  const LeadCreateState({required this.data, this.isDirty = false, this.isLoading = false, this.errorMessage});

  LeadCreateState copyWith({AsyncValue<Lead>? data, bool? isDirty, bool? isLoading, String? errorMessage, bool clearErrorMessage = false}) {
    return LeadCreateState(
      data: data ?? this.data,
      isDirty: isDirty ?? this.isDirty,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class LeadCreateViewModel extends StateNotifier<LeadCreateState> {
  LeadCreateViewModel(this.ref) : super(const LeadCreateState(data: AsyncValue.loading())) {
    _loadInitialLead();
  }

  final Ref ref;

  LeadService get _leadService => ref.read(leadServiceProvider);
  LeadWorkflowService get _workflowService => ref.read(leadWorkflowServiceProvider);

  Future<void> _loadInitialLead() async {
    try {
      final workflow = await ref.read(leadWorkflowProvider.future);
      final stages = workflow.stages.where((stage) => stage.isActive && !stage.isDeleted).toList()..sort((a, b) => a.orderbyNo.compareTo(b.orderbyNo));
      final firstStage = stages.firstOrNull;

      if (firstStage == null || firstStage.stageId.isEmpty) {
        throw StateError('Lead workflow first stage is not available.');
      }

      if (!mounted) return;

      state = state.copyWith(
        data: AsyncValue.data(Lead(pipelineStageID: firstStage.stageId, leadStatusID: firstStage.stageId, leadStatusName: firstStage.displayName, isQualified: false)),
      );
    } catch (e, st) {
      if (!mounted) return;

      state = state.copyWith(data: AsyncValue.error(e, st), errorMessage: e is ApiException ? e.message : e.toString());
    }
  }

  void setFirstName(String value) => _set((lead) => lead.copyWith(firstName: value));
  void setLastName(String value) => _set((lead) => lead.copyWith(lastName: value));
  void setPhone(String value) => _set((lead) => lead.copyWith(phone: value));
  void setEmail(String value) => _set((lead) => lead.copyWith(email: value));
  void setOwnerName(String value) => _set((lead) => lead.copyWith(ownerName: value));
  void setCloseProbability(String value) {
    _set((lead) => lead.copyWith(closeProbability: int.tryParse(value)));
  }

  void setBudget(String value) {
    _set((lead) => lead.copyWith(budget: double.tryParse(value)));
  }

  void setIsQualified(bool value) {
    _set((lead) => lead.copyWith(isQualified: value));
  }

  void setCompany(Company company) {
    _set((lead) => lead.copyWith(companyID: company.companyID ?? '', companyName: company.companyName ?? ''));
  }

  void removeCompany(String companyID) {
    _set((lead) => lead.copyWith(companyID: '', companyName: ''));
  }

  void setJobTitle(String jobTitle) {
    _set((lead) => lead.copyWith(jobTitle: jobTitle));
  }

  void setLineID(String lineID) {
    _set((lead) => lead.copyWith(lineID: lineID));
  }

  void setReportLine(String reportLine) {
    _set((lead) => lead.copyWith(reportLine: reportLine));
  }

  void setNoOfSubordinate(int? noOfSubordinate) {
    _set((lead) => lead.copyWith(noOfSubordinate: noOfSubordinate));
  }

  void setNote(String note) {
    _set((lead) => lead.copyWith(note: note));
  }

  void setSales(User sale) {
    _set((lead) => lead.copyWith(saleID: sale.userID, saleName: sale.fullname));
  }

  void setLeadStatus(LeadStatus status) {
    _set((lead) => lead.copyWith(leadStatusID: status.leadStatusID, leadStatusName: status.leadStatusName));
  }

  Future<bool> updateCloseWonStatus() async {
    try {
      final workflow = await _workflowService.getDefaultWorkflow(ref);
      final closeWonStage = workflow.stages.where((stage) => stage.stageKey.toLowerCase() == 'closed').firstOrNull;
      if (closeWonStage == null || closeWonStage.stageId.isEmpty) {
        state = state.copyWith(errorMessage: 'Close Won workflow stage is not available');
        return false;
      }

      state = state.copyWith(
        data: state.data.whenData((lead) => lead.copyWith(pipelineStageID: closeWonStage.stageId, leadStatusID: closeWonStage.stageId, leadStatusName: closeWonStage.stageKey)),
        clearErrorMessage: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e is ApiException ? e.message : 'Request failed');
      return false;
    }
  }

  void _set(Lead Function(Lead) update) {
    state = state.copyWith(data: state.data.whenData(update), isDirty: true, clearErrorMessage: true);
  }

  Future<bool> createLead() async {
    final lead = state.data.value;
    if (!state.isDirty || lead == null) return false;

    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final result = await _leadService.createLead(lead, ref);
      if (result) {
        ref.invalidate(leadListProvider);
        ref.invalidate(salesPipelineProvider);
        ref.invalidate(salesConversionFunnelProvider);
      }
      return result;
    } catch (e) {
      state = state.copyWith(errorMessage: e is ApiException ? e.message : 'Request failed');
    } finally {
      state = state.copyWith(isLoading: false);
    }

    return false;
  }
}
