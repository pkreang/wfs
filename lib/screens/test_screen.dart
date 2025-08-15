import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/models/user_model.dart';
import 'package:wfs/models/userrole_model.dart';
import 'package:wfs/providers/auth_provider.dart';
import 'package:wfs/providers/user_provider.dart';
import 'package:wfs/services/userservice.dart';

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
    final getUserProfileProvider = ref.watch(GetListUser);
    final authState = ref.watch(authProvider);
    final accessToken = authState.accessToken;
    User user = User(
      firstName: "TestName2",
      lastName: "TestLastName2",
      email: "abc1aaa0@mail.com",
      phoneNumber: "0896-525665588",
      hashedPassword:
          "a2ya10a0Uy.Hd3FuJ/k8xdWuwQFoecjJ9eBiIpz6xkE6SowM0643AqlxC7NW",
      managerID: "9E0DC5F7-1FD6-41F3-9137-14711FC510F6",
      userRoleID: "8CFBD382-FA8B-459C-9BCF-6A3FDF66A8D6",
      isActive: true,
      createdBy: "9E0DC5F7-1FD6-41F3-9137-14711FC510F6",
      modifiedBy: "9E0DC5F7-1FD6-41F3-9137-14711FC510F6",

      createdDate: DateTime.now().toUtc().toIso8601String(),
      modifiedDate: DateTime.now().toUtc().toIso8601String(),
      userID: "",
      userRole: null,
    );
    UserService userService = new UserService();
    userService.Add(accessToken.toString(), user);

    return Scaffold(
      appBar: AppBar(title: const Text('Riverpod API Example')),
      body: Center(
        child: getUserProfileProvider.when(
          data: (data) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                data.toList()[0].firstName.toString(),
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
