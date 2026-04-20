import 'package:flutter/material.dart';
import 'package:frontend/core/utils/colors.dart';
import 'package:frontend/modules/doctor/presentation/screens/doctor_profile_page.dart';
import 'package:frontend/modules/doctor/presentation/screens/profile/doctor_edit_schedule_page.dart';

// ── Edit Schedule Page ────────────────────────────────────────────────────────

class DoctorEditSchedulePage extends StatefulWidget {
  final DoctorProfileData data;
  final Map<String, DayShift> schedule;

  const DoctorEditSchedulePage({
    super.key,
    required this.data,
    required this.schedule,
  });

  @override
  State<DoctorEditSchedulePage> createState() =>
      _DoctorEditSchedulePageState();
}

class _DoctorEditSchedulePageState extends State<DoctorEditSchedulePage> {
  late final Map<String, DayShift> _schedule;

  final List<String> _timezones = [
    'Asia/Kolkata (IST)',
    'America/New_York (EST)',
    'Europe/London (GMT)',
    'Asia/Dubai (GST)',
  ];
  String _timezone = 'Asia/Kolkata (IST)';
  bool _saving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _schedule = Map.from(widget.schedule);
  }

  int get _activeDays =>
      _schedule.values.where((s) => s.isActive).length;

  int get _totalHours => _schedule.values.fold(0, (sum, s) {
        if (!s.isActive) return sum;
        return sum + (s == DayShift.fullDay ? 8 : 4);
      });

  void _onShiftChanged(String day, DayShift shift) {
    setState(() {
      _schedule[day] = shift;
      _hasChanges = true;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      Navigator.pop(context, Map<String, DayShift>.from(_schedule));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline,
                  color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text('Schedule updated successfully.'),
            ],
          ),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Discard changes?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: const Text(
            'You have unsaved changes. Are you sure you want to go back?',
            style: TextStyle(fontSize: 14, color: AppColors.labelColor)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Keep Editing')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Discard',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: _BackButton(onTap: () async {
            if (await _onWillPop()) Navigator.pop(context);
          }),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit Schedule',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText)),
              Text('$_activeDays active days · $_totalHours hrs/week',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.mutedText)),
            ],
          ),
          actions: [
            if (_hasChanges)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFBBF24)),
                    ),
                    child: const Text('Unsaved',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF92400E))),
                  ),
                ),
              ),
          ],
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

              // ── Shift reference ──────────────────────────────────────────
              _buildSectionLabel('SHIFT TIMINGS'),
              const SizedBox(height: 10),
              _ShiftReferenceRow(),

              const SizedBox(height: 18),

              // ── Live stats ───────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      value: '$_activeDays',
                      label: 'Active Days',
                      icon: Icons.calendar_today_outlined,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniStat(
                      value: '${_totalHours}h',
                      label: 'Hours / Week',
                      icon: Icons.schedule_outlined,
                      color: const Color(0xFF16A34A),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniStat(
                      value: _activeDays > 0
                          ? '${(_totalHours / _activeDays).toStringAsFixed(1)}h'
                          : '0h',
                      label: 'Avg / Day',
                      icon: Icons.timer_outlined,
                      color: const Color(0xFF0891B2),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // ── Day rows ─────────────────────────────────────────────────
              _buildSectionLabel('WEEKLY SCHEDULE'),
              const SizedBox(height: 10),
              ..._schedule.entries.map(
                (e) => _DayRow(
                  day: e.key,
                  shift: e.value,
                  onChanged: (s) => _onShiftChanged(e.key, s),
                ),
              ),

              const SizedBox(height: 18),

              // ── Timezone ──────────────────────────────────────────────────
              _buildSectionLabel('TIMEZONE'),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.public_outlined,
                        size: 18, color: Color(0xFF0891B2)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _timezone,
                          isExpanded: true,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.darkText),
                          icon: const Icon(Icons.keyboard_arrow_down,
                              color: AppColors.labelColor, size: 20),
                          items: _timezones
                              .map((t) => DropdownMenuItem(
                                  value: t, child: Text(t)))
                              .toList(),
                          onChanged: (v) {
                            setState(() {
                              _timezone = v!;
                              _hasChanges = true;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              _SaveButton(saving: _saving, onTap: _save),
              const SizedBox(height: 24),
            ],
          ),
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

// ── Shift Reference Row ───────────────────────────────────────────────────────

class _ShiftReferenceRow extends StatelessWidget {
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
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: s.activeBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: s.activeColor.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(s.icon, size: 14, color: s.activeColor),
                const SizedBox(height: 5),
                Text(s.label,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: s.activeColor)),
                const SizedBox(height: 2),
                Text(s.shortTime,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText)),
                Text(s.durationLabel,
                    style: TextStyle(
                        fontSize: 10,
                        color: s.activeColor,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Mini Stat ─────────────────────────────────────────────────────────────────

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _MiniStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
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
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.mutedText),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Day Row ───────────────────────────────────────────────────────────────────

class _DayRow extends StatelessWidget {
  final String day;
  final DayShift shift;
  final ValueChanged<DayShift> onChanged;

  const _DayRow({
    required this.day,
    required this.shift,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: shift.isActive ? AppColors.white : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: shift.isActive
              ? shift.activeColor.withValues(alpha: 0.3)
              : AppColors.borderColor,
          width: shift.isActive ? 1.2 : 1.0,
        ),
        boxShadow: shift.isActive
            ? [
                BoxShadow(
                    color: shift.activeColor.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2))
              ]
            : null,
      ),
      child: Row(
        children: [

          // Day name + duration
          SizedBox(
            width: 44,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day.substring(0, 3).toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: shift.isActive
                        ? AppColors.darkText
                        : AppColors.labelColor,
                  ),
                ),
                if (shift.isActive)
                  Text(
                    shift.durationLabel,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: shift.activeColor),
                  )
                else
                  const Text('—',
                      style: TextStyle(
                          fontSize: 10, color: AppColors.softMuted)),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Shift chips
          Expanded(
            child: Row(
              children: DayShift.values.map((s) {
                final isSelected = shift == s;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: GestureDetector(
                      onTap: () => onChanged(s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (s == DayShift.off
                                  ? const Color(0xFFF1F5F9)
                                  : s.activeColor)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: !isSelected
                              ? Border.all(
                                  color: AppColors.borderColor, width: 0.8)
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          s.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? (s == DayShift.off
                                    ? AppColors.labelColor
                                    : Colors.white)
                                : AppColors.labelColor,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(width: 6),

          // Time badge
          if (shift.isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: shift.activeColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                    color: shift.activeColor.withValues(alpha: 0.2),
                    width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(shift.icon, size: 10, color: shift.activeColor),
                  const SizedBox(width: 4),
                  Text(shift.shortTime,
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: shift.activeColor)),
                ],
              ),
            )
          else
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.block, size: 10, color: AppColors.softMuted),
                  SizedBox(width: 4),
                  Text('Off',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppColors.softMuted)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Save Button ───────────────────────────────────────────────────────────────

class _SaveButton extends StatelessWidget {
  final bool saving;
  final VoidCallback onTap;

  const _SaveButton({required this.saving, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: saving ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              AppColors.primaryColor.withValues(alpha: 0.6),
          padding: const EdgeInsets.symmetric(vertical: 17),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: saving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_rounded, size: 18),
                  SizedBox(width: 8),
                  Text('Save Changes',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ],
              ),
      ),
    );
  }
}

// ── Back Button ───────────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
