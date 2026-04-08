import 'package:flutter/material.dart';

class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
      MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  static double horizontalPadding(BuildContext context) =>
      isDesktop(context) ? 40.0 : 20.0;

  static double cardRadius(BuildContext context) =>
      isDesktop(context) ? 24.0 : 18.0;

  static double sectionSpacing(BuildContext context) =>
      isDesktop(context) ? 36.0 : 28.0;
}
