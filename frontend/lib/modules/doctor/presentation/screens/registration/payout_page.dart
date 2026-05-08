import 'package:frontend/modules/doctor/presentation/screens/registration/submission_success_page.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_app_top_bar.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_bottom_navigation_bar.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_labeled_text_field.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_section_card.dart';
import 'package:frontend/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:frontend/modules/doctor/presentation/router/onboarding_page_route.dart';

class PayoutPage extends StatefulWidget {
  const PayoutPage({super.key});

  @override
  State<PayoutPage> createState() => _PayoutPageState();
}

class _PayoutPageState extends State<PayoutPage> {
  final _formKey = GlobalKey<FormState>();

  // ── Bank fields ───────────────────────────────────────────────────────────
  final _accountNameCtrl   = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  final _ifscCtrl          = TextEditingController();
  bool _showAccountNumber  = false;

  // ── Tax ───────────────────────────────────────────────────────────────────
  final _panCtrl = TextEditingController();

  // ── GST ───────────────────────────────────────────────────────────────────
  final _gstCtrl    = TextEditingController();
  bool _isGstRegistered = false;

  // ── IFSC lookup ───────────────────────────────────────────────────────────
  String? _bankName;
  String? _branchName;
  bool _ifscLoading = false;

  // ── Consent ───────────────────────────────────────────────────────────────
  bool _consentGiven = false;
  bool _consentTouched = false;

  // ── Session fee for breakdown preview ─────────────────────────────────────
  final double _sampleSessionFee = 1000.0;

  @override
  void dispose() {
    _accountNameCtrl.dispose();
    _accountNumberCtrl.dispose();
    _ifscCtrl.dispose();
    _panCtrl.dispose();
    _gstCtrl.dispose();
    super.dispose();
  }

