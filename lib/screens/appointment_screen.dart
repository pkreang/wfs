import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/widgets/app_appointment_info.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/screens/clientaddappointment_screen.dart';

class AppointmentScreen extends ConsumerWidget {
  const AppointmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMonth = ref.watch(selectedMonthProvider);
    final currentDate = ref.watch(selectedDateProvider);

    final markPointsAsync = ref.watch(appointmentMarkDateProvider(DateTime(currentMonth.year, currentMonth.month, 1)));
    final appointmentsAsync = ref.watch(appointmentsByDateProvider(DateFormat("yyyy-MM-dd").format(currentDate)));
    final state = ref.watch(appointmentProvider);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            centerTitle: true,
            leadingWidth: 98,
            leading: GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ClientAddAppointmentScreen(), fullscreenDialog: true)),
              child: Row(
                children: [
                  IconButton(
                    icon: Row(
                      children: [
                        const Icon(Icons.add),
                        AppText(label: 'Create', textColor: AppUtility.colorPrimary, fontSize: 17, fontWeight: FontWeight.w500),
                      ],
                    ),
                    onPressed: null,
                    style: ButtonStyle(iconColor: WidgetStateProperty.all(AppUtility.colorPrimary)),
                  ),
                ],
              ),
            ),
            title: Column(
              children: [
                AppText(label: 'Appointments', fontSize: 17, fontWeight: FontWeight.w600),
                AppText(label: 'Entry', fontSize: 13),
              ],
            ),
            shape: const Border(bottom: BorderSide(color: Color.fromRGBO(60, 60, 67, 0.36), width: 0.5)),
          ),
          body: SafeArea(
            child: ListView(
              children: [
                markPointsAsync.when(
                  loading: () => Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary)),
                  error: (e, _) => Center(child: AppText(label: 'No appointments calendar found.')),
                  data: (appointmentMarkDate) {
                    return _buildCalendarHeader(context, ref, appointmentMarkDate, currentMonth, currentDate);
                  },
                ),
                const SizedBox(height: 24),
                appointmentsAsync.when(
                  loading: () => Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary)),
                  error: (e, _) => Center(child: AppText(label: 'No appointments found.')),
                  data: (appointments) {
                    if (appointments.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: AppText(label: 'No appointments found.')),
                      );
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

        if (state.isLoading) ...[const ModalBarrier(color: Color(0x66000000), dismissible: false), const Center(child: CircularProgressIndicator(color: AppUtility.colorPrimary))],
      ],
    );
  }

  Widget _buildCalendarHeader(BuildContext context, WidgetRef ref, Map<String, bool> appointmentMarkDate, DateTime currentMonth, DateTime selectedDate) {
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
                  ref.read(selectedMonthProvider.notifier).prevMonth();
                },
              ),
              AppText(label: DateFormat('MMMM yyyy').format(currentMonth), fontSize: 18, fontWeight: FontWeight.bold),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 20),
                onPressed: () {
                  ref.read(selectedMonthProvider.notifier).nextMonth();
                },
              ),
            ],
          ),
        ),
        _buildWeekdays(),
        _buildDaysGrid(context, ref, appointmentMarkDate, currentMonth, selectedDate),
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

  Widget _buildDaysGrid(BuildContext context, WidgetRef ref, Map<String, bool> appointmentMarkDate, DateTime currentMonth, DateTime selectedDate) {
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
      // final isToday = day.day == DateTime.now().day && day.month == DateTime.now().month && day.year == DateTime.now().year;

      final isHasAppointment = appointmentMarkDate[DateFormat('yyyy-MM-dd').format(day)] ?? false;

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            ref.read(selectedDateProvider.notifier).setDate(day);
          },
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                // height: 18,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: isSelected ? Color.fromRGBO(0, 0, 0, 0.12) : Colors.transparent, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: AppText(label: '$i', textColor: Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
              ),
              if (isHasAppointment) Positioned(top: 31, child: Icon(Icons.circle, size: 8, color: AppUtility.colorPrimary)),
            ],
          ),
        ),
      );
    }

    return Column(
      spacing: 16,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1.6),
          itemCount: dayWidgets.length,
          itemBuilder: (context, index) {
            return dayWidgets[index];
          },
        ),
        const Divider(height: 0.5, thickness: 0.5, color: Color.fromRGBO(60, 60, 67, 0.36)),
      ],
    );
  }
}
