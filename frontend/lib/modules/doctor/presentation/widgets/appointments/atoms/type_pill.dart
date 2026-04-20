import 'package:frontend/core/utils/colors.dart';
import 'package:flutter/material.dart';

/// Small pill that shows the appointment type (Video or Clinic)
/// with a matching icon and tinted background.
class TypePill extends StatelessWidget {
  final String type;

  const TypePill({super.key, required this.type});

  bool get _isVideo => type == 'Video';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _isVideo ? const Color(0xFFEDE9FB) : const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isVideo ? Icons.videocam_rounded : Icons.local_hospital_rounded,
            size: 12,
            color: _isVideo ? AppColors.accentPurple : AppColors.accentGreen,
          ),
          const SizedBox(width: 4),
          Text(
            type,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _isVideo ? AppColors.accentPurple : AppColors.accentGreen,
            ),
          ),
        ],
      ),
    );
  }
}
