import 'package:frontend/core/constants/colors.dart';
import 'package:flutter/material.dart';

class InfoTileData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bg;

  const InfoTileData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });
}

/// 2×2 grid of icon tiles. Commonly used to show date, time, type, and fee.
/// Supply custom [tiles] to reuse for any set of key-value pairs.
class InfoGrid extends StatelessWidget {
  final List<InfoTileData> tiles;
  final bool isMobile;

  const InfoGrid({super.key, required this.tiles, this.isMobile = true});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: isMobile ? 2.8 : 3.2,
      children: tiles.map((t) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: t.bg,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(t.icon, color: t.color, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      t.label,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.mutedText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t.value,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
