import 'package:frontend/modules/user/presentation/models/wellness_model.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/utils/colors.dart';
import 'package:frontend/core/utils/responsive_data.dart';
import 'wellness_result_screen.dart';

/// Hosts all 7 questions with animated transitions and a progress bar.
/// Each question uses its own tailored A–E answer options.
class WellnessQuestionScreen extends StatefulWidget {
  final VoidCallback onSkip;
  final ValueChanged<WellnessResult> onComplete;

  const WellnessQuestionScreen({
    super.key,
    required this.onSkip,
    required this.onComplete,
  });

  @override
  State<WellnessQuestionScreen> createState() => _WellnessQuestionScreenState();
}

class _WellnessQuestionScreenState extends State<WellnessQuestionScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  int? _selectedValue;
  final List<int> _answers = [];

  late AnimationController _slideCtrl;
  late Animation<Offset> _slideIn;
  late Animation<double> _fadeIn;

  late AnimationController _progressCtrl;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
    _slideIn = Tween<Offset>(
      begin: const Offset(0.04, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _fadeIn = CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut);

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    // Start at exactly 1/7 (first question) with no animation on init.
    // _progressAnim drives the LinearProgressIndicator directly.
    _progressAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_progressCtrl);
    _progressCtrl.value = 1 / kWellnessQuestions.length;

    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ─────────────────────────────────────────────────────────

  void _goNext() {
    if (_selectedValue == null) return;
    final newAnswers = List<int>.from(_answers)..add(_selectedValue!);

    if (_currentIndex == kWellnessQuestions.length - 1) {
      // All 7 answered — compute result
      final total = newAnswers.reduce((a, b) => a + b);
      final result = WellnessResult.fromScore(total);
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, _, _) => WellnessResultScreen(
            result: result,
            onHome: () => widget.onComplete(result),
          ),
          transitionDuration: const Duration(milliseconds: 420),
          transitionsBuilder: (_, anim, _, child) => FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: child,
          ),
        ),
      );
      return;
    }

    _slideCtrl.reset();
    final nextIndex = _currentIndex + 1;
    // Each step = 1/total. Question 1 = 1/7, Q2 = 2/7 … Q7 = 7/7 = 1.0
    final nextProgress = (nextIndex + 1) / kWellnessQuestions.length;

    _progressCtrl.animateTo(
      nextProgress,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );

    setState(() {
      _answers
        ..clear()
        ..addAll(newAnswers);
      _currentIndex = nextIndex;
      _selectedValue = null;
    });
    _slideCtrl.forward();
  }

  void _goPrev() {
    if (_currentIndex == 0) {
      Navigator.pop(context);
      return;
    }
    _slideCtrl.reset();
    _progressCtrl.animateTo(
      _currentIndex / kWellnessQuestions.length,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
    setState(() {
      _currentIndex--;
      if (_answers.isNotEmpty) _answers.removeLast();
      _selectedValue = null;
    });
    _slideCtrl.forward();
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final hPad = Responsive.horizontalPadding(context);
    final question = kWellnessQuestions[_currentIndex];
    final options = optionsFor(_currentIndex);
    final qNum = _currentIndex + 1;
    final total = kWellnessQuestions.length;
    final isLast = _currentIndex == total - 1;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────
            Container(
              color: AppColors.cardColor,
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 14),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: _goPrev,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.bgColor,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 15,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Progress + label
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Wellness Check-in',
                              style: TextStyle(
                                fontSize: isMobile ? 15 : 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkText,
                              ),
                            ),
                            Text(
                              '$qNum of $total',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.mutedText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        AnimatedBuilder(
                          animation: _progressCtrl,
                          builder: (_, _) => ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _progressAnim.value,
                              backgroundColor: AppColors.borderColor,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primaryColor,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Skip button
                  GestureDetector(
                    onTap: widget.onSkip,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.bgColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Question + options ─────────────────────────────────────
            Expanded(
              child: FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _slideIn,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 16),
                    child: Center(
                      child: SizedBox(
                        width: isMobile ? double.infinity : 520,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Question number badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Question $qNum of $total',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Question text
                            Text(
                              question,
                              style: TextStyle(
                                fontSize: isMobile ? 19 : 21,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkText,
                                height: 1.35,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              'Select the option that best describes you',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.labelColor,
                              ),
                            ),

                            const SizedBox(height: 22),

                            // Answer tiles — A through E
                            ...List.generate(options.length, (i) {
                              final opt = options[i];
                              final letter = kOptionLetters[i];
                              final isSelected = _selectedValue == opt.value;
                              return _AnswerTile(
                                letter: letter,
                                label: opt.label,
                                value: opt.value,
                                isSelected: isSelected,
                                onTap: () =>
                                    setState(() => _selectedValue = opt.value),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Bottom CTA ────────────────────────────────────────────
            Container(
              color: AppColors.cardColor,
              padding: EdgeInsets.fromLTRB(
                hPad,
                14,
                hPad,
                14 + MediaQuery.of(context).padding.bottom,
              ),
              child: AnimatedOpacity(
                opacity: _selectedValue != null ? 1.0 : 0.45,
                duration: const Duration(milliseconds: 200),
                child: GestureDetector(
                  onTap: _selectedValue != null ? _goNext : null,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: _selectedValue != null
                          ? [
                              BoxShadow(
                                color: AppColors.primaryColor.withOpacity(0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLast ? 'See My Results' : 'Next Question',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isLast
                              ? Icons.insights_rounded
                              : Icons.arrow_forward_rounded,
                          color: AppColors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Answer tile with letter badge ──────────────────────────────────────────

class _AnswerTile extends StatelessWidget {
  final String letter;
  final String label;
  final int value;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnswerTile({
    required this.letter,
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : AppColors.cardColor,
          borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.borderColor,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.06 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Letter badge (A / B / C / D / E) ──────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : AppColors.inputBg,
                borderRadius: BorderRadius.circular(9),
                border: isSelected
                    ? null
                    : Border.all(color: AppColors.borderColor),
              ),
              child: Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? AppColors.white : AppColors.labelColor,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // ── Answer label ───────────────────────────────────────
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primaryColor
                      : AppColors.darkText,
                  height: 1.35,
                ),
              ),
            ),

            // ── Selected check indicator ───────────────────────────
            if (isSelected)
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 13,
                  color: AppColors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
