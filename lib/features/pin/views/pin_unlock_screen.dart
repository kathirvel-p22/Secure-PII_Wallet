import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../providers/providers.dart';
import '../widgets/pin_input.dart';
import '../services/pin_service.dart';

class PinUnlockScreen extends ConsumerStatefulWidget {
  const PinUnlockScreen({super.key});

  @override
  ConsumerState<PinUnlockScreen> createState() => _PinUnlockScreenState();
}

class _PinUnlockScreenState extends ConsumerState<PinUnlockScreen> {
  String? _errorMessage;
  bool _isLoading = false;
  int _failedAttempts = 0;
  bool _isLocked = false;
  Duration _lockTimeRemaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _checkLockStatus();
  }

  Future<void> _checkLockStatus() async {
    final pinService = ref.read(pinServiceProvider);
    final isLocked = await pinService.isPinLocked();
    final failedAttempts = await pinService.getFailedAttempts();
    final lockTimeRemaining = await pinService.getLockTimeRemaining();

    setState(() {
      _isLocked = isLocked;
      _failedAttempts = failedAttempts;
      _lockTimeRemaining = lockTimeRemaining;
    });

    if (_isLocked) {
      _startLockTimer();
    }
  }

  void _startLockTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _isLocked) {
        _checkLockStatus();
      }
    });
  }

  Future<void> _onPinCompleted(String pin) async {
    if (_isLocked) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pinService = ref.read(pinServiceProvider);
      final isValid = await pinService.verifyPin(pin);

      if (isValid) {
        // PIN is correct
        await pinService.resetFailedAttempts();
        
        // Unlock the session
        ref.read(sessionProvider.notifier).unlock();
        
        if (mounted) {
          context.go('/dashboard');
        }
      } else {
        // PIN is incorrect
        await pinService.incrementFailedAttempts();
        await _checkLockStatus();

        setState(() {
          _errorMessage = _isLocked 
              ? 'Too many failed attempts. App is locked.'
              : 'Incorrect PIN. Try again.';
          _isLoading = false;
        });

        await Future.delayed(const Duration(milliseconds: 500));
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _isLoading = false;
      });

      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  String _formatLockTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // App logo/icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.neon.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(60),
                  border: Border.all(color: AppColors.neon, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neon.withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 60,
                  color: AppColors.neon,
                ),
              ),

              const SizedBox(height: 48),

              // Title
              Text(
                'UNLOCK WALLET',
                style: AppTypography.h1.copyWith(
                  color: AppColors.neon,
                  fontSize: 28,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                _isLocked 
                    ? 'App is locked due to failed attempts'
                    : 'Enter to access your secure files',
                style: AppTypography.body.copyWith(
                  color: _isLocked ? AppColors.error : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Lock status or PIN input
              if (_isLocked) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.timer,
                        color: AppColors.error,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'App Locked',
                        style: AppTypography.h2.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Time remaining: ${_formatLockTime(_lockTimeRemaining)}',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Failed attempts: $_failedAttempts/5',
                        style: AppTypography.metadata.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // PIN input
                Consumer(
                  builder: (context, ref, child) {
                    return FutureBuilder<int>(
                      future: ref.read(pinServiceProvider).getPinLength(),
                      builder: (context, snapshot) {
                        final pinLength = snapshot.data ?? 4;
                        return PinInput(
                          length: pinLength,
                          onCompleted: _onPinCompleted,
                          enabled: !_isLoading && !_isLocked,
                          errorText: _errorMessage,
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Failed attempts indicator
                if (_failedAttempts > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.warning),
                    ),
                    child: Text(
                      'Failed attempts: $_failedAttempts/5',
                      style: AppTypography.metadata.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ],

              const Spacer(),

              // Loading indicator
              if (_isLoading) ...[
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.neon),
                ),
                const SizedBox(height: 16),
                Text(
                  'Verifying PIN...',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],

              // First time message
              if (!_isLocked && !_isLoading) ...[
                TextButton(
                  onPressed: () {
                    // Show help or reset options
                    _showHelpDialog();
                  },
                  child: Text(
                    'First time? Just tap unlock to get started',
                    style: AppTypography.metadata.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          'Need Help?',
          style: AppTypography.h2,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'If this is your first time using the app, you\'ll be guided through the setup process.',
              style: AppTypography.body,
            ),
            const SizedBox(height: 16),
            Text(
              'If you\'ve forgotten your PIN, you\'ll need to reset the app data.',
              style: AppTypography.body,
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
  }
}