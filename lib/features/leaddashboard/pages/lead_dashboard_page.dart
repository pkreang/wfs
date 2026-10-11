import 'package:flutter/material.dart';
import 'package:wfs/features/leaddashboard/models/lead_dashboard_metric.dart';
import 'package:wfs/features/leaddashboard/widgets/lead_conversion_rate_card.dart';
import 'package:wfs/features/leaddashboard/widgets/lead_dashboard_filter_section.dart';
import 'package:wfs/features/leaddashboard/widgets/lead_funnel_chart.dart';
import 'package:wfs/features/leaddashboard/widgets/lead_summary_card.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';

class LeadDashboardPage extends StatelessWidget {
  const LeadDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final data = LeadDashboardData.mock();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        centerTitle: true,
        title: const AppText(
          label: 'Lead Dashboard',
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        shape: const Border(
          bottom: BorderSide(
            color: Color.fromRGBO(60, 60, 67, 0.36),
            width: 0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                title: 'ตัวกรอง',
                subtitle: 'เลือกมุมมองข้อมูล Lead',
              ),
              const SizedBox(height: 10),
              LeadDashboardFilterSection(filters: data.filters),
              const SizedBox(height: 18),
              const _SectionHeader(
                title: 'ภาพรวม Lead',
                subtitle: 'สรุปจำนวนตามสถานะสำคัญ',
              ),
              const SizedBox(height: 10),
              _SummaryGrid(metrics: data.summaryMetrics),
              const SizedBox(height: 18),
              LeadFunnelChart(
                stages: data.funnelStages,
                closedWon: data.closedWon,
                closedLost: data.closedLost,
              ),
              const SizedBox(height: 18),
              const _SectionHeader(
                title: 'Conversion Rates',
                subtitle: 'อัตราสำคัญของกระบวนการขาย',
              ),
              const SizedBox(height: 10),
              _RateGrid(metrics: data.rateMetrics),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label: title,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          lineHeight: 22,
        ),
        const SizedBox(height: 2),
        AppText(
          label: subtitle,
          fontSize: 13,
          textColor: AppUtility.textGray,
          lineHeight: 17,
        ),
      ],
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final List<LeadDashboardMetric> metrics;

  const _SummaryGrid({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 760
            ? 5
            : constraints.maxWidth >= 560
            ? 3
            : 2;

        return GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: 156,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            return LeadSummaryCard(metric: metrics[index]);
          },
        );
      },
    );
  }
}

class _RateGrid extends StatelessWidget {
  final List<LeadDashboardRateMetric> metrics;

  const _RateGrid({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 720 ? 3 : 1;

        return GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: 184,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            return LeadConversionRateCard(metric: metrics[index]);
          },
        );
      },
    );
  }
}
