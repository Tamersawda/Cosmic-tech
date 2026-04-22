import 'package:frontend/modules/admin/presentation/screens/quiz/add_quiz_question_page.dart';
import 'package:frontend/core/utils/colors.dart';
import 'package:frontend/core/utils/responsive_data.dart';
import 'package:frontend/modules/admin/presentation/widgets/shared/admin_page_header.dart';
import 'package:flutter/material.dart';

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String status;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.status,
  });
}

class QuizQuestionsManagement extends StatefulWidget {
  const QuizQuestionsManagement({super.key});

  @override
  State<QuizQuestionsManagement> createState() =>
      _QuizQuestionsManagementState();
}

class _QuizQuestionsManagementState extends State<QuizQuestionsManagement> {
  String searchQuery = "";
  bool showAddQuestion = false;
  QuizQuestion? editingQuestion; // null = add mode, non-null = edit mode

  final List<QuizQuestion> mockQuestions = [
    QuizQuestion(
      id: "Q-001",
      question: "How have you been feeling emotionally over the past few days?",
      options: [
        "Calm and peaceful",
        "Mostly okay with occasional stress",
        "Anxious or restless",
        "Overwhelmed",
        "Numb or disconnected",
      ],
      correctOptionIndex: 0,
      status: "Active",
    ),
    QuizQuestion(
      id: "Q-002",
      question: "What best describes your current thoughts?",
      options: [
        "Clear and focused",
        "Slightly distracted",
        "Overthinking frequently",
        "Negative or worrying thoughts",
        "Racing or uncontrollable thoughts",
      ],
      correctOptionIndex: 0,
      status: "Active",
    ),
    QuizQuestion(
      id: "Q-003",
      question: "How would you describe your current energy level?",
      options: [
        "High and motivated",
        "Stable and balanced",
        "Slightly low",
        "Very low or fatigued",
        "Fluctuating a lot",
      ],
      correctOptionIndex: 0,
      status: "Active",
    ),
    QuizQuestion(
      id: "Q-004",
      question: "How connected do you feel with yourself right now?",
      options: [
        "Very connected and aware",
        "Mostly connected",
        "Neutral",
        "Slightly disconnected",
        "Completely disconnected",
      ],
      correctOptionIndex: 0,
      status: "Active",
    ),
    QuizQuestion(
      id: "Q-005",
      question: "How has your sleep been recently?",
      options: [
        "Restful and consistent",
        "Mostly okay",
        "Irregular",
        "Poor quality sleep",
        "Very disturbed or minimal sleep",
      ],
      correctOptionIndex: 0,
      status: "Active",
    ),
    QuizQuestion(
      id: "Q-006",
      question: "What has been your main source of comfort recently?",
      options: [
        "Personal reflection or inner peace",
        "Friends or family",
        "Entertainment (music, shows, etc.)",
        "Distractions (scrolling, gaming, etc.)",
        "I haven't felt much comfort",
      ],
      correctOptionIndex: 0,
      status: "Active",
    ),
    QuizQuestion(
      id: "Q-007",
      question: "Which best describes your current state?",
      options: [
        "Grounded and stable (like a calm earth)",
        "Flowing but steady (like a river)",
        "Drifting and uncertain (like clouds)",
        "Chaotic and intense (like a storm)",
        "Empty or still (like deep space)",
      ],
      correctOptionIndex: 0,
      status: "Active",
    ),
  ];

  List<QuizQuestion> get filteredQuestions {
    if (searchQuery.isEmpty) return mockQuestions;
    return mockQuestions
        .where(
          (q) => q.question.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER — hidden when form is shown
          if (!showAddQuestion) ...[
            AdminPageHeader(
              title: "Quiz Questions Management",
              subtitle: "Manage health assessment quiz questions and answers",
              action: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    editingQuestion = null;
                    showAddQuestion = true;
                  });
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Add Question",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 24),
            _buildFilterBar(),
            const SizedBox(height: 24),
          ],

          /// MAIN CONTENT — swaps between list and form
          Expanded(
            child: showAddQuestion
                ? AddQuizQuestionPage(
                    existingQuestion: editingQuestion,
                    onCancel: () {
                      setState(() {
                        showAddQuestion = false;
                        editingQuestion = null;
                      });
                    },
                    onSave: (data) {
                      setState(() {
                        showAddQuestion = false;
                        editingQuestion = null;
                        // TODO: add/update in list
                      });
                    },
                  )
                : ListView.separated(
                    itemCount: filteredQuestions.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (_, index) =>
                        _buildQuestionCard(filteredQuestions[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    double searchWidth = Responsive.isMobile(context) ? double.infinity : 320;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xfff3f4f6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: searchWidth,
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: "Search question...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              "${filteredQuestions.length} questions",
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuizQuestion question) {
    Color statusColor = question.status == 'Active'
        ? AppColors.successGreen
        : AppColors.mutedText;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  question.question,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.primaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        editingQuestion = question;
                        showAddQuestion = true;
                      });
                    },
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.dangerRed,
                    ),
                    onPressed: () => _confirmDelete(question),
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  question.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'ID: ${question.id}',
                style: const TextStyle(
                  color: AppColors.mutedText,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(height: 1, color: AppColors.borderColor),
          const SizedBox(height: 16),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(question.options.length, (index) {
              bool isCorrect = index == question.correctOptionIndex;
              return Container(
                width: Responsive.isMobile(context) ? double.infinity : 300,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? AppColors.successGreen.withOpacity(0.1)
                      : Colors.white,
                  border: Border.all(
                    color: isCorrect
                        ? AppColors.successGreen
                        : AppColors.borderColor,
                    width: isCorrect ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? AppColors.successGreen
                            : AppColors.inputBg,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + index),
                          style: TextStyle(
                            color: isCorrect
                                ? Colors.white
                                : AppColors.darkText,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        question.options[index],
                        style: TextStyle(
                          color: isCorrect
                              ? AppColors.successGreen
                              : AppColors.darkText,
                          fontWeight: isCorrect
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isCorrect)
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.successGreen,
                        size: 20,
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(QuizQuestion question) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Delete Question",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${question.question}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              // TODO: remove from list
              Navigator.pop(ctx);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
