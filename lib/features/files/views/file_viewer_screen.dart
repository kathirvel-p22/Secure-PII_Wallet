import 'dart:typed_data';
import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart'; // Removed for Android build
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

class FileViewerScreen extends StatelessWidget {
  final String fileId;
  final String fileName;
  final dynamic fileBytes;

  const FileViewerScreen({
    super.key,
    required this.fileId,
    required this.fileName,
    required this.fileBytes,
  });

  @override
  Widget build(BuildContext context) {
    final isPdf = fileName.toLowerCase().endsWith('.pdf');
    final bytes = fileBytes as Uint8List;

    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.card,
                  title: const Text('File Info', style: AppTypography.h2),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: $fileName', style: AppTypography.body),
                      const SizedBox(height: 8),
                      Text(
                        'Size: ${(bytes.length / 1024).toStringAsFixed(2)} KB',
                        style: AppTypography.body,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '⚠️ This file is decrypted in memory only. It will not be saved to disk.',
                        style: AppTypography.metadata.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: isPdf
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.picture_as_pdf, size: 64, color: AppColors.neon),
                  const SizedBox(height: 16),
                  const Text(
                    'PDF Viewer',
                    style: AppTypography.h2,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'PDF viewing is available in web version',
                    style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'File: $fileName',
                    style: AppTypography.metadata,
                  ),
                  Text(
                    'Size: ${(bytes.length / 1024).toStringAsFixed(2)} KB',
                    style: AppTypography.metadata,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Download functionality would go here
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Use download button to save PDF'),
                          backgroundColor: AppColors.neon,
                        ),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Download PDF'),
                  ),
                ],
              ),
            )
          : Center(
              child: InteractiveViewer(
                child: Image.memory(bytes),
              ),
            ),
    );
  }
}
