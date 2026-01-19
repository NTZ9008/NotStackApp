import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // 1. ลดระยะเวลาลงเล็กน้อยเพื่อความกระชับ (1.2 วิ)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // 2. เอฟเฟกต์ Scale: เด้งดึ๋งเล็กน้อย (YouTube สไตล์)
    // เริ่มจากเล็กนิดนึง (0.5) ไปขนาดจริง (1.0)
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    // 3. เอฟเฟกต์ Fade: ค่อยๆ ชัดขึ้น
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // เริ่ม Animation
    _controller.forward();

    // 4. นับเวลาเปลี่ยนหน้า (ใช้ Timer เดียวจบ ไม่วนลูป)
    Timer(const Duration(seconds: 2), () {
      if (mounted) navigateNext();
    });
  }

  // ✅ Pre-cache รูปภาพ เพื่อป้องกันภาพกระพริบตอนโหลดครั้งแรก
  @override
  void didChangeDependencies() {
    precacheImage(const AssetImage('assets/N.png'), context);
    super.didChangeDependencies();
  }

  void navigateNext() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        // ใช้ FadeTransition ตอนเปลี่ยนหน้า เพื่อความเนียนแบบ YouTube
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: Center(
        child: FadeTransition(
          // ใช้ GPU
          opacity: _opacityAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- โลโก้ (Scale Animation) ---
              ScaleTransition(
                // ใช้ GPU
                scale: _scaleAnimation,
                child: Image.asset(
                  'assets/N.png',
                  width: 100, // กำหนดขนาดให้ชัดเจน ช่วยลด load layout
                  height: 100,
                ),
              ),

              const SizedBox(height: 20),

              // --- ชื่อแอป (แค่ Fade มาพร้อมกัน ไม่ต้องพิมพ์ทีละตัว) ---
              Text(
                'NotStackApp',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                  letterSpacing: 1.2, // เพิ่มระยะห่างตัวอักษรให้ดู Modern
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
