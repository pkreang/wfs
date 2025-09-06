import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DatePickerHelper {
  static Future<DateTime?> pickDate(BuildContext context, {required DateTime initialDate, required DateTime? limitFirstDate}) async {
    DateTime selectedDate = initialDate;

    final minDate = DateUtils.dateOnly(limitFirstDate ?? DateTime(2000));
    final maxDate = DateUtils.dateOnly(DateTime(2100));

    return await showDialog<DateTime>(
      context: context,
      builder: (context) {
        return Localizations.override(
          context: context,
          delegates: const [_CustomMaterialLocalizationsDelegate()],
          child: Theme(
            data: Theme.of(context).copyWith(
              textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: Colors.black87, textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),

              datePickerTheme: DatePickerThemeData(
                weekdayStyle: const TextStyle(fontSize: 13, color: Color.fromRGBO(60, 60, 67, 0.3), fontWeight: FontWeight.w600),

                // todayBackgroundColor: const WidgetStatePropertyAll(Color(0x14007AFF)),
                // todayForegroundColor: const WidgetStatePropertyAll(Color(0xFF007AFF)),
                todayBorder: BorderSide.none,
                dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                  if (states.contains(WidgetState.selected)) return const Color(0x14007AFF);

                  return Colors.transparent;
                }),
                dayForegroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                  if (states.contains(WidgetState.selected)) return const Color(0xFF007AFF);
                  if (states.contains(WidgetState.disabled)) return Colors.black26;

                  return Colors.black87;
                }),
                dayOverlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
                  return const Color(0x14007AFF);
                }),

                yearForegroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return const Color(0xFF007AFF);
                  if (states.contains(WidgetState.disabled)) return Colors.black26;

                  return Colors.black87;
                }),
                yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
                  return Colors.transparent;
                }),
                yearOverlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
                  return const Color(0x14007AFF);
                }),
              ),
            ),
            child: AlertDialog(
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: SizedBox(
                width: 330,
                height: 380,
                child: Column(
                  children: [
                    Expanded(
                      child: CalendarDatePicker(
                        initialDate: selectedDate,
                        firstDate: minDate,
                        lastDate: maxDate,
                        selectableDayPredicate: (d) => !d.isBefore(minDate),
                        onDateChanged: (date) => selectedDate = date,
                      ),
                    ),
                    const Divider(height: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
                        TextButton(onPressed: () => Navigator.pop(context, selectedDate), child: const Text("OK")),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CustomMaterialLocalizations extends DefaultMaterialLocalizations {
  @override
  List<String> get narrowWeekdays => const ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
}

class _CustomMaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const _CustomMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) async => SynchronousFuture<MaterialLocalizations>(_CustomMaterialLocalizations());

  @override
  bool shouldReload(_CustomMaterialLocalizationsDelegate old) => false;
}
