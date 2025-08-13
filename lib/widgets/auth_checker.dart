

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/login_screen.dart';

class AuthChecker extends ConsumerWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
 
    final authState = ref.watch(authProvider);


    if (authState.isAuthenticated) {
      return const MainNavigationScreen();
    } else {
      return const LoginScreen();
    }
  }
}