import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/features/sales/views/sales_screen.dart';
import 'package:wfs/features/team/views/team_screen.dart';
// import 'package:go_router/go_router.dart';
import 'package:wfs/providers/auth_provider.dart';
import 'package:wfs/screens/appointment_screen.dart';
import 'package:wfs/features/client/views/client_list_page.dart';
import 'package:wfs/features/company/views/company_list_page.dart';
import 'package:wfs/screens/dashboard_screen.dart';
import 'package:wfs/screens/setting_screen.dart';
import 'package:wfs/utility/app_text.dart';
import 'package:wfs/utility/app_utility.dart';

// The GoRouter-based navigation for this screen has been replaced
// by a PageView-based navigation for smoother tab interactions.

class NavigationScreen extends ConsumerWidget {
  const NavigationScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const MaterialApp(home: MainScaffold());
  }
}

class MainScaffold extends ConsumerStatefulWidget {
  final Widget? child; // optional, no longer used with PageView
  const MainScaffold({super.key, this.child});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  DateTime? _lastBackPressed;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    final pages = <Widget>[
      const DashboardScreen(),
      const AppointmentScreen(),
      if (authState.isSuperAdmin || authState.isSupervisor) const ClientScreen(),
      if (authState.isSuperAdmin) const CompanyScreen(),
      if (authState.isSuperAdmin || authState.isSupervisor) const SalesScreen(),
      if (authState.isSuperAdmin || authState.isSupervisor) const TeamScreen(),
      const SettingScreen(),
    ];

    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
      const BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Appointment'),
      if (authState.isSuperAdmin || authState.isSupervisor) const BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Clients'),
      if (authState.isSuperAdmin) const BottomNavigationBarItem(icon: Icon(Icons.business_center_outlined), label: 'Company'),
      if (authState.isSuperAdmin || authState.isSupervisor) const BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'User'),
      if (authState.isSuperAdmin || authState.isSupervisor) const BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Team'),
      const BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
    ];

    // Clamp currentIndex to valid range to prevent crash
    final safeIndex = _currentIndex.clamp(0, items.length - 1);

    // Reset index if it was out of bounds
    if (_currentIndex != safeIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          setState(() {
            _currentIndex = safeIndex;
          });
          _pageController.jumpToPage(safeIndex);
        }
      });
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final now = DateTime.now();
        if (_lastBackPressed == null || now.difference(_lastBackPressed!) > const Duration(seconds: 3)) {
          _lastBackPressed = now;
          final messenger = ScaffoldMessenger.of(context);
          messenger.removeCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              backgroundColor: Colors.white,
              content: AppText(label: 'กดอีกครั้งเพื่อออกจากแอป', textAlign: TextAlign.center, textColor: AppUtility.colorRed),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }

        SystemNavigator.pop();
      },
      child: Scaffold(
        body: PageView(controller: _pageController, onPageChanged: (i) => setState(() => _currentIndex = i), children: pages),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: safeIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          items: items,
          onTap: (i) {
            setState(() => _currentIndex = i);
            if (_pageController.hasClients) {
              _pageController.animateToPage(i, duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
            }
          },
        ),
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
