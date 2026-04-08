import 'package:frontend/modules/doctor/screens/doctor_earnings_page.dart';
import 'package:frontend/modules/doctor/screens/doctor_profile_page.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:frontend/modules/doctor/screens/home_page.dart';
import 'package:frontend/modules/doctor/screens/appointments_page.dart';
import 'package:frontend/modules/doctor/screens/patients_page.dart';

class MainDoctorLayout extends StatefulWidget {
  const MainDoctorLayout({super.key});

  @override
  State<MainDoctorLayout> createState() => _MainDoctorLayoutState();
}

class _MainDoctorLayoutState extends State<MainDoctorLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    DoctorHomePage(),
    AppointmentsPage(),
    PatientsPage(),
    DoctorEarningsPage(),
    DoctorProfilePage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 10,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        iconSize: 24,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: "Appointments",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: "Patients",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: "Earnings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
