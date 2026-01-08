import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/utility/app_utility.dart';

class AppDatePickerRange extends StatefulWidget {
  const AppDatePickerRange({required this.appointmentMarkDate, required this.currentMonth, required this.startDate, this.endDate, this.onSelectMonth, this.onClose, this.onConfirm, super.key});

  final Map<String, bool> appointmentMarkDate;
  final DateTime currentMonth;
  final DateTime startDate;
  final DateTime? endDate;
  final ValueChanged<DateTime>? onSelectMonth;
  final VoidCallback? onClose;
  final void Function(DateTime startDate, DateTime? endDate)? onConfirm;

  @override
  State<AppDatePickerRange> createState() => _AppDatePickerRangeState();
}

class _AppDatePickerRangeState extends State<AppDatePickerRange> {
  bool _showMonthPicker = false;
  bool _showCalendar = true;
  DateTime? _tempStartDate;
  DateTime? _tempEndDate;
  late int _selectedYear;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _tempStartDate = widget.startDate;
    _tempEndDate = widget.endDate;
    _selectedYear = widget.currentMonth.year;
    _currentMonth = widget.currentMonth;
  }

  @override
  void didUpdateWidget(covariant AppDatePickerRange oldWidget) {
    super.didUpdateWidget(oldWidget);
    final startChanged = !_isSameDayNullable(oldWidget.startDate, widget.startDate);
    final endChanged = !_isSameDayNullable(oldWidget.endDate, widget.endDate);
    if (startChanged || endChanged) {
      _tempStartDate = widget.startDate;
      _tempEndDate = widget.endDate;
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
      final startDate = _tempStartDate ?? widget.startDate;
      final endDate = _tempEndDate;
      final isStart = _isSameDay(day, startDate);
      final isEnd = endDate != null && _isSameDay(day, endDate);
      final hasRange = endDate != null && !day.isBefore(startDate) && !day.isAfter(endDate);
      final isInRange = hasRange && !isStart && !isEnd;
      final isHasAppointment = widget.appointmentMarkDate[DateFormat('yyyy-MM-dd').format(day)] ?? false;

      dayWidgets.add(
        GestureDetector(
          onTap: () => _handleDayTap(day),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (hasRange)
                Positioned.fill(
                  child: Container(
                    margin: EdgeInsets.only(left: isStart ? 8 : 0, right: isEnd ? 8 : 0),
                    decoration: BoxDecoration(
                      color: AppUtility.colorPrimary.withOpacity(0.16),
                      borderRadius: BorderRadius.horizontal(left: Radius.circular(isStart ? 12 : 0), right: Radius.circular(isEnd ? 12 : 0)),
                    ),
                  ),
                ),
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: isStart && endDate == null ? AppUtility.colorPrimary.withOpacity(0.16) : Colors.transparent, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: AppText(label: '$i', textColor: Colors.black, fontWeight: isStart || isEnd ? FontWeight.bold : FontWeight.normal),
              ),
              if (isHasAppointment) Positioned(top: 31, child: Icon(Icons.circle, size: 8, color: AppUtility.colorPrimary)),
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
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1.6),
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
      if (_tempStartDate == null || (_tempStartDate != null && _tempEndDate != null)) {
        _tempStartDate = normalized;
        _tempEndDate = null;
        return;
      }

      if (_isSameDay(normalized, _tempStartDate!)) {
        _tempEndDate = null;
      } else if (normalized.isBefore(_tempStartDate!)) {
        _tempStartDate = normalized;
        _tempEndDate = null;
      } else {
        _tempEndDate = normalized;
      }
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
    if (widget.onConfirm != null) {
      widget.onConfirm!(_tempStartDate ?? widget.startDate, _tempEndDate);
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