  void _lookupIfsc() async {
    final code = _ifscCtrl.text.trim().toUpperCase();
    if (code.length < 11) return;
    setState(() {
      _ifscLoading = true;
      _bankName    = null;
      _branchName  = null;
    });
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _ifscLoading = false;
      _bankName    = 'State Bank of India';
      _branchName  = 'MG Road, Bengaluru';
    });
  }

  void _showCancellationPolicy() {
    showModalBottomSheet(
      context:      context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CancellationPolicyModal(),
    );
  }

  bool get _bankFilled =>
      _accountNameCtrl.text.isNotEmpty &&
      _accountNumberCtrl.text.isNotEmpty &&
      _ifscCtrl.text.isNotEmpty;

  // ── Earnings calculations ──────────────────────────────────────────────────
  double get _platformFee    => _sampleSessionFee * 0.2879;
  double get _tdsDeduction   => _sampleSessionFee * 0.10;
  double get _doctorReceives => _sampleSessionFee - _platformFee - _tdsDeduction;

  void _submit() {
    setState(() => _consentTouched = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_consentGiven) return;

    Navigator.push(
      context,
      smoothOnboardingRoute(const SubmissionSuccessPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 650;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const DoctorTopBar(),
            _PayoutProgressHeader(),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add your payout details to start accepting\nbookings and receiving earnings.',
                        style: TextStyle(
                          fontSize: 14,
                          color:    AppColors.mutedText,
                          height:   1.5,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Security banner ──────────────────────────────────
                      const _SecurityBanner(),
                      const SizedBox(height: 20),

                      // ── Bank account ─────────────────────────────────────
                      DoctorSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionHeader(
                              icon:     Icons.account_balance_outlined,
                              label:    'BANK ACCOUNT',
                              required: true,
                            ),
                            const SizedBox(height: 16),

                            const _FieldLabel('Account Holder Name *'),
                            const SizedBox(height: 8),
                            DoctorUnderlineTextField(
                              controller: _accountNameCtrl,
                              hint:       'As per your bank records',
                              onChanged:  (_) => setState(() {}),
                            ),
                            const SizedBox(height: 16),

                            const _FieldLabel('Account Number *'),
                            const SizedBox(height: 8),
                            _AccountNumberField(
                              controller:      _accountNumberCtrl,
                              visible:         _showAccountNumber,
                              onToggleVisible: () => setState(
                                () => _showAccountNumber = !_showAccountNumber,
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 16),



                            const _FieldLabel('IFSC Code *'),
                            const SizedBox(height: 8),
                            _IfscField(
                              controller: _ifscCtrl,
                              isLoading:  _ifscLoading,
                              bankName:   _bankName,
                              branchName: _branchName,
                              onChanged: (_) => setState(() {
                                _bankName   = null;
                                _branchName = null;
                              }),
                              onLookup: _lookupIfsc,
                            ),

                            if (_bankName != null) ...[
                              const SizedBox(height: 10),
                              _BankInfoChip(
                                bankName: _bankName!,
                                branch:   _branchName!,
                              ),
                            ],
                          ],
                        ),
                      ),

                      // ── Tax / PAN ─────────────────────────────────────────
                      DoctorSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionHeader(
                              icon:     Icons.receipt_long_outlined,
                              label:    'TAX INFORMATION',
                              required: true,
                            ),
                            const SizedBox(height: 16),
                            const _FieldLabel('PAN Number *'),
                            const SizedBox(height: 8),
                            DoctorUnderlineTextField(
                              controller: _panCtrl,
                              hint:       'e.g. ABCDE1234F',
                              onChanged:  (_) => setState(() {}),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor
                                    .withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.primaryColor
                                      .withValues(alpha: 0.15),
                                ),
                              ),
                              child: const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.info_outline,
                                      size: 14, color: AppColors.primaryColor),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'PAN is required for TDS compliance. '
                                      'Without PAN, TDS is deducted at 20% '
                                      'instead of 10%.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:    AppColors.labelColor,
                                        height:   1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── GST toggle ────────────────────────────────────────
                      DoctorSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionHeader(
                              icon:          Icons.business_outlined,
                              label:         'GST REGISTRATION',
                              required:      false,
                              optionalLabel: 'Optional',
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _GstOption(
                                    label:     'Yes, I am GST registered',
                                    selected:  _isGstRegistered,
                                    onTap: () => setState(
                                      () => _isGstRegistered = true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _GstOption(
                                    label:    'No, not registered',
                                    selected: !_isGstRegistered,
                                    onTap: () => setState(
                                      () => _isGstRegistered = false,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_isGstRegistered) ...[
                              const SizedBox(height: 16),
                              const _FieldLabel('GST Number'),
                              const SizedBox(height: 8),
                              DoctorUnderlineTextField(
                                controller: _gstCtrl,
                                hint:       'e.g. 22ABCDE1234F1Z5',
                              ),
                            ],
                          ],
                        ),
                      ),

                      // ── Consent ───────────────────────────────────────────
                      _ConsentCard(
                        agreed:   _consentGiven,
                        touched:  _consentTouched,
                        onChange: (v) => setState(() {
                          _consentGiven   = v ?? false;
                          _consentTouched = true;
                        }),
                      ),

                      if (_consentTouched && !_consentGiven) ...[
                        const SizedBox(height: 6),
                        const Row(
                          children: [
                            Icon(Icons.error_outline_rounded,
                                size: 13, color: Color(0xFFDC2626)),
                            SizedBox(width: 4),
                            Text(
                              'You must agree before submitting',
                              style: TextStyle(
                                fontSize: 11,
                                color:    Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            DoctorBottomBar(
              showBack:      true,
              showSaveDraft: true,
              nextLabel:     'Submit Details',
              onNext:        _submit,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Progress header ───────────────────────────────────────────────────────────

class _PayoutProgressHeader extends StatelessWidget {
  const _PayoutProgressHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color:  AppColors.cardColor,
        border: Border(bottom: BorderSide(color: AppColors.borderColor)),
      ),
      child: Row(
        children: [
          Container(
            width:  34,
            height: 34,
            decoration: BoxDecoration(
              color:        AppColors.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.payments_outlined,
                size: 18, color: AppColors.primaryColor),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payout Setup',
                  style: TextStyle(
                    fontSize:   15,
                    fontWeight: FontWeight.w800,
                    color:      AppColors.darkText,
                  ),
                ),
                Text(
                  'One-time setup · Takes 2 minutes',
                  style: TextStyle(fontSize: 12, color: AppColors.mutedText),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color:        AppColors.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Final Step',
              style: TextStyle(
                fontSize:   11,
                fontWeight: FontWeight.w700,
                color:      AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Security banner ───────────────────────────────────────────────────────────

class _SecurityBanner extends StatelessWidget {
  const _SecurityBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin:  Alignment.topLeft,
          end:    Alignment.bottomRight,
          colors: [
            AppColors.primaryColor.withValues(alpha: 0.85),
            AppColors.primaryColor,
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width:  40,
            height: 40,
            decoration: BoxDecoration(
              color:        Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.lock_outline,
                size: 20, color: Colors.white),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bank-Grade Encryption',
                  style: TextStyle(
                    fontSize:   14,
                    fontWeight: FontWeight.w700,
                    color:      Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Your financial details are encrypted with AES-256 and never shared.',
                  style: TextStyle(
                    fontSize: 12,
                    color:    Colors.white70,
                    height:   1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Earnings breakdown card ───────────────────────────────────────────────────

class _EarningsBreakdownCard extends StatelessWidget {
  final double sessionFee;
  final double platformFee;
  final double tdsDeduction;
  final double doctorReceives;

  const _EarningsBreakdownCard({
    required this.sessionFee,
    required this.platformFee,
    required this.tdsDeduction,
    required this.doctorReceives,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:        AppColors.cardColor,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:        AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bar_chart_rounded,
                    size: 16, color: AppColors.primaryColor),
              ),
              const SizedBox(width: 10),
              const Text(
                'YOUR EARNINGS BREAKDOWN',
                style: TextStyle(
                  fontSize:      11,
                  fontWeight:    FontWeight.w700,
                  color:         AppColors.primaryColor,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical:   3,
                ),
                decoration: BoxDecoration(
                  color:        AppColors.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Sample: ₹1000 session',
                  style: TextStyle(
                    fontSize: 10,
                    color:    AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Session fee
          _BreakdownRow(
            label:     'Session Fee',
            amount:    '₹${sessionFee.toStringAsFixed(0)}',
            isPositive: true,
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: AppColors.borderColor),
          ),

          // Deductions
          _BreakdownRow(
            label:  'Platform Fee (28.79%)',
            amount: '− ₹${platformFee.toStringAsFixed(2)}',
            color:  const Color(0xFFDC2626),
            sublabel: 'Covers infrastructure, support & processing',
          ),
          const SizedBox(height: 10),
          _BreakdownRow(
            label:    'TDS (10%)',
            amount:   '− ₹${tdsDeduction.toStringAsFixed(2)}',
            color:    const Color(0xFFDC2626),
            sublabel: 'Tax deducted at source (claimable in ITR)',
          ),
          const SizedBox(height: 10),
          _BreakdownRow(
            label:    'GST',
            amount:   '₹0.00',
            color:    AppColors.mutedText,
            sublabel: 'Not applicable if not GST registered',
          ),

          const SizedBox(height: 12),

          // Total
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor.withValues(alpha: 0.08),
                  AppColors.primaryColor.withValues(alpha: 0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primaryColor.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined,
                    size: 18, color: AppColors.primaryColor),
                const SizedBox(width: 10),
                const Text(
                  'You Receive',
                  style: TextStyle(
                    fontSize:   14,
                    fontWeight: FontWeight.w700,
                    color:      AppColors.darkText,
                  ),
                ),
                const Spacer(),
                Text(
                  '₹${doctorReceives.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize:   20,
                    fontWeight: FontWeight.w900,
                    color:      AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          const Text(
            '* Actual amounts vary based on your session fee. '
            'TDS is claimable when filing income tax returns.',
            style: TextStyle(
              fontSize:      11,
              color:         AppColors.mutedText,
              fontStyle:     FontStyle.italic,
              height:        1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String  label;
  final String  amount;
  final Color?  color;
  final bool    isPositive;
  final String? sublabel;

  const _BreakdownRow({
    required this.label,
    required this.amount,
    this.color,
    this.isPositive = false,
    this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize:   13,
                  color:      color ?? AppColors.darkText,
                  fontWeight: isPositive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontSize:   13,
                fontWeight: FontWeight.w700,
                color:      color ?? AppColors.darkText,
              ),
            ),
          ],
        ),
        if (sublabel != null) ...[
          const SizedBox(height: 2),
          Text(
            sublabel!,
            style: const TextStyle(
              fontSize: 11,
              color:    AppColors.mutedText,
            ),
          ),
        ],
      ],
    );
  }
}

// ── Deductions summary card ───────────────────────────────────────────────────

class _DeductionsSummaryCard extends StatelessWidget {
  const _DeductionsSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 15, color: Color(0xFF92400E)),
              SizedBox(width: 8),
              Text(
                'DEDUCTIONS APPLICABLE',
                style: TextStyle(
                  fontSize:      11,
                  fontWeight:    FontWeight.w700,
                  color:         Color(0xFF92400E),
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DeductionItem('Platform Fee',  '25–30% per session'),
          _DeductionItem('TDS',           '10% (20% without PAN)'),
          _DeductionItem('GST',           'Only if GST registered'),
          _DeductionItem('Cancellation',  'Penalty based on timing'),
          _DeductionItem('No-show',       '100% + additional penalty'),
        ],
      ),
    );
  }
}

class _DeductionItem extends StatelessWidget {
  final String label;
  final String value;
  const _DeductionItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.remove_rounded,
              size: 12, color: Color(0xFF92400E)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize:   12,
              fontWeight: FontWeight.w600,
              color:      Color(0xFF92400E),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color:    Color(0xFF78350F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Preferred payout method ───────────────────────────────────────────────────

class _PayoutMethodSelector extends StatelessWidget {
  final String   selected;
  final ValueChanged<String> onChanged;

  const _PayoutMethodSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PayoutMethodOption(
          value:       'bank',
          selected:    selected,
          icon:        Icons.account_balance_outlined,
          label:       'Bank Transfer',
          sublabel:    'Recommended · 2–3 business days',
          badge:       'Recommended',
          badgeColor:  AppColors.primaryColor,
          onChanged:   onChanged,
        ),
        const SizedBox(height: 10),
        _PayoutMethodOption(
          value:      'upi',
          selected:   selected,
          icon:       Icons.flash_on_outlined,
          label:      'UPI',
          sublabel:   'Instant for amounts below ₹1 lakh',
          badge:      'Fastest',
          badgeColor: AppColors.successGreen,
          onChanged:  onChanged,
        ),
      ],
    );
  }
}

class _PayoutMethodOption extends StatelessWidget {
  final String   value;
  final String   selected;
  final IconData icon;
  final String   label;
  final String   sublabel;
  final String   badge;
  final Color    badgeColor;
  final ValueChanged<String> onChanged;

  const _PayoutMethodOption({
    required this.value,
    required this.selected,
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.badge,
    required this.badgeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:  const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:        isSelected
              ? AppColors.primaryColor.withValues(alpha: 0.06)
              : AppColors.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : AppColors.borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width:  36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryColor.withValues(alpha: 0.12)
                    : AppColors.bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size:  18,
                color: isSelected
                    ? AppColors.primaryColor
                    : AppColors.mutedText,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize:   14,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppColors.primaryColor
                          : AppColors.darkText,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: const TextStyle(
                      fontSize: 11,
                      color:    AppColors.mutedText,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical:   3,
              ),
              decoration: BoxDecoration(
                color:        badgeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  fontSize:   10,
                  fontWeight: FontWeight.w700,
                  color:      badgeColor,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? AppColors.primaryColor
                  : AppColors.mutedText,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ── IFSC field ────────────────────────────────────────────────────────────────

class _IfscField extends StatelessWidget {
  final TextEditingController controller;
  final bool     isLoading;
  final String?  bankName;
  final String?  branchName;
  final ValueChanged<String> onChanged;
  final VoidCallback onLookup;

  const _IfscField({
    required this.controller,
    required this.isLoading,
    required this.bankName,
    required this.branchName,
    required this.onChanged,
    required this.onLookup,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: DoctorUnderlineTextField(
            controller: controller,
            hint:       'e.g. SBIN0001234',
            onChanged:  onChanged,
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onLookup,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical:   9,
            ),
            decoration: BoxDecoration(
              color: isLoading
                  ? AppColors.borderColor
                  : (bankName != null
                      ? AppColors.successGreen
                      : AppColors.primaryColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: isLoading
                ? const SizedBox(
                    width:  16,
                    height: 16,
                    child:  CircularProgressIndicator(
                      strokeWidth: 2,
                      color:       Colors.white,
                    ),
                  )
                : Text(
                    bankName != null ? 'Verified ✓' : 'Verify',
                    style: const TextStyle(
                      fontSize:   13,
                      fontWeight: FontWeight.w600,
                      color:      Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _BankInfoChip extends StatelessWidget {
  final String bankName;
  final String branch;

  const _BankInfoChip({required this.bankName, required this.branch});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color:        AppColors.successGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border:       Border.all(
          color: AppColors.successGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 14, color: AppColors.successGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$bankName · $branch',
              style: TextStyle(
                fontSize:   12,
                color:      AppColors.successGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Account number field ──────────────────────────────────────────────────────

class _AccountNumberField extends StatelessWidget {
  final TextEditingController controller;
  final bool         visible;
  final bool         showToggle;
  final String?      hint;
  final VoidCallback? onToggleVisible;
  final ValueChanged<String>? onChanged;

  const _AccountNumberField({
    required this.controller,
    required this.visible,
    this.showToggle      = true,
    this.hint,
    this.onToggleVisible,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller:   controller,
      obscureText:  !visible,
      keyboardType: TextInputType.number,
      onChanged:    onChanged,
      style: const TextStyle(
        fontSize:      15,
        color:         AppColors.darkText,
        letterSpacing: 1.5,
      ),
      decoration: InputDecoration(
        hintText:  hint ?? '●●●● ●●●● ●●●●',
        hintStyle: const TextStyle(
          color:         AppColors.hintColor,
          fontSize:      15,
          letterSpacing: 0,
        ),
        suffixIcon: showToggle && onToggleVisible != null
            ? GestureDetector(
                onTap: onToggleVisible,
                child: Icon(
                  visible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size:  18,
                  color: AppColors.mutedText,
                ),
              )
            : null,
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.primaryColor,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
      ),
    );
  }
}

// ── Payout schedule card ──────────────────────────────────────────────────────

class _PayoutScheduleCard extends StatelessWidget {
  const _PayoutScheduleCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PAYOUT SCHEDULE',
            style: TextStyle(
              fontSize:      10,
              fontWeight:    FontWeight.w700,
              color:         Color(0xFF94A3B8),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          _PayoutScheduleRow(
            icon:  Icons.calendar_today_outlined,
            label: 'Payout Cycle',
            value: 'Weekly (Mon–Sun)',
          ),
          _PayoutScheduleRow(
            icon:  Icons.event_outlined,
            label: 'Payout Day',
            value: 'Every Friday',
          ),
          _PayoutScheduleRow(
            icon:  Icons.account_balance_outlined,
            label: 'Processing Time',
            value: '1–2 business days',
          ),
          _PayoutScheduleRow(
            icon:  Icons.flash_on_outlined,
            label: 'UPI Transfer',
            value: 'Instant (< ₹1 lakh)',
          ),
          _PayoutScheduleRow(
            icon:   Icons.receipt_outlined,
            label:  'TDS Deduction',
            value:  '10% above ₹30,000/year',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _PayoutScheduleRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final bool     isLast;

  const _PayoutScheduleRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color:    Color(0xFF94A3B8),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize:   12,
              fontWeight: FontWeight.w600,
              color:      Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Minimum threshold card ────────────────────────────────────────────────────

class _MinimumThresholdCard extends StatelessWidget {
  const _MinimumThresholdCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width:  36,
            height: 36,
            decoration: BoxDecoration(
              color:        AppColors.accentAmber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.account_balance_wallet_outlined,
                size: 18, color: AppColors.accentAmber),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MINIMUM PAYOUT THRESHOLD',
                  style: TextStyle(
                    fontSize:      9,
                    fontWeight:    FontWeight.w700,
                    color:         AppColors.mutedText,
                    letterSpacing: 0.6,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '₹1,500',
                      style: TextStyle(
                        fontSize:   16,
                        fontWeight: FontWeight.w800,
                        color:      AppColors.accentAmber,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Balance below ₹1,500 rolls over to next weekly cycle.',
                        style: TextStyle(
                          fontSize: 11,
                          color:    AppColors.mutedText,
                          height:   1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Cancellation policy summary ───────────────────────────────────────────────

class _CancellationPolicySummaryCard extends StatelessWidget {
  final VoidCallback onViewFull;
  const _CancellationPolicySummaryCard({required this.onViewFull});

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.cardColor,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.gavel_outlined,
                  size: 15, color: AppColors.accentPurple),
              const SizedBox(width: 8),
              const Text(
                'CANCELLATION POLICY',
                style: TextStyle(
                  fontSize:      11,
                  fontWeight:    FontWeight.w700,
                  color:         AppColors.accentPurple,
                  letterSpacing: 0.6,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onViewFull,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical:   3,
                  ),
                  decoration: BoxDecoration(
                    color:        AppColors.accentPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'View Full Policy',
                    style: TextStyle(
                      fontSize:   10,
                      fontWeight: FontWeight.w700,
                      color:      AppColors.accentPurple,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _CancellationRow('24+ hours before',  'No deduction',    AppColors.successGreen),
          _CancellationRow('12–24 hours before', '25% deduction',  AppColors.accentAmber),
          _CancellationRow('6–12 hours before',  '50% deduction',  AppColors.accentAmber),
          _CancellationRow('< 6 hours before',   '100% deduction', const Color(0xFFDC2626)),
          _CancellationRow('No-show',             '100% + penalty', const Color(0xFFDC2626)),
        ],
      ),
    );
  }
}

class _CancellationRow extends StatelessWidget {
  final String label;
  final String value;
  final Color  color;

  const _CancellationRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Container(
            width:  6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color:    AppColors.darkText,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize:   12,
              fontWeight: FontWeight.w600,
              color:      color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Cancellation policy full modal ────────────────────────────────────────────

class _CancellationPolicyModal extends StatelessWidget {
  const _CancellationPolicyModal();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color:        AppColors.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width:  40,
              height: 4,
              decoration: BoxDecoration(
                color:        AppColors.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Full Cancellation Policy',
            style: TextStyle(
              fontSize:   18,
              fontWeight: FontWeight.w800,
              color:      AppColors.darkText,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Deductions are calculated based on notice period before the scheduled session.',
            style: TextStyle(
              fontSize: 13,
              color:    AppColors.mutedText,
              height:   1.4,
            ),
          ),
          const SizedBox(height: 20),

          _PolicySection('By Doctor',    _doctorPolicies),
          const SizedBox(height: 16),
          _PolicySection('By Patient',   _patientPolicies),
          const SizedBox(height: 16),
          _PolicySection('No-Show',      _noShowPolicies),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding:         const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Got it',
                style: TextStyle(
                  fontSize:   15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  static const _doctorPolicies = [
    ('24+ hrs notice',   'No penalty'),
    ('12–24 hrs notice', '25% of session fee deducted'),
    ('6–12 hrs notice',  '50% of session fee deducted'),
    ('< 6 hrs notice',   '100% of session fee deducted'),
  ];

  static const _patientPolicies = [
    ('24+ hrs notice',   'Full refund to patient'),
    ('12–24 hrs notice', '75% refund to patient'),
    ('< 12 hrs notice',  'No refund'),
  ];

  static const _noShowPolicies = [
    ('Doctor no-show',  '100% refund to patient + ₹200 penalty'),
    ('Patient no-show', 'No refund · Doctor receives 80% of session fee'),
  ];
}

class _PolicySection extends StatelessWidget {
  final String                     title;
  final List<(String, String)> items;

  const _PolicySection(this.title, this.items);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize:   13,
            fontWeight: FontWeight.w700,
            color:      AppColors.darkText,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ',
                    style: TextStyle(color: AppColors.primaryColor)),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 12,
                        color:    AppColors.darkText,
                      ),
                      children: [
                        TextSpan(
                          text: '${item.$1}: ',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: item.$2),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Field label ───────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize:   13,
        fontWeight: FontWeight.w600,
        color:      AppColors.labelColor,
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String   label;
  final bool     required;
  final String?  optionalLabel;

  const _SectionHeader({
    required this.icon,
    required this.label,
    this.required = true,
    this.optionalLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryColor),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize:      11,
            fontWeight:    FontWeight.w700,
            color:         AppColors.primaryColor,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Container(height: 1, color: AppColors.borderColor)),
        if (required) ...[
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color:        const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Required',
              style: TextStyle(
                fontSize:   10,
                fontWeight: FontWeight.w700,
                color:      Color(0xFFDC2626),
              ),
            ),
          ),
        ],
        if (!required && optionalLabel != null) ...[
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color:        AppColors.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              optionalLabel!,
              style: const TextStyle(
                fontSize:   10,
                fontWeight: FontWeight.w700,
                color:      AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── GST option tile ───────────────────────────────────────────────────────────

class _GstOption extends StatelessWidget {
  final String      label;
  final bool        selected;
  final VoidCallback onTap;

  const _GstOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryColor.withValues(alpha: 0.06)
              : AppColors.inputBgLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColors.primaryColor.withValues(alpha: 0.5)
                : AppColors.borderColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size:  18,
              color: selected ? AppColors.primaryColor : AppColors.mutedText,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize:   11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppColors.primaryColor : AppColors.labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── First payout info card ────────────────────────────────────────────────────

class _FirstPayoutInfoCard extends StatelessWidget {
  const _FirstPayoutInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.primaryColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width:  36,
            height: 36,
            decoration: BoxDecoration(
              color:        AppColors.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.info_outline,
                size: 18, color: AppColors.primaryColor),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FIRST PAYOUT',
                  style: TextStyle(
                    fontSize:      10,
                    fontWeight:    FontWeight.w700,
                    color:         AppColors.primaryColor,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your first payout may take up to 7 business days for verification. '
                  'Subsequent payouts follow the weekly schedule.',
                  style: TextStyle(
                    fontSize: 12,
                    color:    AppColors.labelColor,
                    height:   1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Payout status card ────────────────────────────────────────────────────────

class _PayoutStatusCard extends StatelessWidget {
  const _PayoutStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width:  34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.mutedText.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_outlined,
                size: 17, color: AppColors.mutedText),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PAYOUT VERIFICATION STATUS',
                  style: TextStyle(
                    fontSize:      9,
                    fontWeight:    FontWeight.w700,
                    color:         AppColors.mutedText,
                    letterSpacing: 0.7,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Status will be updated after admin verification.',
                  style: TextStyle(
                    fontSize:  12,
                    color:     AppColors.mutedText,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Consent card ──────────────────────────────────────────────────────────────

class _ConsentCard extends StatelessWidget {
  final bool               agreed;
  final bool               touched;
  final ValueChanged<bool?> onChange;

  const _ConsentCard({
    required this.agreed,
    required this.touched,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChange(!agreed),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width:   double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: agreed
              ? AppColors.primaryColor.withValues(alpha: 0.06)
              : AppColors.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: touched && !agreed
                ? const Color(0xFFDC2626)
                : agreed
                    ? AppColors.primaryColor.withValues(alpha: 0.4)
                    : AppColors.borderColor,
            width: agreed ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width:  22,
              height: 22,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: agreed ? AppColors.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: agreed ? AppColors.primaryColor : AppColors.mutedText,
                  width: 1.5,
                ),
              ),
              child: agreed
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'I confirm that my payout details are correct',
                    style: TextStyle(
                      fontSize:   14,
                      fontWeight: FontWeight.w700,
                      color:      AppColors.darkText,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'I understand that incorrect details may delay my payouts. '
                    'I agree to the platform\'s payout terms and cancellation policy.',
                    style: TextStyle(
                      fontSize: 12,
                      color:    AppColors.labelColor,
                      height:   1.5,
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
}