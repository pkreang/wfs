import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/models/company_model.dart';
import 'package:wfs/models/user_model.dart';
import 'package:wfs/providers/appointment_provider.dart';

import 'package:wfs/providers/auth_provider.dart';
import 'package:wfs/providers/user_provider.dart';
import 'package:wfs/providers/userrole_provider.dart';
import 'package:wfs/services/company_service.dart';
import 'package:wfs/services/user_service.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Riverpod API Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentGetByIdProviderState = ref.watch(
      appointmentGetSummaryProvider("2025-08-14"),
    );
    final authState = ref.watch(authProvider);
    final accessToken = authState.accessToken;

    return Scaffold(
      appBar: AppBar(title: const Text('Riverpod API Example')),
      body: Center(
        child: appointmentGetByIdProviderState.when(
          data: (data) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                data.toList()[0].companyName.toString(),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: () => ref.refresh(activityProvider),
              //   child: const Text('โหลดใหม่'),
              // )
            ],
          ),
          loading: () => const CircularProgressIndicator(),
          error: (err, stack) => Text('เกิดข้อผิดพลาด: $err'),
        ),
      ),
    );
  }
}
