import 'package:frontend/modules/admin/screens/quiz_questions_management.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/modules/admin/widgets/shared/admin_card_container.dart';
import 'package:frontend/modules/admin/widgets/shared/admin_text_field.dart';
import 'package:flutter/material.dart';

class AddQuizQuestionPage extends StatefulWidget {
  final QuizQuestion? existingQuestion; // null = add, non-null = edit
  final VoidCallback? onCancel;
  final Function(Map<String, dynamic>)? onSave;

  const AddQuizQuestionPage({
    super.key,
    this.existingQuestion,
    this.onCancel,
    this.onSave,
  });

  @override
  State<AddQuizQuestionPage> createState() => _AddQuizQuestionPageState();
}

class _AddQuizQuestionPageState extends State<AddQuizQuestionPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _questionController;
  late String _selectedStatus;
  late List<TextEditingController> _optionControllers;
  late int _correctOptionIndex;

  bool get isEditMode => widget.existingQuestion != null;

  @override
  void initState() {
    super.initState();
    final q = widget.existingQuestion;
    _questionController = TextEditingController(text: q?.question ?? '');
    _selectedStatus = q?.status ?? 'Active';
    _correctOptionIndex = q?.correctOptionIndex ?? 0;
    _optionControllers = q != null
        ? q.options.map((o) => TextEditingController(text: o)).toList()
        : [TextEditingController(), TextEditingController()];
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    setState(() => _optionControllers.add(TextEditingController()));
  }

  void _removeOption(int index) {
    setState(() {
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
      if (_correctOptionIndex >= _optionControllers.length) {
        _correctOptionIndex = _optionControllers.length - 1;
      } else if (_correctOptionIndex == index) {
        _correctOptionIndex = 0;
      }
    });
  }

  void _saveQuestion() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditMode ? "Question Updated!" : "Question Saved!"),
          backgroundColor: AppColors.successGreen,
        ),
      );
      widget.onSave?.call({
        'question': _questionController.text,
        'status': _selectedStatus,
        'options': _optionControllers.map((c) => c.text).toList(),
        'correctOptionIndex': _correctOptionIndex,
      });
      widget.onCancel?.call();
    }
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Reset Form",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to clear all entered information?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              _resetForm();
              Navigator.pop(ctx);
            },
            child: const Text("Reset", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _questionController.clear();
      for (var c in _optionControllers) {
        c.dispose();
      }
      _optionControllers = [TextEditingController(), TextEditingController()];
      _correctOptionIndex = 0;
      _selectedStatus = "Active";
    });
  }

  @override
  Widget build(BuildContext context) {
    // No Scaffold — lives inside AdminLayout
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// BACK BUTTON
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  tooltip: "Back",
                  onPressed: widget.onCancel,
                ),
              ),

              /// TITLE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditMode ? "Edit Quiz Question" : "Add Quiz Question",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Create and manage illness assessment question information",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              /// RESET BUTTON
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                  side: const BorderSide(color: AppColors.primaryColor),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _confirmReset,
                child: const Text("Reset"),
              ),

              const SizedBox(width: 10),

              /// SAVE BUTTON
              ElevatedButton(
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
                onPressed: _saveQuestion,
                child: Text(
                  isEditMode ? "Update" : "Save",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          /// FORM CARD
          AdminCardContainer(
            padding: const EdgeInsets.all(30),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// BASIC INFO SECTION
                  const Text(
                    "Basic Information",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Provide general assessment format details.",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 24),

                  AdminTextField(
                    topLabel: "Question Text",
                    controller: _questionController,
                    maxLines: 3,
                    hintText: "Enter the question text",
                    validator: (v) => v == null || v.isEmpty
                        ? "Please enter a question"
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.primaryColor,
                        width: 1.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.dangerRed),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Divider(color: Color(0xffeeeeee)),
                  const SizedBox(height: 32),

                  /// ANSWER OPTIONS SECTION
                  const Text(
                    "Answer Options",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Add options and select the correct answer by clicking the radio button.",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 24),

                  ...List.generate(_optionControllers.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Radio<int>(
                            value: index,
                            groupValue: _correctOptionIndex,
                            activeColor: AppColors.primaryColor,
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _correctOptionIndex = val);
                              }
                            },
                          ),
                          Expanded(
                            child: AdminTextField(
                              controller: _optionControllers[index],
                              hintText:
                                  "Option ${String.fromCharCode(65 + index)}",
                              validator: (v) => v == null || v.isEmpty
                                  ? "Cannot be empty"
                                  : null,
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppColors.primaryColor,
                                  width: 1.5,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppColors.dangerRed,
                                ),
                              ),
                            ),
                          ),
                          if (_optionControllers.length > 2)
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: AppColors.dangerRed,
                              ),
                              onPressed: () => _removeOption(index),
                              tooltip: "Remove Option",
                            )
                          else
                            const SizedBox(width: 48),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 8),

                  TextButton.icon(
                    onPressed: _addOption,
                    icon: const Icon(Icons.add, color: AppColors.primaryColor),
                    label: const Text(
                      "Add Another Option",
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
