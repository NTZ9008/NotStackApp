import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'dashboard_screen.dart';
import 'exam_list_screen.dart';
import 'comment_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // ignore: unused_field
  final List<Widget> _screens = [
    DashboardScreen(onTabChange: (index) {}), // (ต้องใส่ฟังก์ชัน dummy หรือส่ง function จริงถ้าต้องการ)
    const ExamListScreen(),
    const CommentScreen(),
    const ProfileScreen(),
  ];

  // แก้ไขเพื่อให้ Dashboard ส่งค่ากลับมาเปลี่ยน Tab ได้จริง
  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ส่ง _changeTab เข้าไปใหม่เพื่อให้ปุ่มใน Dashboard ทำงาน
    final List<Widget> screensWithFunction = [
      DashboardScreen(onTabChange: _changeTab),
      const ExamListScreen(),
      const CommentScreen(),
      const ProfileScreen(),
    ];

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screensWithFunction,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _changeTab,
          type: BottomNavigationBarType.fixed,
          // ✅ ปรับสีพื้นหลัง Nav Bar
          backgroundColor: theme.cardColor, 
          selectedItemColor: const Color(Constants.primaryColorHex),
          // ✅ ปรับสีไอคอนตอนไม่ได้เลือก
          unselectedItemColor: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'หน้าหลัก'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment_rounded), label: 'ข้อสอบ'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded), label: 'พูดคุย'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'โปรไฟล์'),
          ],
        ),
      ),
    );
  }
}