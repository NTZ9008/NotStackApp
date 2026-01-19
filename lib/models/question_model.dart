class Question {
  final int id;
  final String text; // ตัวโจทย์ (q)
  final String type; // mc, checkbox, number, fill, matching
  final String chapter; // ✅ เพิ่ม: สำหรับกรองบทเรียน
  final List<String> choices; 
  final dynamic rawAnswer; // ✅ เพิ่ม: เก็บคำตอบดิบ (int, List<int>, String) ไว้เช็ค Logic
  final List<String> correctAnswers; // คำตอบที่แปลงเป็น String แล้ว
  final String? explain;
  final String? unit; // ✅ เพิ่ม: สำหรับโจทย์ประเภท Number
  final List<dynamic>? items; // ✅ เพิ่ม: สำหรับโจทย์ Matching/Fill

  Question({
    required this.id,
    required this.text,
    required this.type,
    required this.chapter,
    required this.choices,
    required this.rawAnswer,
    required this.correctAnswers,
    this.explain,
    this.unit,
    this.items,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    var choicesList = <String>[];
    if (json['choices'] != null) {
      choicesList = List<String>.from(json['choices']);
    }

    // แปลงคำตอบให้เป็น List<String> เสมอ เพื่อความง่ายในการเช็คเบื้องต้น
    var answersList = <String>[];
    if (json['answer'] != null) {
      if (json['answer'] is List) {
        answersList = List<String>.from(json['answer'].map((e) => e.toString()));
      } else {
        answersList = [json['answer'].toString()];
      }
    }

    return Question(
      id: json['id'],
      text: json['q'] ?? '',
      type: json['type'] ?? 'mc',
      chapter: json['chapter']?.toString() ?? 'General', // ✅ ดึง Chapter
      choices: choicesList,
      rawAnswer: json['answer'], // ✅ เก็บค่าดิบ
      correctAnswers: answersList,
      explain: json['explain'],
      unit: json['unit'],
      items: json['items'],
    );
  }
}