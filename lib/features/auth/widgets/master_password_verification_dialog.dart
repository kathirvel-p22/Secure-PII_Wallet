import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../providers/providers.dart';

/// Dialog for verifying master password before critical operations
class MasterPasswordVerificationDialog extends ConsumerStatefulWidget {
  final String title;
  final String message;
  final VoidCallback onVerified;

  const MasterPasswordVerificationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onVerified,
  });

  @override
  ConsumerState<MasterPasswordVerificationDialog> createState() =>
      _MasterPasswordVerificationDialogState();
}

class _MasterPasswordVerificationDialogState
    extends ConsumerState<MasterPasswordVerificationDialog> {
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _verifyPassword() async {
    final password = _passwordController.text;

    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your master password';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final masterPasswordService = await ref.read(masterPasswordServiceProvider.future);
      final isValid = await masterPasswordService.verifyMasterPassword(password);

      if (isValid) {
        if (mounted) {
          Navigator.pop(context);
          widget.onVerified();
        }
      } else {
        setState(() {
          _errorMessage = 'Incorrect master password';
          _isVerifying = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Verification failed: ${e.toString()}';
        _isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.shield, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.title,
              style: AppTypography.h2.copyWith(fontSize: 18),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.message,
            style: AppTypography.body,
          ),
          const SizedBox(height: 24),
          const Text(
            'MASTER PASSWORD',
            style: AppTypography.labelCaps,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            autofocus: true,
            enabled: !_isVerifying,
            style: AppTypography.secureInput,
            decoration: InputDecoration(
              hintText: 'Enter master password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            onSubmitted: (_) => _verifyPassword(),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: AppColors.error, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: AppTypography.metadata.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isVerifying ? null : () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: _isVerifying ? null : _verifyPassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          child: _isVerifying
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('VERIFY'),
        ),
      ],
    );
  }
}
