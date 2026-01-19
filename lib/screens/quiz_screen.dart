import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class QuizScreen extends StatefulWidget {
  final String examName;
  final String title;

  const QuizScreen({super.key, required this.examName, required this.title});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // Data
  List<Question> allQuestions = [];
  List<Question> filteredQuestions = [];
  List<String> chapters = ['All'];
  String selectedChapter = 'All';

  // Quiz State
  bool isLoading = true;
  bool isQuizStarted = false;
  bool isResultShown = false;
  bool isSavingScore = false; // สถานะกำลังบันทึก
  int currentIndex = 0;
  int score = 0;

  // Answer State
  bool isAnswered = false;
  bool isCorrect = false;

  // Temp Answers
  dynamic _userAnswerMC;
  List<int> _userAnswerCheckbox = [];
  Map<int, int> _userAnswerMatching = {};
  Map<int, int> _userAnswerFill = {};
  final TextEditingController _numberController = TextEditingController();

  // Leaderboard
  List<dynamic> leaderboard = [];
  bool isLoadingLeaderboard = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final data = await ApiService.fetchQuestions(widget.examName);
      final uniqueChapters = data.map((q) => q.chapter).toSet().toList()
        ..sort();

      if (mounted) {
        setState(() {
          allQuestions = data;
          chapters = ['All', ...uniqueChapters];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _startQuiz() {
    setState(() {
      if (selectedChapter == 'All') {
        filteredQuestions = List.from(allQuestions);
      } else {
        filteredQuestions = allQuestions
            .where((q) => q.chapter == selectedChapter)
            .toList();
      }

      if (filteredQuestions.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ไม่พบข้อสอบในบทนี้')));
        return;
      }

      currentIndex = 0;
      score = 0;
      isQuizStarted = true;
      isResultShown = false;
      _resetQuestionState();
    });
  }

  void _resetQuestionState() {
    isAnswered = false;
    isCorrect = false;
    _userAnswerMC = null;
    _userAnswerCheckbox = [];
    _userAnswerMatching = {};
    _userAnswerFill = {};
    _numberController.clear();
  }

  void _submitAnswer() {
    final q = filteredQuestions[currentIndex];
    bool correct = false;

    // Logic ตรวจคำตอบ
    if (q.type == 'mc' || q.type == 'mc_image') {
      if (_userAnswerMC == null) return;
      if (q.rawAnswer is int)
        correct = _userAnswerMC == q.rawAnswer;
      else if (q.rawAnswer is List)
        correct = (q.rawAnswer as List).contains(_userAnswerMC);
    } else if (q.type == 'checkbox') {
      if (_userAnswerCheckbox.isEmpty) return;
      final userSorted = [..._userAnswerCheckbox]..sort();
      final ansSorted = List<int>.from(q.rawAnswer)..sort();
      correct = userSorted.toString() == ansSorted.toString();
    } else if (q.type == 'number') {
      if (_numberController.text.trim().isEmpty) return;
      correct = _numberController.text.trim() == q.rawAnswer.toString().trim();
    } else if (q.type == 'matching') {
      if (_userAnswerMatching.length != (q.items?.length ?? 0)) return;
      bool allMatch = true;
      for (int i = 0; i < (q.items?.length ?? 0); i++) {
        if (_userAnswerMatching[i] != q.items![i]['answer']) {
          allMatch = false;
          break;
        }
      }
      correct = allMatch;
    } else if (q.type == 'fill') {
      if (_userAnswerFill.length != (q.items?.length ?? 0)) return;
      bool allCorrect = true;
      final answers = List<int>.from(q.rawAnswer);
      for (int i = 0; i < answers.length; i++) {
        if (_userAnswerFill[i] != answers[i]) {
          allCorrect = false;
          break;
        }
      }
      correct = allCorrect;
    }

    setState(() {
      isAnswered = true;
      isCorrect = correct;
      if (correct) score++;
    });
  }

  void _nextQuestion() async {
    if (currentIndex < filteredQuestions.length - 1) {
      setState(() {
        currentIndex++;
        _resetQuestionState();
      });
    } else {
      await _finishQuiz();
    }
  }

  // ✅ ฟังก์ชันจบเกม (บันทึกคะแนน)
  Future<void> _finishQuiz() async {
    setState(() {
      isResultShown = true;
      isSavingScore = true; // เริ่มหมุนติ้วๆ
    });

    // 1. ส่งคะแนนไป Server
    bool success = await ApiService.submitScore(
      widget.examName,
      selectedChapter,
      score,
      filteredQuestions.length,
    );

    if (mounted) {
      setState(() => isSavingScore = false); // หยุดหมุน
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ บันทึกคะแนนเรียบร้อย!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ บันทึกคะแนนไม่สำเร็จ'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    // 2. โหลด Leaderboard
    setState(() => isLoadingLeaderboard = true);
    final lbData = await ApiService.fetchLeaderboard(
      widget.examName,
      selectedChapter,
    );

    if (mounted) {
      setState(() {
        leaderboard = lbData;
        isLoadingLeaderboard = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: isDark
            ? theme.appBarTheme.backgroundColor
            : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : !isQuizStarted
          ? _buildStartScreen(theme, isDark)
          : isResultShown
          ? _buildResultScreen(theme, isDark)
          : _buildQuizScreen(theme, isDark),
    );
  }

  Widget _buildStartScreen(ThemeData theme, bool isDark) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20),
        color: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "เลือกบทเรียน",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedChapter,
                    isExpanded: true,
                    dropdownColor: theme.cardColor,
                    style: theme.textTheme.bodyMedium,
                    items: chapters
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedChapter = val!),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _startQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(Constants.primaryColorHex),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "เริ่มทำข้อสอบ",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizScreen(ThemeData theme, bool isDark) {
    final q = filteredQuestions[currentIndex];

    bool canSubmit = false;
    if (!isAnswered) {
      if (q.type == 'mc' && _userAnswerMC != null)
        canSubmit = true;
      else if (q.type == 'checkbox' && _userAnswerCheckbox.isNotEmpty)
        canSubmit = true;
      else if (q.type == 'number')
        canSubmit = true;
      else if (q.type == 'matching' &&
          _userAnswerMatching.length == (q.items?.length ?? 0))
        canSubmit = true;
      else if (q.type == 'fill' &&
          _userAnswerFill.length == (q.items?.length ?? 0))
        canSubmit = true;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "ข้อที่ ${currentIndex + 1}/${filteredQuestions.length}",
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "คะแนน: $score",
                style: TextStyle(
                  color: isDark ? Colors.blue.shade200 : Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: (currentIndex + 1) / filteredQuestions.length,
            backgroundColor: isDark
                ? Colors.grey.shade800
                : Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation(
              Color(Constants.primaryColorHex),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            q.text,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),

          if (q.type == 'mc' || q.type == 'mc_image')
            _buildMC(q, theme, isDark),
          if (q.type == 'checkbox') _buildCheckbox(q, theme, isDark),
          if (q.type == 'number') _buildNumber(q, theme, isDark),
          if (q.type == 'matching') _buildMatching(q, theme, isDark),
          if (q.type == 'fill') _buildFill(q, theme, isDark),

          if (isAnswered) _buildExplainBox(q, theme, isDark),

          const SizedBox(height: 30),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: isAnswered
                  ? _nextQuestion
                  : (canSubmit ? _submitAnswer : null),
              style: ElevatedButton.styleFrom(
                backgroundColor: isAnswered ? Colors.blue : Colors.green,
                disabledBackgroundColor: isDark
                    ? Colors.grey.shade800
                    : Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                isAnswered
                    ? (currentIndex == filteredQuestions.length - 1
                          ? "ดูสรุปผล"
                          : "ข้อถัดไป")
                    : "ยืนยันคำตอบ",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMC(Question q, ThemeData theme, bool isDark) {
    return Column(
      children: List.generate(q.choices.length, (index) {
        final choice = q.choices[index];
        bool isSelected = _userAnswerMC == index;

        Color bgColor = isDark ? theme.cardColor : Colors.white;
        Color borderColor = isDark
            ? Colors.grey.shade700
            : Colors.grey.shade300;

        if (isAnswered) {
          bool isCorrectChoice = false;
          if (q.rawAnswer is int)
            isCorrectChoice = (q.rawAnswer == index);
          else if (q.rawAnswer is List)
            isCorrectChoice = (q.rawAnswer as List).contains(index);

          if (isCorrectChoice) {
            bgColor = isDark
                ? Colors.green.withOpacity(0.2)
                : Colors.green.shade100;
            borderColor = Colors.green;
          } else if (isSelected) {
            bgColor = isDark
                ? Colors.red.withOpacity(0.2)
                : Colors.red.shade100;
            borderColor = Colors.red;
          }
        } else if (isSelected) {
          bgColor = isDark ? Colors.blue.withOpacity(0.2) : Colors.blue.shade50;
          borderColor = Colors.blue;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: isAnswered
                ? null
                : () => setState(() => _userAnswerMC = index),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border.all(color: borderColor, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isAnswered
                          ? Colors.transparent
                          : (isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade200),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      String.fromCharCode(65 + index),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      choice,
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCheckbox(Question q, ThemeData theme, bool isDark) {
    return Column(
      children: List.generate(q.choices.length, (index) {
        final choice = q.choices[index];
        bool isSelected = _userAnswerCheckbox.contains(index);
        Color bgColor = isDark ? theme.cardColor : Colors.white;
        Color borderColor = isDark
            ? Colors.grey.shade700
            : Colors.grey.shade300;

        if (isAnswered) {
          if ((q.rawAnswer as List).contains(index)) {
            bgColor = isDark
                ? Colors.green.withOpacity(0.2)
                : Colors.green.shade100;
            borderColor = Colors.green;
          } else if (isSelected) {
            bgColor = isDark
                ? Colors.red.withOpacity(0.2)
                : Colors.red.shade100;
            borderColor = Colors.red;
          }
        } else if (isSelected) {
          bgColor = isDark ? Colors.blue.withOpacity(0.2) : Colors.blue.shade50;
          borderColor = Colors.blue;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: isAnswered
                ? null
                : () => setState(
                    () => isSelected
                        ? _userAnswerCheckbox.remove(index)
                        : _userAnswerCheckbox.add(index),
                  ),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border.all(color: borderColor, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: isAnswered
                        ? borderColor
                        : (isSelected ? Colors.blue : Colors.grey),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      choice,
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNumber(Question q, ThemeData theme, bool isDark) {
    return Column(
      children: [
        TextField(
          controller: _numberController,
          enabled: !isAnswered,
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: "ใส่คำตอบที่นี่",
            suffixText: q.unit,
            filled: true,
            fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        if (isAnswered)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              isCorrect ? "ถูกต้อง! ✅" : "ผิด! คำตอบคือ ${q.rawAnswer}",
              style: TextStyle(
                color: isCorrect ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMatching(Question q, ThemeData theme, bool isDark) {
    return Column(
      children: List.generate(q.items?.length ?? 0, (index) {
        final item = q.items![index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            border: Border.all(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['q'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                isExpanded: true,
                itemHeight: null,
                value: _userAnswerMatching[index],
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: isAnswered
                      ? (_userAnswerMatching[index] == item['answer']
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2))
                      : (isDark ? Colors.grey.shade800 : Colors.grey.shade50),
                ),
                dropdownColor: theme.cardColor,
                hint: Text(
                  "เลือกคำตอบ",
                  style: TextStyle(
                    color: isDark ? Colors.grey : Colors.grey.shade600,
                  ),
                ),
                items: List.generate(q.choices.length, (choiceIdx) {
                  return DropdownMenuItem(
                    value: choiceIdx,
                    child: Text(
                      q.choices[choiceIdx],
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.2),
                    ),
                  );
                }),
                onChanged: isAnswered
                    ? null
                    : (val) =>
                          setState(() => _userAnswerMatching[index] = val!),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFill(Question q, ThemeData theme, bool isDark) {
    return Column(
      children: [
        Column(
          children: List.generate(q.items?.length ?? 0, (index) {
            final item = q.items![index];
            final choiceIdx = _userAnswerFill[index];
            Color boxColor = isDark
                ? Colors.grey.shade800
                : Colors.grey.shade200;
            if (isAnswered) {
              if (choiceIdx == q.rawAnswer[index])
                boxColor = Colors.green.withOpacity(0.3);
              else
                boxColor = Colors.red.withOpacity(0.3);
            }
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(item['text'] ?? '', style: theme.textTheme.bodyMedium),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: isAnswered
                        ? null
                        : () => _showChoiceBottomSheet(q, index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: boxColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.5)),
                      ),
                      child: Text(
                        choiceIdx != null ? q.choices[choiceIdx] : "____",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: choiceIdx != null
                              ? (isDark ? Colors.white : Colors.black)
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        const Divider(),
        const Text(
          "ตัวเลือกที่มี:",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: q.choices
              .map(
                (c) => Chip(
                  label: Text(c),
                  backgroundColor: isDark
                      ? Colors.grey.shade800
                      : Colors.grey.shade100,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  void _showChoiceBottomSheet(Question q, int itemIndex) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: q.choices.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(q.choices[index]),
              onTap: () {
                setState(() => _userAnswerFill[itemIndex] = index);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildExplainBox(Question q, ThemeData theme, bool isDark) {
    if (q.explain == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? Colors.orange.withOpacity(0.1) : Colors.orange.shade50,
        border: Border.all(
          color: isDark
              ? Colors.orange.withOpacity(0.3)
              : Colors.orange.shade200,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "💡 คำอธิบาย:",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
          ),
          const SizedBox(height: 5),
          Text(q.explain!, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  // ✅ 4. แก้ไข: จัดกึ่งกลางหน้าสรุปผล
  Widget _buildResultScreen(ThemeData theme, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // จัดกึ่งกลางแนวตั้ง
                children: [
                  if (isSavingScore)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),

                  Text(
                    "สรุปผลคะแนน",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "$score / ${filteredQuestions.length}",
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.emoji_events, color: Colors.amber),
                            SizedBox(width: 8),
                            Text(
                              "Top Players",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        if (isLoadingLeaderboard)
                          const CircularProgressIndicator()
                        else if (leaderboard.isEmpty)
                          Text(
                            "ยังไม่มีใครทำคะแนนในบทนี้",
                            style: TextStyle(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          )
                        else
                          ...leaderboard
                              .take(5)
                              .map(
                                (player) => ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.person),
                                  ),
                                  title: Text(
                                    player['user_name'] ?? 'Guest',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      "${player['score']} pts",
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      // ✅ สั่งปิดหน้านี้และส่งค่า true กลับไป (บอกหน้าก่อนหน้าว่ามีอะไรอัปเดต)
                      Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: const Text("กลับหน้าหลัก"),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
