import 'package:flutter/material.dart';
import 'package:frontend/core/utils/colors.dart';
import 'package:frontend/modules/doctor/presentation/screens/doctor_profile_page.dart';
import 'package:frontend/modules/doctor/presentation/screens/profile/detail/doctor_availibility_section.dart';
import 'doctor_edit_schedule_page.dart';

// ── Shared model (import from a shared file in real project) ──────────────────

enum DayShift { morning, afternoon, fullDay, off }

extension DayShiftExt on DayShift {
  String get label => switch (this) {
        DayShift.morning   => 'Morning',
        DayShift.afternoon => 'Afternoon',
        DayShift.fullDay   => 'Full Day',
        DayShift.off       => 'Off',
      };

  String get timeRange => switch (this) {
        DayShift.morning   => '9:00 AM – 1:00 PM',
        DayShift.afternoon => '1:00 PM – 5:00 PM',
        DayShift.fullDay   => '9:00 AM – 5:00 PM',
        DayShift.off       => 'Unavailable',
      };

  String get shortTime => switch (this) {
        DayShift.morning   => '9 AM – 1 PM',
        DayShift.afternoon => '1 PM – 5 PM',
        DayShift.fullDay   => '9 AM – 5 PM',
        DayShift.off       => '—',
      };

  String get durationLabel => switch (this) {
        DayShift.morning   => '4 hrs',
        DayShift.afternoon => '4 hrs',
        DayShift.fullDay   => '8 hrs',
        DayShift.off       => '',
      };

  bool get isActive => this != DayShift.off;

  Color get activeColor => switch (this) {
        DayShift.morning   => const Color(0xFFD97706),
        DayShift.afternoon => AppColors.primaryColor,
        DayShift.fullDay   => const Color(0xFF16A34A),
        DayShift.off       => AppColors.borderColor,
      };

  Color get activeBg => switch (this) {
        DayShift.morning   => const Color(0xFFFFFBEB),
        DayShift.afternoon => const Color(0xFFEEF2FF),
        DayShift.fullDay   => const Color(0xFFF0FDF4),
        DayShift.off       => const Color(0xFFF8FAFC),
      };

  IconData get icon => switch (this) {
        DayShift.morning   => Icons.wb_sunny_outlined,
        DayShift.afternoon => Icons.wb_twilight_outlined,
        DayShift.fullDay   => Icons.calendar_today_outlined,
        DayShift.off       => Icons.block,
      };
}

// ── Default schedule ──────────────────────────────────────────────────────────

Map<String, DayShift> get defaultSchedule => {
      'Monday':    DayShift.fullDay,
      'Tuesday':   DayShift.fullDay,
      'Wednesday': DayShift.morning,
      'Thursday':  DayShift.fullDay,
      'Friday':    DayShift.morning,
      'Saturday':  DayShift.off,
      'Sunday':    DayShift.off,
    };

// ── Summary Page ──────────────────────────────────────────────────────────────

class DoctorScheduleSummaryPage extends StatefulWidget {
  final DoctorProfileData data;

  const DoctorScheduleSummaryPage({super.key, required this.data});

  @override
  State<DoctorScheduleSummaryPage> createState() =>
      _DoctorScheduleSummaryPageState();
}

