import 'package:frontend/core/utils/colors.dart';
import 'package:frontend/core/utils/responsive_data.dart';
import 'package:frontend/modules/user/presentation/models/wellness_model.dart';
import 'package:flutter/material.dart';

/// Home screen card showing the saved wellness result (score out of 35),
/// or a CTA banner to take the assessment when no result exists.
class WellbeingHomeCard extends StatelessWidget {
  final WellnessResult? result;
  final VoidCallback onFindTherapist;
  final VoidCallback onTakeAssessment;

  const WellbeingHomeCard({
    super.key,
    required this.result,
    required this.onFindTherapist,
    required this.onTakeAssessment,
  });

  @override
  Widget build(BuildContext context) {
    return result == null
        ? _NoResultCard(onTake: onTakeAssessment)
        : _ResultCard(result: result!, onFindTherapist: onFindTherapist);
  }
}

// ── No result: CTA banner ──────────────────────────────────────────────────

class _NoResultCard extends StatelessWidget {
  final VoidCallback onTake;

  const _NoResultCard({required this.onTake});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTake,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.wellnessBannerGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('🧘', style: TextStyle(fontSize: 40)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How are you feeling today?',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Take a 3-min wellness check-in · 7 questions',
                    style: TextStyle(fontSize: 12, color: AppColors.labelColor),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Text(
                'Start',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Result card ────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  final WellnessResult result;
  final VoidCallback onFindTherapist;

  const _ResultCard({required this.result, required this.onFindTherapist});

  Color get _statusColor => result.status.color;
  Color get _statusBg => result.status.bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
        border: Border.all(color: _statusColor.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _statusBg,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: Text(
                    result.status.emoji,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Wellbeing Status',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    result.status.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _statusColor,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Score badge — shows X/35
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _statusColor.withOpacity(0.25)),
                ),
                child: Text(
                  '${result.score}/100',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Progress bar ──────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: result.normalised,
              backgroundColor: AppColors.borderColor,
              valueColor: AlwaysStoppedAnimation<Color>(_statusColor),
              minHeight: 7,
            ),
          ),

          const SizedBox(height: 14),

          // ── Short message ─────────────────────────────────────────
          Text(
            result.status.message,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.labelColor,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 16),

          // ── CTA ───────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onFindTherapist,
              icon: const Icon(Icons.favorite_border_rounded, size: 16),
              label: const Text(
                'Find a Therapist',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
