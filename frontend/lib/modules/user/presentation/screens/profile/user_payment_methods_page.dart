import 'package:frontend/core/utils/colors.dart';
import 'package:frontend/core/utils/responsive_data.dart';
import 'package:flutter/material.dart';

class UserPaymentMethodsPage extends StatefulWidget {
  const UserPaymentMethodsPage({super.key});

  @override
  State<UserPaymentMethodsPage> createState() => _UserPaymentMethodsPageState();
}

class _UserPaymentMethodsPageState extends State<UserPaymentMethodsPage> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _cards = [
    {
      'type': 'Visa',
      'last4': '4242',
      'expiry': '08/26',
      'holder': 'Tamer',
      'gradient': [const Color(0xFF1D0E8A), const Color(0xFF3D2CC4)],
      'icon': Icons.credit_card_rounded,
    },
    {
      'type': 'Mastercard',
      'last4': '8921',
      'expiry': '11/25',
      'holder': 'Tamer',
      'gradient': [const Color(0xFF7C3AED), const Color(0xFF4A2FCC)],
      'icon': Icons.credit_card_rounded,
    },
  ];

  final List<Map<String, dynamic>> _upiMethods = [
    {
      'label': 'tamer@upi',
      'bank': 'HDFC Bank',
      'icon': Icons.account_balance_rounded,
      'color': AppColors.accentGreen,
    },
    {
      'label': 'tamer@paytm',
      'bank': 'Paytm',
      'icon': Icons.account_balance_wallet_rounded,
      'color': AppColors.accentSky,
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
          SliverPadding(
            padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Saved Cards ──
                _sectionLabel('Saved Cards'),
                const SizedBox(height: 12),
                SizedBox(
                  height: isMobile ? 170 : 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _cards.length + 1,
                    itemBuilder: (_, i) {
                      if (i == _cards.length) {
                        return _buildAddCardSlot(isMobile);
                      }
                      return _buildCardWidget(_cards[i], i, isMobile);
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // ── UPI Methods ──
                _sectionLabel('UPI Methods'),
                const SizedBox(height: 12),
                _buildUpiSection(),
                const SizedBox(height: 20),

                // ── Add UPI ──
                _buildAddUpiButton(context),
                const SizedBox(height: 24),

                // ── Net Banking ──
                _sectionLabel('Net Banking'),
                const SizedBox(height: 12),
                _buildNetBankingSection(),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCardSheet(context),
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add_rounded, color: AppColors.white),
        label: const Text(
          'Add Card',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
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
                'Payment Methods',
                style: TextStyle(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Manage your payments',
                style: TextStyle(fontSize: 12, color: AppColors.mutedText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardWidget(Map<String, dynamic> card, int index, bool isMobile) {
    final isSelected = _selectedIndex == index;
    final gradient = List<Color>.from(card['gradient']);

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isMobile ? 230 : 270,
        margin: EdgeInsets.only(
          right: 14,
          bottom: isSelected ? 0 : 8,
          top: isSelected ? 0 : 8,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(isSelected ? 0.45 : 0.2),
              blurRadius: isSelected ? 22 : 10,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: _decCircle(100, 0.08, Colors.white),
            ),
            Positioned(
              right: 30,
              bottom: -30,
              child: _decCircle(70, 0.06, Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        card['type'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Default',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    '•••• •••• •••• ${card['last4']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CARD HOLDER',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.white60,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            card['holder'],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'EXPIRES',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.white60,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            card['expiry'],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCardSlot(bool isMobile) {
    return GestureDetector(
      onTap: () => _showAddCardSheet(context),
      child: Container(
        width: isMobile ? 180 : 210,
        margin: const EdgeInsets.only(right: 14, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.borderColor,
            style: BorderStyle.solid,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 22,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Add New Card',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpiSection() {
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
        children: _upiMethods.asMap().entries.map((e) {
          final i = e.key;
          final upi = e.value;
          final isLast = i == _upiMethods.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (upi['color'] as Color).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        upi['icon'] as IconData,
                        color: upi['color'] as Color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            upi['label'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkText,
                            ),
                          ),
                          Text(
                            upi['bank'],
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() => _upiMethods.removeAt(i));
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEEEE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          size: 15,
                          color: AppColors.dangerRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  thickness: 1,
                  indent: 70,
                  color: AppColors.borderColor,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAddUpiButton(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 18, color: AppColors.primaryColor),
            SizedBox(width: 8),
            Text(
              'Link UPI ID',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetBankingSection() {
    final banks = [
      {
        'name': 'HDFC Bank',
        'icon': Icons.account_balance_rounded,
        'color': AppColors.accentSky,
      },
      {
        'name': 'SBI',
        'icon': Icons.account_balance_rounded,
        'color': AppColors.accentGreen,
      },
      {
        'name': 'ICICI Bank',
        'icon': Icons.account_balance_rounded,
        'color': AppColors.accentAmber,
      },
    ];

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
        children: banks.asMap().entries.map((e) {
          final i = e.key;
          final bank = e.value;
          final isLast = i == banks.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (bank['color'] as Color).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        bank['icon'] as IconData,
                        color: bank['color'] as Color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        bank['name'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 13,
                      color: AppColors.mutedText,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  thickness: 1,
                  indent: 70,
                  color: AppColors.borderColor,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showAddCardSheet(BuildContext context) {
    final numberCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final expiryCtrl = TextEditingController();
    final cvvCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Add New Card',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.bgColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _sheetField(numberCtrl, 'Card Number', TextInputType.number),
              const SizedBox(height: 12),
              _sheetField(nameCtrl, 'Cardholder Name', TextInputType.name),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _sheetField(
                      expiryCtrl,
                      'MM/YY',
                      TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _sheetField(cvvCtrl, 'CVV', TextInputType.number),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  if (numberCtrl.text.length >= 4) {
                    setState(() {
                      _cards.add({
                        'type': 'Card',
                        'last4': numberCtrl.text
                            .replaceAll(' ', '')
                            .substring(
                              numberCtrl.text.replaceAll(' ', '').length - 4,
                            ),
                        'expiry': expiryCtrl.text,
                        'holder': nameCtrl.text,
                        'gradient': [
                          AppColors.accentTeal,
                          const Color(0xFF0B6EFD),
                        ],
                        'icon': Icons.credit_card_rounded,
                      });
                    });
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text(
                      'Save Card',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetField(
    TextEditingController c,
    String label,
    TextInputType type,
  ) {
    return TextField(
      controller: c,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.bgColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _decCircle(double size, double opacity, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withOpacity(opacity),
    ),
  );

  Widget _sectionLabel(String text) => Text(
    text.toUpperCase(),
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: AppColors.mutedText,
      letterSpacing: 1.1,
    ),
  );
}
