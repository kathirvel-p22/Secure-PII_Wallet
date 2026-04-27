import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../providers/providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      // Check if PIN is set up
      final pinService = ref.read(pinServiceProvider);
      final isPinSetup = await pinService.isPinSetup();
      
      if (isPinSetup) {
        // PIN is set up, go to PIN unlock
        context.go('/pin-unlock');
      } else {
        // First time user, go to onboarding
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.bg, Color(0xFF0D1421)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lock icon with glow effect
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.card,
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
                  size: 64,
                  color: AppColors.neon,
                ),
              ),
              const SizedBox(height: 32),
              
              // App title
              Text(
                'SECURE PII WALLET',
                style: AppTypography.h1.copyWith(
                  letterSpacing: 2,
                  color: AppColors.neon,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                'Military-Grade Encryption',
                style: AppTypography.body.copyWith(
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 48),
              
              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.neon),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
