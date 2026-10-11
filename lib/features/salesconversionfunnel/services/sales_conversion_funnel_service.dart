import 'package:wfs/features/lead/models/lead.dart';
import 'package:wfs/features/salepepeline/models/sales_pipeline_stage.dart';
import 'package:wfs/features/salesconversionfunnel/models/sales_conversion_funnel_item.dart';

class SalesConversionFunnelService {
  List<SalesConversionFunnelItem> buildFunnelItems({required List<Lead> leads, List<SalesPipelineStage> stages = SalesPipelineStage.defaults}) {
    final denominator = leads.isEmpty ? 1 : leads.length;
    final sortedStages = [...stages]..sort((a, b) => a.order.compareTo(b.order));
    final groupedLeads = _groupByStage(leads, sortedStages);

    return sortedStages.map((stage) {
      final count = groupedLeads[stage.id]?.length ?? 0;
      return SalesConversionFunnelItem(stage: stage, dealCount: count, conversionRate: count / denominator);
    }).toList();
  }

  Map<String, List<Lead>> _groupByStage(List<Lead> leads, List<SalesPipelineStage> stages) {
    final groups = {for (final stage in stages) stage.id: <Lead>[]};
    final stageIds = stages.map((stage) => stage.id).toSet();
    final defaultStageID = stages.first.id;

    for (final lead in leads) {
      final statusID = (lead.leadStatusID ?? '').trim();
      final statusName = (lead.leadStatus ?? '').trim();
      final stageID = stageIds.contains(statusID)
          ? statusID
          : stageIds.contains(statusName)
          ? statusName
          : defaultStageID;

      groups.putIfAbsent(stageID, () => <Lead>[]).add(lead);
    }

    return groups;
  }
}
