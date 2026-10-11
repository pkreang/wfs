import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/leaddashboard2/models/lead_dashboard2_metric.dart';
import 'package:wfs/features/leaddashboard2/providers/lead_dashboard2_date_range_provider.dart';
import 'package:wfs/features/leaddashboard2/widgets/lead_dashboard2_conversion_rate_card.dart';
import 'package:wfs/features/leaddashboard2/widgets/lead_dashboard2_filter_section.dart';
import 'package:wfs/features/leaddashboard2/widgets/lead_dashboard2_funnel_chart.dart';
import 'package:wfs/features/leaddashboard2/widgets/lead_dashboard2_summary_card.dart';
import 'package:wfs/features/appointment/widgets/app_datepicker.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';

class LeadDashboard2Page extends ConsumerWidget {
  const LeadDashboard2Page({required this.onOpenLeads, super.key});

  final VoidCallback onOpenLeads;

  Future<bool> showDateRangeDialog({required BuildContext context, required WidgetRef ref}) async {
    var completed = false;
    final selectedRange = ref.read(leadDashboard2SelectedDateRangeProvider);
    final datePickerNotifier = ref.read(leadDashboard2DatePickerProvider.notifier);
    if (selectedRange.start != null && selectedRange.end != null) {
      datePickerNotifier.setDateRange(selectedRange.start!, selectedRange.end!);
    } else {
      datePickerNotifier.reset();
    }

    void handleClose(BuildContext context) {
      Navigator.of(context).pop();
    }

    void handleClear(BuildContext context) {
      ref.read(leadDashboard2DatePickerProvider.notifier).reset();
      ref.read(leadDashboard2SelectedDateRangeProvider.notifier).state = (start: null, end: null);
      // Navigator.of(context).pop();
    }

    void handleConfirm(BuildContext context) {
      final datePickerState = ref.read(leadDashboard2DatePickerProvider);
      final startDate = datePickerState.startDate;
      final endDate = datePickerState.endDate;
      if (startDate == null || endDate == null) return;

      ref.read(leadDashboard2SelectedDateRangeProvider.notifier).state = (start: startDate, end: endDate);

      //  ref.read(currentDateProvider.notifier).state = datePickerState.startDate!;
      //         ref.invalidate(appointmentsProvider(datePickerState.startDate!));
      //         ref.invalidate(appointmentSummaryProvider(datePickerState.startDate!));

      completed = true;
      Navigator.of(context).pop();
    }

    await showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Consumer(
          builder: (context, ref, child) {
            final datePickerState = ref.watch(leadDashboard2DatePickerProvider);
            final startDate = datePickerState.startDate;
            final endDate = datePickerState.endDate;

            return CupertinoAlertDialog(
              title: Center(child: const AppText(label: "เลือกช่วงวันที่")),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      await showDialog<DateTime>(
                        context: context,
                        builder: (pickerContext) => Dialog(
                          child: AppDatePicker(
                            appointmentMarkDate: const {},
                            currentMonth: datePickerState.currentMonth,
                            selectedDate: startDate ?? DateTime.now(),
                            onConfirm: (date) => ref.read(leadDashboard2DatePickerProvider.notifier).setStartDate(date),
                            onClose: () => Navigator.of(pickerContext).pop(),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AppText(
                        label: startDate == null ? 'เลือกวันที่เริ่มต้น' : 'วันที่เริ่มต้น: ${DateFormat('dd/MM/yyyy').format(startDate)}',
                        fontSize: 14,
                        textColor: startDate == null ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      await showDialog<DateTime>(
                        context: context,
                        builder: (pickerContext) => Dialog(
                          child: AppDatePicker(
                            appointmentMarkDate: const {},
                            currentMonth: datePickerState.currentMonth,
                            selectedDate: endDate ?? DateTime.now(),
                            onConfirm: (date) => ref.read(leadDashboard2DatePickerProvider.notifier).setEndDate(date),
                            onClose: () => Navigator.of(pickerContext).pop(),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AppText(
                        label: endDate == null ? 'เลือกวันที่สิ้นสุด' : 'วันที่สิ้นสุด: ${DateFormat('dd/MM/yyyy').format(endDate)}',
                        fontSize: 14,
                        textColor: endDate == null ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => handleClear(context),
                          child: const AppText(label: 'ล้างค่า'),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => handleClose(context),
                              child: const AppText(label: 'ปิด'),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: startDate != null && endDate != null ? () => handleConfirm(context) : null,
                              child: AppText(label: 'ค้นหา', textColor: startDate != null && endDate != null ? AppUtility.colorPrimary : Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    return completed;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRange = ref.watch(leadDashboard2SelectedDateRangeProvider);
    final state = ref.watch(leadDashboard2Provider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        centerTitle: true,
        title: const AppText(label: 'Convesrion', fontSize: 17, fontWeight: FontWeight.w600),
        shape: const Border(bottom: BorderSide(color: Color.fromRGBO(60, 60, 67, 0.36), width: 0.5)),
      ),
      body: SafeArea(
        child: state.data.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorView(message: error.toString(), onRetry: () => ref.read(leadDashboard2Provider.notifier).fetch()),
          data: (data) => RefreshIndicator(
            onRefresh: () => ref.read(leadDashboard2Provider.notifier).fetch(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(label: 'ตัวกรอง'),
                  const SizedBox(height: 8),
                  LeadDashboard2FilterSection(
                    filters: data.filters,
                    selectedStartDate: selectedRange.start,
                    selectedEndDate: selectedRange.end,
                    onDateRangeTap: () => showDateRangeDialog(context: context, ref: ref),
                  ),
                  const SizedBox(height: 18),
                  const _SectionTitle(label: 'ผลสรุป'),
                  const SizedBox(height: 8),
                  _SummaryGrid(metrics: data.summaryMetrics, onOpenLeads: onOpenLeads),
                  const SizedBox(height: 18),
                  const _SectionTitle(label: 'แผนภาพ'),
                  const SizedBox(height: 8),
                  LeadDashboard2FunnelChart(stages: data.funnelStages, closedWon: data.closedWon, closedLost: data.closedLost),
                  const SizedBox(height: 18),
                  const _SectionTitle(label: 'Conversion Rate'),
                  const SizedBox(height: 8),
                  _RateGrid(metrics: data.rateMetrics),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(label: message, textColor: Colors.red, maxLines: 3, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: const AppText(label: 'Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;

  const _SectionTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    return AppText(label: label, fontSize: 16, fontWeight: FontWeight.w600, lineHeight: 20);
  }
}

class _SummaryGrid extends StatelessWidget {
  final List<LeadDashboard2Metric> metrics;
  final VoidCallback onOpenLeads;

  const _SummaryGrid({required this.metrics, required this.onOpenLeads});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      itemBuilder: (context, index) => SizedBox(
        child: LeadDashboard2SummaryCard(metric: metrics[index], onOpenLeads: onOpenLeads),
      ),
      separatorBuilder: (context, index) => const SizedBox(height: 10),
    );
  }
}

class _RateGrid extends ConsumerWidget {
  final List<LeadDashboard2RateMetric> metrics;

  const _RateGrid({required this.metrics});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 760 ? 3 : 1;

        return GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, mainAxisExtent: 164, crossAxisSpacing: 10, mainAxisSpacing: 10),
          itemBuilder: (context, index) => GestureDetector(
            onTap: () {},
            child: LeadDashboard2ConversionRateCard(metric: metrics[index]),
          ),
        );
      },
    );
  }
}
