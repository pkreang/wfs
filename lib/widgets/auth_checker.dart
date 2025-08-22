import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/screens/%E0%B8%B7navigation_screen.dart';
import 'package:wfs/screens/main_navigation_screen.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';

class AuthChecker extends ConsumerWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isAuthenticated) {
      return const NavigationScreen();
    } else {
      return const LoginScreen();
    }
  }
}
