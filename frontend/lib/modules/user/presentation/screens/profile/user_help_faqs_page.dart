import 'package:frontend/core/utils/colors.dart';
import 'package:frontend/core/utils/responsive_data.dart';
import 'package:flutter/material.dart';

class UserHelpFaqsPage extends StatefulWidget {
  const UserHelpFaqsPage({super.key});

  @override
  State<UserHelpFaqsPage> createState() => _UserHelpFaqsPageState();
}

class _UserHelpFaqsPageState extends State<UserHelpFaqsPage> {
  String _searchQuery = '';
  final Set<int> _expanded = {};

  static const List<Map<String, dynamic>> _faqs = [
    {
      'category': 'Appointments',
      'icon': Icons.calendar_month_rounded,
      'color': AppColors.primaryColor,
      'bg': AppColors.primarySurface,
      'items': [
        {
          'q': 'How do I book an appointment?',
          'a':
              'Go to the Doctors tab, find a doctor you like, and tap "Book Now". Choose a time slot and confirm your booking. You\'ll receive a confirmation notification.',
        },
        {
          'q': 'Can I reschedule my appointment?',
          'a':
              'Yes! Head to the Appointments tab, find your upcoming session, and tap "Reschedule". You can select a new time slot up to 2 hours before the session.',
        },
        {
          'q': 'How do I cancel an appointment?',
          'a':
              'Open the appointment card from your Appointments tab and tap "Cancel". Cancellations made 24 hours before the session are fully refunded.',
        },
      ],
    },
    {
      'category': 'Payments & Billing',
      'icon': Icons.credit_card_rounded,
      'color': AppColors.accentAmber,
      'bg': Color(0xFFFFF4E6),
      'items': [
        {
          'q': 'What payment methods are accepted?',
          'a':
              'We accept Visa, Mastercard, UPI, Net Banking, and digital wallets like Paytm and Google Pay.',
        },
        {
          'q': 'How do I get a refund?',
          'a':
              'Refunds for cancelled sessions are processed within 5–7 business days to your original payment method. Contact support if you face any issues.',
        },
        {
          'q': 'Is my payment information secure?',
          'a':
              'Yes. All payment data is encrypted using 256-bit SSL encryption. We never store your full card details on our servers.',
        },
      ],
    },
    {
      'category': 'Doctors & Sessions',
      'icon': Icons.medical_services_rounded,
      'color': AppColors.accentPurple,
      'bg': Color(0xFFEDE9FB),
      'items': [
        {
          'q': 'How do I join a video session?',
          'a':
              'A few minutes before your session, open the Appointments tab and tap "Join". Make sure you have a stable internet connection and your camera/microphone enabled.',
        },
        {
          'q': 'Are the sessions confidential?',
          'a':
              'Absolutely. All sessions are private, encrypted, and governed by strict confidentiality agreements. Your data is never shared without consent.',
        },
        {
          'q': 'Can I switch doctors?',
          'a':
              'Yes. You can explore and book with any available doctor at any time. There are no restrictions on booking with multiple practitioners.',
        },
      ],
    },
    {
      'category': 'Account & Privacy',
      'icon': Icons.lock_outline_rounded,
      'color': AppColors.accentGreen,
      'bg': Color(0xFFDCFCE7),
      'items': [
        {
          'q': 'How do I delete my account?',
          'a':
              'Go to Profile → Settings → Account Settings → Delete Account. Note that this action is irreversible and all your data will be permanently removed.',
        },
        {
          'q': 'How is my personal data used?',
          'a':
              'Your data is used only to provide you with our services. We do not sell or share personal data with third parties for advertising purposes.',
        },
      ],
    },
  ];

  List<Map<String, dynamic>> get _filteredFaqs {
    if (_searchQuery.isEmpty) return _faqs;
    final query = _searchQuery.toLowerCase();
    return _faqs
        .map((cat) {
          final filtered = (cat['items'] as List)
              .where(
                (item) =>
                    item['q'].toString().toLowerCase().contains(query) ||
                    item['a'].toString().toLowerCase().contains(query),
              )
              .toList();
          return filtered.isEmpty ? null : {...cat, 'items': filtered};
        })
        .whereType<Map<String, dynamic>>()
        .toList();
  }

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
          SliverToBoxAdapter(child: _buildSearchBar(hPad)),
          SliverToBoxAdapter(child: _buildContactBanner(hPad, isMobile)),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ..._filteredFaqs.map((cat) => _buildCategory(cat)),
                if (_filteredFaqs.isEmpty) _buildEmptyState(),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
              ]),
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
                'Help & FAQs',
                style: TextStyle(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Find answers to common questions',
                style: TextStyle(fontSize: 12, color: AppColors.mutedText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(double hPad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(
              Icons.search_rounded,
              color: AppColors.mutedText,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.darkText,
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  hintText: 'Search questions...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: AppColors.mutedText,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactBanner(double hPad, bool isMobile) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 0),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Can't find the answer?",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Contact our support team',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Contact Us',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(Map<String, dynamic> cat) {
    final color = cat['color'] as Color;
    final bg = cat['bg'] as Color;
    final items = cat['items'] as List;
    int globalStart = 0;

    for (var c in _filteredFaqs) {
      if (c == cat) break;
      globalStart += (c['items'] as List).length;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(cat['icon'] as IconData, color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                cat['category'],
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
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
              children: items.asMap().entries.map((e) {
                final qi = e.key;
                final globalIndex = globalStart + qi;
                final item = e.value;
                final isExpanded = _expanded.contains(globalIndex);
                final isLast = qi == items.length - 1;

                return Column(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() {
                        isExpanded
                            ? _expanded.remove(globalIndex)
                            : _expanded.add(globalIndex);
                      }),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                item['q'],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isExpanded
                                      ? AppColors.primaryColor
                                      : AppColors.darkText,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            AnimatedRotation(
                              turns: isExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 20,
                                color: AppColors.mutedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      child: isExpanded
                          ? Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                                bottom: 14,
                              ),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.bgColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                item['a'],
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.labelColor,
                                  height: 1.6,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    if (!isLast)
                      const Divider(
                        height: 1,
                        thickness: 1,
                        indent: 16,
                        color: AppColors.borderColor,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 34,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No results found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try a different search term',
            style: TextStyle(fontSize: 13, color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}
