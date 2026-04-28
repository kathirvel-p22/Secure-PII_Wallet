import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PinService {
  static const String _boxName = 'pin_box';
  static const String _pinKey = 'app_pin_hash';
  static const String _pinLengthKey = 'app_pin_length';
  static const String _setupCompleteKey = 'pin_setup_complete';
  static const String _failedAttemptsKey = 'pin_failed_attempts';
  static const String _lockedUntilKey = 'pin_locked_until';

  late final Box _box;

  PinService._();

  static Future<PinService> create() async {
    final service = PinService._();
    service._box = await Hive.openBox(_boxName);
    return service;
  }

  /// Check if PIN is set up
  Future<bool> isPinSetup() async {
    return _box.get(_setupCompleteKey, defaultValue: false);
  }

  /// Get PIN length
  Future<int> getPinLength() async {
    return _box.get(_pinLengthKey, defaultValue: 4);
  }

  /// Set up PIN
  Future<void> setupPin(String pin) async {
    final pinHash = _hashPin(pin);
    await _box.put(_pinKey, pinHash);
    await _box.put(_pinLengthKey, pin.length);
    await _box.put(_setupCompleteKey, true);
    await _box.delete(_failedAttemptsKey);
    await _box.delete(_lockedUntilKey);
  }

  /// Verify PIN
  Future<bool> verifyPin(String pin) async {
    final storedHash = _box.get(_pinKey);
    if (storedHash == null) return false;
    
    final pinHash = _hashPin(pin);
    return storedHash == pinHash;
  }

  /// Get failed attempts count
  Future<int> getFailedAttempts() async {
    return _box.get(_failedAttemptsKey, defaultValue: 0);
  }

  /// Increment failed attempts
  Future<void> incrementFailedAttempts() async {
    final currentAttempts = await getFailedAttempts();
    final newAttempts = currentAttempts + 1;
    await _box.put(_failedAttemptsKey, newAttempts);
    
    // Lock after 5 failed attempts
    if (newAttempts >= 5) {
      final lockUntil = DateTime.now().add(const Duration(minutes: 5));
      await _box.put(_lockedUntilKey, lockUntil.toIso8601String());
    }
  }

  /// Reset failed attempts
  Future<void> resetFailedAttempts() async {
    await _box.delete(_failedAttemptsKey);
    await _box.delete(_lockedUntilKey);
  }

  /// Check if PIN is locked
  Future<bool> isPinLocked() async {
    final lockedUntilStr = _box.get(_lockedUntilKey);
    if (lockedUntilStr == null) return false;
    
    final lockedUntil = DateTime.tryParse(lockedUntilStr);
    if (lockedUntil == null) return false;
    
    return DateTime.now().isBefore(lockedUntil);
  }

  /// Get lock time remaining
  Future<Duration> getLockTimeRemaining() async {
    final lockedUntilStr = _box.get(_lockedUntilKey);
    if (lockedUntilStr == null) return Duration.zero;
    
    final lockedUntil = DateTime.tryParse(lockedUntilStr);
    if (lockedUntil == null) return Duration.zero;
    
    final now = DateTime.now();
    if (now.isAfter(lockedUntil)) {
      // Lock expired, clean up
      await _box.delete(_lockedUntilKey);
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
    await _box.delete(_pinKey);
    await _box.delete(_pinLengthKey);
    await _box.delete(_setupCompleteKey);
    await _box.delete(_failedAttemptsKey);
    await _box.delete(_lockedUntilKey);
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