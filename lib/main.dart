import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/widgets/auth_checker.dart';

final selectedItemProvider = StateProvider<String?>((ref) => null);
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Win Field Sale',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'YourFontFamily',
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthChecker(),
      // --------------------
    );
  }
}

// void main() {
//   runApp(const ProviderScope(child: MyApp()));
// }

// final routerProvider = Provider<GoRouter>((ref) {
//   return GoRouter(
//     initialLocation: '/dashboard',
//     routes: [
//       ShellRoute(
//         builder: (context, state, child) {
//           return MainScaffold(child: child); // Scaffold หลัก
//         },
//         routes: [
//           GoRoute(
//             path: '/dashboard',
//             builder: (context, state) => const DashboardScreen(),
//           ),
//           GoRoute(
//             path: '/clients',
//             builder: (context, state) => const ClientScreen(),
//           ),
//           GoRoute(
//             path: '/company',
//             builder: (context, state) => const CompanyScreen(),
//           ),
//           GoRoute(
//             path: '/test',
//             builder: (context, state) => const TestScreen(),
//           ),
//         ],
//       ),
//     ],
//   );
// });

// /// 2️⃣ MaterialApp.router
// class MyApp extends ConsumerWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final router = ref.watch(routerProvider);
//     return MaterialApp.router(routerConfig: router);
//   }
// }

// /// 3️⃣ Scaffold หลัก + BottomNavigationBar
// class MainScaffold extends ConsumerStatefulWidget {
//   final Widget child;
//   const MainScaffold({super.key, required this.child});

//   @override
//   ConsumerState<MainScaffold> createState() => _MainScaffoldState();
// }

// class _MainScaffoldState extends ConsumerState<MainScaffold> {
//   int _currentIndex = 0;

//   final tabs = ['/dashboard', '/clients', '/company', '/test'];

//   @override
//   Widget build(BuildContext context) {
//     // sync index กับ path ของ go_router
//     final location = GoRouter.of(
//       context,
//     ).routerDelegate.currentConfiguration.uri.toString();
//     if (location.startsWith('/dashboard'))
//       _currentIndex = 0;
//     else if (location.startsWith('/clients'))
//       _currentIndex = 1;
//     else if (location.startsWith('/company'))
//       _currentIndex = 2;
//     else if (location.startsWith('/test'))
//       _currentIndex = 3;

//     return Scaffold(
//       body: widget.child,
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: Colors.blue,
//         unselectedItemColor: Colors.grey,
//         onTap: (index) {
//           ref.read(routerProvider).go(tabs[index]);
//         },
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.dashboard),
//             label: 'Dashboard',
//           ),
//           BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Clients'),
//           BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Company'),
//           BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Test'),
//         ],
//       ),
//     );
//   }
// }
