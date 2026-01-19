import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// ✅ 1. Import หน้า Splash Screen เข้ามา
import 'screens/splash_screen.dart';
// import 'screens/home_screen.dart'; // ไม่ต้องใช้หน้านี้ใน main แล้ว เพราะ Splash จะเป็นคนเรียก Home เอง

import 'providers/theme_provider.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ดึงค่า themeProvider มาใช้
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'NotStackApp',
      debugShowCheckedModeBanner: false,

      // ผูกค่า themeMode กับ Provider
      themeMode: themeProvider.themeMode,

      // 🌞 Theme สว่าง (คงค่าเดิมของคุณไว้)
      theme: ThemeData(
        brightness: Brightness.light,
        textTheme: GoogleFonts.promptTextTheme(),
        primaryColor: const Color(Constants.primaryColorHex),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey.shade50,
        colorScheme: ColorScheme.fromSwatch(brightness: Brightness.light)
            .copyWith(
              primary: const Color(Constants.primaryColorHex),
              secondary: Colors.blueAccent,
            ),
      ),

      // 🌚 Theme มืด (คงค่าเดิมของคุณไว้)
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        textTheme: GoogleFonts.promptTextTheme(ThemeData.dark().textTheme),
        primaryColor: Colors.blue.shade200,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.fromSwatch(brightness: Brightness.dark)
            .copyWith(
              primary: Colors.blue.shade200,
              secondary: Colors.tealAccent,
              surface: const Color(0xFF1E1E1E),
            ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          foregroundColor: Colors.white,
        ),
      ),

      // ✅ 2. เปลี่ยนจุดเริ่มต้นจาก HomeScreen เป็น SplashScreen
      home: const SplashScreen(),
    );
  }
}
