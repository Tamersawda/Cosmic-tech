/* import 'package:frontend/modules/doctor/models/appointment_model.dart';
import 'package:frontend/modules/doctor/router/main_layout.dart';
import 'package:frontend/modules/doctor/router/error_page.dart';
import 'package:frontend/modules/doctor/screens/appointment_details_page.dart';
import 'package:frontend/modules/doctor/screens/appointments_page.dart';
import 'package:frontend/modules/doctor/screens/doctor_profile_page.dart';
import 'package:frontend/modules/doctor/screens/home_page.dart';
import 'package:frontend/modules/doctor/screens/patients_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyAppRoutes {
  static GoRouter returnRouter(bool isAuth) {
    return GoRouter(
      initialLocation: '/',
      routes: [

        ShellRoute(
          builder: (context, state, child) {
            return MainLayout(
              location: state.fullPath ?? '/',
              child: child,
            );
          },
          routes: [

            GoRoute(
              path: '/',
              pageBuilder: (context, state) => const MaterialPage(
                child: HomePage(),
              ),
            ),

            GoRoute(
              path: '/appointments',
              pageBuilder: (context, state) => MaterialPage(
                child: AppointmentsPage(),
              ),
            ),

            GoRoute(
              path: '/patients',
              pageBuilder: (context, state) => const MaterialPage(
                child: PatientsPage(),
              ),
            ),
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) => const MaterialPage(
                child: ProfileCompletedPage()
              ),
            ),

            GoRoute(
              path: '/appointment_details',
              pageBuilder: (context, state) {
                final appointment = state.extra as Appointment?;
                if (appointment == null) {
                  return MaterialPage(
                    child: ErrorPage(),
                  );
                }
                return MaterialPage(
                  child: AppointmentDetailsPage(appointment: appointment),
                );
              },
            )

          ],
        ),
      ],

      errorPageBuilder: (context, state) => const MaterialPage(
        child: ErrorPage(),
      ),

      redirect: (context, state) {
        final location = state.fullPath ?? '/';

        if (!isAuth && location.startsWith('/profile')) {
          return '/';
        }

        return null;
      },
    );
  }
} */
