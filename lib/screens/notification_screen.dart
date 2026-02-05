import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/appointment/models/appointment.dart';
import 'package:wfs/features/appointment/views/appointment_detail_page.dart';
import 'package:wfs/features/client/models/client.dart';
import 'package:wfs/features/client/views/client_detail_page.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Client> _clientNotifications = [];
  List<Appointment> _appointmentNotifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);

    try {
      final clientService = ref.read(clientServiceProvider);
      final appointmentService = ref.read(appointmentServiceProvider);

      final clients = await clientService.getNotifications(ref);
      final appointments = await appointmentService.getNotifications(ref);

      setState(() {
        _clientNotifications = clients;
        _appointmentNotifications = appointments;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching notifications: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText(label: 'Notifications', fontSize: 20, fontWeight: FontWeight.bold),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppUtility.colorPrimary),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppUtility.colorPrimary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppUtility.colorPrimary,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline, size: 18),
                  const SizedBox(width: 8),
                  AppText(label: 'Clients (${_clientNotifications.length})', fontSize: 14),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 18),
                  const SizedBox(width: 8),
                  AppText(label: 'Appointments (${_appointmentNotifications.length})', fontSize: 14),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchNotifications,
              child: TabBarView(controller: _tabController, children: [_buildClientNotifications(), _buildAppointmentNotifications()]),
            ),
    );
  }

  Widget _buildClientNotifications() {
    if (_clientNotifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            AppText(label: 'No client notifications', fontSize: 16, textColor: Colors.grey),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _clientNotifications.length,
      separatorBuilder: (context, index) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final notification = _clientNotifications[index];

        return GestureDetector(
          onTap: () async {
            final clientService = ref.read(clientServiceProvider);
            await clientService.markNotification(clientID: notification.clientID ?? '', ref: ref);
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => ClientDetailPage(clientID: notification.clientID ?? '')));
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(label: 'มี Client ใหม่สำหรับคุณ', fontSize: 16, fontWeight: FontWeight.bold),
                const SizedBox(height: 6),
                AppText(label: 'Client ใหม่ ชื่อ ${notification.firstName} ${notification.lastName}', fontSize: 14, textColor: Colors.grey.shade700, maxLines: 2),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppointmentNotifications() {
    if (_appointmentNotifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            AppText(label: 'No appointment notifications', fontSize: 16, textColor: Colors.grey),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _appointmentNotifications.length,
      separatorBuilder: (context, index) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final notification = _appointmentNotifications[index];

        return GestureDetector(
          onTap: () async {
            final appointmentService = ref.read(appointmentServiceProvider);
            await appointmentService.markNotification(appointmentID: notification.appointmentID ?? '', ref: ref);
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => AppointmentDetailPage(appointmentID: notification.appointmentID ?? '')));
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(label: notification.appointmentTitle ?? '', fontSize: 16, fontWeight: FontWeight.bold),
                const SizedBox(height: 6),
                AppText(label: 'Client ชื่อ ${notification.clientName} บริษัทชื่อ ${notification.companyName}', fontSize: 14, textColor: Colors.grey.shade700, maxLines: 2),
              ],
            ),
          ),
        );
      },
    );
  }
}
