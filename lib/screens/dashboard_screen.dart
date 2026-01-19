import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import 'about_us_screen.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onTabChange;

  const DashboardScreen({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // ignore: unused_local_variable
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // ✅ ใช้สีพื้นหลังตาม Theme
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ================= HERO SECTION =================
            Container(
              padding: const EdgeInsets.fromLTRB(24, 80, 24, 60),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    "NotStackApp",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade200,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "ฝึกทำข้อสอบสาย IT\nแบบเข้าใจจริง",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.prompt(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "ศูนย์รวมข้อสอบ สรุป และเครื่องมือ\nสำหรับนักเรียนสาย IT / DST",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.prompt(
                      fontSize: 16,
                      color: Colors.blueGrey.shade200,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () => onTabChange(1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(Constants.primaryColorHex),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                      shadowColor: Colors.blue.withOpacity(0.5),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "เริ่มทำข้อสอบ",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ================= MENU GRID =================
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "เมนูลัด",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.4,
                    children: [
                      _buildMenuCard(
                        context,
                        icon: Icons.library_books_rounded,
                        label: "คลังข้อสอบ",
                        color: Colors.blue,
                        onTap: () => onTabChange(1),
                      ),
                      _buildMenuCard(
                        context,
                        icon: Icons.chat_bubble_rounded,
                        label: "พูดคุย",
                        color: Colors.indigo,
                        onTap: () => onTabChange(2),
                      ),
                      _buildMenuCard(
                        context,
                        icon: Icons.person_rounded,
                        label: "โปรไฟล์ของฉัน",
                        color: Colors.teal,
                        onTap: () => onTabChange(3),
                      ),
                      _buildMenuCard(
                        context,
                        icon: Icons.info_outline_rounded,
                        label: "เกี่ยวกับเรา",
                        color: Colors.orange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AboutUsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          // ✅ ปรับสีพื้นหลัง Card
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
