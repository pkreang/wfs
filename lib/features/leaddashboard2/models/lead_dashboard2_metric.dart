import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LeadDashboard2Metric {
  final String title;
  final int value;
  final String? valueLabel;
  final IconData icon;
  final Color color;
  final String statusSearch;

  const LeadDashboard2Metric({required this.title, required this.value, this.valueLabel, required this.icon, required this.color, required this.statusSearch});

  String get displayValue => valueLabel ?? value.toString();
}

class LeadDashboard2FilterItem {
  final String title;
  final String value;
  final IconData icon;

  const LeadDashboard2FilterItem({required this.title, required this.value, required this.icon});
}

class LeadDashboard2FunnelStage {
  final String id;
  final String title;
  final int value;
  final double? percent;
  final Color color;

  const LeadDashboard2FunnelStage({this.id = '', required this.title, required this.value, this.percent, required this.color});
}

class LeadDashboard2PipelineStage {
  final String stageID;
  final String stageName;
  final int ordering;
  final bool isSystemLocked;
  final int leadCount;
  final double? percents;

  const LeadDashboard2PipelineStage({required this.stageID, required this.stageName, required this.ordering, required this.isSystemLocked, required this.leadCount, this.percents});

  factory LeadDashboard2PipelineStage.fromJson(Map<String, dynamic> json) {
    return LeadDashboard2PipelineStage(
      stageID: (json['StageID'] ?? json['stageID'] ?? json['stage_id'] ?? '').toString(),
      stageName: (json['StageName'] ?? json['stageName'] ?? json['stage_name'] ?? '').toString(),
      ordering: _parseInt(json['Ordering'] ?? json['ordering']),
      isSystemLocked: _parseBool(json['IsSystemLocked'] ?? json['isSystemLocked'] ?? json['is_system_locked']),
      leadCount: _parseInt(json['LeadCount'] ?? json['leadCount'] ?? json['lead_count']),
      percents: _parseOptionalDouble(json['StagePercent'] ?? json['stagePercent']),
    );
  }
}

class LeadDashboard2Response {
  final int leadCount;
  final int leadActive;
  final int unqualifiedCount;
  final int closedWonCount;
  final double closedWonPercent;
  final int closedLostCount;
  final double closedLostPercent;
  final double totalDealValue;
  final double conversionRate;
  final List<LeadDashboard2PipelineStage> pipelineStages;

  const LeadDashboard2Response({
    required this.leadCount,
    required this.leadActive,
    required this.unqualifiedCount,
    required this.closedWonCount,
    required this.closedWonPercent,
    required this.closedLostCount,
    required this.closedLostPercent,
    required this.totalDealValue,
    required this.conversionRate,
    required this.pipelineStages,
  });

  factory LeadDashboard2Response.fromJson(Map<String, dynamic> json) {
    final stages = json['PipelineStages'] ?? json['pipelineStages'] ?? json['pipeline_stages'];
    return LeadDashboard2Response(
      leadCount: _parseInt(json['LeadCount'] ?? json['leadCount'] ?? json['lead_count']),
      leadActive: _parseInt(json['LeadActive'] ?? json['leadActive'] ?? json['lead_active']),
      unqualifiedCount: _parseInt(json['UnqualifiedCount'] ?? json['unqualifiedCount'] ?? json['unqualified_count']),
      closedWonCount: _parseInt(json['ClosedWonCount'] ?? json['closedWonCount'] ?? json['closed_won_count']),
      closedWonPercent: _parseDouble(json['ClosedWonPercent'] ?? json['closedWonPercent'] ?? json['closed_won_percent']),
      closedLostCount: _parseInt(json['ClosedLostCount'] ?? json['closedLostCount'] ?? json['closed_lost_count']),
      closedLostPercent: _parseDouble(json['ClosedLostPercent'] ?? json['closedLostPercent'] ?? json['closed_lost_percent']),
      totalDealValue: _parseDouble(json['TotalDealValue'] ?? json['totalDealValue'] ?? json['total_deal_value']),
      conversionRate: _parseDouble(json['ConversionRate'] ?? json['conversionRate'] ?? json['conversion_rate']),
      pipelineStages: stages is List ? stages.whereType<Map>().map((item) => LeadDashboard2PipelineStage.fromJson(Map<String, dynamic>.from(item))).toList() : const [],
    );
  }
}

