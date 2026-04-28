import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../providers/providers.dart';
import '../services/master_password_service.dart';

class MasterPasswordSetupScreen extends ConsumerStatefulWidget {
  const MasterPasswordSetupScreen({super.key});

  @override
  ConsumerState<MasterPasswordSetupScreen> createState() => _MasterPasswordSetupScreenState();
}

class _MasterPasswordSetupScreenState extends ConsumerState<MasterPasswordSetupScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  int _passwordStrength = 0;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged(String password) {
    setState(() {
      _passwordStrength = MasterPasswordService.calculatePasswordStrength(password);
      _errorMessage = null;
    });
  }

  Future<void> _setupMasterPassword() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validate passwords
    if (password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both passwords';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    if (!MasterPasswordService.isStrongPassword(password)) {
      setState(() {
        _errorMessage = MasterPasswordService.getPasswordStrengthFeedback(password);
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final masterPasswordService = await ref.read(masterPasswordServiceProvider.future);
      await masterPasswordService.setupMasterPassword(password);

      if (mounted) {
        // Go to PIN setup
        context.go('/pin-setup');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to setup password: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Color _getStrengthColor() {
    if (_passwordStrength < 40) return AppColors.error;
    if (_passwordStrength < 70) return AppColors.warning;
    return AppColors.success;
  }

  String _getStrengthText() {
    if (_passwordStrength < 40) return 'Weak';
    if (_passwordStrength < 70) return 'Medium';
    return 'Strong';
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
          onPressed: _isLoading ? null : () => context.go('/onboarding'),
        ),
        title: const Text(
          'Master Password',
          style: AppTypography.h2,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),

              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: AppColors.error, width: 2),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  size: 40,
                  color: AppColors.error,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Create Master Password',
                style: AppTypography.h1.copyWith(
                  color: AppColors.neon,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                'This password protects critical operations like clearing data and resetting the app. Make it strong!',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Password field
              const Text('MASTER PASSWORD', style: AppTypography.labelCaps),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                onChanged: _onPasswordChanged,
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

              // Password strength indicator
              if (_passwordController.text.isNotEmpty) ...[
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Password Strength',
                          style: AppTypography.metadata,
                        ),
                        Text(
                          _getStrengthText(),
                          style: AppTypography.metadata.copyWith(
                            color: _getStrengthColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _passwordStrength / 100,
                        backgroundColor: AppColors.divider,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getStrengthColor(),
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),

              // Confirm password field
              const Text('CONFIRM PASSWORD', style: AppTypography.labelCaps),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                style: AppTypography.secureInput,
                decoration: InputDecoration(
                  hintText: 'Re-enter password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
              ),

              // Error message
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: AppTypography.metadata.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Requirements
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PASSWORD REQUIREMENTS',
                      style: AppTypography.labelCaps,
                    ),
                    const SizedBox(height: 12),
                    _buildRequirement('At least 10 characters', _passwordController.text.length >= 10),
                    _buildRequirement('One uppercase letter', RegExp(r'[A-Z]').hasMatch(_passwordController.text)),
                    _buildRequirement('One lowercase letter', RegExp(r'[a-z]').hasMatch(_passwordController.text)),
                    _buildRequirement('One number', RegExp(r'[0-9]').hasMatch(_passwordController.text)),
                    _buildRequirement('One special character', RegExp(r'[^A-Za-z0-9]').hasMatch(_passwordController.text)),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Continue button
              ElevatedButton(
                onPressed: _isLoading ? null : _setupMasterPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neon,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : const Text('CONTINUE'),
              ),

              const SizedBox(height: 16),

              // Warning
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Store this password safely. It cannot be recovered if forgotten.',
                        style: AppTypography.metadata.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: met ? AppColors.success : AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTypography.metadata.copyWith(
              color: met ? AppColors.success : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}