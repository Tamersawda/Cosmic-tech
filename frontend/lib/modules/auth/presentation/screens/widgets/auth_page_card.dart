import 'package:flutter/material.dart';
import 'package:frontend/core/utils/colors.dart';
import 'package:frontend/core/utils/responsive_data.dart';

class AuthPageCard extends StatelessWidget {
  final Widget child;

  /// Optional gradient decoration — used on ForgotPasswordPage.
  final bool useGradient;

  const AuthPageCard({
    super.key,
    required this.child,
    this.useGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: isMobile ? double.infinity : 420,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: useGradient ? null : AppColors.white,
                gradient: useGradient
                    ? const LinearGradient(
                        colors: AppColors.wellnessBannerGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkText.withOpacity(0.06),
                    blurRadius: 28,
                    spreadRadius: 3,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
