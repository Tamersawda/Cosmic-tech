import 'package:frontend/core/utils/enums.dart';
import 'package:frontend/modules/admin/presentation/screens/admin_dashboard.dart';
import 'package:frontend/modules/admin/presentation/screens/content_management_page.dart';
import 'package:frontend/modules/admin/presentation/screens/doctor_management.dart';
import 'package:frontend/modules/admin/presentation/screens/notification_management_page.dart';
import 'package:frontend/modules/admin/presentation/screens/quiz_questions_management.dart';
import 'package:frontend/modules/admin/presentation/screens/reviews_and_ratings_page.dart';
import 'package:frontend/modules/admin/presentation/screens/settings_page.dart';
import 'package:frontend/modules/admin/presentation/screens/support_and_complaints_page.dart';
import 'package:frontend/modules/admin/presentation/screens/user_registration.dart';
import 'package:frontend/modules/admin/presentation/screens/patients_management.dart';
import 'package:frontend/core/utils/colors.dart';
import 'package:frontend/modules/admin/presentation/widgets/layout/admin_menu_bar.dart';
import 'package:frontend/modules/admin/presentation/widgets/layout/search_field.dart';
import 'package:frontend/modules/doctor/presentation/screens/appointments_page.dart';
import 'package:flutter/material.dart';

class AdminLayout extends StatefulWidget {
  const AdminLayout({super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  bool isCollapsed = false;
  Admin currentPage = Admin.dashboard;

  Widget getPage() {
    switch (currentPage) {
      case Admin.dashboard:
        return const AdminDashboard();
      case Admin.patients:
        return const PatientsManagementPage();
      case Admin.doctors:
        return const DoctorManagement();
      case Admin.notifications:
        return const NotificationManagementPage();
      case Admin.settings:
        return const SettingsPage();
      case Admin.userRegistration:
        return const UserRegistration();
      case Admin.appointments:
        return const AppointmentsPage();
      case Admin.contentManagement:
        return const ContentManagementPage();
      case Admin.reviewsAndRatings:
        return const ReviewsAndRatingsPage();
      case Admin.supportAndComplaints:
        return const SupportAndComplaintsPage();
      case Admin.quizQuestionsManagement:
        return QuizQuestionsManagement();
      //case Admin.trainingModules:
      //  return const TrainingModulesPage();
      default:
        return const AdminDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool isTablet = width > 900 && width <= 1200;
    bool isMobile = width <= 900;
    if (isTablet) isCollapsed = true;
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      drawer: isMobile
          ? Drawer(
              child: AdminMenuBar(
                selectedPage: currentPage,
                isCollapsed: false,
                onMenuSelected: (page) {
                  setState(() {
                    currentPage = page;
                  });
                  Navigator.pop(context);
                },
              ),
            )
          : null,
      body: SafeArea(
        child: Row(
          children: [
            if (!isMobile)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: isCollapsed ? 80 : 250,
                child: AdminMenuBar(
                  selectedPage: currentPage,
                  isCollapsed: isCollapsed,
                  onMenuSelected: (page) {
                    setState(() {
                      currentPage = page;
                    });
                  },
                ),
              ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    height: 70,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Color(0xffe6e9ef)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Builder(
                          builder: (context) {
                            return IconButton(
                              icon: const Icon(
                                Icons.menu,
                                color: Colors.black54,
                              ),
                              onPressed: () {
                                if (isMobile) {
                                  Scaffold.of(context).openDrawer();
                                } else {
                                  setState(() {
                                    isCollapsed = !isCollapsed;
                                  });
                                }
                              },
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        if (width > 700) const Expanded(child: SearchField()),
                        if (width > 700) const SizedBox(width: 20),
                        if (width > 600) const Icon(Icons.notifications_none),
                        const SizedBox(width: 10),
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primaryColor,
                          child: Text("AD"),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(color: Colors.white, child: getPage()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
