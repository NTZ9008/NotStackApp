import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isSigningIn = false;
  Future<List<dynamic>>? _historyFuture; // ตัวแปรเก็บ Future

  @override
  void initState() {
    super.initState();
    // เริ่มต้นเรายังไม่โหลดที่นี่ รอไปโหลดตอนได้ user ใน StreamBuilder ก็ได้
    // หรือจะโหลดเลยถ้ามี user อยู่แล้ว
    if (FirebaseAuth.instance.currentUser != null) {
      _refreshHistory();
    }
  }

  // ฟังก์ชันโหลดข้อมูล (ใช้ setState ได้ เพราะเรียกจาก Event)
  void _refreshHistory() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // ถ้าอยู่นอก build phase ให้ setState
      // แต่ถ้าเรียกใน build (เช่น FutureBuilder) ห้ามใช้ setState
      if (mounted) {
        setState(() {
          _historyFuture = ApiService.fetchUserHistory(user.uid);
        });
      } else {
        _historyFuture = ApiService.fetchUserHistory(user.uid);
      }
    }
  }

  void _handleGoogleSignIn() async {
    setState(() => _isSigningIn = true);
    final user = await AuthService().signInWithGoogle();

    if (mounted) {
      setState(() => _isSigningIn = false);
      if (user != null) {
        _refreshHistory(); // โหลดข้อมูลใหม่เมื่อ login
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('เข้าสู่ระบบไม่สำเร็จ')));
      }
    }
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text("เลือกธีม"),
          children: [
            _buildRadioOption(
              context,
              themeProvider,
              "ตามระบบ (System)",
              ThemeMode.system,
            ),
            _buildRadioOption(
              context,
              themeProvider,
              "โหมดสว่าง (Light)",
              ThemeMode.light,
            ),
            _buildRadioOption(
              context,
              themeProvider,
              "โหมดมืด (Dark)",
              ThemeMode.dark,
            ),
          ],
        );
      },
    );
  }

  Widget _buildRadioOption(
    BuildContext context,
    ThemeProvider provider,
    String title,
    ThemeMode value,
  ) {
    return RadioListTile<ThemeMode>(
      title: Text(title),
      value: value,
      groupValue: provider.themeMode,
      onChanged: (ThemeMode? newValue) {
        if (newValue != null) {
          provider.setTheme(newValue);
          Navigator.pop(context);
        }
      },
      activeColor: const Color(Constants.primaryColorHex),
    );
  }

  String _getThemeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return "โหมดสว่าง (Light)";
      case ThemeMode.dark:
        return "โหมดมืด (Dark)";
      case ThemeMode.system:
        return "ตามระบบ (System)";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ตั้งค่าและบัญชี'),
        centerTitle: true,
        backgroundColor: isDark
            ? theme.appBarTheme.backgroundColor
            : Colors.indigo.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      // RefreshIndicator ครอบเพื่อให้ลากลงเพื่อโหลดใหม่ได้
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshHistory();
          // รอให้ Future เสร็จสิ้นเพื่อปิด loading indicator ของ RefreshIndicator
          if (_historyFuture != null) await _historyFuture;
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "การแสดงผล",
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  ),
                ),
                color: theme.cardColor,
                child: ListTile(
                  leading: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: isDark ? Colors.yellow : Colors.grey,
                  ),
                  title: const Text("ธีมแอปพลิเคชัน"),
                  subtitle: Text(_getThemeText(themeProvider.themeMode)),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                  onTap: () => _showThemeDialog(context, themeProvider),
                ),
              ),
              const SizedBox(height: 30),

              Text(
                "บัญชีผู้ใช้",
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),

              StreamBuilder<User?>(
                stream: AuthService().authStateChanges,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final user = snapshot.data;
                  if (user != null) {
                    // ✅ แก้ไขจุดที่ Error:
                    // ถ้ายังไม่มี Future ให้กำหนดค่าตรงๆ (ห้ามใช้ setState ใน build)
                    if (_historyFuture == null) {
                      _historyFuture = ApiService.fetchUserHistory(user.uid);
                    }

                    return _buildUserProfile(user, theme);
                  }
                  // ถ้าไม่มี user ให้เคลียร์ history future ทิ้ง
                  _historyFuture = null;
                  return _buildLoginCard(theme);
                },
              ),

              const SizedBox(height: 40),

              Center(
                child: FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    String versionText = "Loading...";
                    if (snapshot.hasData) {
                      versionText =
                          "v${snapshot.data!.version} build ${snapshot.data!.buildNumber} beta";
                    }
                    return Column(
                      children: [
                        Text(
                          "NotStackApp $versionText",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Designed by NotStack Team",
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.blue.withOpacity(0.2)
                  : Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_person_rounded,
              size: 40,
              color: Color(Constants.primaryColorHex),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "เข้าสู่ระบบเพื่อดูประวัติ",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "บันทึกคะแนนสอบและดูสถิติย้อนหลังได้ทันที",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 45,
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
                _isSigningIn ? "กำลังเชื่อมต่อ..." : "เข้าสู่ระบบด้วย Google",
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(Constants.primaryColorHex),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile(User user, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(
                  user.photoURL ?? 'https://via.placeholder.com/150',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName ?? "User",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.email ?? "",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  AuthService().signOut();
                  // เคลียร์ history เมื่อ logout
                  setState(() {
                    _historyFuture = null;
                  });
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                tooltip: "ออกจากระบบ",
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "🕒 ประวัติการทำข้อสอบล่าสุด",
            style: TextStyle(
              color: theme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // แสดงประวัติจาก Future
        FutureBuilder(
          future: _historyFuture,
          builder: (context, apiSnapshot) {
            if (apiSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (apiSnapshot.hasError) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Text(
                  "เกิดข้อผิดพลาดในการโหลดข้อมูล: ${apiSnapshot.error}",
                  textAlign: TextAlign.center,
                ),
              );
            }

            final history = apiSnapshot.data ?? [];
            if (history.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 40,
                      color: isDark
                          ? Colors.grey.shade600
                          : Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "ยังไม่มีประวัติการสอบ",
                      style: TextStyle(
                        color: isDark ? Colors.grey.shade400 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  color: theme.cardColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.assignment_turned_in,
                        color: Colors.blue,
                      ),
                    ),
                    title: Text(
                      item['set_name'] ?? 'Unknown',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "Chapter: ${item['chapter'] ?? '-'}",
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        "${item['score']} / ${item['total_questions']}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
