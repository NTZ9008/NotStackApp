import 'package:flutter/material.dart';
// ignore: unused_import
import 'dart:math'; // เอาไว้สุ่มสี Avatar
import '../services/api_service.dart';
// ignore: unused_import
import '../utils/constants.dart';

class CommentScreen extends StatefulWidget {
  const CommentScreen({super.key});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _comments = [];
  bool _isLoading = true;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    try {
      final comments = await ApiService.fetchComments();
      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching comments: $e");
    }
  }

  Future<void> _handlePost() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _isPosting = true);
    final success = await ApiService.postComment(_controller.text.trim());
    if (mounted) {
      setState(() => _isPosting = false);
      if (success) {
        _controller.clear();
        _fetchComments();
        FocusScope.of(context).unfocus();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ส่งข้อความไม่สำเร็จ')));
      }
    }
  }

  // ฟังก์ชันสุ่มสี Avatar ให้ดูมีลูกเล่น
  Color _getAvatarColor(int index) {
    final colors = [
      Colors.red.shade200,
      Colors.blue.shade200,
      Colors.green.shade200,
      Colors.orange.shade200,
      Colors.purple.shade200,
      Colors.teal.shade200,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.forum_rounded, size: 24),
            SizedBox(width: 10),
            Text('Anonymous Chat'),
          ],
        ),
        backgroundColor: isDark
            ? theme.appBarTheme.backgroundColor
            : Colors.indigo.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        // พื้นหลังแบบมีสไตล์
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
        ),
        child: Column(
          children: [
            // --- พื้นที่แสดงแชท ---
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _fetchComments,
                      child: _comments.isEmpty
                          ? ListView(
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.3,
                                ),
                                Icon(
                                  Icons.mark_chat_unread_rounded,
                                  size: 80,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                const Center(
                                  child: Text(
                                    "ยังไม่มีข้อความ\nเป็นคนแรกที่เริ่มบทสนทนาสิ!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 20,
                              ),
                              itemCount: _comments.length,
                              itemBuilder: (context, index) {
                                final item = _comments[index];
                                return _buildChatBubble(
                                  item,
                                  index,
                                  theme,
                                  isDark,
                                );
                              },
                            ),
                    ),
            ),

            // --- ช่องพิมพ์ข้อความ (Floating Style) ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _controller,
                          style: theme.textTheme.bodyMedium,
                          decoration: InputDecoration(
                            hintText: 'พิมพ์ข้อความ...',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            isDense: true,
                          ),
                          minLines: 1,
                          maxLines: 3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _isPosting ? null : _handlePost,
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.blueAccent, Colors.indigoAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _isPosting
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(
    dynamic item,
    int index,
    ThemeData theme,
    bool isDark,
  ) {
    final avatarColor = _getAvatarColor(index);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar (Random Color)
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: avatarColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),

          // Chat Bubble
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? theme.cardColor : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.zero, // มุมแหลมชี้ไปหาคนพูด
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                        blurRadius: 6,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    item['content'] ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40), // เว้นที่ขวาให้ดูไม่เต็มเกินไป
        ],
      ),
    );
  }
}
