import 'package:frontend/core/utils/colors.dart';
import 'package:frontend/core/utils/responsive_data.dart';
import 'package:flutter/material.dart';
import 'package:frontend/modules/doctor/presentation/widgets/home/appointment_tile.dart';

class DoctorScheduleSection extends StatelessWidget {
  const DoctorScheduleSection({super.key});

  static const _appointments = [
    AppointmentData(
      time: '09:00 AM',
      name: 'Rahul Mehta',
      type: 'General Checkup',
      status: AppointmentStatus.upcoming,
      initials: 'RM',
      color: AppColors.primaryColor,
      avatarBg: AppColors.primarySurface,
    ),
    AppointmentData(
      time: '10:30 AM',
      name: 'Priya Sharma',
      type: 'Follow-up Consult',
      status: AppointmentStatus.inProgress,
      initials: 'PS',
      color: AppColors.accentGreen,
      avatarBg: Color(0xFFDCFCE7),
    ),
    AppointmentData(
      time: '12:00 PM',
      name: 'Ankit Verma',
      type: 'Cardiology Review',
      status: AppointmentStatus.upcoming,
      initials: 'AV',
      color: AppColors.accentPurple,
      avatarBg: Color(0xFFEDE9FB),
    ),
    AppointmentData(
      time: '02:30 PM',
      name: 'Sneha Pillai',
      type: 'Therapy Session',
      status: AppointmentStatus.upcoming,
      initials: 'SP',
      color: AppColors.accentAmber,
      avatarBg: Color(0xFFFFF4E6),
    ),
    AppointmentData(
      time: '04:00 PM',
      name: 'Kabir Nair',
      type: 'Psychiatric Eval',
      status: AppointmentStatus.cancelled,
      initials: 'KN',
      color: AppColors.dangerRed,
      avatarBg: Color(0xFFFFEEEE),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final hPad = Responsive.horizontalPadding(context);
    final isMobile = Responsive.isMobile(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        hPad,
        Responsive.sectionSpacing(context),
        hPad,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "TODAY'S SCHEDULE",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mutedText,
                  letterSpacing: 1.2,
                ),
              ),
              // Date badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 11,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _todayLabel(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Appointment tiles
          ..._appointments.map(
            (a) => AppointmentTile(data: a, isMobile: isMobile),
          ),
          // View all button
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View Full Schedule',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: AppColors.primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _todayLabel() {
    final now = DateTime.now();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${now.day} ${months[now.month - 1]}';
  }
}
