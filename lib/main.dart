import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wfs/widgets/auth_checker.dart';
import 'package:wfs/services/notification_service.dart';

final selectedItemProvider = StateProvider<String?>((ref) => null);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  await NotificationService().initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Win Field Sale',
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue, fontFamily: 'YourFontFamily'),

      debugShowCheckedModeBanner: false,
      home: const AuthChecker(),

      // --------------------
    );
  }
}
