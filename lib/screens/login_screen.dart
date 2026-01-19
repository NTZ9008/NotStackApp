import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSigningIn = false;

  void _handleGoogleSignIn() async {
    setState(() => _isSigningIn = true);
    final user = await AuthService().signInWithGoogle();

    if (mounted) {
      setState(() => _isSigningIn = false);
      if (user != null) {
        print("Login Success: ${user.displayName}");
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('เข้าสู่ระบบไม่สำเร็จ')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_person_rounded,
                  size: 60,
                  color: Color(Constants.primaryColorHex),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "เข้าสู่ระบบ",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "เข้าสู่ระบบเพื่อดูประวัติคะแนน\nและบันทึกผลการสอบของคุณ",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSigningIn ? null : _handleGoogleSignIn,
                  icon: _isSigningIn
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.login),
                  label: Text(
                    _isSigningIn
                        ? "กำลังเชื่อมต่อ..."
                        : "เข้าสู่ระบบด้วย Google",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(Constants.primaryColorHex),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
