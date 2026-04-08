import 'dart:math' as math;
import 'package:frontend/modules/user/models/wellness_model.dart';
import 'package:frontend/modules/user/router/main_user_layout.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/constants/responsive_data.dart';

/// Result screen: animated arc meter, 5-level status, score/100,
/// personalised recommendations, and CTAs.
class WellnessResultScreen extends StatefulWidget {
  final WellnessResult result;
  final VoidCallback onHome;

  const WellnessResultScreen({
    super.key,
    required this.result,
    required this.onHome,
  });

  @override
  State<WellnessResultScreen> createState() => _WellnessResultScreenState();
}

class _WellnessResultScreenState extends State<WellnessResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _meterCtrl;
  late Animation<double> _meterAnim;
  late AnimationController _contentCtrl;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    _meterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _meterAnim = Tween<double>(
      begin: 0,
      end: widget.result.normalised,
    ).animate(CurvedAnimation(parent: _meterCtrl, curve: Curves.easeOutCubic));

    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _contentFade = CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut);
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
          CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic),
        );

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _meterCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _contentCtrl.forward();
    });
  }

  @override
  void dispose() {
    _meterCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Color get _color => widget.result.status.color;
  Color get _bg => widget.result.status.bgColor;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final hPad = Responsive.horizontalPadding(context);
    final status = widget.result.status;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ──────────────────────────────────────────────
            Container(
              color: AppColors.cardColor,
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.insights_rounded,
                      size: 18,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Wellbeing Results',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkText,
                        ),
                      ),
                      const Text(
                        'Based on your 7 responses',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Scrollable body ──────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 32),
                child: Center(
                  child: SizedBox(
                    width: isMobile ? double.infinity : 520,
                    child: Column(
                      children: [
                        // ── Arc meter card ─────────────────────────
                        _SectionCard(
                          borderColor: _color.withOpacity(0.2),
                          borderWidth: 1.5,
                          child: Column(
                            children: [
                              _CompletionChip(),
                              const SizedBox(height: 24),
                              AnimatedBuilder(
                                animation: _meterCtrl,
                                builder: (_, _) => _ArcMeter(
                                  progress: _meterAnim.value,
                                  statusColor: _color,
                                  score: widget.result.score,
                                  emoji: status.emoji,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: _bg,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: _color.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  status.label,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: _color,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Score range for this level: ${status.scoreRange}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.mutedText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        FadeTransition(
                          opacity: _contentFade,
                          child: SlideTransition(
                            position: _contentSlide,
                            child: Column(
                              children: [
                                // ── Wellbeing note ─────────────────
                                _SectionCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 38,
                                            height: 38,
                                            decoration: BoxDecoration(
                                              color: _bg,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child: Text(
                                                status.emoji,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Text(
                                            'Your wellbeing note',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.darkText,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        status.message,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.labelColor,
                                          height: 1.6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // ── Score breakdown ────────────────
                                _SectionCard(
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: AppColors.primarySurface,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.bar_chart_rounded,
                                          color: AppColors.primaryColor,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Wellness score',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.mutedText,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            '${widget.result.score} out of 100',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.darkText,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          const Text(
                                            '0 — 100',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: AppColors.mutedText,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          SizedBox(
                                            width: 100,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: LinearProgressIndicator(
                                                value: widget.result.normalised,
                                                backgroundColor:
                                                    AppColors.borderColor,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(_color),
                                                minHeight: 8,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // ── Recommendations ────────────────
                                _SectionCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 38,
                                            height: 38,
                                            decoration: BoxDecoration(
                                              color: _bg,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              Icons.tips_and_updates_rounded,
                                              color: _color,
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Text(
                                            'Recommended next steps',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.darkText,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      ...status.recommendations
                                          .asMap()
                                          .entries
                                          .map(
                                            (e) => _RecommendationRow(
                                              index: e.key + 1,
                                              text: e.value,
                                              color: _color,
                                              bg: _bg,
                                            ),
                                          ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Find Therapist
                                GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.circular(28),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryColor
                                              .withOpacity(0.25),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.favorite_border_rounded,
                                          color: AppColors.white,
                                          size: 18,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Find a Therapist',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Go to Home
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MainUserLayout(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 54,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(28),
                                      border: Border.all(
                                        color: AppColors.borderColor,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Go to Home',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.labelColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Disclaimer
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.inputBg,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppColors.borderColor,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Icon(
                                        Icons.info_outline_rounded,
                                        size: 16,
                                        color: AppColors.mutedText,
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'This assessment is for self-awareness only and does not constitute a clinical diagnosis. '
                                          'Please consult a licensed mental health professional for personalised advice.',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            color: AppColors.softMuted,
                                            height: 1.5,
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

// ── Recommendation row ─────────────────────────────────────────────────────

class _RecommendationRow extends StatelessWidget {
  final int index;
  final String text;
  final Color color;
  final Color bg;

  const _RecommendationRow({
    required this.index,
    required this.text,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Center(
              child: Text(
                '$index',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.darkText,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Completion chip ────────────────────────────────────────────────────────

class _CompletionChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.check_circle_rounded,
            size: 14,
            color: AppColors.primaryColor,
          ),
          SizedBox(width: 6),
          Text(
            'All 7 questions complete',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Arc meter ──────────────────────────────────────────────────────────────

class _ArcMeter extends StatelessWidget {
  final double progress;
  final Color statusColor;
  final int score;
  final String emoji;

  const _ArcMeter({
    required this.progress,
    required this.statusColor,
    required this.score,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 148,
      child: CustomPaint(
        painter: _ArcPainter(progress: progress, color: statusColor),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 2),
            Text(
              '$score',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: statusColor,
                height: 1,
              ),
            ),
            const Text(
              'out of 100',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.mutedText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _ArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height - 8;
    final radius = size.width / 2 - 12;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = AppColors.borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        math.pi,
        math.pi * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round,
      );
      final angle = math.pi + math.pi * progress;
      final tx = cx + radius * math.cos(angle);
      final ty = cy + radius * math.sin(angle);
      canvas.drawCircle(Offset(tx, ty), 10, Paint()..color = color);
      canvas.drawCircle(Offset(tx, ty), 5.5, Paint()..color = Colors.white);
    }

    void drawLabel(String text, double angle) {
      final lx = cx + (radius + 22) * math.cos(angle);
      final ly = cy + (radius + 22) * math.sin(angle);
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.mutedText,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(lx - tp.width / 2, ly - tp.height / 2));
    }

    drawLabel('Low', math.pi);
    drawLabel('Mid', math.pi * 1.5);
    drawLabel('High', 0);
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.color != color;
}

// ── Section card ───────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final double borderWidth;

  const _SectionCard({
    required this.child,
    this.borderColor,
    this.borderWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
        border: Border.all(
          color: borderColor ?? AppColors.borderColor,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
