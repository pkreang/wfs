import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wfs/screens/appointment_screen.dart';
import 'package:wfs/screens/navigation_screen.dart'; // สมมติว่า MainScaffold อยู่ในไฟล์นี้
import 'package:wfs/features/client/views/client_list_page.dart';
import 'package:wfs/features/company/views/company_list_page.dart';
import 'package:wfs/screens/dashboard_screen.dart';
import 'package:wfs/screens/test_screen.dart';
import 'package:wfs/features/appointment/views/appointment_detail_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
          GoRoute(path: '/Appointments', builder: (context, state) => const AppointmentScreen()),
          GoRoute(
            path: '/appointmentDetail/:appointmentId', // กำหนด parameter สำหรับ appointmentId
            builder: (context, state) {
              final appointmentId = state.pathParameters['appointmentId'].toString();
              return AppointmentDetailPage(appointmentID: appointmentId);
            },
          ),
          GoRoute(path: '/clients', builder: (context, state) => const ClientScreen()),
          GoRoute(path: '/company', builder: (context, state) => const CompanyScreen()),
          GoRoute(path: '/test', builder: (context, state) => const TestScreen()),
        ],
      ),
    ],
  );
});

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderScreen({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text('Coming Soon', style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
