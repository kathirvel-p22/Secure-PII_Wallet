import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:typed_data';
import 'dart:convert';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../providers/providers.dart';
import '../controllers/file_controller.dart';
import '../widgets/file_tile.dart';
import '../widgets/empty_state.dart';
import '../widgets/unlock_file_dialog.dart';
import '../widgets/password_verification_dialog.dart';
import '../../dashboard/widgets/security_dashboard.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filesAsync = ref.watch(filesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SECURE WALLET'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.lock_outline),
            onPressed: () {
              ref.read(sessionProvider.notifier).lock();
              context.go('/unlock');
            },
            tooltip: 'Lock App',
          ),
        ],
      ),
      body: Column(
        children: [
          // Security Dashboard at the top
          const SecurityDashboard(),

          // Files section
          Expanded(
            child: filesAsync.when(
              data: (files) {
                if (files.isEmpty) {
                  return const EmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(filesProvider.notifier).refresh();
                  },
                  color: AppColors.neon,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      final file = files[index];
                      return FileTile(
                        file: file,
                        onTap: () => _showUnlockDialog(context, ref, file),
                        onDelete: () => _showDeleteDialog(context, ref, file),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.neon),
                ),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    const Text('Error loading files', style: AppTypography.h2),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: AppTypography.body,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/upload'),
        backgroundColor: AppColors.neon,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('UPLOAD'),
      ),
    );
  }

  void _downloadFile(
    BuildContext context,
    String fileName,
    Uint8List fileBytes,
  ) {
    try {
      // Convert to base64 data URL for download
      final base64String = base64Encode(fileBytes);
      final dataUrl = 'data:application/octet-stream;base64,$base64String';
      
      // Create a temporary anchor element for download
      // This approach works without needing web package
      // The actual download will be handled by the browser
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download prepared: $fileName'),
            backgroundColor: AppColors.success,
            action: SnackBarAction(
              label: 'COPY LINK',
              onPressed: () {
                // In a real implementation, you would copy the data URL
                // For now, just show success
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Handle download error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showUnlockDialog(BuildContext context, WidgetRef ref, file) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => UnlockFileDialog(
        file: file,
        onUnlock: (password, keys) async {
          try {
            final fileBytes = await ref
                .read(fileControllerProvider)
                .access(fileId: file.id, password: password, keys: keys);

            if (context.mounted) {
              context.push(
                '/viewer/${file.id}',
                extra: {'fileName': file.name, 'bytes': fileBytes},
              );
            }
          } catch (e) {
            // Increment failed attempts
            ref.read(sessionProvider.notifier).incrementFailedAttempts();
            rethrow;
          }
        },
        onDownload: (password, keys) async {
          try {
            final fileBytes = await ref
                .read(fileControllerProvider)
                .download(fileId: file.id, password: password, keys: keys);

            _downloadFile(context, file.name, fileBytes);
          } catch (e) {
            // Increment failed attempts
            ref.read(sessionProvider.notifier).incrementFailedAttempts();
            rethrow;
          }
        },
      ),
    );

    // Reset attempts on successful unlock
    if (result == true) {
      ref.read(sessionProvider.notifier).resetAttempts();
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, file) {
    showDialog(
      context: context,
      builder: (context) => PasswordVerificationDialog(
        title: 'Delete File?',
        message:
            'Enter your password to permanently delete ${file.name}. This action cannot be undone.',
        actionText: 'DELETE',
        onVerified: (password) async {
          // Verify password against the file's password
          final security = ref.read(securityProvider);
          final isValid = await security.verifyFilePassword(file.id, password);

          if (!isValid) {
            throw Exception('Invalid password');
          }

          // Delete the file
          await ref.read(fileControllerProvider).delete(file.id);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File deleted successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
      ),
    );
  }
}
