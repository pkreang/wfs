

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/appointment_model.dart';
import '../providers/appointment_provider.dart';
import 'create_appointment_screen.dart'; 


class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsyncValue = ref.watch(appointmentsProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            return ref.refresh(appointmentsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSummarySection(),
              const SizedBox(height: 24),


              _buildSectionHeader(context, "Today's Appointments"),

              const SizedBox(height: 16),
              
              appointmentsAsyncValue.when(
                loading: () => const Center(heightFactor: 5, child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(heightFactor: 5, child: Text('Error: $error')),
                data: (appointments) {
                  if (appointments.isEmpty) {
                    return const Center(heightFactor: 5, child: Text('No appointments found.'));
                  }
                  
                  String? lastTimeHeader;
                  return Column(
                    children: appointments.map((appointment) {
                      final timeHeader = DateFormat('HH:00').format(appointment.dateTime);
                      final bool showHeader = timeHeader != lastTimeHeader;
                      lastTimeHeader = timeHeader;
                      
                      return _buildAppointmentItem(
                        appointment: appointment, 
                        showHeader: showHeader
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),

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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          Text(
            DateFormat('MMMM d').format(DateTime.now()),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 20),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Summary",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildSummaryChart(),
            const SizedBox(width: 24),
            Expanded(child: _buildSummaryLegend()),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryChart() {
    const double completedValue = 71.4 / 100;
    const double pendingValue = 14.0 / 100;

    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 20,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE0E0E0)),
          ),
          CircularProgressIndicator(
            value: completedValue + pendingValue,
            strokeWidth: 20,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
          ),
          CircularProgressIndicator(
            value: completedValue,
            strokeWidth: 20,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          Center(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              margin: const EdgeInsets.all(18),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "71.4%",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Text(
                      "10 of 14",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLegendItem(Colors.blue, "Total Completed", "10/14 tasks", "71%"),
        const SizedBox(height: 16),
        _buildLegendItem(Colors.red, "Pending", "2/14 tasks", "14%"),
        const SizedBox(height: 16),
        _buildLegendItem(const Color(0xFFBDBDBD), "Canceled", "2/14 tasks", "14%"),
      ],
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
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            Text(tasks, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        const Spacer(),
        Text(percentage, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }


  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        TextButton.icon(
            onPressed: () {
            // ตอนนี้ context ที่ใช้ใน Navigator เป็นตัวที่ถูกต้องแล้ว
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CreateAppointmentScreen(),
                fullscreenDialog: true,
              ),
            );
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text(
            'Create Appointment',
            style: TextStyle(fontSize: 12),
          ),
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue,
            backgroundColor: const Color(0xFFE3F2FD),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentItem({
    required Appointment appointment,
    required bool showHeader,
  }) {
    final tags = [
      Chip(
        label: Text(appointment.typeName),
        backgroundColor: _getTypeColor(appointment.typeName),
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        visualDensity: VisualDensity.compact,
      ),
      Chip(
        label: Text(appointment.statusName),
        backgroundColor: _getStatusColor(appointment.statusName),
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        visualDensity: VisualDensity.compact,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
            child: Text(
              DateFormat('HH:00').format(appointment.dateTime),
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          appointment.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Wrap(spacing: 4.0, children: tags),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.access_time_outlined, color: Colors.grey.shade600, size: 20),
                      const SizedBox(width: 12),
                      Text(DateFormat('HH:mm').format(appointment.dateTime), style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                      const SizedBox(width: 16),
                      Icon(Icons.business_center_outlined, color: Colors.grey.shade600, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          appointment.companyName,
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.location_on_outlined, appointment.customerAddress),
                  _buildInfoRow(Icons.favorite_border, appointment.noted),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(color: Colors.grey.shade700, fontSize: 14))),
        ],
      ),
    );
  }
}