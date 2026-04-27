import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinService {
  static const String _pinKey = 'app_pin_hash';
  static const String _pinLengthKey = 'app_pin_length';
  static const String _setupCompleteKey = 'pin_setup_complete';
  static const String _failedAttemptsKey = 'pin_failed_attempts';
  static const String _lockedUntilKey = 'pin_locked_until';

  final SharedPreferences _prefs;

  PinService(this._prefs);

  /// Check if PIN is set up
  Future<bool> isPinSetup() async {
    return _prefs.getBool(_setupCompleteKey) ?? false;
  }

  /// Get PIN length
  Future<int> getPinLength() async {
    return _prefs.getInt(_pinLengthKey) ?? 4;
  }

  /// Set up PIN
  Future<void> setupPin(String pin) async {
    final pinHash = _hashPin(pin);
    await _prefs.setString(_pinKey, pinHash);
    await _prefs.setInt(_pinLengthKey, pin.length);
    await _prefs.setBool(_setupCompleteKey, true);
    await _prefs.remove(_failedAttemptsKey);
    await _prefs.remove(_lockedUntilKey);
  }

  /// Verify PIN
  Future<bool> verifyPin(String pin) async {
    final storedHash = _prefs.getString(_pinKey);
    if (storedHash == null) return false;
    
    final pinHash = _hashPin(pin);
    return storedHash == pinHash;
  }

  /// Get failed attempts count
  Future<int> getFailedAttempts() async {
    return _prefs.getInt(_failedAttemptsKey) ?? 0;
  }

  /// Increment failed attempts
  Future<void> incrementFailedAttempts() async {
    final currentAttempts = await getFailedAttempts();
    final newAttempts = currentAttempts + 1;
    await _prefs.setInt(_failedAttemptsKey, newAttempts);
    
    // Lock after 5 failed attempts
    if (newAttempts >= 5) {
      final lockUntil = DateTime.now().add(const Duration(minutes: 5));
      await _prefs.setString(_lockedUntilKey, lockUntil.toIso8601String());
    }
  }

  /// Reset failed attempts
  Future<void> resetFailedAttempts() async {
    await _prefs.remove(_failedAttemptsKey);
    await _prefs.remove(_lockedUntilKey);
  }

  /// Check if PIN is locked
  Future<bool> isPinLocked() async {
    final lockedUntilStr = _prefs.getString(_lockedUntilKey);
    if (lockedUntilStr == null) return false;
    
    final lockedUntil = DateTime.tryParse(lockedUntilStr);
    if (lockedUntil == null) return false;
    
    return DateTime.now().isBefore(lockedUntil);
  }

  /// Get lock time remaining
  Future<Duration> getLockTimeRemaining() async {
    final lockedUntilStr = _prefs.getString(_lockedUntilKey);
    if (lockedUntilStr == null) return Duration.zero;
    
    final lockedUntil = DateTime.tryParse(lockedUntilStr);
    if (lockedUntil == null) return Duration.zero;
    
    final now = DateTime.now();
    if (now.isAfter(lockedUntil)) {
      // Lock expired, clean up
      await _prefs.remove(_lockedUntilKey);
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
    await _prefs.remove(_pinKey);
    await _prefs.remove(_pinLengthKey);
    await _prefs.remove(_setupCompleteKey);
    await _prefs.remove(_failedAttemptsKey);
    await _prefs.remove(_lockedUntilKey);
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