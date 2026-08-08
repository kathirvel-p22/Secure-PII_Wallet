import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/views/splash_screen.dart';
import '../features/auth/views/unlock_screen.dart';
import '../features/auth/views/master_password_setup_screen.dart';
import '../features/onboarding/views/onboarding_screen.dart';
import '../features/pin/views/pin_setup_screen.dart';
import '../features/pin/views/pin_unlock_screen.dart';
import '../features/files/views/dashboard_screen.dart';
import '../features/files/views/upload_screen.dart';
import '../features/files/views/file_viewer_screen.dart';
import '../features/security/views/security_screen.dart';
import '../features/settings/views/settings_screen.dart';
import '../features/logs/views/access_logs_screen.dart';
import '../features/navigation/views/main_navigation.dart';
import '../providers/providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final sessionState = ref.read(sessionProvider);
      final isLocked = sessionState.locked;
      final currentPath = state.matchedLocation;

      // Check if PIN is set up
      final pinService = await ref.read(pinServiceProvider.future);
      final isPinSetup = await pinService.isPinSetup();

      // Check if master password is set up
      final masterPasswordService = await ref.read(masterPasswordServiceProvider.future);
      final isMasterPasswordSetup = await masterPasswordService.isMasterPasswordSetup();

      // Allow splash screen always
      if (currentPath == '/') {
        return null;
      }

      // If master password is not set up, redirect to onboarding
      if (!isMasterPasswordSetup) {
        if (currentPath != '/onboarding' && currentPath != '/master-password-setup') {
          return '/onboarding';
        }
        return null;
      }

      // If master password is set up but PIN is not, redirect to PIN setup
      if (!isPinSetup) {
        if (currentPath != '/pin-setup') {
          return '/pin-setup';
        }
        return null;
      }

      // If PIN is set up but session is locked, redirect to PIN unlock
      if (isLocked) {
        if (currentPath != '/pin-unlock') {
          return '/pin-unlock';
        }
        return null;
      }

      // If trying to access onboarding/setup after both are set up, redirect to dashboard
      if (currentPath == '/onboarding' || currentPath == '/master-password-setup' || 
          currentPath == '/pin-setup' || currentPath == '/unlock') {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      
      // Onboarding flow
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/master-password-setup',
        builder: (context, state) => const MasterPasswordSetupScreen(),
      ),
      GoRoute(
        path: '/pin-setup',
        builder: (context, state) => const PinSetupScreen(),
      ),
      GoRoute(
        path: '/pin-unlock',
        builder: (context, state) => const PinUnlockScreen(),
      ),
      
      // Legacy unlock screen (for backward compatibility)
      GoRoute(
        path: '/unlock',
        builder: (context, state) => const UnlockScreen(),
      ),
      
      // Main navigation shell
      ShellRoute(
        builder: (context, state, child) {
          return ResponsiveNavigation(
            location: state.matchedLocation,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/security',
            builder: (context, state) => const SecurityScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      
      // Routes outside navigation shell
      GoRoute(
        path: '/upload',
        builder: (context, state) => const UploadScreen(),
      ),
      GoRoute(
        path: '/logs',
        builder: (context, state) => const AccessLogsScreen(),
      ),
      GoRoute(
        path: '/viewer/:fileId',
        builder: (context, state) {
          final fileId = state.pathParameters['fileId']!;
          final fileBytes = state.extra as Map<String, dynamic>;
          return FileViewerScreen(
            fileId: fileId,
            fileName: fileBytes['fileName'] as String,
            fileBytes: fileBytes['bytes'],
          );
        },
      ),
    ],
  );
});