class _DoctorScheduleSummaryPageState
    extends State<DoctorScheduleSummaryPage> {
  Map<String, DayShift> _schedule = defaultSchedule;

  int get _activeDays =>
      _schedule.values.where((s) => s.isActive).length;

  int get _totalHours => _schedule.values.fold(0, (sum, s) {
        if (!s.isActive) return sum;
        return sum + (s == DayShift.fullDay ? 8 : 4);
      });

  double get _avgHours =>
      _activeDays > 0 ? _totalHours / _activeDays : 0.0;

  Future<void> _goToEdit() async {
    final updated = await Navigator.push<Map<String, DayShift>>(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorEditSchedulePage(
          data: widget.data,
          schedule: Map.from(_schedule),
        ),
      ),
    );
    if (updated != null && mounted) {
      setState(() => _schedule = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: _BackButton(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Schedule & Availability',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText),
            ),
            Text(
              'Overview for the week',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.mutedText),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Stats ──────────────────────────────────────────────────────
            _buildSectionLabel('THIS WEEK'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    value: '$_activeDays',
                    label: 'Active Days',
                    sublabel: 'out of 7',
                    icon: Icons.calendar_today_outlined,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    value: '${_totalHours}h',
                    label: 'Hours / Week',
                    sublabel: 'total scheduled',
                    icon: Icons.schedule_outlined,
                    color: const Color(0xFF16A34A),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    value: '${_avgHours.toStringAsFixed(1)}h',
                    label: 'Avg / Day',
                    sublabel: 'on active days',
                    icon: Icons.timer_outlined,
                    color: const Color(0xFF0891B2),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Shift legend ───────────────────────────────────────────────
            _buildSectionLabel('SHIFT REFERENCE'),
            const SizedBox(height: 10),
            _ShiftLegendRow(),

            const SizedBox(height: 24),

            // ── Weekly schedule summary ────────────────────────────────────
            _ScheduleSummaryCard(
              schedule: _schedule,
              totalHours: _totalHours,
              onEditTap: _goToEdit,
            ),

            const SizedBox(height: 24),

            // ── Timezone info ──────────────────────────────────────────────
            _buildSectionLabel('TIMEZONE'),
            const SizedBox(height: 10),
            _TimezoneInfoTile(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.mutedText,
          letterSpacing: 0.8,
        ),
      );
}

// ── Stat Card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final String sublabel;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText),
              textAlign: TextAlign.center),
          const SizedBox(height: 1),
          Text(sublabel,
              style: const TextStyle(
                  fontSize: 9, color: AppColors.mutedText),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Shift Legend Row ──────────────────────────────────────────────────────────

class _ShiftLegendRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const shifts = [DayShift.morning, DayShift.afternoon, DayShift.fullDay];
    return Row(
      children: shifts.asMap().entries.map((entry) {
        final s = entry.value;
        final isLast = entry.key == shifts.length - 1;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: isLast ? 0 : 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: s.activeBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: s.activeColor.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(s.icon, size: 16, color: s.activeColor),
                const SizedBox(height: 6),
                Text(s.label,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: s.activeColor)),
                const SizedBox(height: 3),
                Text(s.shortTime,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText)),
                const SizedBox(height: 2),
                Text(s.durationLabel,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: s.activeColor)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Schedule Summary Card ─────────────────────────────────────────────────────

class _ScheduleSummaryCard extends StatelessWidget {
  final Map<String, DayShift> schedule;
  final int totalHours;
  final VoidCallback onEditTap;

  const _ScheduleSummaryCard({
    required this.schedule,
    required this.totalHours,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeDays =
        schedule.entries.where((e) => e.value.isActive).toList();
    final offDays =
        schedule.entries.where((e) => !e.value.isActive).toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Card header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.event_available_outlined,
                      size: 17, color: AppColors.primaryColor),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Weekly Schedule',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkText)),
                      SizedBox(height: 1),
                      Text('Tap Edit to modify shifts',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.mutedText)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onEditTap,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.primaryColor.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.edit_outlined,
                            size: 13, color: AppColors.primaryColor),
                        const SizedBox(width: 5),
                        const Text('Edit',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryColor)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(height: 1, color: AppColors.borderColor),

          // ── Day rows ──
          if (activeDays.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No active days. Tap Edit to set your schedule.',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.mutedText,
                      fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                children: [

                  // Table header
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: const [
                        Expanded(flex: 3, child: _TH('DAY')),
                        Expanded(flex: 3, child: _TH('SHIFT')),
                        Expanded(flex: 5, child: _TH('TIMING', right: true)),
                      ],
                    ),
                  ),

                  ...activeDays.map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            // Day name
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.key,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.darkText)),
                                  Text(e.value.durationLabel,
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: e.value.activeColor,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),

                            // Shift pill
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                        color: e.value.activeColor,
                                        shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: e.value.activeBg,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: e.value.activeColor
                                              .withValues(alpha: 0.2)),
                                    ),
                                    child: Text(e.value.label,
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: e.value.activeColor)),
                                  ),
                                ],
                              ),
                            ),

                            // Timing
                            Expanded(
                              flex: 5,
                              child: Text(e.value.timeRange,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.labelColor)),
                            ),
                          ],
                        ),
                      )),

                  const SizedBox(height: 6),
                  Container(height: 1, color: AppColors.borderColor),
                  const SizedBox(height: 10),

                  // Off days
                  if (offDays.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.block,
                            size: 12, color: AppColors.softMuted),
                        const SizedBox(width: 6),
                        Text(
                          'Off: ${offDays.map((e) => e.key.substring(0, 3)).join(', ')}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.softMuted),
                        ),
                      ],
                    ),

                  const SizedBox(height: 10),

                  // Total hours
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.primaryColor.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.access_time_outlined,
                                size: 14, color: AppColors.primaryColor),
                            SizedBox(width: 6),
                            Text('Total weekly commitment',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryColor)),
                          ],
                        ),
                        Text('$totalHours hrs / week',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Timezone Info Tile ────────────────────────────────────────────────────────

class _TimezoneInfoTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFF0891B2).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.public_outlined,
                size: 16, color: Color(0xFF0891B2)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Asia/Kolkata (IST)',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText)),
                SizedBox(height: 2),
                Text('All times displayed in local timezone',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.mutedText)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              color: AppColors.labelColor, size: 18),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _TH extends StatelessWidget {
  final String text;
  final bool right;

  const _TH(this.text, {this.right = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: right ? TextAlign.right : TextAlign.left,
      style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.mutedText,
          letterSpacing: 0.6),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 16, color: AppColors.darkText),
      ),
    );
  }
}
