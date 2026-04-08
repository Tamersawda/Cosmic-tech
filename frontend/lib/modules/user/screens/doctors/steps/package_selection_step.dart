import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class PackageSelectionStep extends StatelessWidget {
  final String? selectedService;
  final String fee;
  final String? selectedPackage;
  final ValueChanged<String?> onPackageChanged;

  const PackageSelectionStep({
    super.key,
    required this.selectedService,
    required this.fee,
    required this.selectedPackage,
    required this.onPackageChanged,
  });

  // Helper to parse fee and format
  int _parseFee(String feeStr) {
    String numStr = feeStr.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(numStr) ?? 1500;
  }

  String _formatCurrency(int amount, String originalFeeStr) {
    String symbol = originalFeeStr.replaceAll(RegExp(r'[0-9.,]'), '').trim();
    if (symbol.isEmpty) symbol = '₹';
    // simple format for thousands
    String amtStr = amount.toString();
    if (amtStr.length > 3) {
      amtStr =
          '${amtStr.substring(0, amtStr.length - 3)},${amtStr.substring(amtStr.length - 3)}';
    }
    return '$symbol$amtStr';
  }

  @override
  Widget build(BuildContext context) {
    int baseFee = _parseFee(fee);

    final List<Map<String, dynamic>> multiSessionPackages = [
      {'sessions': 4, 'discount': 10},
      {'sessions': 8, 'discount': 15},
      {'sessions': 12, 'discount': 20},
    ];

    String srvName = selectedService ?? 'Service';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hey, there are special packages with this service, check out',
          style: TextStyle(fontSize: 15, color: AppColors.darkText),
        ),
        const SizedBox(height: 16),
        ...multiSessionPackages.map((pkg) {
          int sessions = pkg['sessions'];
          int discount = pkg['discount'];
          double total = (baseFee * sessions) * (1 - discount / 100);
          int finalPrice = total.round();

          String pkgTitle = '$srvName - $sessions sessions';
          String pkgSubtitle = '$srvName x $sessions';

          bool isSelected = selectedPackage == pkgTitle;

          return GestureDetector(
            onTap: () => onPackageChanged(pkgTitle),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryColor
                      : AppColors.borderColor,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pkgTitle,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? AppColors.primaryColor
                                : AppColors.darkText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          pkgSubtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Save $discount%',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _formatCurrency(finalPrice, fee),
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Container(height: 1, color: AppColors.borderColor)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('Or', style: TextStyle(color: AppColors.mutedText)),
            ),
            Expanded(child: Container(height: 1, color: AppColors.borderColor)),
          ],
        ),
        const SizedBox(height: 16),
        // Single session
        GestureDetector(
          onTap: () => onPackageChanged('$srvName - Single Session'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(
                0xFFFFF9E6,
              ), // light yellowish background matching image
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selectedPackage == '$srvName - Single Session'
                    ? AppColors.primaryColor
                    : Colors.transparent,
                width: selectedPackage == '$srvName - Single Session' ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Or get a single session at',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    fee,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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
