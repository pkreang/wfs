import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/utility/app_utility.dart';

class AppDatePicker extends StatelessWidget {
  const AppDatePicker({
    required this.appointmentMarkDate,
    required this.currentMonth,
    required this.selectedDate,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectDate,
    super.key,
  });

  final Map<String, bool> appointmentMarkDate;
  final DateTime currentMonth;
  final DateTime selectedDate;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onSelectDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
                onPressed: onPreviousMonth,
              ),
              AppText(label: DateFormat('MMMM yyyy').format(currentMonth), fontSize: 18, fontWeight: FontWeight.bold),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 20),
                onPressed: onNextMonth,
              ),
            ],
          ),
        ),
        _buildWeekdays(),
        _buildDaysGrid(context),
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

  Widget _buildDaysGrid(BuildContext context) {
    final daysInMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1).weekday; // 1 = Monday, 7 = Sunday
    final startDayOffset = (firstDayOfMonth == 7) ? 0 : firstDayOfMonth;

    final List<Widget> dayWidgets = [];

    for (int i = 0; i < startDayOffset; i++) {
      dayWidgets.add(const SizedBox.shrink());
    }

    for (int i = 1; i <= daysInMonth; i++) {
      final day = DateTime(currentMonth.year, currentMonth.month, i);
      final isSelected = day.day == selectedDate.day && day.month == selectedDate.month && day.year == selectedDate.year;
      final isHasAppointment = appointmentMarkDate[DateFormat('yyyy-MM-dd').format(day)] ?? false;

      dayWidgets.add(
        GestureDetector(
          onTap: () => onSelectDate(day),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: isSelected ? const Color.fromRGBO(0, 0, 0, 0.12) : Colors.transparent, shape: BoxShape.circle),
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
          itemBuilder: (context, index) => dayWidgets[index],
        ),
        const Divider(height: 0.5, thickness: 0.5, color: Color.fromRGBO(60, 60, 67, 0.36)),
      ],
    );
  }
}
