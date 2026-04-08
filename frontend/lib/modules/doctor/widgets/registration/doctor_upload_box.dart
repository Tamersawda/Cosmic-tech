import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class DoctorUploadBox extends StatelessWidget {
  final String label;
  final String subtitle;
  final String? fileName;
  final VoidCallback onTap;
  final IconData icon;

  const DoctorUploadBox({
    super.key,
    required this.label,
    required this.subtitle,
    this.fileName,
    required this.onTap,
    this.icon = Icons.upload_file_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasFile = fileName != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: hasFile
              ? AppColors.primaryColor.withValues(alpha: 0.04)
              : AppColors.inputBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasFile
                ? AppColors.primaryColor.withValues(alpha: 0.3)
                : AppColors.borderColor,
            width: hasFile ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: hasFile
                    ? AppColors.successGreen.withValues(alpha: 0.12)
                    : AppColors.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFile ? Icons.check_circle_rounded : icon,
                size: 22,
                color: hasFile
                    ? AppColors.successGreen
                    : AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              hasFile ? fileName! : label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: hasFile ? AppColors.successGreen : AppColors.darkText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorDropFileBox extends StatelessWidget {
  final String? fileName;
  final VoidCallback onTap;
  final String label;
  final String subtitle;

  const DoctorDropFileBox({
    super.key,
    this.fileName,
    required this.onTap,
    this.label = 'Drop file here or click to browse',
    this.subtitle = 'MAXIMUM FILE SIZE: 10MB',
  });

  @override
  Widget build(BuildContext context) {
    final bool hasFile = fileName != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: hasFile
              ? AppColors.primaryColor.withValues(alpha: 0.04)
              : AppColors.inputBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasFile
                ? AppColors.primaryColor.withValues(alpha: 0.3)
                : AppColors.borderColor,
            width: hasFile ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: hasFile
                    ? AppColors.successGreen.withValues(alpha: 0.12)
                    : AppColors.primaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFile
                    ? Icons.check_circle_rounded
                    : Icons.cloud_upload_outlined,
                size: 20,
                color: hasFile
                    ? AppColors.successGreen
                    : AppColors.primaryColor,
              ),
            ),
            const SizedBox(width: 14),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasFile ? fileName! : label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: hasFile
                          ? AppColors.successGreen
                          : AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mutedText,
                      letterSpacing: 0.5,
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

class DoctorCertificateUploadBox extends StatelessWidget {
  final String? fileName;
  final VoidCallback onTap;

  const DoctorCertificateUploadBox({
    super.key,
    this.fileName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: AppColors.inputBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.upload_file_outlined,
                size: 26,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              fileName ?? 'Click to upload or drag and drop',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: fileName != null
                    ? AppColors.primaryColor
                    : AppColors.darkText,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'PDF, PNG or JPG (max. 10MB)',
              style: TextStyle(fontSize: 12, color: AppColors.mutedText),
            ),
          ],
        ),
      ),
    );
  }
}
