import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/constants/responsive_data.dart';
import 'package:flutter/material.dart';

class UserLanguagePage extends StatefulWidget {
  const UserLanguagePage({super.key});

  @override
  State<UserLanguagePage> createState() => _UserLanguagePageState();
}

class _UserLanguagePageState extends State<UserLanguagePage> {
  String _selected = 'English';

  static const List<Map<String, dynamic>> _languages = [
    {'name': 'English', 'native': 'English', 'flag': '🇺🇸'},
    {'name': 'Hindi', 'native': 'हिन्दी', 'flag': '🇮🇳'},
    {'name': 'Tamil', 'native': 'தமிழ்', 'flag': '🇮🇳'},
    {'name': 'Telugu', 'native': 'తెలుగు', 'flag': '🇮🇳'},
    {'name': 'Kannada', 'native': 'ಕನ್ನಡ', 'flag': '🇮🇳'},
    {'name': 'Malayalam', 'native': 'മലയാളം', 'flag': '🇮🇳'},
    {'name': 'Bengali', 'native': 'বাংলা', 'flag': '🇮🇳'},
    {'name': 'Marathi', 'native': 'मराठी', 'flag': '🇮🇳'},
    {'name': 'Gujarati', 'native': 'ગુજરાતી', 'flag': '🇮🇳'},
    {'name': 'Arabic', 'native': 'العربية', 'flag': '🇸🇦'},
    {'name': 'French', 'native': 'Français', 'flag': '🇫🇷'},
    {'name': 'Spanish', 'native': 'Español', 'flag': '🇪🇸'},
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
          SliverToBoxAdapter(child: _buildCurrentBanner(hPad, isMobile)),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ALL LANGUAGES',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mutedText,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildLanguageList(),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
                ],
              ),
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
                'Language',
                style: TextStyle(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Choose your preferred language',
                style: TextStyle(fontSize: 12, color: AppColors.mutedText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentBanner(double hPad, bool isMobile) {
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
          borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
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
            Text(
              _languages.firstWhere((l) => l['name'] == _selected)['flag'],
              style: const TextStyle(fontSize: 36),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Language',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white60,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selected,
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
                Text(
                  _languages.firstWhere(
                    (l) => l['name'] == _selected,
                  )['native'],
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageList() {
    return Container(
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
      child: Column(
        children: _languages.asMap().entries.map((e) {
          final i = e.key;
          final lang = e.value;
          final isSelected = _selected == lang['name'];
          final isLast = i == _languages.length - 1;

          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() => _selected = lang['name']);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Language changed to ${lang['name']}'),
                      backgroundColor: AppColors.accentGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  color: isSelected
                      ? AppColors.primarySurface
                      : Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Text(lang['flag'], style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang['name'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? AppColors.primaryColor
                                    : AppColors.darkText,
                              ),
                            ),
                            Text(
                              lang['native'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.mutedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppColors.primaryColor
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryColor
                                : AppColors.borderColor,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check_rounded,
                                size: 13,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  thickness: 1,
                  indent: 64,
                  color: AppColors.borderColor,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
