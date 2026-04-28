import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

import '../../../core/crypto/shamir_secret_sharing.dart';
import '../../../core/security/pii_detector.dart';
import '../../../providers/providers.dart';
import '../controllers/file_controller.dart';
import '../widgets/key_input_box.dart';
import '../widgets/sss_config_dialog.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  File? _selectedFile;
  bool _highSecurity = false;
  bool _obscurePassword = true;
  bool _isUploading = false;

  final _passwordController = TextEditingController();
  final _key1Controller = TextEditingController();
  final _key2Controller = TextEditingController();
  final _key3Controller = TextEditingController();

  // Store the generated shares and AES key
  List<ShamirShare>? _generatedShares;
  Uint8List? _generatedAESKey;
  int _totalShares = 5;
  int _threshold = 3;

  // PII Detection
  PIIDetectionResult? _piiDetection;

  @override
  void dispose() {
    _passwordController.dispose();
    _key1Controller.dispose();
    _key2Controller.dispose();
    _key3Controller.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    // File picker commented out to fix Android build
    /*
    // Use regular file picker for mobile
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);

      // Read file for PII detection
      Uint8List? fileBytes;
      try {
        fileBytes = await file.readAsBytes();
      } catch (e) {
        // Handle file read error
      }

      // Perform PII detection
      final piiResult = PIIDetector.detectPII(
        file.path.split('/').last,
        fileBytes,
      );

      setState(() {
        _selectedFile = file;
        _piiDetection = piiResult;

        // Auto-suggest high security if PII detected
        if (piiResult.suggestHighSecurity) {
          _highSecurity = true;
        }
      });

      // Show PII detection results if any PII found
      if (piiResult.hasPII) {
        _showPIIDetectionDialog(piiResult);
      }
    }
    */
  }

  void _configureSSS() async {
    await showDialog(
      context: context,
      builder: (context) => SSSConfigDialog(
        onConfigured: (totalShares, threshold) {
          setState(() {
            _totalShares = totalShares;
            _threshold = threshold;
          });
        },
      ),
    );
  }

  Future<void> _generateKeys() async {
    if (_highSecurity) {
      // Generate Shamir shares for high security mode

      // Generate a random AES key
      final aesKey = ShamirSecretSharing.generateRandomSecret(32);

      // Split into configured shares with configured threshold
      final shares = ShamirSecretSharing.split(
        secret: aesKey,
        threshold: _threshold,
        totalShares: _totalShares,
      );

      // Store the generated shares and key for upload
      _generatedShares = shares;
      _generatedAESKey = aesKey;

      // Convert shares to human-readable format
      final shareStrings = shares
          .map((share) => share.toHumanReadable())
          .toList();

      setState(() {
        _key1Controller.text = shareStrings[0];
        _key2Controller.text = shareStrings[1];
        _key3Controller.text = shareStrings[2];
      });

      _showKeysDialog(shareStrings);
    } else {
      // Generate simple keys for legacy mode
      final keyService = await ref.read(keyProvider.future);
      final keys = keyService.generateKeys();

      setState(() {
        _key1Controller.text = keys[0];
        _key2Controller.text = keys[1];
        _key3Controller.text = keys[2];
      });

      _showKeysDialog(keys);
    }
  }

  void _showKeysDialog(List<String> keys) {
    final isSSS = _highSecurity;
    final threshold = isSSS ? _threshold : keys.length;
    final totalShares = isSSS ? _totalShares : keys.length;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Row(
          children: [
            const Icon(Icons.security, color: AppColors.warning),
            const SizedBox(width: 8),
            Text(
              isSSS ? 'SHAMIR SECRET SHARES' : 'SECURITY KEYS',
              style: AppTypography.h2,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isSSS
                  ? 'Your file will be protected using Shamir\'s Secret Sharing. Save these shares securely - you need $threshold out of $totalShares shares to access your file.'
                  : 'Your file will be protected with these security keys. Save them securely - you need all keys to access your file.',
              style: AppTypography.body.copyWith(color: AppColors.warning),
            ),
            const SizedBox(height: 16),
            Text(
              isSSS ? 'CRYPTOGRAPHIC SHARES:' : 'SECURITY KEYS:',
              style: AppTypography.labelCaps,
            ),
            const SizedBox(height: 8),
            ...keys.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.neon),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSSS
                            ? 'Share ${entry.key + 1}:'
                            : 'Key ${entry.key + 1}:',
                        style: AppTypography.label,
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        entry.value,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.neon,
                          fontFamily: 'monospace',
                          fontSize: isSSS ? 10 : 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error),
              ),
              child: Text(
                isSSS
                    ? '⚠️ CRITICAL: If you lose these shares, your file cannot be recovered. Store them in multiple secure locations.'
                    : '⚠️ CRITICAL: If you lose these keys, your file cannot be recovered. Store them securely.',
                style: AppTypography.metadata.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              isSSS ? 'I HAVE SAVED ALL SHARES' : 'I HAVE SAVED ALL KEYS',
            ),
          ),
        ],
      ),
    );
  }

  void _showPIIDetectionDialog(PIIDetectionResult piiResult) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppColors.warning),
            SizedBox(width: 8),
            Text('PII DETECTED', style: AppTypography.h2),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sensitive information detected in your file:',
              style: AppTypography.body,
            ),
            const SizedBox(height: 16),

            // Show detected PII types
            ...piiResult.detections
                .map(
                  (detection) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.warning.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          detection.type.icon,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                detection.type.displayName,
                                style: AppTypography.labelCaps.copyWith(
                                  color: AppColors.warning,
                                ),
                              ),
                              Text(
                                detection.description,
                                style: AppTypography.metadata,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                ,

            const SizedBox(height: 16),

            // Security recommendation
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.neon.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.neon),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🔐 SECURITY RECOMMENDATION',
                    style: AppTypography.labelCaps.copyWith(
                      color: AppColors.neon,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    piiResult.securityRecommendation,
                    style: AppTypography.metadata.copyWith(
                      color: AppColors.neon,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('UNDERSTOOD'),
          ),
          if (piiResult.suggestHighSecurity && !_highSecurity)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _highSecurity = true;
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neon,
                foregroundColor: Colors.black,
              ),
              child: const Text('USE HIGH SECURITY'),
            ),
        ],
      ),
    );
  }

  Future<void> _upload() async {
    if (_selectedFile == null) {
      _showError('Please select a file');
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showError('Please enter a password');
      return;
    }

    final security = ref.read(securityProvider);
    if (!security.isStrongPassword(_passwordController.text)) {
      _showError(
        security.getPasswordStrengthFeedback(_passwordController.text),
      );
      return;
    }

    List<String>? keys;
    if (_highSecurity) {
      if (_key1Controller.text.isEmpty ||
          _key2Controller.text.isEmpty ||
          _key3Controller.text.isEmpty) {
        _showError('Please enter all required shares/keys');
        return;
      }
      keys = [
        _key1Controller.text.toUpperCase(),
        _key2Controller.text.toUpperCase(),
        _key3Controller.text.toUpperCase(),
      ];
    }

    setState(() => _isUploading = true);

    try {
      // Handle file upload
      await ref
          .read(fileControllerProvider)
          .upload(
            file: _selectedFile!,
            password: _passwordController.text,
            highSecurity: _highSecurity,
            keys: keys,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File uploaded successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UPLOAD SECURE FILE')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // File selection
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedFile != null
                        ? AppColors.neon
                        : AppColors.divider,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _selectedFile != null
                          ? Icons.check_circle
                          : Icons.upload_file,
                      size: 48,
                      color: _selectedFile != null
                          ? AppColors.neon
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _selectedFile != null
                          ? _selectedFile!.path
                                .split('/')
                                .last
                                .split('\\')
                                .last
                          : 'Tap to select file',
                      style: AppTypography.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    if (_selectedFile != null) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'PDF, JPG, PNG supported',
                        style: AppTypography.metadata,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // PII Detection Results
            if (_piiDetection != null && _piiDetection!.hasPII) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _piiDetection!.suggestHighSecurity
                      ? AppColors.error.withOpacity(0.1)
                      : AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _piiDetection!.suggestHighSecurity
                        ? AppColors.error
                        : AppColors.warning,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning,
                          color: _piiDetection!.suggestHighSecurity
                              ? AppColors.error
                              : AppColors.warning,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'PII DETECTED',
                          style: AppTypography.labelCaps.copyWith(
                            color: _piiDetection!.suggestHighSecurity
                                ? AppColors.error
                                : AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _piiDetection!.securityRecommendation,
                      style: AppTypography.metadata,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _piiDetection!.detections
                          .map(
                            (detection) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.bg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${detection.type.icon} ${detection.type.displayName}',
                                style: AppTypography.metadata.copyWith(
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Security mode
            const Text('SECURITY MODE', style: AppTypography.labelCaps),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _SecurityModeCard(
                    title: 'Secure',
                    description: 'Password only',
                    icon: Icons.lock,
                    selected: !_highSecurity,
                    onTap: () => setState(() => _highSecurity = false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SecurityModeCard(
                    title: 'High Secure',
                    description: 'Password + SSS Shares',
                    icon: Icons.security,
                    selected: _highSecurity,
                    onTap: () => setState(() => _highSecurity = true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Password
            const Text('PASSWORD', style: AppTypography.labelCaps),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: AppTypography.secureInput,
              decoration: InputDecoration(
                hintText: 'Enter strong password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Min 10 chars, uppercase, lowercase, number, special char',
              style: AppTypography.metadata,
            ),

            // Keys (High Security)
            if (_highSecurity) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('SECURITY SHARES', style: AppTypography.labelCaps),
                  Row(
                    children: [
                      if (_highSecurity) ...[
                        TextButton.icon(
                          onPressed: _configureSSS,
                          icon: const Icon(Icons.settings, size: 16),
                          label: const Text('CONFIG'),
                        ),
                        const SizedBox(width: 8),
                      ],
                      TextButton.icon(
                        onPressed: _generateKeys,
                        icon: const Icon(Icons.auto_awesome, size: 16),
                        label: const Text('GENERATE'),
                      ),
                    ],
                  ),
                ],
              ),
              if (_highSecurity) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.neon.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.neon),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.neon,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'SSS Config: $_totalShares total shares, $_threshold needed to unlock',
                          style: AppTypography.metadata.copyWith(
                            color: AppColors.neon,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              KeyInputBox(label: 'Share 1', controller: _key1Controller),
              const SizedBox(height: 12),
              KeyInputBox(label: 'Share 2', controller: _key2Controller),
              const SizedBox(height: 12),
              KeyInputBox(label: 'Share 3', controller: _key3Controller),
            ],

            const SizedBox(height: 32),

            // Upload button
            ElevatedButton(
              onPressed: _isUploading ? null : _upload,
              child: _isUploading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : const Text('SECURE UPLOAD'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurityModeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SecurityModeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.neon.withOpacity(0.1) : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.neon : AppColors.divider,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? AppColors.neon : AppColors.textSecondary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTypography.bodyMedium.copyWith(
                color: selected ? AppColors.neon : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: AppTypography.metadata,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
