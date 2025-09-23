import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wfs/providers/auth_provider.dart';
import 'package:wfs/screens/appointment_screen.dart';
import 'package:wfs/features/client/views/client_list_page.dart';
import 'package:wfs/features/company/views/company_list_page.dart';
import 'package:wfs/screens/dashboard_screen.dart';
import 'package:wfs/screens/test_screen.dart';

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
          GoRoute(path: '/appointment', builder: (context, state) => const AppointmentScreen()),
          GoRoute(path: '/clients', builder: (context, state) => const ClientScreen()),
          GoRoute(path: '/company', builder: (context, state) => const CompanyScreen()),
          GoRoute(path: '/test', builder: (context, state) => const TestScreen()),
        ],
      ),
    ],
  );
});

class NavigationScreen extends ConsumerWidget {
  const NavigationScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(routerConfig: router);
  }
}

class MainScaffold extends ConsumerStatefulWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _currentIndex = 0;

  final tabs = ['/dashboard', '/appointment', '/clients', '/company', '/sale'];

  @override
  Widget build(BuildContext context) {
    final location = GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();
    if (location.startsWith('/dashboard')) _currentIndex = 0;
    if (location.startsWith('/appointment'))
      _currentIndex = 1;
    else if (location.startsWith('/clients'))
      _currentIndex = 2;
    else if (location.startsWith('/company'))
      _currentIndex = 3;
    else if (location.startsWith('/test'))
      _currentIndex = 4;

    final authState = ref.watch(authProvider);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (!authState.isSuperAdmin && (index == 2 || index == 3)) {
            return;
          }

          ref.read(routerProvider).go(tabs[index]);
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Appointment'),
          if (authState.isSuperAdmin) BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Clients'),
          if (authState.isSuperAdmin) BottomNavigationBarItem(icon: Icon(Icons.business_center_outlined), label: 'Company'),
          /*BottomNavigationBarItem(
            icon: Icon(Icons.settings), 
            label: 'Test'),*/
        ],
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