class LeadDashboard2RateMetric {
  final String title;
  final String description;
  final String formula;
  final double value;
  final IconData icon;
  final Color color;

  const LeadDashboard2RateMetric({required this.title, required this.description, required this.formula, required this.value, required this.icon, required this.color});
}

class LeadDashboard2Data {
  final List<LeadDashboard2FilterItem> filters;
  final List<LeadDashboard2Metric> summaryMetrics;
  final List<LeadDashboard2FunnelStage> funnelStages;
  final LeadDashboard2FunnelStage closedWon;
  final LeadDashboard2FunnelStage closedLost;
  final List<LeadDashboard2RateMetric> rateMetrics;

  const LeadDashboard2Data({required this.filters, required this.summaryMetrics, required this.funnelStages, required this.closedWon, required this.closedLost, required this.rateMetrics});

  factory LeadDashboard2Data.fromResponse(LeadDashboard2Response response) {
    const blue = Color(0xFF007AFF);
    const purple = Color(0xFF7B61FF);
    const orange = Color(0xFFFF9500);
    const green = Color(0xFF34C759);
    const red = Color(0xFFFF3B30);
    const stageColors = [blue, purple, orange, green, Color(0xFF5856D6), Color(0xFF5AC8FA)];

    final stages = [...response.pipelineStages]..sort((a, b) => a.ordering.compareTo(b.ordering));
    final total = stages.fold<int>(0, (sum, stage) => sum + stage.leadCount);
    final totalDealValue = NumberFormat('#,##0.##').format(response.totalDealValue);

    return LeadDashboard2Data(
      filters: const [LeadDashboard2FilterItem(title: 'ช่วงวันที่', value: 'ทั้งหมด', icon: Icons.calendar_today_outlined)],
      summaryMetrics: [
        LeadDashboard2Metric(title: 'Lead ทั้งหมด', value: total, icon: Icons.people_outline, color: blue, statusSearch: "Active"),
        LeadDashboard2Metric(title: 'Closed Won', value: response.closedWonCount, icon: Icons.check_circle_outline, color: green, statusSearch: "Win"),
        LeadDashboard2Metric(title: 'Closed Lost', value: response.closedLostCount, icon: Icons.cancel_outlined, color: red, statusSearch: "Lose"),
        LeadDashboard2Metric(title: 'UnQualify', value: response.unqualifiedCount, icon: Icons.person_off_outlined, color: const Color(0xFF6B7280), statusSearch: "UnQualify"),
        LeadDashboard2Metric(title: 'Total Deal Value', value: response.totalDealValue.round(), valueLabel: totalDealValue, icon: Icons.payments_outlined, color: orange, statusSearch: ""),
      ],
      funnelStages: [
        for (var i = 0; i < stages.length; i++)
          LeadDashboard2FunnelStage(id: stages[i].stageID, title: stages[i].stageName, value: stages[i].leadCount, percent: stages[i].percents, color: stageColors[i % stageColors.length]),
      ],
      closedWon: LeadDashboard2FunnelStage(title: 'Closed Won', value: response.closedWonCount, percent: response.closedWonPercent, color: green),
      closedLost: LeadDashboard2FunnelStage(title: 'Closed Lost', value: response.closedLostCount, percent: response.closedLostPercent, color: red),
      rateMetrics: [
        LeadDashboard2RateMetric(
          title: 'Conversion Rate',
          description: 'อัตราการเปลี่ยน Lead เป็น Closed Won',
          formula: 'Closed Won / Lead ทั้งหมด',
          value: response.conversionRate,
          icon: Icons.trending_up_outlined,
          color: green,
        ),
      ],
    );
  }
}

int _parseInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse((value ?? '').toString()) ?? 0;
}

double _parseDouble(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse((value ?? '').toString()) ?? 0;
}

double? _parseOptionalDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

bool _parseBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = (value ?? '').toString().toLowerCase().trim();
  return text == 'true' || text == '1';
}
