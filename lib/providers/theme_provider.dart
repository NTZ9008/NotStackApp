import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // ค่าเริ่มต้น: ตามระบบ

  ThemeMode get themeMode => _themeMode;

  // เช็คว่าเป็นโหมดมืดหรือไม่ (สำหรับใช้ตรวจสอบใน UI)
  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  ThemeProvider() {
    _loadTheme();
  }

  // ✅ ฟังก์ชันเปลี่ยน Theme (รับค่า 3 แบบ)
  void setTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    // บันทึกค่าลงเครื่องเป็น String
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_preference', mode.toString());
  }

  // โหลดค่าเดิม
  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('theme_preference');

    if (themeString != null) {
      if (themeString == ThemeMode.light.toString()) {
        _themeMode = ThemeMode.light;
      } else if (themeString == ThemeMode.dark.toString()) {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.system;
      }
      notifyListeners();
    }
  }
}
