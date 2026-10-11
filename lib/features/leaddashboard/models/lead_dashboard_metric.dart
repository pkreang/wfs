import 'package:flutter/material.dart';
import 'package:wfs/features/lead/models/lead_status.dart';

class LeadDashboardMetric {
  final String title;
  final int value;
  final IconData icon;
  final Color color;

  const LeadDashboardMetric({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class LeadDashboardFunnelStage {
  final String title;
  final int value;
  final double percent;
  final Color color;

  const LeadDashboardFunnelStage({
    required this.title,
    required this.value,
    required this.percent,
    required this.color,
  });
}

class LeadDashboardRateMetric {
  final String title;
  final String description;
  final String formula;
  final double value;
  final IconData icon;
  final Color color;

  const LeadDashboardRateMetric({
    required this.title,
    required this.description,
    required this.formula,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class LeadDashboardFilterItem {
  final String title;
  final String value;
  final IconData icon;
  final bool hasDropdown;

  const LeadDashboardFilterItem({
    required this.title,
    required this.value,
    required this.icon,
    this.hasDropdown = true,
  });
}

class LeadDashboardData {
  final List<LeadDashboardFilterItem> filters;
  final List<LeadDashboardMetric> summaryMetrics;
  final List<LeadDashboardFunnelStage> funnelStages;
  final LeadDashboardFunnelStage closedWon;
  final LeadDashboardFunnelStage closedLost;
  final List<LeadDashboardRateMetric> rateMetrics;

  const LeadDashboardData({
    required this.filters,
    required this.summaryMetrics,
    required this.funnelStages,
    required this.closedWon,
    required this.closedLost,
    required this.rateMetrics,
  });

  factory LeadDashboardData.mock() {
    const total = 120;
    const qualified = 80;
    const proposal = 45;
    const closed = 45;
    const closedWon = 25;
    const closedLost = 20;

    const leadStatuses = LeadStatus.defaults;
    final qualifiedLabel = leadStatuses[1].leadStatusName;
    final proposalLabel = leadStatuses[2].leadStatusName;
    final closedLabel = leadStatuses[3].leadStatusName;

    const blue = Color(0xFF2F80ED);
    const purple = Color(0xFF9B51E0);
    const orange = Color(0xFFF2994A);
    const green = Color(0xFF27AE60);
    const red = Color(0xFFEB5757);

    double percentOfTotal(int value) => total == 0 ? 0 : value / total * 100;
    double percent(int value, int denominator) =>
        denominator == 0 ? 0 : value / denominator * 100;

    return LeadDashboardData(
      filters: const [
        LeadDashboardFilterItem(
          title: 'ช่วงวันที่',
          value: '1 พ.ค. 2567 - 21 พ.ค. 2567',
          icon: Icons.calendar_today_outlined,
        ),
        LeadDashboardFilterItem(
          title: 'ทีม',
          value: 'ทั้งหมด',
          icon: Icons.groups_outlined,
        ),
        LeadDashboardFilterItem(
          title: 'ผู้ดูแลการขาย',
          value: 'ทั้งหมด',
          icon: Icons.person_outline,
        ),
        LeadDashboardFilterItem(
          title: 'สถานะ',
          value: 'ทั้งหมด',
          icon: Icons.fact_check_outlined,
        ),
        LeadDashboardFilterItem(
          title: 'แหล่งที่มาของ Lead',
          value: 'ทั้งหมด',
          icon: Icons.campaign_outlined,
        ),
        LeadDashboardFilterItem(
          title: 'ตัวกรองเพิ่มเติม',
          value: 'ทั้งหมด',
          icon: Icons.tune_outlined,
        ),
      ],
      summaryMetrics: [
        const LeadDashboardMetric(
          title: 'Lead ทั้งหมด',
          value: total,
          icon: Icons.people_outline,
          color: blue,
        ),
        LeadDashboardMetric(
          title: qualifiedLabel,
          value: qualified,
          icon: Icons.verified_outlined,
          color: purple,
        ),
        LeadDashboardMetric(
          title: proposalLabel,
          value: proposal,
          icon: Icons.description_outlined,
          color: orange,
        ),
        const LeadDashboardMetric(
          title: 'Closed Won',
          value: closedWon,
          icon: Icons.check_circle_outline,
          color: green,
        ),
        const LeadDashboardMetric(
          title: 'Closed Lost',
          value: closedLost,
          icon: Icons.cancel_outlined,
          color: red,
        ),
      ],
      funnelStages: [
        LeadDashboardFunnelStage(
          title: 'Lead ทั้งหมด',
          value: total,
          percent: percentOfTotal(total),
          color: blue,
        ),
        LeadDashboardFunnelStage(
          title: qualifiedLabel,
          value: qualified,
          percent: percentOfTotal(qualified),
          color: purple,
        ),
        LeadDashboardFunnelStage(
          title: proposalLabel,
          value: proposal,
          percent: percentOfTotal(proposal),
          color: orange,
        ),
        LeadDashboardFunnelStage(
          title: closedLabel,
          value: closed,
          percent: percentOfTotal(closed),
          color: green,
        ),
      ],
      closedWon: LeadDashboardFunnelStage(
        title: 'Closed Won',
        value: closedWon,
        percent: percentOfTotal(closedWon),
        color: green,
      ),
      closedLost: LeadDashboardFunnelStage(
        title: 'Closed Lost',
        value: closedLost,
        percent: percentOfTotal(closedLost),
        color: red,
      ),
      rateMetrics: [
        LeadDashboardRateMetric(
          title: 'Qualification Rate',
          description: 'อัตรา Lead ที่ผ่านคุณสมบัติ',
          formula: '$qualifiedLabel / Lead ทั้งหมด',
          value: percent(qualified, total),
          icon: Icons.military_tech_outlined,
          color: purple,
        ),
        LeadDashboardRateMetric(
          title: 'Conversion Rate',
          description: 'อัตราการเปลี่ยนจาก $qualifiedLabel เป็น $closedLabel',
          formula: '$closedLabel / $qualifiedLabel',
          value: percent(closedWon, qualified),
          icon: Icons.trending_up_outlined,
          color: green,
        ),
        LeadDashboardRateMetric(
          title: 'Lead to Won Rate',
          description: 'อัตรา Lead ที่ปิดการขายได้สำเร็จ',
          formula: 'Closed Won / Lead ทั้งหมด',
          value: percent(closedWon, total),
          icon: Icons.emoji_events_outlined,
          color: blue,
        ),
      ],
    );
  }
}
