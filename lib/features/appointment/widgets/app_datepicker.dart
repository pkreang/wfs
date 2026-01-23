import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/utility/app_utility.dart';

class AppDatePicker extends StatefulWidget {
  const AppDatePicker({required this.appointmentMarkDate, required this.currentMonth, required this.selectedDate, this.onSelectMonth, this.onClose, this.onConfirm, super.key});

  final Map<String, bool> appointmentMarkDate;
  final DateTime currentMonth;
  final DateTime selectedDate;
  final ValueChanged<DateTime>? onSelectMonth;
  final VoidCallback? onClose;
  final ValueChanged<DateTime>? onConfirm;

  @override
  State<AppDatePicker> createState() => _AppDatePickerState();
}

class _AppDatePickerState extends State<AppDatePicker> {
  bool _showMonthPicker = false;
  bool _showCalendar = true;
  DateTime? _tempSelectedDate;
  late int _selectedYear;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _tempSelectedDate = widget.selectedDate;
    _selectedYear = widget.currentMonth.year;
    _currentMonth = widget.currentMonth;
  }

  @override
  void didUpdateWidget(covariant AppDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isSameDayNullable(oldWidget.selectedDate, widget.selectedDate)) {
      _tempSelectedDate = widget.selectedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showMonthPicker) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showMonthPicker) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
                    onPressed: _previousYear,
                  ),
                  GestureDetector(
                    onTap: widget.onSelectMonth == null
                        ? null
                        : () => setState(() {
                            _showMonthPicker = !_showMonthPicker;
                            _showCalendar = !_showCalendar;
                          }),
                    child: AppText(label: '$_selectedYear', fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 20),
                    onPressed: _nextYear,
                  ),
                ],
              ),
            ),
            _buildMonthPicker(),
          ],
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_showCalendar) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
                  onPressed: _previousMonth,
                ),
                GestureDetector(
                  onTap: widget.onSelectMonth == null
                      ? null
                      : () => setState(() {
                          _showMonthPicker = !_showMonthPicker;
                          _showCalendar = !_showCalendar;
                        }),
                  child: AppText(label: DateFormat('MMMM yyyy').format(_currentMonth), fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 20),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),
          _buildWeekdays(),
          _buildDaysGrid(context),
        ],
        if (widget.onClose != null || widget.onConfirm != null)
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
                  onPressed: () => _handleConfirm(context),
                  child: const AppText(label: 'เลือก', textColor: AppUtility.colorPrimary),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildWeekdays() {
    const weekdays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekdays.map((day) => AppText(label: day, fontSize: 12, textColor: Colors.grey)).toList(),
      ),
    );
  }

  Widget _buildMonthPicker() {
    if (widget.onSelectMonth == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(12, (index) {
          final month = index + 1;
          final monthDate = DateTime(_selectedYear, month, 1);
          final isSelected = month == _currentMonth.month && _selectedYear == _currentMonth.year;
          return SizedBox(
            width: 92,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _currentMonth = monthDate;
                  _showMonthPicker = false;
                });
                widget.onSelectMonth!(monthDate);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: isSelected ? const Color(0xFFEFF3F9) : Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: AppText(label: DateFormat('MMMM').format(monthDate), fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, maxLines: 2),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDaysGrid(BuildContext context) {
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday;
    final startDayOffset = (firstDayOfMonth == DateTime.sunday) ? 0 : firstDayOfMonth;

    final List<Widget> dayWidgets = [];

    for (int i = 0; i < startDayOffset; i++) {
      dayWidgets.add(const SizedBox.shrink());
    }

    for (int i = 1; i <= daysInMonth; i++) {
      final day = DateTime(_currentMonth.year, _currentMonth.month, i);
      final selectedDate = _tempSelectedDate ?? widget.selectedDate;
      final isSelected = _isSameDay(day, selectedDate);
      final isHasAppointment = widget.appointmentMarkDate[DateFormat('yyyy-MM-dd').format(day)] ?? false;

      dayWidgets.add(
        GestureDetector(
          onTap: () => _handleDayTap(day),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: isSelected ? AppUtility.colorPrimary.withOpacity(0.16) : Colors.transparent, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: AppText(label: '$i', fontSize: 16, textColor: Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
              ),
              if (isHasAppointment) Positioned(bottom: 4, child: Icon(Icons.circle, size: 6, color: AppUtility.colorPrimary)),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1.0, mainAxisSpacing: 8, crossAxisSpacing: 4),
          itemCount: dayWidgets.length,
          itemBuilder: (context, index) => dayWidgets[index],
        ),
        const Divider(height: 0.5, thickness: 0.5, color: Color.fromRGBO(60, 60, 67, 0.36)),
      ],
    );
  }

  void _handleDayTap(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    setState(() {
      _tempSelectedDate = normalized;
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isSameDayNullable(DateTime? a, DateTime? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return _isSameDay(a, b);
  }

  void _handleClose(BuildContext context) {
    if (widget.onClose != null) {
      widget.onClose!();
      return;
    }
    Navigator.of(context).pop();
  }

  void _handleConfirm(BuildContext context) {
    if (widget.onConfirm != null && _tempSelectedDate != null) {
      widget.onConfirm!(_tempSelectedDate!);
    }
    Navigator.of(context).pop();
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
      widget.onSelectMonth?.call(_currentMonth);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
      widget.onSelectMonth?.call(_currentMonth);
    });
  }

  void _previousYear() {
    setState(() => _selectedYear--);
  }

  void _nextYear() {
    setState(() => _selectedYear++);
  }
}
