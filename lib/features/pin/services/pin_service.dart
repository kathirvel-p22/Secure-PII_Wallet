import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinService {
  static const String _pinKey = 'app_pin_hash';
  static const String _pinLengthKey = 'app_pin_length';
  static const String _setupCompleteKey = 'pin_setup_complete';
  static const String _failedAttemptsKey = 'pin_failed_attempts';
  static const String _lockedUntilKey = 'pin_locked_until';

  final FlutterSecureStorage _storage;

  PinService(this._storage);

  /// Check if PIN is set up
  Future<bool> isPinSetup() async {
    final setupComplete = await _storage.read(key: _setupCompleteKey);
    return setupComplete == 'true';
  }

  /// Get PIN length
  Future<int> getPinLength() async {
    final lengthStr = await _storage.read(key: _pinLengthKey);
    return int.tryParse(lengthStr ?? '4') ?? 4;
  }

  /// Set up PIN
  Future<void> setupPin(String pin) async {
    final pinHash = _hashPin(pin);
    await _storage.write(key: _pinKey, value: pinHash);
    await _storage.write(key: _pinLengthKey, value: pin.length.toString());
    await _storage.write(key: _setupCompleteKey, value: 'true');
    await _storage.delete(key: _failedAttemptsKey);
    await _storage.delete(key: _lockedUntilKey);
  }

  /// Verify PIN
  Future<bool> verifyPin(String pin) async {
    final storedHash = await _storage.read(key: _pinKey);
    if (storedHash == null) return false;
    
    final pinHash = _hashPin(pin);
    return storedHash == pinHash;
  }

  /// Get failed attempts count
  Future<int> getFailedAttempts() async {
    final attemptsStr = await _storage.read(key: _failedAttemptsKey);
    return int.tryParse(attemptsStr ?? '0') ?? 0;
  }

  /// Increment failed attempts
  Future<void> incrementFailedAttempts() async {
    final currentAttempts = await getFailedAttempts();
    final newAttempts = currentAttempts + 1;
    await _storage.write(key: _failedAttemptsKey, value: newAttempts.toString());
    
    // Lock after 5 failed attempts
    if (newAttempts >= 5) {
      final lockUntil = DateTime.now().add(const Duration(minutes: 5));
      await _storage.write(key: _lockedUntilKey, value: lockUntil.toIso8601String());
    }
  }

  /// Reset failed attempts
  Future<void> resetFailedAttempts() async {
    await _storage.delete(key: _failedAttemptsKey);
    await _storage.delete(key: _lockedUntilKey);
  }

  /// Check if PIN is locked
  Future<bool> isPinLocked() async {
    final lockedUntilStr = await _storage.read(key: _lockedUntilKey);
    if (lockedUntilStr == null) return false;
    
    final lockedUntil = DateTime.tryParse(lockedUntilStr);
    if (lockedUntil == null) return false;
    
    return DateTime.now().isBefore(lockedUntil);
  }

  /// Get lock time remaining
  Future<Duration> getLockTimeRemaining() async {
    final lockedUntilStr = await _storage.read(key: _lockedUntilKey);
    if (lockedUntilStr == null) return Duration.zero;
    
    final lockedUntil = DateTime.tryParse(lockedUntilStr);
    if (lockedUntil == null) return Duration.zero;
    
    final now = DateTime.now();
    if (now.isAfter(lockedUntil)) {
      // Lock expired, clean up
      await _storage.delete(key: _lockedUntilKey);
      return Duration.zero;
    }
    
    return lockedUntil.difference(now);
  }

  /// Change PIN
  Future<bool> changePin(String oldPin, String newPin) async {
    if (!await verifyPin(oldPin)) return false;
    await setupPin(newPin);
    return true;
  }

  /// Reset PIN (for admin/recovery)
  Future<void> resetPin() async {
    await _storage.delete(key: _pinKey);
    await _storage.delete(key: _pinLengthKey);
    await _storage.delete(key: _setupCompleteKey);
    await _storage.delete(key: _failedAttemptsKey);
    await _storage.delete(key: _lockedUntilKey);
  }

  /// Hash PIN for secure storage
  String _hashPin(String pin) {
    final bytes = utf8.encode('${pin}secure_pii_salt');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Validate PIN format
  static bool isValidPin(String pin) {
    if (pin.length != 4 && pin.length != 6) return false;
    return RegExp(r'^\d+$').hasMatch(pin);
  }
}