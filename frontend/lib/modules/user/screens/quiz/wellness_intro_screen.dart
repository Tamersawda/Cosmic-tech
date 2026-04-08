import 'package:frontend/modules/user/screens/quiz/wellness_questions_screen.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/constants/responsive_data.dart';
import 'package:frontend/modules/user/models/wellness_model.dart';
import 'package:flutter/material.dart';

/// Intro screen launched right after [UserRegistrationPage] completes.
class WellnessIntroScreen extends StatefulWidget {
  final VoidCallback onSkip;
  final ValueChanged<WellnessResult> onComplete;

  const WellnessIntroScreen({
    super.key,
    required this.onSkip,
    required this.onComplete,
  });

  @override
  State<WellnessIntroScreen> createState() => _WellnessIntroScreenState();
}

class _WellnessIntroScreenState extends State<WellnessIntroScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _start() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => WellnessQuestionScreen(
          onSkip: widget.onSkip,
          onComplete: widget.onComplete,
        ),
        transitionDuration: const Duration(milliseconds: 380),
        transitionsBuilder: (_, anim, _, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hPad = Responsive.horizontalPadding(context);
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Stack(
        children: [
          // ── Gradient header band ────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: isMobile ? 270 : 310,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top: isMobile ? 28 : 44,
                    bottom: 40,
                    left: hPad,
                    right: hPad,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: isMobile ? double.infinity : 480,
                      child: Column(
                        children: [
                          // ── Emoji blob ────────────────────────────
                          Container(
                            width: isMobile ? 150 : 170,
                            height: isMobile ? 150 : 170,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '🧘',
                                style: TextStyle(fontSize: isMobile ? 68 : 80),
                              ),
                            ),
                          ),

                          SizedBox(height: isMobile ? 30 : 38),

                          // ── White content card ────────────────────
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(isMobile ? 28 : 36),
                            decoration: BoxDecoration(
                              color: AppColors.cardColor,
                              borderRadius: BorderRadius.circular(
                                Responsive.cardRadius(context),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.darkText.withOpacity(0.08),
                                  blurRadius: 30,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Title
                                Text(
                                  "Let's check in on\nhow you're feeling",
                                  style: TextStyle(
                                    fontSize: isMobile ? 24 : 28,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.darkText,
                                    height: 1.25,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),

                                // Subtitle
                                Text(
                                  'Answer 7 short questions to help us\npersonalise your experience.',
                                  style: TextStyle(
                                    fontSize: isMobile ? 14 : 15,
                                    color: AppColors.labelColor,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 28),

                                // Info pills
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _InfoPill(
                                      icon: Icons.timer_outlined,
                                      label: '3 min',
                                    ),
                                    const SizedBox(width: 10),
                                    _InfoPill(
                                      icon: Icons.lock_outline_rounded,
                                      label: 'Private',
                                    ),
                                    const SizedBox(width: 10),
                                    _InfoPill(
                                      icon: Icons.quiz_outlined,
                                      label: '7 questions',
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 32),

                                // Start button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _start,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryColor,
                                      foregroundColor: AppColors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 17,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Start Check-in',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 14),

                                // Skip
                                GestureDetector(
                                  onTap: widget.onSkip,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    child: Text(
                                      'Skip for now',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.mutedText,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.mutedText,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primaryColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.labelColor,
            ),
          ),
        ],
      ),
    );
  }
}
