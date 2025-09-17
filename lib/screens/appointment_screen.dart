import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/views/appointment_detail_page.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/features/appointment/widgets/appointment_status_capsule.dart';
import 'package:wfs/features/appointment/widgets/appointment_type_capsule.dart';
import 'package:wfs/features/appointment/widgets/cancel_appointment_dialog.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/screens/clientaddappointment_screen.dart';
import 'package:wfs/utility/appdialogs.dart';
import 'package:wfs/utility/validator.dart';
import 'package:wfs/widgets/app_text_form_field.dart';

class AppointmentScreen extends ConsumerWidget {
  const AppointmentScreen({super.key});

  // void handleCancelAppointment(BuildContext context, WidgetRef ref, DateTime currentDate, String appointmentID) async {
  //   if (appointmentID.isEmpty) {
  //     return;
  //   }

  //   final TextEditingController notedController = TextEditingController();

  //   void handleConfirm() async {
  //     if (Validator.required(notedController.text) != null) {
  //       AppDialogs.error(context, message: "กรุณากรอก canceled note");
  //       return;
  //     }

  //     Navigator.pop(context);

  //     await ref
  //         .read(appointmentProvider.notifier)
  //         .updateAppointmentStatus(
  //           appointmentID: appointmentID,
  //           appointmentStatusID: "16CBDB62-30BB-4679-A1ED-CB935E11B7E2",
  //           onSuccess: () {
  //             ref.read(selectedMonthProvider.notifier).setMonth(currentDate);
  //             ref.read(selectedDateProvider.notifier).setDate(currentDate);
  //           },
  //           cancelNoted: notedController.text,
  //         );
  //   }

  //   Widget dialogCancelAppointment() {
  //     return Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 24),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           AppText(label: 'Cancel Appointment', fontSize: 17, fontWeight: FontWeight.bold),
  //           const SizedBox(height: 24),
  //           AppText(label: 'canceled note'),
  //           const SizedBox(height: 4),
  //           AppTextFormField(controller: notedController, hintText: 'canceled note', isShowBorder: true),
  //           const SizedBox(height: 24),
  //           Row(
  //             spacing: 24,
  //             children: [
  //               Expanded(
  //                 child: GestureDetector(
  //                   onTap: () => Navigator.pop(context),
  //                   child: Container(
  //                     alignment: Alignment.center,
  //                     padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
  //                     decoration: BoxDecoration(color: AppUtility.colorRed, borderRadius: BorderRadius.circular(12)),
  //                     child: AppText(label: 'Cancel', fontSize: 14, fontWeight: FontWeight.bold, textColor: Colors.white),
  //                   ),
  //                 ),
  //               ),
  //               Expanded(
  //                 child: GestureDetector(
  //                   onTap: () => handleConfirm(),
  //                   child: Container(
  //                     alignment: Alignment.center,
  //                     padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
  //                     decoration: BoxDecoration(color: AppUtility.colorRed, borderRadius: BorderRadius.circular(12)),
  //                     child: AppText(label: 'Confirm', fontSize: 14, fontWeight: FontWeight.bold, textColor: Colors.white),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     );
  //   }

  //   AppDialogs.custom(context, widget: dialogCancelAppointment());
  // }

  void handleCompleteAppointment(WidgetRef ref, DateTime currentDate, String appointmentID) async {
    if (appointmentID.isEmpty) {
      return;
    }

    await ref
        .read(appointmentProvider.notifier)
        .updateAppointmentStatus(
          appointmentID: appointmentID,
          appointmentStatusID: "C9B78060-8F8C-46FA-92A6-65D932701EB7",
          onSuccess: () {
            ref.read(selectedMonthProvider.notifier).setMonth(currentDate);
            ref.read(selectedDateProvider.notifier).setDate(currentDate);
          },
        );
  }

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
                AppText(label: '210 Entry', fontSize: 13),
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
                        bool isShowCompleteButton = false;
                        bool isShowCancelButton = false;

