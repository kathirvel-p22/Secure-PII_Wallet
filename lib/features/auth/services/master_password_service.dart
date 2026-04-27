import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for managing the master password (strong password for critical operations)
class MasterPasswordService {
  static const String _masterPasswordKey = 'master_password_hash';
  static const String _setupCompleteKey = 'master_password_setup_complete';

  final FlutterSecureStorage _storage;

  MasterPasswordService(this._storage);

  /// Check if master password is set up
  Future<bool> isMasterPasswordSetup() async {
    final setupComplete = await _storage.read(key: _setupCompleteKey);
    return setupComplete == 'true';
  }

  /// Set up master password
  Future<void> setupMasterPassword(String password) async {
    if (!isStrongPassword(password)) {
      throw Exception('Password does not meet security requirements');
    }

    final passwordHash = _hashPassword(password);
    await _storage.write(key: _masterPasswordKey, value: passwordHash);
    await _storage.write(key: _setupCompleteKey, value: 'true');
  }

  /// Verify master password
  Future<bool> verifyMasterPassword(String password) async {
    final storedHash = await _storage.read(key: _masterPasswordKey);
    if (storedHash == null) return false;
    
    final passwordHash = _hashPassword(password);
    return storedHash == passwordHash;
  }

  /// Change master password
  Future<bool> changeMasterPassword(String oldPassword, String newPassword) async {
    if (!await verifyMasterPassword(oldPassword)) return false;
    if (!isStrongPassword(newPassword)) return false;
    
    await setupMasterPassword(newPassword);
    return true;
  }

  /// Reset master password (requires complete app reset)
  Future<void> resetMasterPassword() async {
    await _storage.delete(key: _masterPasswordKey);
    await _storage.delete(key: _setupCompleteKey);
  }

  /// Hash password for secure storage
  String _hashPassword(String password) {
    final bytes = utf8.encode('$password-master_password_salt_secure_pii');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Validate password strength
  static bool isStrongPassword(String password) {
    // Minimum 10 characters
    if (password.length < 10) return false;
    
    // Must contain uppercase
    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;
    
    // Must contain lowercase
    if (!RegExp(r'[a-z]').hasMatch(password)) return false;
    
    // Must contain number
    if (!RegExp(r'[0-9]').hasMatch(password)) return false;
    
    // Must contain special character
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(password)) return false;
    
    return true;
  }

  /// Get password strength feedback
  static String getPasswordStrengthFeedback(String password) {
    if (password.length < 10) {
      return 'Password must be at least 10 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Add at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Add at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Add at least one number';
    }
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      return r'Add at least one special character (!@#$%^&*)';
    }
    return 'Strong password';
  }

  /// Calculate password strength score (0-100)
  static int calculatePasswordStrength(String password) {
    int score = 0;
    
    // Length score (max 30 points)
    if (password.length >= 10) score += 15;
    if (password.length >= 12) score += 10;
    if (password.length >= 16) score += 5;
    
    // Character variety (max 40 points)
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 10;
    if (RegExp(r'[a-z]').hasMatch(password)) score += 10;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 10;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score += 10;
    
    // Multiple occurrences (max 20 points)
    if (RegExp(r'[A-Z].*[A-Z]').hasMatch(password)) score += 5;
    if (RegExp(r'[a-z].*[a-z]').hasMatch(password)) score += 5;
    if (RegExp(r'[0-9].*[0-9]').hasMatch(password)) score += 5;
    if (RegExp(r'[^A-Za-z0-9].*[^A-Za-z0-9]').hasMatch(password)) score += 5;
    
    // Complexity bonus (max 10 points)
    if (password.length >= 14 && 
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      score += 10;
    }
    
    return score.clamp(0, 100);
  }
}