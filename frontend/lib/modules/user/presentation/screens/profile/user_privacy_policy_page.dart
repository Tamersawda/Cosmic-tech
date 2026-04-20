import 'package:frontend/core/utils/colors.dart';
import 'package:frontend/core/utils/responsive_data.dart';
import 'package:flutter/material.dart';

class UserPrivacyPolicyPage extends StatelessWidget {
  const UserPrivacyPolicyPage({super.key});

  static const List<Map<String, dynamic>> _sections = [
    {
      'title': 'Information We Collect',
      'icon': Icons.info_outline_rounded,
      'color': AppColors.primaryColor,
      'bg': AppColors.primarySurface,
      'body':
          'We collect information you provide directly to us, including your name, email address, phone number, date of birth, and health information. We also collect data generated through your use of the app such as appointments, session notes, and interaction data.',
    },
    {
      'title': 'How We Use Information',
      'icon': Icons.manage_search_rounded,
      'color': AppColors.accentPurple,
      'bg': Color(0xFFEDE9FB),
      'body':
          'We use the information we collect to provide, maintain, and improve our services, process transactions, send you technical notices and support messages, and respond to your comments and questions. We also use it to personalise your experience and match you with the most suitable doctors.',
    },
    {
      'title': 'Data Sharing & Disclosure',
      'icon': Icons.share_outlined,
      'color': AppColors.accentAmber,
      'bg': Color(0xFFFFF4E6),
      'body':
          'We do not sell your personal data to third parties. We may share information with healthcare practitioners involved in your care with your explicit consent. We may also share data with third‑party service providers who assist us in operating the app under strict data processing agreements.',
    },
    {
      'title': 'Data Security',
      'icon': Icons.lock_outline_rounded,
      'color': AppColors.accentGreen,
      'bg': Color(0xFFDCFCE7),
      'body':
          'We implement industry-standard security measures including 256-bit SSL encryption, secure data storage, and regular security audits. Access to personal data is restricted to authorised personnel only. Despite our efforts, no method of transmission over the Internet is 100% secure.',
    },
    {
      'title': 'Session Confidentiality',
      'icon': Icons.psychology_outlined,
      'color': AppColors.accentSky,
      'bg': Color(0xFFE8F6FD),
      'body':
          'All therapy sessions are governed by strict professional confidentiality agreements. Session recordings (where applicable) are encrypted and stored securely. Practitioners are bound by ethical and legal obligations regarding client confidentiality.',
    },
    {
      'title': 'Your Rights',
      'icon': Icons.gavel_rounded,
      'color': AppColors.accentTeal,
      'bg': Color(0xFFE0F7FA),
      'body':
          'You have the right to access, correct, or delete the personal data we hold about you. You may also object to or restrict certain processing, and request data portability. To exercise these rights, contact us at privacy@demodoctorapp.com.',
    },
    {
      'title': 'Cookies & Tracking',
      'icon': Icons.cookie_outlined,
      'color': AppColors.accentAmber,
      'bg': Color(0xFFFFF4E6),
      'body':
          'We use cookies and similar tracking technologies to enhance your experience. You can control cookie settings through your device or browser settings. Disabling cookies may affect app functionality.',
    },
    {
      'title': 'Changes to This Policy',
      'icon': Icons.edit_note_rounded,
      'color': AppColors.accentPurple,
      'bg': Color(0xFFEDE9FB),
      'body':
          'We may update this Privacy Policy from time to time. We will notify you of any significant changes via in-app notification or email. Your continued use of the app after changes constitutes your acceptance of the revised policy.',
    },
    {
      'title': 'Contact Us',
      'icon': Icons.mail_outline_rounded,
      'color': AppColors.primaryColor,
      'bg': AppColors.primarySurface,
      'body':
          'If you have any questions or concerns about this Privacy Policy, please contact our Data Protection Officer at: privacy@demodoctorapp.com or write to us at DemoDoctor Pvt. Ltd., 123 Wellness Park, Bengaluru, Karnataka, India — 560001.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final hPad = Responsive.horizontalPadding(context);
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, hPad, isMobile)),
          SliverToBoxAdapter(child: _buildEffectiveBanner(hPad, isMobile)),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((_, i) {
                if (i == _sections.length) {
                  return SizedBox(
                    height: MediaQuery.of(context).padding.bottom + 32,
                  );
                }
                return _buildSection(_sections[i]);
              }, childCount: _sections.length + 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double hPad, bool isMobile) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(
        hPad,
        MediaQuery.of(context).padding.top + 14,
        hPad,
        18,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppColors.darkText,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy Policy',
                style: TextStyle(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'How we handle your data',
                style: TextStyle(fontSize: 12, color: AppColors.mutedText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEffectiveBanner(double hPad, bool isMobile) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 0),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 18 : 22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shield_rounded,
                size: 24,
                color: AppColors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Effective Date: 1 January 2025',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    'Last Updated: 28 March 2026',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(Map<String, dynamic> section) {
    final color = section['color'] as Color;
    final bg = section['bg'] as Color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      section['icon'] as IconData,
                      color: color,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      section['title'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  section['body'],
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.labelColor,
                    height: 1.7,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
