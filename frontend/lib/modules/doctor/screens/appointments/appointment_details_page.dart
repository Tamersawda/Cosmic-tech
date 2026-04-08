import 'package:frontend/modules/doctor/widgets/appointments/atoms/snackbar_helper.dart';
import 'package:frontend/modules/doctor/widgets/appointments/banners/cancelled_banner.dart';
import 'package:frontend/modules/doctor/widgets/appointments/banners/completed_banner.dart';
import 'package:frontend/modules/doctor/widgets/appointments/buttons/action_button.dart';
import 'package:frontend/modules/doctor/widgets/appointments/buttons/prescription_button.dart';
import 'package:frontend/modules/doctor/widgets/appointments/buttons/reschedule_cancel_row.dart';
import 'package:frontend/modules/doctor/widgets/appointments/buttons/start_consultation_button.dart';
import 'package:frontend/modules/doctor/widgets/appointments/cards/detail_app_bar.dart';
import 'package:frontend/modules/doctor/widgets/appointments/cards/info_grid.dart';
import 'package:frontend/modules/doctor/widgets/appointments/cards/patient_card.dart';
import 'package:frontend/modules/doctor/widgets/appointments/sections/history_card.dart';
import 'package:frontend/modules/doctor/widgets/appointments/sections/reason_card.dart';
import 'package:frontend/modules/doctor/widgets/appointments/sheets/cancel_dialog.dart';
import 'package:frontend/modules/doctor/widgets/appointments/sheets/more_options_sheet.dart';
import 'package:frontend/modules/doctor/widgets/appointments/sheets/prescription_sheet.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/constants/responsive_data.dart';
import 'package:frontend/modules/doctor/models/appointment_model.dart';
import 'package:frontend/modules/doctor/screens/appointments/full_history_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentDetailsPage extends StatefulWidget {
  final Appointment appointment;
  final Color avatarColor;

  const AppointmentDetailsPage({
    super.key,
    required this.appointment,
    required this.avatarColor,
  });

  @override
  State<AppointmentDetailsPage> createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {
  late String _currentStatus;
  DateTime? _rescheduledDate;
  TimeOfDay? _rescheduledTime;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.appointment.status;
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _startVideoConsultation() async {
    const url = 'https://meet.jit.si/DemoDocConsultation';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      showAppSnack(context, 'Could not open video consultation');
    }
  }

  Future<void> _callPatient() async {
    const phone = 'tel:+919876543210';
    final uri = Uri.parse(phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      showAppSnack(context, 'Could not launch phone dialer');
    }
  }

  void _openPrescriptionSheet() {
    PrescriptionSheet.show(
      context,
      patientName: widget.appointment.name,
      onSubmit: (_) {
        Navigator.pop(context);
        showAppSnack(
          context,
          'Prescription saved for ${widget.appointment.name}',
        );
      },
    );
  }

  Future<void> _reschedule() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primaryColor,
            onPrimary: AppColors.white,
            surface: AppColors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primaryColor,
            onPrimary: AppColors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (pickedTime == null || !mounted) return;

    setState(() {
      _rescheduledDate = pickedDate;
      _rescheduledTime = pickedTime;
      _currentStatus = 'Confirmed';
    });

    final formatted =
        '${pickedDate.day}/${pickedDate.month}/${pickedDate.year} at ${pickedTime.format(context)}';
    showAppSnack(context, 'Rescheduled to $formatted');
  }

  void _cancelAppointment() {
    showCancelDialog(
      context,
      patientName: widget.appointment.name,
      onConfirm: () {
        setState(() => _currentStatus = 'Cancelled');
        showAppSnack(context, 'Appointment cancelled');
      },
    );
  }

  void _showMoreOptions() {
    MoreOptionsSheet.show(
      context,
      onMarkCompleted: _currentStatus != 'Completed'
          ? () {
              setState(() => _currentStatus = 'Completed');
              showAppSnack(context, 'Marked as completed');
            }
          : null,
      onShare: () => showAppSnack(context, 'Appointment details shared'),
    );
  }

  // ── Info grid tiles ───────────────────────────────────────────────────────

  List<InfoTileData> get _infoTiles {
    final displayDate = _rescheduledDate != null
        ? '${_rescheduledDate!.day}/${_rescheduledDate!.month}/${_rescheduledDate!.year}'
        : widget.appointment.date;
    final displayTime = _rescheduledTime != null
        ? _rescheduledTime!.format(context)
        : widget.appointment.time;

    return [
      InfoTileData(
        icon: Icons.calendar_today_rounded,
        label: 'Date',
        value: displayDate,
        color: AppColors.primaryColor,
        bg: AppColors.primarySurface,
      ),
      InfoTileData(
        icon: Icons.access_time_rounded,
        label: 'Time',
        value: displayTime,
        color: AppColors.accentPurple,
        bg: const Color(0xFFEDE9FB),
      ),
      InfoTileData(
        icon: Icons.videocam_rounded,
        label: 'Type',
        value: widget.appointment.type,
        color: AppColors.accentSky,
        bg: const Color(0xFFE0F7FA),
      ),
      InfoTileData(
        icon: Icons.receipt_long_rounded,
        label: 'Fee',
        value: widget.appointment.fee,
        color: AppColors.accentGreen,
        bg: const Color(0xFFDCFCE7),
      ),
    ];
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final hPad = Responsive.horizontalPadding(context);
    final isMobile = Responsive.isMobile(context);
    final isCancelled = _currentStatus == 'Cancelled';
    final isCompleted = _currentStatus == 'Completed';

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App bar
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: DetailAppBar(
                isMobile: isMobile,
                appointmentId: 'ID #APT${widget.appointment.age}2026',
                onMoreTap: _showMoreOptions,
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Patient hero card
                PatientCard(
                  appointment: widget.appointment,
                  avatarColor: widget.avatarColor,
                  currentStatus: _currentStatus,
                  isMobile: isMobile,
                ),
                const SizedBox(height: 16),

                // Info grid (date / time / type / fee)
                InfoGrid(tiles: _infoTiles, isMobile: isMobile),
                const SizedBox(height: 16),

                // Reason card
                ReasonCard(reason: widget.appointment.reason),
                const SizedBox(height: 16),

                // History card
                HistoryCard(
                  history: widget.appointment.history,
                  onViewFull: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullHistoryPage(
                        patientName: widget.appointment.name,
                        initials: widget.appointment.initials,
                        avatarColor: widget.avatarColor,
                        history: widget.appointment.history,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Primary CTA — hidden when cancelled / completed
                if (!isCancelled && !isCompleted) ...[
                  StartConsultationButton(onTap: _startVideoConsultation),
                  const SizedBox(height: 12),
                ],

                // Call + Report
                Row(
                  children: [
                    Expanded(
                      child: ActionButton(
                        label: 'Call',
                        icon: Icons.call_outlined,
                        color: AppColors.accentGreen,
                        bg: const Color(0xFFDCFCE7),
                        onTap: _callPatient,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ActionButton(
                        label: 'Report',
                        icon: Icons.bar_chart_rounded,
                        color: AppColors.accentPurple,
                        bg: const Color(0xFFEDE9FB),
                        onTap: () =>
                            showAppSnack(context, 'Reports coming soon'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Write prescription
                PrescriptionButton(onTap: _openPrescriptionSheet),
                const SizedBox(height: 12),

                // Reschedule / Cancel — hidden when done
                if (!isCancelled && !isCompleted) ...[
                  RescheduleCancelRow(
                    onReschedule: _reschedule,
                    onCancel: _cancelAppointment,
                  ),
                  const SizedBox(height: 12),
                ],

                // Status banners
                if (isCancelled) const CancelledBanner(),
                if (isCompleted) const CompletedBanner(),

                SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
