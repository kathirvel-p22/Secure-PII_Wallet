import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../providers/providers.dart';
import '../widgets/auto_lock_dialog.dart';
import '../../backup/services/backup_service.dart';
import '../../auth/widgets/master_password_verification_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final autoLockTimer = ref.watch(autoLockTimerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Section
            _buildSectionHeader('Appearance'),
            const SizedBox(height: 16),
            _buildThemeCard(context, ref, isDarkMode),
            const SizedBox(height: 32),

            // Security Section
            _buildSectionHeader('Security'),
            const SizedBox(height: 16),
            _buildSecurityCard(context, ref, autoLockTimer),
            const SizedBox(height: 32),

            // Storage Section
            _buildSectionHeader('Storage'),
            const SizedBox(height: 16),
            _buildStorageCard(context, ref),
            const SizedBox(height: 32),

            // About Section
            _buildSectionHeader('About'),
            const SizedBox(height: 16),
            _buildAboutCard(context),
            const SizedBox(height: 32),

            // Danger Zone
            _buildSectionHeader('Danger Zone'),
            const SizedBox(height: 16),
            _buildDangerCard(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: AppTypography.labelCaps.copyWith(
        color: AppColors.neon,
        fontSize: 14,
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context, WidgetRef ref, bool isDarkMode) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: AppColors.neon,
              ),
              title: const Text('Theme Mode'),
              subtitle: Text(isDarkMode ? 'Dark Mode' : 'Light Mode'),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (value) {
                  ref.read(themeModeProvider.notifier).toggleTheme();
                },
              ),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.palette, color: AppColors.accent),
              title: const Text('Color Scheme'),
              subtitle: const Text('Cybersecurity Theme'),
              trailing: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.neon,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Color customization coming soon!'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityCard(BuildContext context, WidgetRef ref, int autoLockTimer) {
    final session = ref.watch(sessionProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.timer, color: AppColors.warning),
              title: const Text('Auto-Lock Timer'),
              subtitle: Text('Lock app after $autoLockTimer minutes of inactivity'),
              trailing: const Icon(Icons.chevron_right),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const AutoLockDialog(),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.security, color: AppColors.neon),
              title: const Text('Security Score'),
              subtitle: const Text('View your security assessment'),
              trailing: const Icon(Icons.chevron_right),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                context.push('/security');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.history, color: AppColors.accent),
              title: const Text('Access Logs'),
              subtitle: const Text('View file access history'),
              trailing: const Icon(Icons.chevron_right),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                context.push('/logs');
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                session.failedAttempts > 0 ? Icons.warning : Icons.check_circle,
                color: session.failedAttempts > 0 ? AppColors.error : AppColors.success,
              ),
              title: const Text('Failed Attempts'),
              subtitle: Text('${session.failedAttempts} failed login attempts'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageCard(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.folder, color: AppColors.accent),
              title: const Text('Storage Location'),
              subtitle: const Text('Browser Local Storage'),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.backup, color: AppColors.neon),
              title: const Text('Export Vault'),
              subtitle: const Text('Download encrypted backup'),
              trailing: const Icon(Icons.chevron_right),
              contentPadding: EdgeInsets.zero,
              onTap: () => _showExportDialog(context, ref),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.restore, color: AppColors.warning),
              title: const Text('Import Vault'),
              subtitle: const Text('Restore from backup'),
              trailing: const Icon(Icons.chevron_right),
              contentPadding: EdgeInsets.zero,
              onTap: () => _showImportDialog(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.info, color: AppColors.neon),
              title: const Text('Version'),
              subtitle: const Text('1.0.0 (Build 1)'),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.security, color: AppColors.accent),
              title: const Text('Encryption'),
              subtitle: const Text('AES-256 + Shamir\'s Secret Sharing'),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.code, color: AppColors.warning),
              title: const Text('Open Source'),
              subtitle: const Text('Built with Flutter & Riverpod'),
              trailing: const Icon(Icons.chevron_right),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('GitHub repository coming soon!'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerCard(BuildContext context, WidgetRef ref) {
    return Card(
      color: AppColors.error.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.delete_forever, color: AppColors.error),
              title: const Text('Factory Reset'),
              subtitle: const Text('Delete all files (keeps PIN & master password)'),
              trailing: const Icon(Icons.chevron_right, color: AppColors.error),
              contentPadding: EdgeInsets.zero,
              onTap: () => _showClearDataDialog(context, ref),
            ),
            const Divider(color: AppColors.error),
            ListTile(
              leading: const Icon(Icons.restart_alt, color: AppColors.error),
              title: const Text('Lock & Reset'),
              subtitle: const Text('Delete EVERYTHING and restart from beginning'),
              trailing: const Icon(Icons.chevron_right, color: AppColors.error),
              contentPadding: EdgeInsets.zero,
              onTap: () => _showLockAndResetDialog(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context, WidgetRef ref) {
    final passwordController = TextEditingController();
    bool isExporting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Export Vault'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create an encrypted backup of all your files. '
                'Enter a strong password to protect the backup.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Backup Password',
                  hintText: 'Enter a strong password',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isExporting ? null : () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: isExporting ? null : () async {
                if (passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a backup password'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                setState(() => isExporting = true);

                try {
                  final storage = ref.read(storageProvider);
                  final crypto = ref.read(cryptoProvider);
                  final backupService = BackupService(storage, crypto);
                  
                  await backupService.exportVault(passwordController.text);
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vault exported successfully!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  setState(() => isExporting = false);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Export failed: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              child: isExporting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('EXPORT'),
            ),
          ],
        ),
      ),
    );
  }

  void _showImportDialog(BuildContext context, WidgetRef ref) {
    final passwordController = TextEditingController();
    bool isImporting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Import Vault'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Restore files from an encrypted backup. '
                'Select your backup file and enter the password.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Backup Password',
                  hintText: 'Enter backup password',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isImporting ? null : () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: isImporting ? null : () async {
                if (passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter the backup password'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                // Pick backup file
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['json'],
                );

                if (result == null || result.files.isEmpty) return;

                setState(() => isImporting = true);

                try {
                  final file = result.files.first;
                  final backupContent = String.fromCharCodes(file.bytes!);
                  
                  final storage = ref.read(storageProvider);
                  final crypto = ref.read(cryptoProvider);
                  final backupService = BackupService(storage, crypto);
                  
                  final importedCount = await backupService.importVault(
                    passwordController.text,
                    backupContent,
                  );
                  
                  // Refresh files list
                  await ref.read(filesProvider.notifier).refresh();
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Successfully imported $importedCount files!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  setState(() => isImporting = false);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Import failed: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              child: isImporting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('SELECT FILE'),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    // Show master password verification dialog first
    showDialog(
      context: context,
      builder: (context) => MasterPasswordVerificationDialog(
        title: 'Verify Master Password',
        message: 'Enter your master password to delete all stored files and data. Your PIN and master password will remain.',
        onVerified: () => _performClearData(context, ref),
      ),
    );
  }

  void _performClearData(BuildContext context, WidgetRef ref) {
    bool isClearing = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Factory Reset'),
          content: const Text(
            'This will permanently delete:\n'
            '• ALL files and encrypted data\n'
            '• All settings and preferences\n\n'
            'Your PIN and master password will remain.\n\n'
            'This action CANNOT be undone!\n\n'
            'Are you absolutely sure?',
          ),
          actions: [
            TextButton(
              onPressed: isClearing ? null : () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: isClearing ? null : () async {
                setState(() => isClearing = true);

                try {
                  final storage = ref.read(storageProvider);
                  final crypto = ref.read(cryptoProvider);
                  final backupService = BackupService(storage, crypto);
                  
                  // Only clear files and data, keep PIN and master password
                  await backupService.clearAllData();
                  
                  // Refresh files list
                  await ref.read(filesProvider.notifier).refresh();
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All data cleared successfully'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  setState(() => isClearing = false);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to clear data: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: isClearing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('DELETE ALL DATA'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLockAndResetDialog(BuildContext context, WidgetRef ref) {
    // Show master password verification dialog first
    showDialog(
      context: context,
      builder: (context) => MasterPasswordVerificationDialog(
        title: 'Verify Master Password',
        message: 'Enter your master password to perform a complete system reset. This will delete EVERYTHING and restart the app from the beginning.',
        onVerified: () => _performCompleteSystemReset(context, ref),
      ),
    );
  }

  void _performCompleteSystemReset(BuildContext context, WidgetRef ref) {
    bool isResetting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Complete System Reset'),
          content: const Text(
            'This will permanently delete:\n'
            '• ALL files and encrypted data\n'
            '• Master password\n'
            '• PIN code\n'
            '• All settings and preferences\n\n'
            'The app will restart from the beginning:\n'
            '1. Onboarding slides\n'
            '2. Master password setup\n'
            '3. PIN setup\n\n'
            'This action CANNOT be undone!\n\n'
            'Are you absolutely sure?',
          ),
          actions: [
            TextButton(
              onPressed: isResetting ? null : () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: isResetting ? null : () async {
                setState(() => isResetting = true);

                try {
                  final storage = ref.read(storageProvider);
                  final crypto = ref.read(cryptoProvider);
                  final backupService = BackupService(storage, crypto);
                  final pinService = ref.read(pinServiceProvider);
                  final masterPasswordService = ref.read(masterPasswordServiceProvider);
                  
                  // Perform complete system reset (delete everything)
                  await backupService.completeSystemReset(pinService, masterPasswordService);
                  
                  // Refresh files list
                  await ref.read(filesProvider.notifier).refresh();
                  
                  // Lock the session
                  ref.read(sessionProvider.notifier).lock();
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('System reset complete! Restarting app...'),
                        backgroundColor: AppColors.success,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    
                    // Wait a moment then redirect to onboarding
                    await Future.delayed(const Duration(seconds: 2));
                    
                    if (context.mounted) {
                      // Navigate to onboarding (fresh start)
                      context.go('/onboarding');
                    }
                  }
                } catch (e) {
                  setState(() => isResetting = false);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('System reset failed: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: isResetting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('RESET SYSTEM'),
            ),
          ],
        ),
      ),
    );
  }
}