                        bool isOnline = appointment.appointmentTypeName == "Online";
                        bool isOnCall = appointment.appointmentTypeName == "On Call";
                        if (isOnline || isOnCall) isShowCompleteButton = true;

                        bool isCancel = appointment.appointmentStatusName == "Canceled";
                        bool isComplete = appointment.appointmentStatusName == "Completed";

                        if (isComplete || isCancel) isShowCompleteButton = false;
                        if (!isComplete && !isCancel) isShowCancelButton = true;

                        return GestureDetector(
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => AppointmentDetailPage(appointmentID: appointment.appointmentID ?? ''))),
                          child: Container(
                            height: 152,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(border: Border(bottom: AppUtility.borderSide)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              spacing: 16,
                              children: [
                                Expanded(
                                  child: Column(
                                    spacing: 6,
                                    children: [
                                      Row(
                                        spacing: 6,
                                        children: [
                                          AppText(label: appointment.clientName ?? '', fontSize: 17),
                                          AppointmentTypeCapsule(appointmentTypeName: appointment.appointmentTypeName ?? ''),
                                          AppointmentStatusCapsule(appointmentStatusName: appointment.appointmentStatusName ?? ''),
                                        ],
                                      ),
                                      Row(
                                        spacing: 24,
                                        children: [
                                          Row(
                                            spacing: 6,
                                            children: [
                                              Icon(Icons.access_time_outlined, color: AppUtility.textGray, size: 18),
                                              AppText(label: '${appointment.appointmentTimeFrom}-${appointment.appointmentTimeTo.toString()}', fontSize: 14, textColor: AppUtility.textLight),
                                            ],
                                          ),
                                          Expanded(
                                            child: Row(
                                              spacing: 6,
                                              children: [
                                                Icon(Icons.business_center_outlined, color: AppUtility.textGray, size: 18),
                                                Expanded(
                                                  child: AppText(label: appointment.companyName ?? '', fontSize: 14, textColor: AppUtility.textLight),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 48,
                                        child: Row(
                                          spacing: 6,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(top: 2),
                                              child: Icon(Icons.location_on, color: AppUtility.textGray, size: 18),
                                            ),
                                            Expanded(
                                              child: AppText(label: appointment.address ?? '', fontSize: 14, textColor: AppUtility.textLight, maxLines: 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        spacing: 6,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.favorite, color: AppUtility.textGray, size: 18),
                                          Expanded(
                                            child: AppText(label: '', fontSize: 14, textColor: AppUtility.textLight),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    isShowCancelButton
                                        ? GestureDetector(
                                            onTap: () => showCancelAppointmentDialog(context: context, ref: ref, appointmentID: appointment.appointmentID ?? '', currentDate: currentDate),
                                            child: Icon(Icons.delete_outline, color: AppUtility.colorGray, size: 24),
                                          )
                                        : const SizedBox.shrink(),
                                    Icon(Icons.chevron_right, color: AppUtility.colorGray, size: 24),
                                    isShowCompleteButton
                                        ? GestureDetector(
                                            onTap: () => handleCompleteAppointment(ref, currentDate, appointment.appointmentID ?? ''),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                                              decoration: BoxDecoration(color: AppUtility.colorRed, borderRadius: BorderRadius.circular(12)),
                                              child: AppText(label: 'Complete', fontSize: 14, textColor: Colors.white),
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
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
            ref.read(selectedDateProvider.notifier).state = day;
            // อัปเดต currentDateProvider เพื่อให้ข้อมูลด้านล่างรีเฟรช
            ref.read(selectedDateProvider.notifier).setDate(day);
          },
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 32,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: isSelected ? Color.fromRGBO(0, 0, 0, 0.12) : Colors.transparent, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: AppText(label: '$i', textColor: Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
              ),
              if (isHasAppointment) Positioned(top: 44, child: Icon(Icons.circle, size: 8, color: AppUtility.colorPrimary)),
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
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1.2),
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
