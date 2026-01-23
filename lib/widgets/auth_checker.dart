import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/models/user_model.dart';
import 'package:wfs/screens/navigation_screen.dart';
import 'package:wfs/features/pin/views/pin_code_screen.dart';
import 'package:wfs/features/pin/viewmodels/pin_viewmodel.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';

final userPinCheckProvider = FutureProvider.autoDispose<User?>((ref) async {
  const storage = FlutterSecureStorage();
  final tokenExpiry = await storage.read(key: 'token_expiry');
  if (tokenExpiry != null) {
    try {
      final expiryDate = DateTime.parse(tokenExpiry);
      if (DateTime.now().isAfter(expiryDate)) {
        await storage.delete(key: 'access_token');
        await storage.delete(key: 'user_id');
        await storage.delete(key: 'token_type');
        await storage.delete(key: 'token_expiry');
        await storage.delete(key: 'user_data');

        return null;
      }
    } catch (e) {
      print('Error parsing token expiry: $e');
    }
  }

  // Check user from storage first (even if not authenticated)
  final userStorage = await ref.read(pinServiceProvider).getUser();
  print('userStorage: ${jsonEncode(userStorage)}');

  if (userStorage != null && (userStorage.pincode ?? '').isNotEmpty) {
    return userStorage;
  }

  final authState = ref.read(authProvider);

  // If not authenticated and no storage, return null (show login screen)
  if (!authState.isAuthenticated) {
    return null;
  }

  if ((authState.pincode ?? '').isEmpty && (authState.userID ?? '').isNotEmpty) {
    try {
      final user = await ref.read(userServiceProvider).getByID(authState.accessToken, authState.userID!);
      if ((user.pincode ?? '').isNotEmpty) {
        await ref.read(pinServiceProvider).saveUser(user);
      }

      return user;
    } catch (e) {
      print('Error loading user: $e');
      return null;
    }
  }

  return null;
});

class AuthChecker extends ConsumerWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    print('AuthChecker build called');

    final userAsync = ref.watch(userPinCheckProvider);
    return userAsync.when(
      data: (user) {
        if (user == null && !authState.isAuthenticated) {
          return const LoginScreen();
        }

        if ((user?.pincode ?? '').isNotEmpty) {
          return PinCodeScreen(
            mode: PinMode.verify,
            title: 'กรอก PIN ของคุณ',
            subtitle: 'กรอก PIN 6 หลัก เพื่อเข้าถึงแอปพลิเคชัน',
            onSuccess: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const NavigationScreen()));
            },
          );
        }

        if (authState.isAuthenticated && (authState.pincode ?? '').isEmpty) {
          return PinCodeScreen(
            mode: PinMode.create,
            title: 'สร้าง PIN ของคุณ',
            subtitle: 'ตั้งค่า PIN 6 หลัก เพื่อความปลอดภัย',
            onSuccess: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const NavigationScreen()));
            },
          );
        }

        if (authState.isAuthenticated && (authState.pincode ?? '').isNotEmpty) {
          return const NavigationScreen();
        }

        return const LoginScreen();
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) {
        print('Error in userPinCheckProvider: $error');
        return const LoginScreen();
      },
    );
  }
}
