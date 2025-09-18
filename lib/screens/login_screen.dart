import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/models/auth_model.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).clearError();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ฟัง error จาก authProvider
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login Failed: ${next.error}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    });

    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_image.png', // เพิ่มรูปภาพพื้นหลังที่นี่
              fit: BoxFit.cover,
            ),
          ),
          Align(
            // Use Align to position the SingleChildScrollView at the bottom
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0), // Remove horizontal padding here
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Remove SizedBox(height: MediaQuery.of(context).size.height * 0.3)
                    // The Align widget will handle positioning the form at the bottom.
                    Container(
                      width: double.infinity, // Make the container take full width
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)), // Only top corners are rounded
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, -2), // Adjust offset for shadow to be on top
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch, // Change to stretch
                        children: [
                          const Text('Welcome!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const SizedBox(height: 32),

                          // Email
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: const BorderSide(
                                  color: Colors.blue, // สามารถปรับสีได้
                                  width: 2,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            onSubmitted: (_) => _performLogin(),
                          ),
                          const SizedBox(height: 16),

                          // Password
                          TextField(
                            controller: passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: const BorderSide(
                                  color: Colors.blue, // สามารถปรับสีได้
                                  width: 2,
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.grey, // ทำให้ icon เป็นสีเทา
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            onSubmitted: (_) => _performLogin(),
                          ),
                          const SizedBox(height: 32),

                          // ปุ่ม Login
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: authState.isLoading ? null : _performLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE42226), // เปลี่ยนสีปุ่มเป็น #E42226
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                elevation: 2,
                              ),
                              child: authState.isLoading
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text(
                                      'Login',
                                      style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Error display
                          if (authState.error != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(authState.error!, style: TextStyle(color: Colors.red.shade700, fontSize: 14)),
                                  ),
                                ],
                              ),
                            ),

                          // Align(
                          //   alignment: Alignment.center,
                          //   child: TextButton(
                          //     onPressed: () {
                          //       // TODO: Implement forgot password
                          //     },
                          //     child: const Text('Forgot password?'),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _performLogin() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    // email = "systemadmin@mail.com";
    // password = "abcd1234";

    // email = "Sup01@mail.com";
    // // email = "sale01@mail.com";
    // password = "abcd1234";

    //email = "john@mail.com";
    //password = "abcd1234";
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter both email and password'), backgroundColor: Colors.orange));
      return;
    }
    ref.read(authProvider.notifier).login(email, password);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
