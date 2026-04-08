import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/constants/responsive_data.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class HomeCarousel extends StatefulWidget {
  const HomeCarousel({super.key});

  @override
  State<HomeCarousel> createState() => _HomeCarouselState();
}

class _HomeCarouselState extends State<HomeCarousel> {
  final PageController _controller = PageController(viewportFraction: 0.88);
  int _currentSlide = 0;
  Timer? _timer;

  final List<Map<String, dynamic>> _slides = [
    {
      'title': 'Your Mind\nMatters',
      'subtitle': 'Book therapy in minutes',
      'colors': AppColors.primaryGradient,
      'icon': Icons.spa_rounded,
    },
    {
      'title': 'Talk to a\nPsychiatrist',
      'subtitle': 'Safe, private & confidential',
      'colors': AppColors.purpleGradient,
      'icon': Icons.psychology_rounded,
    },
    {
      'title': 'Daily Wellness\nCheck-in',
      'subtitle': 'Track your mental health journey',
      'colors': AppColors.blueGradient,
      'icon': Icons.favorite_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      final next = (_currentSlide + 1) % _slides.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Padding(
      padding: EdgeInsets.only(top: Responsive.sectionSpacing(context)),
      child: Column(
        children: [
          SizedBox(
            height: isMobile ? 160 : 200,
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (i) => setState(() => _currentSlide = i),
              itemCount: _slides.length,
              itemBuilder: (_, i) => _buildSlide(_slides[i]),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_slides.length, (i) {
              final active = i == _currentSlide;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.primaryColor
                      : AppColors.borderColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(Map<String, dynamic> slide) {
    final colors = List<Color>.from(slide['colors']);
    final isMobile = Responsive.isMobile(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
      ),
      child: Stack(
        children: [
          Positioned(right: -20, top: -20, child: _decorCircle(100, 0.08)),
          Positioned(right: 30, bottom: -30, child: _decorCircle(70, 0.06)),
          Positioned(
            right: 20,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: isMobile ? 70 : 90,
                height: isMobile ? 70 : 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                ),
                child: Icon(
                  slide['icon'] as IconData,
                  color: AppColors.white,
                  size: isMobile ? 34 : 44,
                ),
              ),
            ),
          ),
          Positioned(
            left: 22,
            top: 0,
            bottom: 0,
            right: isMobile ? 110 : 140,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slide['title'],
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  slide['subtitle'],
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Book Session',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.first,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _decorCircle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}
