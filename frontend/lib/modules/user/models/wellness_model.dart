import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════════════════════════
//  SCORING SYSTEM
//  Raw score  : 7–35   (7 questions × 1–5 each)
//  Display score: mapped linearly to 0–100 for user-facing output
//
//  formula: displayScore = ((rawScore - 7) / 28) × 100   (rounded)
//
//  5-Level Stress Framework (inspired by PSS / WHO-5 thresholds):
//  ┌──────────────────────┬────────────┬────────────────────────────────────┐
//  │ Display score        │ Level      │ Meaning                            │
//  ├──────────────────────┼────────────┼────────────────────────────────────┤
//  │  0 – 20              │ Thriving   │ Excellent mental wellness          │
//  │ 21 – 40              │ Balanced   │ Healthy with minor fluctuations    │
//  │ 41 – 60              │ Mild Stress│ Manageable stress, monitor it      │
//  │ 61 – 80              │ High Stress│ Significant stress, action needed  │
//  │ 81 – 100             │ Critical   │ Severe distress, seek help now     │
//  └──────────────────────┴────────────┴────────────────────────────────────┘
// ════════════════════════════════════════════════════════════════════════════

class WellnessResult {
  /// Raw score 7–35 (internal use only).
  final int rawScore;

  /// Display score 0–100 (user-facing).
  final int score;

  final WellnessStatus status;
  final DateTime completedAt;

  const WellnessResult({
    required this.rawScore,
    required this.score,
    required this.status,
    required this.completedAt,
  });

  /// Build a result from the raw 7–35 sum.
  factory WellnessResult.fromScore(int rawScore) {
    // Map 7–35 → 0–100
    final int display = (((rawScore - 7) / 28.0) * 100).round().clamp(0, 100);

    final WellnessStatus status;
    if (display <= 20) {
      status = WellnessStatus.thriving;
    } else if (display <= 40) {
      status = WellnessStatus.balanced;
    } else if (display <= 60) {
      status = WellnessStatus.mildStress;
    } else if (display <= 80) {
      status = WellnessStatus.highStress;
    } else {
      status = WellnessStatus.critical;
    }

    return WellnessResult(
      rawScore: rawScore,
      score: display,
      status: status,
      completedAt: DateTime.now(),
    );
  }

  /// 0.0–1.0 for arc meter and progress indicators.
  double get normalised => (score / 100.0).clamp(0.0, 1.0);
}

// ── 5-Level Stress Status ────────────────────────────────────────────────────

enum WellnessStatus { thriving, balanced, mildStress, highStress, critical }

extension WellnessStatusX on WellnessStatus {
  // ── Display label ──────────────────────────────────────────────────────────
  String get label {
    switch (this) {
      case WellnessStatus.thriving:
        return 'Thriving';
      case WellnessStatus.balanced:
        return 'Balanced';
      case WellnessStatus.mildStress:
        return 'Mild Stress';
      case WellnessStatus.highStress:
        return 'High Stress';
      case WellnessStatus.critical:
        return 'Needs Urgent Care';
    }
  }

  // ── Score range label shown under the status pill ──────────────────────────
  String get scoreRange {
    switch (this) {
      case WellnessStatus.thriving:
        return '0 – 20';
      case WellnessStatus.balanced:
        return '21 – 40';
      case WellnessStatus.mildStress:
        return '41 – 60';
      case WellnessStatus.highStress:
        return '61 – 80';
      case WellnessStatus.critical:
        return '81 – 100';
    }
  }

  // ── Supportive message (non-clinical, warm tone) ───────────────────────────
  String get message {
    switch (this) {
      case WellnessStatus.thriving:
        return 'You\'re in a great place emotionally. Your mental balance is strong — '
            'keep nurturing your wellbeing through healthy habits, rest, and connection.';
      case WellnessStatus.balanced:
        return 'Your mental health is generally stable with some minor ups and downs. '
            'Stay mindful, maintain your routines, and reach out to someone you trust when needed.';
      case WellnessStatus.mildStress:
        return 'You\'re experiencing a manageable level of stress. This is common, but '
            'worth paying attention to. Consider journalling, breathing exercises, '
            'or speaking with a counsellor to stay on top of it.';
      case WellnessStatus.highStress:
        return 'You\'re carrying significant stress right now. It\'s important to take '
            'this seriously. Talking to a mental health professional can provide '
            'real, practical support — you don\'t have to navigate this alone.';
      case WellnessStatus.critical:
        return 'Your responses suggest you may be experiencing severe emotional distress. '
            'Please reach out to a licensed therapist or a mental health helpline as '
            'soon as possible. Support is available and you deserve care right now.';
    }
  }

  // ── Recommended actions list ───────────────────────────────────────────────
  List<String> get recommendations {
    switch (this) {
      case WellnessStatus.thriving:
        return [
          'Maintain your sleep and exercise routine',
          'Practice daily gratitude journalling',
          'Schedule regular social time with loved ones',
        ];
      case WellnessStatus.balanced:
        return [
          'Try a 10-minute mindfulness or breathing session daily',
          'Identify and reduce one recurring stressor this week',
          'Connect with a friend or family member regularly',
        ];
      case WellnessStatus.mildStress:
        return [
          'Book a session with a therapist or counsellor',
          'Reduce screen time and improve sleep hygiene',
          'Start a daily mood-tracking journal',
          'Try guided meditation (10 min/day)',
        ];
      case WellnessStatus.highStress:
        return [
          'Consult a licensed mental health professional soon',
          'Inform a trusted person about how you\'re feeling',
          'Reduce workload or commitments where possible',
          'Prioritise sleep, nutrition, and gentle movement',
          'Avoid alcohol or substances as coping mechanisms',
        ];
      case WellnessStatus.critical:
        return [
          'Reach out to a therapist or mental health helpline today',
          'Do not isolate — tell someone you trust how you feel',
          'Avoid making major life decisions right now',
          'Emergency support: iCall 9152987821 (India) | 988 Lifeline (US)',
        ];
    }
  }

