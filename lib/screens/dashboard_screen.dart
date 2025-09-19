import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';
import 'package:wfs/features/appointment/widgets/app_appointment_info.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/models/appointment_summary_model.dart';
import 'package:wfs/providers/auth_provider.dart';
import '../providers/appointment_provider.dart';
import 'package:wfs/screens/clientaddappointment_screen.dart';

final currentDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ปุ่มย้อนกลับ (ลดวัน)
          // แสดงวันที่ปัจจุบัน
          AppText(label: DateFormat('MMMM d').format(currentDate), fontSize: 18, fontWeight: FontWeight.bold),
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
          children: [
            AppText(label: "Today's Summary", fontSize: 18, fontWeight: FontWeight.bold),
            GestureDetector(
              onTap: () {
                ref.read(authProvider.notifier).logout();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                decoration: BoxDecoration(border: Border.all(color: Colors.red, width: 1)),
                child: AppText(label: 'Logout', fontSize: 14, fontWeight: FontWeight.bold, textColor: Colors.red),
              ),
            ),
          ],
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
