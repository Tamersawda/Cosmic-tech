import 'dart:math' as math;
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/constants/responsive_data.dart';
import 'package:flutter/material.dart';

class DoctorEarningsPage extends StatefulWidget {
  const DoctorEarningsPage({super.key});

  @override
  State<DoctorEarningsPage> createState() => _DoctorEarningsPageState();
}

class _DoctorEarningsPageState extends State<DoctorEarningsPage>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 1; // 0=Day, 1=Week, 2=Month
  late TabController _tabController;

  // ── period labels ──
  final _dayLabel = 'Today: 2 Apr';
  final _weekLabel = '30 Mar – 5 Apr';
  final _monthLabel = 'April 2026';

  final _dayAmount = '₹4,200';
  final _weekAmount = '₹18,750';
  final _monthAmount = '₹72,500';

  String get _currentLabel =>
      [_dayLabel, _weekLabel, _monthLabel][_selectedTab];
  String get _currentAmount =>
      [_dayAmount, _weekAmount, _monthAmount][_selectedTab];

  // ── bar data ──
  final _dayBars = [3200.0, 4200.0];
  final _dayBarLabels = ['AM', 'PM'];

  final _weekBars = [2100.0, 3400.0, 2800.0, 4200.0, 3900.0, 1200.0, 900.0];
  final _weekBarLabels = ['30', '31', '1', '2', '3', '4', '5'];

  final _monthBars = [14200.0, 18750.0, 21300.0, 12500.0, 5750.0];
  final _monthBarLabels = ['1-5', '6-12', '13-19', '20-26', '27-30'];

  List<double> get _bars => [_dayBars, _weekBars, _monthBars][_selectedTab];
  List<String> get _barLabels =>
      [_dayBarLabels, _weekBarLabels, _monthBarLabels][_selectedTab];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedTab = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hPad = Responsive.horizontalPadding(context);
    final radius = Responsive.cardRadius(context);

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ───
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 14),
              child: Row(
                children: [
                  const Text(
                    'Earnings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        Icon(
                          Icons.share_rounded,
                          size: 18,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Share',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ─── Tab Switcher ───
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: ['Day', 'Week', 'Month'].asMap().entries.map((e) {
                    final selected = _selectedTab == e.key;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedTab = e.key);
                          _tabController.animateTo(e.key);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.all(4),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: selected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            e.value,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? AppColors.primaryColor
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ─── Period + Amount Navigator ───
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(radius),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.inputBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentLabel,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_drop_down_rounded,
                            size: 18,
                            color: AppColors.labelColor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: const Icon(
                            Icons.chevron_left_rounded,
                            size: 28,
                            color: AppColors.darkText,
                          ),
                        ),
                        Text(
                          _currentAmount,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: AppColors.darkText,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: const Icon(
                            Icons.chevron_right_rounded,
                            size: 28,
                            color: AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ─── Scrollable Body ───
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.bgColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildChartCard(radius),
                      const SizedBox(height: 14),
                      _buildStatsRow(),
                      const SizedBox(height: 14),
                      _buildBreakdownCard(radius),
                      const SizedBox(height: 14),
                      _buildPocketCard(radius),
                      const SizedBox(height: 14),
                      _buildMoreServices(radius),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  Bar Chart Card
  // ═══════════════════════════════════════════════

  Widget _buildChartCard(double radius) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _currentLabel,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: _EarningsBarChart(values: _bars, labels: _barLabels),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  Stats Row
  // ═══════════════════════════════════════════════

  Widget _buildStatsRow() {
    final stats = _selectedTab == 0
        ? [('8', 'Appointments'), ('2', 'Pending'), ('6h 20m', 'On duty')]
        : _selectedTab == 1
        ? [('42', 'Appointments'), ('3', 'Cancelled'), ('38h', 'On duty')]
        : [('164', 'Appointments'), ('9', 'Cancelled'), ('148h', 'On duty')];

    return Row(
      children: stats.asMap().entries.map((e) {
        final isLast = e.key == stats.length - 1;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: isLast ? 0 : 10),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  e.value.$1,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  e.value.$2,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.labelColor,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════════
  //  Breakdown Card
  // ═══════════════════════════════════════════════

  Widget _buildBreakdownCard(double radius) {
    final rows = _selectedTab == 0
        ? [
            ('Consultation fees', '₹3,500', AppColors.primaryColor),
            ('Follow-up fees', '₹500', AppColors.accentTeal),
            ('Incentive bonus', '₹200', AppColors.accentGreen),
            ('Other earnings', '₹0', AppColors.labelColor),
          ]
        : _selectedTab == 1
        ? [
            ('Consultation fees', '₹14,000', AppColors.primaryColor),
            ('Follow-up fees', '₹2,750', AppColors.accentTeal),
            ('Incentive bonus', '₹1,500', AppColors.accentGreen),
            ('Deductions', '-₹500', AppColors.dangerRed),
            ('Other earnings', '₹0', AppColors.labelColor),
          ]
        : [
            ('Consultation fees', '₹54,000', AppColors.primaryColor),
            ('Follow-up fees', '₹10,500', AppColors.accentTeal),
            ('Incentive bonus', '₹6,000', AppColors.accentGreen),
            ('Deductions', '-₹2,000', AppColors.dangerRed),
            ('Tips', '₹4,000', AppColors.accentAmber),
            ('Other earnings', '₹0', AppColors.labelColor),
          ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: rows.asMap().entries.map((e) {
          final isLast = e.key == rows.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: e.value.$3,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        e.value.$1,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkText,
                        ),
                      ),
                    ),
                    Text(
                      e.value.$2,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: e.value.$3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: AppColors.mutedText,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  color: AppColors.borderColor,
                  indent: 18,
                  endIndent: 18,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  Pocket Card
  // ═══════════════════════════════════════════════

  Widget _buildPocketCard(double radius) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Text(
              'POCKET',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryColor,
                letterSpacing: 1.2,
              ),
            ),
          ),
          _buildSimpleRow('Pocket balance', '₹0'),
          const Divider(
            height: 1,
            color: AppColors.borderColor,
            indent: 18,
            endIndent: 18,
          ),
          _buildSimpleRow('Available cash limit', '₹500'),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Deposit',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.inputBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Withdraw',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mutedText,
                      ),
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

  Widget _buildSimpleRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.darkText),
          ),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.mutedText,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  More Services Grid
  // ═══════════════════════════════════════════════

  Widget _buildMoreServices(double radius) {
    const services = [
      _ServiceItem(
        icon: Icons.account_balance_wallet_outlined,
        label: 'Payout',
        subtitle: '23 Mar – 29 Mar',
        value: '₹0',
      ),
      _ServiceItem(
        icon: Icons.monetization_on_outlined,
        label: 'Tips statement',
      ),
      _ServiceItem(
        icon: Icons.remove_circle_outline_rounded,
        label: 'Deduction statement',
      ),
      _ServiceItem(
        icon: Icons.receipt_long_outlined,
        label: 'Pocket statement',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'MORE SERVICES',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryColor,
              letterSpacing: 1.2,
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.55,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: services.map((s) => _buildServiceTile(s, radius)).toList(),
        ),
      ],
    );
  }

  Widget _buildServiceTile(_ServiceItem item, double radius) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.value != null)
            Text(
              item.value!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.darkText,
              ),
            ),
          Icon(item.icon, size: 22, color: AppColors.primaryColor),
          const Spacer(),
          Text(
            item.label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          if (item.subtitle != null)
            Text(
              item.subtitle!,
              style: const TextStyle(fontSize: 11, color: AppColors.labelColor),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Bar Chart Widget
// ═══════════════════════════════════════════════

class _EarningsBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;

  const _EarningsBarChart({required this.values, required this.labels});

  // Fixed pixel budgets so the bar column never overflows
  static const double _labelHeight = 14; // Text height
  static const double _spacerHeight = 6; // SizedBox between bar and label
  static const double _badgeHeight = 20; // Tooltip badge + bottom margin
  static const double _totalHeight = 120;
  static const double _maxBarHeight =
      _totalHeight - _labelHeight - _spacerHeight - _badgeHeight;

  @override
  Widget build(BuildContext context) {
    final maxVal = values.reduce(math.max);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: values.asMap().entries.map((e) {
        final frac = maxVal == 0 ? 0.0 : e.value / maxVal;
        final isHighest = e.value == maxVal;
        final barHeight = frac == 0 ? 4.0 : _maxBarHeight * frac;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Column(
              mainAxisSize: MainAxisSize.min, // ← don't expand, just wrap
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Badge slot — always takes up the same space
                SizedBox(
                  height: _badgeHeight,
                  child: isHighest
                      ? Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '₹${(e.value / 1000).toStringAsFixed(1)}k',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                // Bar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: isHighest
                        ? AppColors.primaryColor
                        : AppColors.primaryColor.withValues(alpha: 0.25),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: _spacerHeight),
                // Label
                SizedBox(
                  height: _labelHeight,
                  child: Text(
                    labels[e.key],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isHighest
                          ? AppColors.primaryColor
                          : AppColors.labelColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ═══════════════════════════════════════════════
//  Service Item Model
// ═══════════════════════════════════════════════

class _ServiceItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final String? value;

  const _ServiceItem({
    required this.icon,
    required this.label,
    this.subtitle,
    this.value,
  });
}
