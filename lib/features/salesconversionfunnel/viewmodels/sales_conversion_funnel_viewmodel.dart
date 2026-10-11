import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/features/lead/services/lead_service.dart';
import 'package:wfs/features/salepepeline/models/sales_pipeline_stage.dart';
import 'package:wfs/features/salesconversionfunnel/models/sales_conversion_funnel_item.dart';
import 'package:wfs/features/salesconversionfunnel/services/sales_conversion_funnel_service.dart';

@immutable
class SalesConversionFunnelState {
  final AsyncValue<List<SalesConversionFunnelItem>> items;

  const SalesConversionFunnelState({required this.items});

  SalesConversionFunnelState copyWith({AsyncValue<List<SalesConversionFunnelItem>>? items}) {
    return SalesConversionFunnelState(items: items ?? this.items);
  }
}

class SalesConversionFunnelViewModel extends StateNotifier<SalesConversionFunnelState> {
  SalesConversionFunnelViewModel(this.ref, {required this.leadService, required this.funnelService}) : super(const SalesConversionFunnelState(items: AsyncValue.loading())) {
    fetch();
  }

  final Ref ref;
  final LeadService leadService;
  final SalesConversionFunnelService funnelService;

  Future<void> fetch({List<SalesPipelineStage> stages = SalesPipelineStage.defaults}) async {
    state = state.copyWith(items: const AsyncValue.loading());
    final result = await AsyncValue.guard(() async {
      final leads = await leadService.fetchLeads(ref);
      return funnelService.buildFunnelItems(leads: leads, stages: stages);
    });

    state = state.copyWith(items: result);
  }
}
