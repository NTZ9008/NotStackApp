import 'package:flutter/material.dart';
import '../models/exam_set_model.dart';
import '../utils/constants.dart';

class QuizCard extends StatelessWidget {
  final ExamSet exam;
  final VoidCallback onTap;

  const QuizCard({super.key, required this.exam, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isReady = exam.status != 'not_ready';
    final theme = Theme.of(context); // ✅ ดึง Theme มาใช้

    // ปรับสีพื้นหลังการ์ดตาม Theme
    final Color cardColor = isReady
        ? theme.cardColor
        : (theme.brightness == Brightness.dark
              ? Colors.grey.shade900
              : Colors.grey.shade200);

    return Card(
      elevation: isReady ? 2 : 0,
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: isReady ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon ด้านซ้าย
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isReady
                      ? Colors.blue.withOpacity(
                          0.1,
                        ) // ใช้ความโปร่งแสงแทนสีตายตัว
                      : Colors.grey.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isReady ? Icons.check_circle : Icons.build,
                  color: isReady
                      ? const Color(Constants.primaryColorHex)
                      : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // ข้อความตรงกลาง
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isReady
                            ? null
                            : Colors.grey, // ถ้าไม่พร้อมให้เป็นสีเทา
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exam.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Badge บอกชั้นปี
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? Colors.white10
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: theme.dividerColor.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        exam.yearLevel == 'general'
                            ? 'All Years'
                            : 'Year ${exam.yearLevel}',
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ลูกศรขวา
              if (isReady)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
