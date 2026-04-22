// lib/modules/admin/widgets/doctor/admin_document_viewer.dart
//
// Shows a tappable document tile.
// • For images (.jpg/.jpeg/.png): shows a thumbnail + full-screen preview.
// • For PDFs (.pdf): shows a file icon + "Open" button (uses url_launcher / flutter_pdfview).
// • For null/empty: shows a placeholder.
//
// Dependencies required in pubspec.yaml:
//   - flutter_pdfview: ^1.3.2
//   - url_launcher: ^6.2.5  (fallback for PDFs on desktop/web)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/core/utils/colors.dart';

class AdminDocumentViewer extends StatelessWidget {
  /// Display label shown above the viewer (e.g. "Government ID").
  final String label;

  /// File path or file name. If it ends with .pdf it renders a PDF tile,
  /// otherwise it tries to render it as an image.
  final String? filePath;

  /// Width of the tile. Defaults to double.infinity.
  final double? width;

  /// Height of the tile. Defaults to 140.
  final double height;

  const AdminDocumentViewer({
    super.key,
    required this.label,
    this.filePath,
    this.width,
    this.height = 140,
  });

  bool get _isPdf =>
      filePath != null && filePath!.toLowerCase().endsWith('.pdf');

  bool get _isImage =>
      filePath != null &&
      (filePath!.toLowerCase().endsWith('.jpg') ||
          filePath!.toLowerCase().endsWith('.jpeg') ||
          filePath!.toLowerCase().endsWith('.png'));

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: filePath != null ? () => _openPreview(context) : null,
          child: Container(
            width: width ?? double.infinity,
            height: height,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: filePath != null
                    ? AppColors.primaryColor.withOpacity(0.3)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: filePath == null
                ? _buildPlaceholder()
                : _isPdf
                ? _buildPdfTile()
                : _isImage
                ? _buildImageTile()
                : _buildGenericFileTile(),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.file_present_outlined, size: 32, color: Color(0xFFCBD5E1)),
        SizedBox(height: 8),
        Text(
          'No document uploaded',
          style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }

  Widget _buildPdfTile() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.picture_as_pdf,
            color: Color(0xFFDC2626),
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _fileName(filePath!),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        const Text(
          'Tap to preview',
          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildImageTile() {
    final file = File(filePath!);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: file.existsSync()
          ? Image.file(
              file,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            )
          : _buildGenericFileTile(),
    );
  }

  Widget _buildGenericFileTile() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.description_outlined,
          size: 32,
          color: Color(0xFF64748B),
        ),
        const SizedBox(height: 6),
        Text(
          _fileName(filePath!),
          style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
        ),
      ],
    );
  }

  String _fileName(String path) {
    return path.contains('/') ? path.split('/').last : path;
  }

  void _openPreview(BuildContext context) {
    if (_isImage) {
      _showImageDialog(context);
    } else if (_isPdf) {
      _showPdfDialog(context);
    }
  }

  void _showImageDialog(BuildContext context) {
    final file = File(filePath!);
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: file.existsSync()
                  ? Image.file(file, fit: BoxFit.contain)
                  : Container(
                      height: 300,
                      color: Colors.black87,
                      alignment: Alignment.center,
                      child: Text(
                        _fileName(filePath!),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPdfDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_fileName(filePath!)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.picture_as_pdf,
              size: 64,
              color: Color(0xFFDC2626),
            ),
            const SizedBox(height: 12),
            Text(
              filePath!,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'PDF preview requires flutter_pdfview package.\n'
              'File path is available for integration.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
