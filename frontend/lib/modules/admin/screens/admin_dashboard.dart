import 'package:frontend/core/utils/colors.dart';
import 'package:frontend/core/utils/responsive_data.dart';
import 'package:flutter/material.dart';
import 'package:frontend/modules/admin/widgets/dashboard_card.dart';
import 'package:frontend/modules/admin/widgets/recent_appointments.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = 1;

    if (Responsive.isDesktop(context)) {
      crossAxisCount = 4;
    } else if (Responsive.isTablet(context)) {
      crossAxisCount = 2;
    } else if (Responsive.isMobile(context)) {
      crossAxisCount = 1;
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TITLE
              const Text(
                'Dashboard',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              const Text(
                "Welcome back, Admin. Here's your healthcare platform overview.",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 30),

              /// DASHBOARD CARDS
              GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),

                /// Fix overflow
                childAspectRatio: Responsive.isMobile(context) ? 2.8 : 2.2,

                children: const [
                  DashboardCard(
                    title: "Total Users",
                    value: "24,580",
                    icon: Icons.people_outline,
                  ),

                  DashboardCard(
                    title: "Total Doctors",
                    value: "1,245",
                    icon: Icons.medical_services_outlined,
                  ),

                  DashboardCard(
                    title: "Total Appointments",
                    value: "8,420",
                    icon: Icons.calendar_today_outlined,
                  ),

                  DashboardCard(
                    title: "Total Revenue",
                    value: "\$152,800",
                    icon: Icons.attach_money_outlined,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// RECENT APPOINTMENTS
              Container(
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        const Text(
                          "Recent Appointments",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const Spacer(),

                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            "View All",
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const AppointmentTile(
                      initials: "SJ",
                      patientName: "Sarah Johnson",
                      doctorName: "Dr. Michael Chen",
                      time: "10:30 AM",
                      status: "Completed",
                      statusColor: Colors.green,
                    ),

                    const Divider(height: 30),

                    const AppointmentTile(
                      initials: "JW",
                      patientName: "James Wilson",
                      doctorName: "Dr. Emily Parker",
                      time: "11:00 AM",
                      status: "Pending",
                      statusColor: Colors.orange,
                    ),

                    const Divider(height: 30),

                    const AppointmentTile(
                      initials: "MG",
                      patientName: "Maria Garcia",
                      doctorName: "Dr. David Kim",
                      time: "2:00 PM",
                      status: "Active",
                      statusColor: Colors.green,
                    ),

                    const Divider(height: 30),

                    const AppointmentTile(
                      initials: "RB",
                      patientName: "Robert Brown",
                      doctorName: "Dr. Lisa Wang",
                      time: "3:30 PM",
                      status: "Pending",
                      statusColor: Colors.orange,
                    ),

                    const Divider(height: 30),

                    const AppointmentTile(
                      initials: "AC",
                      patientName: "Amy Chen",
                      doctorName: "Dr. John Smith",
                      time: "4:15 PM",
                      status: "Completed",
                      statusColor: Colors.green,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
