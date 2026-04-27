import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../core/crypto/crypto_service.dart';
import '../core/storage/storage_service.dart';
import '../core/storage/web_storage_service.dart';
import '../core/keys/key_service.dart';
import '../core/security/security_engine.dart';
import '../features/files/models/file_meta.dart';
import '../features/files/models/session_state.dart';
import '../features/pin/services/pin_service.dart';
import '../features/auth/services/master_password_service.dart';

// Core service providers
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final cryptoProvider = Provider<CryptoService>((ref) {
  return CryptoService();
});

final storageProvider = Provider<dynamic>((ref) {
  // Use web storage for web platform, regular storage for mobile
  if (kIsWeb) {
    return WebStorageService();
  } else {
    return StorageService();
  }
});

final keyProvider = Provider<KeyService>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return KeyService(secureStorage);
});

final securityProvider = Provider<SecurityEngine>((ref) {
  final crypto = ref.watch(cryptoProvider);
  final storage = ref.watch(storageProvider);
  final keyService = ref.watch(keyProvider);
  return SecurityEngine(crypto, storage, keyService);
});

// Session state provider
final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier();
});

class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier() : super(SessionState(locked: true));

  void unlock() {
    state = state.copyWith(
      locked: false,
      failedAttempts: 0,
      lastUnlockAt: DateTime.now(),
      lockedUntil: null,
    );
  }

  void lock() {
    state = state.copyWith(locked: true);
  }

  void incrementFailedAttempts() {
    final newAttempts = state.failedAttempts + 1;
    
    if (newAttempts >= SecurityEngine.maxFailedAttempts) {
      // Temporary lock
      state = state.copyWith(
        failedAttempts: newAttempts,
        lockedUntil: DateTime.now().add(SecurityEngine.lockDuration),
      );
    } else {
      state = state.copyWith(failedAttempts: newAttempts);
    }
  }

  void resetAttempts() {
    state = state.copyWith(failedAttempts: 0, lockedUntil: null);
  }

  bool canAttemptUnlock() {
    return !state.isTemporarilyLocked;
  }
}

// Files list provider
final filesProvider = StateNotifierProvider<FilesNotifier, AsyncValue<List<FileMeta>>>((ref) {
  final storage = ref.watch(storageProvider);
  return FilesNotifier(storage);
});

class FilesNotifier extends StateNotifier<AsyncValue<List<FileMeta>>> {
  final dynamic _storage; // Can be StorageService or WebStorageService

  FilesNotifier(this._storage) : super(const AsyncValue.loading()) {
    loadFiles();
  }

  Future<void> loadFiles() async {
    state = const AsyncValue.loading();
    try {
      final files = await _storage.loadMeta();
      state = AsyncValue.data(files);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void addFile(FileMeta meta) {
    state.whenData((files) {
      state = AsyncValue.data([...files, meta]);
    });
  }

  void removeFile(String fileId) {
    state.whenData((files) {
      state = AsyncValue.data(files.where((f) => f.id != fileId).toList());
    });
  }

  Future<void> refresh() async {
    await loadFiles();
  }
}

// Theme provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark); // Default to dark mode

  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  void setTheme(ThemeMode mode) {
    state = mode;
  }
}

// Auto-lock timer provider
final autoLockTimerProvider = StateProvider<int>((ref) => 2); // Default 2 minutes

// PIN service provider
final pinServiceProvider = Provider<PinService>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return PinService(secureStorage);
});

// Master password service provider
final masterPasswordServiceProvider = Provider<MasterPasswordService>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return MasterPasswordService(secureStorage);
});
