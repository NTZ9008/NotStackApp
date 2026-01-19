import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/exam_set_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/quiz_card.dart';
import 'quiz_screen.dart';
import 'login_screen.dart';

class ExamListScreen extends StatefulWidget {
  const ExamListScreen({super.key});

  @override
  State<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends State<ExamListScreen> {
  late Future<List<ExamSet>> futureExams;
  String selectedYear = 'All';

  @override
  void initState() {
    super.initState();
    futureExams = ApiService.fetchExamSets();
  }

  Future<void> _refreshExams() async {
    setState(() {
      futureExams = ApiService.fetchExamSets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!authSnapshot.hasData) {
          return const LoginScreen();
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text('เลือกชุดข้อสอบ'),
            centerTitle: true,
            backgroundColor: isDark
                ? theme.appBarTheme.backgroundColor
                : Colors.indigo.shade900,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Column(
            children: [
              // --- Filter Section ---
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: ['All', '1', '2', '3', '4'].map((year) {
                      final isSelected = selectedYear == year;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(year == 'All' ? 'ทั้งหมด' : 'ปี $year'),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => selectedYear = year);
                          },
                          selectedColor: Colors.blue.shade100,
                          backgroundColor: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade100,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.blue.shade800
                                : (isDark
                                      ? Colors.grey.shade300
                                      : Colors.black87),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.transparent
                                  : (isDark
                                        ? Colors.grey.shade700
                                        : Colors.grey.shade300),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // --- List Section ---
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshExams,
                  child: FutureBuilder<List<ExamSet>>(
                    future: futureExams,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            'ไม่พบชุดข้อสอบ',
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        );
                      }

                      final allExams = snapshot.data!;

                      // ✅ กรองข้อมูล: ปี + สถานะ
                      final filteredExams = allExams.where((e) {
                        final matchesYear =
                            selectedYear == 'All' ||
                            e.yearLevel == selectedYear;

                        // Debug: ปริ้นท์ค่า status ออกมาดูถ้ามันไม่โชว์
                        // print("Exam: ${e.name}, Status: ${e.status}, MatchYear: $matchesYear");

                        // กรองเฉพาะ ACTIVE (ที่แปลงเป็นตัวใหญ่จาก Model แล้ว)
                        final isActive = e.status == 'ACTIVE';

                        return matchesYear && isActive;
                      }).toList();

                      if (filteredExams.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.layers_clear,
                                size: 48,
                                color: isDark
                                    ? Colors.grey.shade600
                                    : Colors.grey,
                              ),
                              const SizedBox(height: 8),
                              // แสดงข้อความเพิ่มเติมเพื่อให้รู้ว่าทำไมถึงไม่เจอ
                              Text(
                                'ไม่พบข้อสอบที่เปิดใช้งาน \nสำหรับปี $selectedYear',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredExams.length,
                        itemBuilder: (context, index) {
                          final exam = filteredExams[index];
                          return QuizCard(
                            exam: exam,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QuizScreen(
                                    examName: exam.name,
                                    title: exam.title,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
