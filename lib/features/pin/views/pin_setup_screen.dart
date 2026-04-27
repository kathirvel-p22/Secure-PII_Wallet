import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../providers/providers.dart';
import '../widgets/pin_input.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  int _selectedLength = 4;
  String _firstPin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String? _errorMessage;
  bool _isLoading = false;

  void _onPinLengthChanged(int length) {
    setState(() {
      _selectedLength = length;
      _firstPin = '';
      _confirmPin = '';
      _isConfirming = false;
      _errorMessage = null;
    });
  }

  void _onPinCompleted(String pin) async {
    if (!_isConfirming) {
      // First PIN entry
      setState(() {
        _firstPin = pin;
        _isConfirming = true;
        _errorMessage = null;
      });
    } else {
      // PIN confirmation
      setState(() {
        _confirmPin = pin;
      });

      if (_firstPin == _confirmPin) {
        // PINs match, save and proceed
        await _savePinAndProceed(pin);
      } else {
        // PINs don't match
        setState(() {
          _errorMessage = 'PINs do not match. Please try again.';
          _isConfirming = false;
          _firstPin = '';
          _confirmPin = '';
        });
      }
    }
  }

  Future<void> _savePinAndProceed(String pin) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pinService = ref.read(pinServiceProvider);
      await pinService.setupPin(pin);
      
      if (mounted) {
        // Mark onboarding as complete and go to main app
        context.go('/dashboard');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save PIN. Please try again.';
        _isConfirming = false;
        _firstPin = '';
        _confirmPin = '';
        _isLoading = false;
      });
    }
  }

  void _goBack() {
    if (_isConfirming) {
      setState(() {
        _isConfirming = false;
        _firstPin = '';
        _confirmPin = '';
        _errorMessage = null;
      });
    } else {
      context.go('/master-password-setup');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: _isLoading ? null : _goBack,
        ),
        title: Text(
          'Setup PIN',
          style: AppTypography.h2,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),

              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.neon.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: AppColors.neon, width: 2),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 40,
                  color: AppColors.neon,
                ),
              ),

              const SizedBox(height: 32),

              // Title and description
              Text(
                _isConfirming ? 'Confirm Your PIN' : 'Create Your PIN',
                style: AppTypography.h1.copyWith(
                  color: AppColors.neon,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                _isConfirming
                    ? 'Enter your PIN again to confirm'
                    : 'Choose a $_selectedLength-digit PIN to secure your app',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // PIN length selector (only show when not confirming)
              if (!_isConfirming) ...[
                Text(
                  'PIN LENGTH',
                  style: AppTypography.labelCaps,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildLengthOption(4),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildLengthOption(6),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
              ],

              // PIN input
              PinInput(
                key: ValueKey('${_selectedLength}_${_isConfirming}'),
                length: _selectedLength,
                onCompleted: _onPinCompleted,
                enabled: !_isLoading,
                errorText: _errorMessage,
              ),

              const Spacer(),

              // Loading indicator
              if (_isLoading) ...[
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.neon),
                ),
                const SizedBox(height: 16),
                Text(
                  'Setting up your PIN...',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],

              // Security note
              if (!_isLoading) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.security,
                        color: AppColors.neon,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your PIN is encrypted and stored securely on your device. We cannot recover it if forgotten.',
                          style: AppTypography.metadata.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLengthOption(int length) {
    final isSelected = _selectedLength == length;
    
    return GestureDetector(
      onTap: () => _onPinLengthChanged(length),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neon.withValues(alpha: 0.1) : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.neon : AppColors.divider,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              '$length Digits',
              style: AppTypography.bodyMedium.copyWith(
                color: isSelected ? AppColors.neon : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              length == 4 ? 'Quick & Easy' : 'More Secure',
              style: AppTypography.metadata.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}