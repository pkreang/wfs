import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/leaddashboard2/models/lead_dashboard2_metric.dart';
import 'package:wfs/features/leaddashboard2/services/lead_dashboard2_service.dart';

@immutable
class LeadDashboard2State {
  final AsyncValue<LeadDashboard2Data> data;

  const LeadDashboard2State({required this.data});

  LeadDashboard2State copyWith({AsyncValue<LeadDashboard2Data>? data}) {
    return LeadDashboard2State(data: data ?? this.data);
  }
}

class LeadDashboard2ViewModel extends StateNotifier<LeadDashboard2State> {
  LeadDashboard2ViewModel(this.ref, this.selectedRange) : super(const LeadDashboard2State(data: AsyncValue.loading())) {
    fetch();
  }

  final Ref ref;
  final ({DateTime? start, DateTime? end}) selectedRange;

  LeadDashboard2Service get _service => ref.read(leadDashboard2ServiceProvider);

  Future<void> fetch() async {
    final start = selectedRange.start;
    final end = selectedRange.end;
    final hasDateRange = start != null && end != null;

    state = state.copyWith(data: const AsyncValue.loading());
    final result = await AsyncValue.guard(() async {
      final response = await _service.fetchDashboard(ref, startDate: hasDateRange ? DateFormat('yyyy-MM-dd').format(start) : null, endDate: hasDateRange ? DateFormat('yyyy-MM-dd').format(end) : null);
      return LeadDashboard2Data.fromResponse(response);
    });
    if (mounted) {
      state = state.copyWith(data: result);
    }
  }
}
