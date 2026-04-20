import 'package:frontend/core/utils/colors.dart';
import 'package:flutter/material.dart';

class SummaryTileData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;

  const SummaryTileData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bg,
  });
}

/// A row of four stat tiles showing appointment summary counts.
/// Supply [tiles] to customise labels, values, icons and colours.
class SummaryStrip extends StatelessWidget {
  final List<SummaryTileData> tiles;
  final bool isMobile;

  const SummaryStrip({super.key, required this.tiles, this.isMobile = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: tiles.asMap().entries.map((e) {
        final i = e.key;
        final t = e.value;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < tiles.length - 1 ? 10 : 0),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderColor),
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
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: t.bg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(t.icon, color: t.color, size: 15),
                ),
                const SizedBox(height: 6),
                Text(
                  t.value,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  t.label,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.mutedText,
                    fontWeight: FontWeight.w500,
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
