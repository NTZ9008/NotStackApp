class ExamSet {
  final int id;
  final String name;
  final String title;
  final String description;
  final String status;
  final String yearLevel;

  ExamSet({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.status,
    required this.yearLevel,
  });

  factory ExamSet.fromJson(Map<String, dynamic> json) {
    // 1. ดึงค่า status ดิบออกมา แล้วทำเป็นตัวพิมพ์เล็กให้หมดก่อน
    String rawStatus =
        json['status']?.toString().toLowerCase().trim() ?? 'closed';

    // 2. เช็คเงื่อนไข: ถ้าเป็น 'open' หรือ 'active' ให้ถือว่าเป็น ACTIVE
    String normalizedStatus = 'CLOSED'; // ค่าเริ่มต้น
    if (rawStatus == 'open' || rawStatus == 'active') {
      normalizedStatus = 'ACTIVE';
    }

    return ExamSet(
      id: json['id'],
      name: json['name'] ?? '',
      title: json['title'] ?? 'No Title',
      description:
          (json['sub_description'] != null &&
              json['sub_description'].toString().trim().isNotEmpty)
          ? json['sub_description']
          : json['description'] ?? '',

      // ✅ ใช้ค่าที่แปลงแล้ว (ACTIVE / CLOSED)
      status: normalizedStatus,

      yearLevel: json['year_level']?.toString() ?? 'general',
    );
  }
}
