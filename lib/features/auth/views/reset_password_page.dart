import 'package:flutter/material.dart';

class ResetPasswordPage extends StatefulWidget {
  final String? token;
  const ResetPasswordPage({super.key, this.token});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_image.png',
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _BottomSheetContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Change Password', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _newPasswordController,
                    obscureText: _obscureNew,
                    decoration: InputDecoration(
                      labelText: 'New password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                        onPressed: () => setState(() => _obscureNew = !_obscureNew),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirm new password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const _PasswordGuidelines(),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onResetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE42226),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        elevation: 2,
                      ),
                      child: const Text('Reset Password', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onResetPassword() {
    final newPw = _newPasswordController.text.trim();
    final confirmPw = _confirmPasswordController.text.trim();

    if (newPw.isEmpty || confirmPw.isEmpty) {
      _showMsg('Please fill all fields');
      return;
    }
    if (newPw != confirmPw) {
      _showMsg('Passwords do not match');
      return;
    }
    final score = _passwordScore(newPw);
    if (newPw.length < 6 || score < 3) {
      _showMsg('Password does not meet complexity requirements');
      return;
    }

    // TODO: Hook into backend using widget.token
    _showMsg('Password reset request submitted');
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  int _passwordScore(String pw) {
    bool hasUpper = pw.contains(RegExp(r'[A-Z]'));
    bool hasLower = pw.contains(RegExp(r'[a-z]'));
    bool hasDigit = pw.contains(RegExp(r'\d'));
    bool hasSpecial = pw.contains(RegExp(r'[^A-Za-z0-9]'));
    int categories = 0;
    if (hasUpper) categories++;
    if (hasLower) categories++;
    if (hasDigit) categories++;
    if (hasSpecial) categories++;
    return categories;
  }
}

class _BottomSheetContainer extends StatelessWidget {
  final Widget child;
  const _BottomSheetContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.60;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: double.infinity,
      height: height,
      padding: EdgeInsets.only(bottom: bottomInset > 0 ? 8.0 : 0.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: SingleChildScrollView(physics: const BouncingScrollPhysics(), child: child),
        ),
      ),
    );
  }
}

class _PasswordGuidelines extends StatelessWidget {
  const _PasswordGuidelines();

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(color: Colors.grey.shade700, fontSize: 14);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Password must meet the following complexity requirements:', style: style),
        const SizedBox(height: 8),
        _bullet('Be at least six characters in length.', style),
        _bullet('Contain characters from three of the following four', style),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bullet('Nonalphanumeric characters (e.g., !,@, %,...)', style, bullet: '•'),
              _bullet('Base 10 digits (0-9)', style, bullet: '•'),
              _bullet('English uppercase characters (A-Z)', style, bullet: '•'),
              _bullet('English lowercase characters (a-z)', style, bullet: '•'),
            ],
          ),
        ),
        _bullet('New password is difference with old password.', style),
      ],
    );
  }

  Widget _bullet(String text, TextStyle style, {String bullet = '•'}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$bullet ', style: style),
          Expanded(child: Text(text, style: style)),
        ],
      ),
    );
  }
}

