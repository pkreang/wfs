import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wfs/features/appointment/widgets/app_appointment_info.dart';
import 'package:wfs/features/appointment/widgets/app_datepicker.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/models/appointment_summary_model.dart';
import 'package:wfs/providers/date_picker_provider.dart';
import 'package:wfs/screens/clientaddappointment_screen.dart';
import 'package:wfs/utility/app_utility.dart';
import '../providers/appointment_provider.dart';

final currentDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<bool> showDateRangeDialog({required BuildContext context, required WidgetRef ref}) async {
    // ref.read(datePickerProvider.notifier).reset();
    var completed = false;
    String? validationError;

    void _handleClose(BuildContext context) {
      Navigator.of(context).pop();
    }

    void _handleConfirm(BuildContext context) {
      final datePickerState = ref.read(datePickerProvider);
      if (datePickerState.startDate != null && datePickerState.endDate != null) {
        // อัปเดต selectedDateRangeProvider
        ref.read(selectedDateRangeProvider.notifier).state = (start: datePickerState.startDate!, end: datePickerState.endDate);

        ref.read(currentDateProvider.notifier).state = datePickerState.startDate!;
        ref.invalidate(appointmentsProvider(datePickerState.startDate!));
        ref.invalidate(appointmentSummaryProvider(datePickerState.startDate!));

        Navigator.of(context).pop();
      }
    }

    await showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Consumer(
          builder: (context, ref, child) {
            final datePickerState = ref.watch(datePickerProvider);
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
                            onConfirm: (date) => ref.read(datePickerProvider.notifier).setStartDate(date),
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
                            onConfirm: (date) => ref.read(datePickerProvider.notifier).setEndDate(date),
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
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => _handleClose(context),
                          child: const AppText(label: 'ปิด'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: startDate != null && endDate != null ? () => _handleConfirm(context) : null,
                          child: AppText(label: 'ค้นหา', textColor: startDate != null && endDate != null ? AppUtility.colorPrimary : Colors.grey),
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
    final currentDate = ref.watch(currentDateProvider);

    final appointmentsAsyncValue = ref.watch(appointmentsProvider(currentDate));
    final summaryAsyncValue = ref.watch(appointmentSummaryProvider(currentDate));

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // เมื่อดึงจอลง ให้ refresh provider ทั้งหมด
            ref.invalidate(appointmentsProvider(currentDate));
            return ref.refresh(appointmentSummaryProvider(currentDate).future);
          },
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    // ส่ง ref และ currentDate ไปให้ Header
                    _buildHeader(context, ref, currentDate),
                    const SizedBox(height: 24),
                    _buildSummarySection(context, ref, summaryAsyncValue),
                    const SizedBox(height: 24),
                    _buildSectionHeader(context, "Today's Appointments"),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              appointmentsAsyncValue.when(
                loading: () => const Center(heightFactor: 5, child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(heightFactor: 5, child: Text('Error: $error')),
                data: (appointments) {
                  if (appointments.isEmpty) {
                    return const Center(heightFactor: 5, child: AppText(label: 'No appointments found.'));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final appointment = appointments[index];

                      return AppointmentInfo(appointment: appointment, currentDate: currentDate);
                    },
                    itemCount: appointments.length,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, DateTime currentDate) {
    final selectedRange = ref.watch(selectedDateRangeProvider);

    String dateLabel;
    if (selectedRange.end != null) {
      // แสดงช่วงวันที่
      dateLabel = '${DateFormat('dd/MM/yyyy').format(selectedRange.start)} - ${DateFormat('dd/MM/yyyy').format(selectedRange.end!)}';
    } else {
      // แสดงวันเดียว
      dateLabel = DateFormat('dd/MM/yyyy').format(selectedRange.start);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => showDateRangeDialog(context: context, ref: ref),
            child: Row(
              children: [
                AppText(label: dateLabel, fontSize: 18, fontWeight: FontWeight.bold),
                const SizedBox(width: 8),
                const Icon(Icons.calendar_today, size: 18, color: AppUtility.colorPrimary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, WidgetRef ref, AsyncValue<AppointmentSummary> summaryAsyncValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [AppText(label: "Today's Summary", fontSize: 18, fontWeight: FontWeight.bold)],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildSummaryChart(summaryAsyncValue),
            const SizedBox(width: 24),
            Expanded(
              child: summaryAsyncValue.when(
                loading: () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem(Colors.blue, "Completed", "-", "-"),
                    const SizedBox(height: 16),
                    _buildLegendItem(Colors.red, "Pending", "-", "-"),
                    const SizedBox(height: 16),
                    _buildLegendItem(const Color(0xFFBDBDBD), "Canceled", "-", "-"),
                  ],
                ),
                error: (err, stack) => Text('Error loading summary', style: TextStyle(color: Colors.red)),
                data: (summary) => _buildSummaryLegend(summary),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryLegend(AppointmentSummary summary) {
    int total = summary.total > 0 ? summary.total : 1;
    double completedRatio = 100 * summary.completed / total;
    double pendingRatio = 100 * summary.pending / total;
    double canceledRatio = 100 * summary.canceled / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLegendItem(Colors.blue, "Total Completed", "${summary.completed}/${summary.total} tasks", "${completedRatio.toStringAsFixed(0)}%"),
        const SizedBox(height: 16),
        _buildLegendItem(Colors.red, "Pending", "${summary.pending}/${summary.total} tasks", "${pendingRatio.toStringAsFixed(0)}%"),
        const SizedBox(height: 16),
        _buildLegendItem(const Color(0xFFBDBDBD), "Canceled", "${summary.canceled}/${summary.total} tasks", "${canceledRatio.toStringAsFixed(0)}%"),
      ],
    );
  }

  Widget _buildSummaryChart(AsyncValue<AppointmentSummary> summaryAsyncValue) {
    return summaryAsyncValue.when(
      loading: () => const SizedBox(width: 140, height: 140, child: Center(child: CircularProgressIndicator())),
      error: (err, stack) => SizedBox(
        width: 140,
        height: 140,
        child: Center(child: Icon(Icons.error, color: Colors.red)),
      ),
      data: (summary) {
        final total = summary.total > 0 ? summary.total : 1;
        final completedValue = summary.completed / total;
        final pendingValue = summary.pending / total;
        final percent = (completedValue * 100).toStringAsFixed(1);

        return SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const CircularProgressIndicator(value: 1.0, strokeWidth: 20, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE0E0E0))),
              CircularProgressIndicator(value: completedValue + pendingValue, strokeWidth: 20, valueColor: const AlwaysStoppedAnimation<Color>(Colors.red)),
              CircularProgressIndicator(value: completedValue, strokeWidth: 20, valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue)),
              Center(
                child: Container(
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  margin: const EdgeInsets.all(18),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText(label: "$percent%", fontSize: 24, fontWeight: FontWeight.bold),
                        AppText(label: "${summary.completed} of ${summary.total}", fontSize: 14, textColor: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(Color color, String title, String tasks, String percentage) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.circle, color: color, size: 16),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(label: title, fontSize: 14, fontWeight: FontWeight.w500),
            AppText(label: tasks, fontSize: 12, textColor: Colors.grey),
          ],
        ),
        const Spacer(),
        AppText(label: percentage, fontSize: 14, fontWeight: FontWeight.bold),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: AppText(label: title, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ClientAddAppointmentScreen(), fullscreenDialog: true));
          },
          icon: const Icon(Icons.add, size: 18),
          label: AppText(label: 'Create Appointment', fontSize: 12),
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue,
            backgroundColor: const Color(0xFFE3F2FD),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }
}
