import 'package:wfs/features/salepepeline/models/sales_pipeline_stage.dart';

class SalesConversionFunnelItem {
  final SalesPipelineStage stage;
  final int dealCount;
  final double conversionRate;

  const SalesConversionFunnelItem({
    required this.stage,
    required this.dealCount,
    required this.conversionRate,
  });
}
