import 'package:frontend/core/utils/colors.dart';
import 'package:frontend/core/utils/enums.dart';
import 'package:frontend/modules/admin/presentation/widgets/layout/menu_tile.dart';
import 'package:flutter/material.dart';

class AdminMenuBar extends StatelessWidget {
  final Function(Admin) onMenuSelected;
  final Admin selectedPage;
  final bool isCollapsed;

  const AdminMenuBar({
    super.key,
    required this.onMenuSelected,
    required this.selectedPage,
    required this.isCollapsed,
  });

  Widget menuTile({
    required IconData icon,
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return MenuTile(
      icon: icon,
      title: title,
      selected: selected,
      collapsed: isCollapsed,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryColor,

      child: Column(
        crossAxisAlignment: isCollapsed
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,

        children: [
          const SizedBox(height: 10),

          /// HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: Color(0xff1F2937),
                    size: 22,
                  ),
                ),

                if (!isCollapsed) ...[
                  const SizedBox(width: 10),
                  const Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Admin Panel",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Management System",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Divider(color: Colors.white24),

          /// SCROLLABLE MENU
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  menuTile(
                    icon: Icons.dashboard_outlined,
                    title: 'Dashboard',
                    selected: selectedPage == Admin.dashboard,
                    onTap: () => onMenuSelected(Admin.dashboard),
                  ),
                  menuTile(
                    icon: Icons.people_outline,
                    title: 'Patients',
                    selected: selectedPage == Admin.patients,
                    onTap: () => onMenuSelected(Admin.patients),
                  ),
                  menuTile(
                    icon: Icons.local_pharmacy_rounded,
                    title: 'Doctors',
                    selected: selectedPage == Admin.doctors,
                    onTap: () => onMenuSelected(Admin.doctors),
                  ),
                  menuTile(
                    icon: Icons.calendar_today_outlined,
                    title: 'Appointments',
                    selected: selectedPage == Admin.appointments,
                    onTap: () => onMenuSelected(Admin.appointments),
                  ),
                  menuTile(
                    icon: Icons.content_paste_outlined,
                    title: 'Content Management',
                    selected: selectedPage == Admin.contentManagement,
                    onTap: () => onMenuSelected(Admin.contentManagement),
                  ),
                  menuTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    selected: selectedPage == Admin.notifications,
                    onTap: () => onMenuSelected(Admin.notifications),
                  ),
                  menuTile(
                    icon: Icons.quiz_outlined,
                    title: 'Quiz Management',
                    selected: selectedPage == Admin.quizQuestionsManagement,
                    onTap: () => onMenuSelected(Admin.quizQuestionsManagement),
                  ),
                  menuTile(
                    icon: Icons.rate_review_outlined,
                    title: 'Reviews & Ratings',
                    selected: selectedPage == Admin.reviewsAndRatings,
                    onTap: () => onMenuSelected(Admin.reviewsAndRatings),
                  ),
                  menuTile(
                    icon: Icons.support_agent_outlined,
                    title: 'Support & Complaints',
                    selected: selectedPage == Admin.supportAndComplaints,
                    onTap: () => onMenuSelected(Admin.supportAndComplaints),
                  ),
                  //menuTile(
                  //  icon: Icons.library_books,
                  //  title: 'Training Modules',
                  //  selected: selectedPage == Admin.trainingModules,
                  //  onTap: () => onMenuSelected(Admin.trainingModules),
                  //),
                  menuTile(
                    icon: Icons.supervised_user_circle_outlined,
                    title: 'User Registration',
                    selected: selectedPage == Admin.userRegistration,
                    onTap: () => onMenuSelected(Admin.userRegistration),
                  ),
                  menuTile(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    selected: selectedPage == Admin.settings,
                    onTap: () => onMenuSelected(Admin.settings),
                  ),
                ],
              ),
            ),
          ),
          const Divider(color: Colors.white24),
          menuTile(
            icon: Icons.logout,
            title: 'Logout',
            selected: false,
            onTap: () {},
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
