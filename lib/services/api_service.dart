import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/exam_set_model.dart';
import '../models/question_model.dart';

class ApiService {
  // Base URL ของ API คุณ
  static const String baseUrl = 'https://devexamapi.thanaboat.com/api';

  // 1. ดึงชุดข้อสอบทั้งหมด
  static Future<List<ExamSet>> fetchExamSets() async {
    try {
      // 🔧 แก้ไข: เปลี่ยนจาก /exam-sets เป็น /sets ให้ตรงกับ Backend
      final response = await http.get(Uri.parse('$baseUrl/sets'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ExamSet.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load exam sets');
      }
    } catch (e) {
      throw Exception('Error fetching exam sets: $e');
    }
  }

  // 2. ดึงโจทย์ข้อสอบ (อันนี้ถูกแล้ว)
  static Future<List<Question>> fetchQuestions(String examName) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/questions/$examName'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Question.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load questions');
      }
    } catch (e) {
      throw Exception('Error fetching questions: $e');
    }
  }

  // 3. ดึงคอมเมนต์ (อันนี้ถูกแล้ว)
  static Future<List<dynamic>> fetchComments() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/comments'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print("Error fetching comments: $e");
      return [];
    }
  }

  // 4. ส่งคอมเมนต์
  static Future<bool> postComment(String content) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/comments'),
        headers: {'Content-Type': 'application/json'},
        // 🔧 แก้ไข: Backend รอรับ key ชื่อ 'text' ไม่ใช่ 'content'
        body: jsonEncode({'text': content}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error posting comment: $e");
      return false;
    }
  }

  // 5. ดึงประวัติการสอบของผู้ใช้
  static Future<List<dynamic>> fetchUserHistory(String uid) async {
    try {
      // 🔧 แก้ไข: Backend ใช้ route '/all-scores' และ parameter 'user_uid'
      final response = await http.get(
        Uri.parse('$baseUrl/all-scores?user_uid=$uid'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print("Error fetching history: $e");
      return [];
    }
  }

  // 6. ดึง Leaderboard (อันนี้ถูกแล้ว)
  static Future<List<dynamic>> fetchLeaderboard(
    String examName,
    String chapter,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/leaderboard?set_name=$examName&chapter=$chapter'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print("Error fetching leaderboard: $e");
      return [];
    }
  }

  // 7. บันทึกคะแนน (อันนี้ถูกแล้ว)
  static Future<bool> submitScore(
    String examName,
    String chapter,
    int score,
    int totalQuestions,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final token = await user.getIdToken();

      final response = await http.post(
        Uri.parse('$baseUrl/scores'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'set_name': examName,
          'chapter': chapter,
          'score': score,
          'total_questions': totalQuestions,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error submitting score: $e");
      return false;
    }
  }
}
