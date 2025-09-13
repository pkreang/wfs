import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import '../providers/appointment_provider.dart';
import 'package:wfs/screens/clientaddappointment_screen.dart';
import '../models/appointment_model.dart';
import '../features/appointment/views/appointment_detail_page.dart';

final currentDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
final currentMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

class AppointmentScreen extends ConsumerWidget {
  const AppointmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentDate = ref.watch(currentDateProvider);
    final currentMonth = ref.watch(currentMonthProvider);
    //    final selectedDate = ref.watch(selectedDateProvider);

    final appointmentsAsyncValue = ref.watch(appointmentsProvider(currentDate));

    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),

            _buildCalendarHeader(context, ref, currentMonth, currentDate),
            const SizedBox(height: 24),

            // Appointment List Header
            appointmentsAsyncValue.when(
              loading: () => const Center(heightFactor: 5, child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(heightFactor: 5, child: Text('Error: $error')),
              data: (appointments) {
                if (appointments.isEmpty) {
                  //return  Center(heightFactor: 5, child: Text('No appointments found for ${DateFormat('MMMM d, yyyy').format(currentDate)}.'));
                  return Center(heightFactor: 5, child: AppText(label: 'No appointments found.'));
                }

                return Column(
                  children: appointments.map((appointment) {
                    return _buildAppointmentItem(
                      appointment: appointment,
                      context: context,
                      // showHeader: false, // เราจะจัดการ header เวลาด้วยการจัดกลุ่มด้านล่าง
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Centered Title
        const Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              AppText(label: 'Appointments', fontSize: 18, fontWeight: FontWeight.bold),
              AppText(label: '210 Entry', fontSize: 12, textColor: Colors.grey),
            ],
          ),
        ),
        // "+ Create" button on the left
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ClientAddAppointmentScreen(), fullscreenDialog: true));
            },
            icon: const Icon(Icons.add, size: 18),
            label: const AppText(label: 'Create', textColor: Colors.blue),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
              // backgroundColor: const Color(0xFFE3F2FD), // Removed background as per image
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8), // Adjusted padding
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),

        // Optional: More options icon on the right if needed, matching the original AppBar
      ],
    );
  }

  Widget _buildCalendarHeader(BuildContext context, WidgetRef ref, DateTime currentMonth, DateTime selectedDate) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
                onPressed: () {
                  ref.read(currentMonthProvider.notifier).update((state) => DateTime(state.year, state.month - 1, 1));
                },
              ),
              AppText(label: DateFormat('MMMM yyyy').format(currentMonth), fontSize: 18, fontWeight: FontWeight.bold),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 20),
                onPressed: () {
                  ref.read(currentMonthProvider.notifier).update((state) => DateTime(state.year, state.month + 1, 1));
                },
              ),
            ],
          ),
        ),
        _buildWeekdays(),
        _buildDaysGrid(context, ref, currentMonth, selectedDate),
      ],
    );
  }

  Widget _buildWeekdays() {
    final weekdays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekdays.map((day) => AppText(label: day, fontSize: 12, textColor: Colors.grey)).toList(),
      ),
    );
  }

  Widget _buildDaysGrid(BuildContext context, WidgetRef ref, DateTime currentMonth, DateTime selectedDate) {
    final daysInMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1).weekday; // 1 = Monday, 7 = Sunday
    // ปรับให้ Sunday เป็น 0, Monday เป็น 1 ... เพื่อให้ตรงกับ index ของกริด
    final startDayOffset = (firstDayOfMonth == 7) ? 0 : firstDayOfMonth;

    final List<Widget> dayWidgets = [];

    // เพิ่มช่องว่างสำหรับวันก่อนหน้าเดือนปัจจุบัน
    for (int i = 0; i < startDayOffset; i++) {
      dayWidgets.add(const SizedBox.shrink());
    }

    // เพิ่มวันในเดือน
    for (int i = 1; i <= daysInMonth; i++) {
      final day = DateTime(currentMonth.year, currentMonth.month, i);
      final isSelected = day.day == selectedDate.day && day.month == selectedDate.month && day.year == selectedDate.year;
      final isToday = day.day == DateTime.now().day && day.month == DateTime.now().month && day.year == DateTime.now().year;

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            ref.read(selectedDateProvider.notifier).state = day;
            // อัปเดต currentDateProvider เพื่อให้ข้อมูลด้านล่างรีเฟรช
            ref.read(currentDateProvider.notifier).state = day;
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: isSelected ? Colors.blue : (isToday ? Colors.blue.withOpacity(0.2) : Colors.transparent), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: AppText(label: '$i', textColor: isSelected ? Colors.white : Colors.black, fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1.0),
      itemCount: dayWidgets.length,
      itemBuilder: (context, index) {
        return dayWidgets[index];
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFFE8F5E9);
      case 'scheduled':
        return const Color(0xFFFFF3E0);
      case 'postpone':
        return const Color(0xFFFBE9E7);
      default:
        return const Color(0xFFE0E0E0);
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'visit':
        return const Color(0xFFE3F2FD);
      case 'online':
        return const Color(0xFFE0F7FA);
      case 'on call':
        return const Color(0xFFF1E6FF);
      default:
        return const Color(0xFFE0E0E0);
    }
  }

  Widget _buildAppointmentItem({required Appointment appointment, required context}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: AppText(label: appointment.clientName, fontSize: 16, fontWeight: FontWeight.bold, textColor: Colors.black),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: _getTypeColor(appointment.appointmentTypeName), borderRadius: BorderRadius.circular(16)),
                          child: AppText(label: appointment.appointmentTypeName, fontSize: 13, fontWeight: FontWeight.w500, textColor: Colors.black),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: _getStatusColor(appointment.appointmentStatusName), borderRadius: BorderRadius.circular(16)),
                          child: AppText(label: appointment.appointmentStatusName, fontSize: 13, fontWeight: FontWeight.w500, textColor: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.access_time_outlined, color: Colors.grey.shade600, size: 18),
                        const SizedBox(width: 4),
                        AppText(label: '${appointment.appointmentTimeFrom}-${appointment.appointmentTimeto.toString()}', fontSize: 14, fontWeight: FontWeight.w500, textColor: Colors.grey.shade700),
                        const SizedBox(width: 12),
                        Icon(Icons.business_center_outlined, color: Colors.grey.shade600, size: 18),
                        const SizedBox(width: 4),
                        Expanded(
                          child: AppText(label: appointment.companyName, fontSize: 14, textColor: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_outlined, color: Colors.grey.shade600, size: 18),
                        const SizedBox(width: 4),
                        Expanded(
                          child: AppText(label: appointment.customerAddress, fontSize: 14, textColor: Colors.grey.shade700, maxLines: 2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.favorite_border, color: Colors.grey.shade600, size: 18),
                        const SizedBox(width: 4),
                        Expanded(
                          child: AppText(label: appointment.product, fontSize: 14, textColor: Colors.grey.shade700, maxLines: 2),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              GestureDetector(
                onTap: () {
                  if (appointment.id != null) {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => AppointmentDetailPage(appointmentID: appointment.id.toString())));
                  } else {
                    print('Error: appointmentId is null');
                  }
                },
                child: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
        const Divider(height: 32),
      ],
    );
  }
}