  // ── Emoji ──────────────────────────────────────────────────────────────────
  String get emoji {
    switch (this) {
      case WellnessStatus.thriving:
        return '🌟';
      case WellnessStatus.balanced:
        return '🌿';
      case WellnessStatus.mildStress:
        return '🌤';
      case WellnessStatus.highStress:
        return '🌧';
      case WellnessStatus.critical:
        return '⛈';
    }
  }

  // ── AppColors-compatible accent color ─────────────────────────────────────
  Color get color {
    switch (this) {
      case WellnessStatus.thriving:
        return const Color(0xFF10B981); // accentGreen
      case WellnessStatus.balanced:
        return const Color(0xFF0EA5C9); // accentTeal
      case WellnessStatus.mildStress:
        return const Color(0xFFF59E0B); // accentAmber
      case WellnessStatus.highStress:
        return const Color(0xFFEF4444); // dangerRed
      case WellnessStatus.critical:
        return const Color(0xFFDC2626); // dangerDark
    }
  }

  Color get bgColor {
    switch (this) {
      case WellnessStatus.thriving:
        return const Color(0xFFDCFCE7);
      case WellnessStatus.balanced:
        return const Color(0xFFE0F7FA);
      case WellnessStatus.mildStress:
        return const Color(0xFFFFF4E6);
      case WellnessStatus.highStress:
        return const Color(0xFFFFEEEE);
      case WellnessStatus.critical:
        return const Color(0xFFFFE4E4);
    }
  }
}

// ── 7 Questions ──────────────────────────────────────────────────────────────

const List<String> kWellnessQuestions = [
  'How have you been feeling emotionally over the past few days?',
  'What best describes your current thoughts?',
  'How would you describe your current energy level?',
  'How connected do you feel with yourself right now?',
  'How has your sleep been recently?',
  'What has been your main source of comfort recently?',
  'Which best describes your current state?',
];

// ── Per-question answer options (A–E) ─────────────────────────────────────────
// A = 1 (healthiest/lowest distress) → E = 5 (highest distress)

const List<List<({String label, int value})>> kWellnessOptions = [
  // Q1 – Emotional feeling
  [
    (label: 'Calm and peaceful', value: 1),
    (label: 'Mostly okay with occasional stress', value: 2),
    (label: 'Anxious or restless', value: 3),
    (label: 'Overwhelmed', value: 4),
    (label: 'Numb or disconnected', value: 5),
  ],
  // Q2 – Current thoughts
  [
    (label: 'Clear and focused', value: 1),
    (label: 'Slightly distracted', value: 2),
    (label: 'Overthinking frequently', value: 3),
    (label: 'Negative or worrying thoughts', value: 4),
    (label: 'Racing or uncontrollable thoughts', value: 5),
  ],
  // Q3 – Energy level
  [
    (label: 'High and motivated', value: 1),
    (label: 'Stable and balanced', value: 2),
    (label: 'Slightly low', value: 3),
    (label: 'Very low or fatigued', value: 4),
    (label: 'Fluctuating a lot', value: 5),
  ],
  // Q4 – Connection with self
  [
    (label: 'Very connected and aware', value: 1),
    (label: 'Mostly connected', value: 2),
    (label: 'Neutral', value: 3),
    (label: 'Slightly disconnected', value: 4),
    (label: 'Completely disconnected', value: 5),
  ],
  // Q5 – Sleep quality
  [
    (label: 'Restful and consistent', value: 1),
    (label: 'Mostly okay', value: 2),
    (label: 'Irregular', value: 3),
    (label: 'Poor quality sleep', value: 4),
    (label: 'Very disturbed or minimal sleep', value: 5),
  ],
  // Q6 – Source of comfort
  [
    (label: 'Personal reflection or inner peace', value: 1),
    (label: 'Friends or family', value: 2),
    (label: 'Entertainment (music, shows, etc.)', value: 3),
    (label: 'Distractions (scrolling, gaming, etc.)', value: 4),
    (label: "I haven't felt much comfort", value: 5),
  ],
  // Q7 – Current state metaphor
  [
    (label: 'Grounded and stable (like a calm earth)', value: 1),
    (label: 'Flowing but steady (like a river)', value: 2),
    (label: 'Drifting and uncertain (like clouds)', value: 3),
    (label: 'Chaotic and intense (like a storm)', value: 4),
    (label: 'Empty or still (like deep space)', value: 5),
  ],
];

/// Options for a given question index (0-based).
List<({String label, int value})> optionsFor(int questionIndex) =>
    kWellnessOptions[questionIndex];

/// Option letter labels A–E.
const List<String> kOptionLetters = ['A', 'B', 'C', 'D', 'E'];
