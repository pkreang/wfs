
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/auth_checker.dart'; 

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