import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/features/client/views/client_list_page.dart';
import 'package:wfs/screens/test_screen.dart';
import 'appointment_screen.dart';
import 'dashboard_screen.dart';
import '../features/company/views/company_list_page.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const Scaffold(body: SafeArea(child: AppointmentScreen())),
    const Scaffold(body: SafeArea(child: ClientScreen())),
    const Scaffold(body: SafeArea(child: CompanyScreen())),
    const Scaffold(body: SafeArea(child: TestScreen())),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Appointments'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Clients'),
          BottomNavigationBarItem(icon: Icon(Icons.business_center_outlined), label: 'Company'),
          BottomNavigationBarItem(icon: Icon(Icons.business_center_outlined), label: 'Test'),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          if (index == 3) {
            // loadCompanies(ref);
          }

          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

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
