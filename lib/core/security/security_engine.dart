import 'dart:io';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import '../crypto/crypto_service.dart';
import '../crypto/shamir_secret_sharing.dart';
import '../keys/key_service.dart';
import '../../features/files/models/file_meta.dart';

/// Security Engine - Core decision and policy enforcement
class SecurityEngine {
  final CryptoService _crypto;
  final dynamic _storage; // Can be StorageService or WebStorageService
  final KeyService _keyService;

  SecurityEngine(this._crypto, this._storage, this._keyService);

  // Password policy constants
  static const int minPasswordLength = 10;
  static const int maxFailedAttempts = 3;
  static const Duration lockDuration = Duration(minutes: 2);

  /// Validate password strength
  bool isStrongPassword(String password) {
    if (password.length < minPasswordLength) return false;
    
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

  /// Assert password strength (throws if weak)
  void assertStrongPassword(String password) {
    if (!isStrongPassword(password)) {
      throw SecurityException(
        'Password must be at least $minPasswordLength characters and contain uppercase, lowercase, number, and special character',
      );
    }
  }

  /// Prepare and store file (complete upload pipeline)
  Future<FileMeta> prepareAndStore(
    File file,
    String password,
    bool highSecurity,
    List<String>? keys,
  ) async {
    // Validate password
    assertStrongPassword(password);

    // Read original file
    final fileBytes = await file.readAsBytes();
    
    // Generate file hash for integrity
    final fileHash = _crypto.hashFile(fileBytes);
    
    // Hash password for storage
    final pwdHash = _crypto.hashPassword(password);
    
    // Generate unique file ID
    final fileId = const Uuid().v4();
    
    if (highSecurity) {
      // HIGH SECURITY: Use Shamir's Secret Sharing
      if (keys == null || keys.length < 3) {
        throw SecurityException('High security mode requires at least 3 shares');
      }
      
      // Generate random AES key for this file
      final aesKey = ShamirSecretSharing.generateRandomSecret(32); // 256-bit key
      
      // Split the AES key using Shamir's Secret Sharing
      final totalShares = keys.length;
      final threshold = (totalShares * 2 / 3).ceil(); // 2/3 threshold
      
      final shares = ShamirSecretSharing.split(
        secret: aesKey,
        threshold: threshold,
        totalShares: totalShares,
      );
      
      // Encrypt file with the generated AES key
      final encrypted = await _crypto.encryptWithKey(fileBytes, aesKey);
      
      // Store encrypted file
      await _storage.writeEncrypted(fileId, encrypted);
      
      // Store shares (user gets some, system stores some)
      await _keyService.storeShamirShares(fileId, shares, threshold);
      
      // Create metadata
      final meta = FileMeta(
        id: fileId,
        name: file.path.split('/').last.split('\\').last,
        path: fileId,
        mode: 'HIGH_SSS', // Shamir's Secret Sharing mode
        hash: fileHash,
        pwdHash: pwdHash,
        createdAt: DateTime.now(),
      );
      
      // Save metadata
      await _storage.addMeta(meta);
      
      return meta;
    } else {
      // NORMAL SECURITY: Password-based encryption
      final encrypted = await _crypto.encrypt(fileBytes, password);
      
      // Store encrypted file
      await _storage.writeEncrypted(fileId, encrypted);
      
      // Create metadata
      final meta = FileMeta(
        id: fileId,
        name: file.path.split('/').last.split('\\').last,
        path: fileId,
        mode: 'NORMAL',
        hash: fileHash,
        pwdHash: pwdHash,
        createdAt: DateTime.now(),
      );
      
      // Save metadata
      await _storage.addMeta(meta);
      
      return meta;
    }
  }

  /// Prepare and store web file with pre-generated SSS shares
  Future<FileMeta> prepareAndStoreWebFileWithShares(
    dynamic webFile, // WebFile type
    String password,
    Uint8List aesKey,
    List<ShamirShare> allShares,
    int threshold,
  ) async {
    // Validate password
    assertStrongPassword(password);

    // Get file bytes (webFile.bytes)
    final fileBytes = webFile.bytes;
    
    // Generate file hash for integrity
    final fileHash = _crypto.hashFile(fileBytes);
    
    // Hash password for storage
    final pwdHash = _crypto.hashPassword(password);
    
    // Generate unique file ID
    final fileId = const Uuid().v4();
    
    // Encrypt file with the provided AES key
    final encrypted = await _crypto.encryptWithKey(fileBytes, aesKey);
    
    // Store encrypted file
    await _storage.writeEncrypted(fileId, encrypted);
    
    // Store system shares based on threshold configuration
    // User gets the first (threshold) shares, system stores the remaining ones
    final systemShares = allShares.skip(threshold).toList();
    await _keyService.storeShamirShares(fileId, systemShares, threshold);
    
    // Create metadata
    final meta = FileMeta(
      id: fileId,
      name: webFile.name,
      path: fileId,
      mode: 'HIGH_SSS', // Shamir's Secret Sharing mode
      hash: fileHash,
      pwdHash: pwdHash,
      createdAt: DateTime.now(),
    );
    
    // Save metadata
    await _storage.addMeta(meta);
    
    return meta;
  }
  Future<FileMeta> prepareAndStoreWebFile(
    dynamic webFile, // WebFile type
    String password,
    bool highSecurity,
    List<String>? keys,
  ) async {
    // Validate password
    assertStrongPassword(password);

    // Get file bytes (webFile.bytes)
    final fileBytes = webFile.bytes;
    
    // Generate file hash for integrity
    final fileHash = _crypto.hashFile(fileBytes);
    
    // Hash password for storage
    final pwdHash = _crypto.hashPassword(password);
    
    // Generate unique file ID
    final fileId = const Uuid().v4();
    
    if (highSecurity) {
      // HIGH SECURITY: Use Shamir's Secret Sharing
      if (keys == null || keys.length < 3) {
        throw SecurityException('High security mode requires at least 3 shares');
      }
      
      // Generate random AES key for this file
      final aesKey = ShamirSecretSharing.generateRandomSecret(32); // 256-bit key
      
      // Split the AES key using Shamir's Secret Sharing
      // Use default values for legacy compatibility
      final totalShares = 5; // Default total shares
      final threshold = 3; // Default threshold
      
      final shares = ShamirSecretSharing.split(
        secret: aesKey,
        threshold: threshold,
        totalShares: totalShares,
      );
      
      // Encrypt file with the generated AES key
      final encrypted = await _crypto.encryptWithKey(fileBytes, aesKey);
      
      // Store encrypted file
      await _storage.writeEncrypted(fileId, encrypted);
      
      // Store system shares (user gets first threshold shares, system stores remaining)
      final systemShares = shares.skip(threshold).toList();
      await _keyService.storeShamirShares(fileId, systemShares, threshold);
      
      // Create metadata
      final meta = FileMeta(
        id: fileId,
        name: webFile.name,
        path: fileId,
        mode: 'HIGH_SSS', // Shamir's Secret Sharing mode
        hash: fileHash,
        pwdHash: pwdHash,
        createdAt: DateTime.now(),
      );
      
      // Save metadata
      await _storage.addMeta(meta);
      
      return meta;
    } else {
      // NORMAL SECURITY: Password-based encryption
      final encrypted = await _crypto.encrypt(fileBytes, password);
      
      // Store encrypted file
      await _storage.writeEncrypted(fileId, encrypted);
      
      // Create metadata
      final meta = FileMeta(
        id: fileId,
        name: webFile.name,
        path: fileId,
        mode: 'NORMAL',
        hash: fileHash,
        pwdHash: pwdHash,
        createdAt: DateTime.now(),
      );
      
      // Save metadata
      await _storage.addMeta(meta);
      
      return meta;
    }
  }

  /// Access file (complete access pipeline with verification)
  Future<Uint8List> access(
    String fileId,
    String password,
    List<String>? keys,
  ) async {
    // Get metadata
    final meta = await _storage.getMetaById(fileId);
    if (meta == null) {
      throw SecurityException('File not found');
    }

    // Verify password
    if (!_crypto.verifyPassword(password, meta.pwdHash)) {
      throw SecurityException('Wrong password');
    }

    // Handle different security modes
    if (meta.mode == 'HIGH_SSS') {
      // HIGH SECURITY with Shamir's Secret Sharing
      if (keys == null || keys.isEmpty) {
        throw SecurityException('Shamir shares required for high security files');
      }
      
      // Parse user-provided shares
      List<ShamirShare> userShares = [];
      try {
        userShares = ShamirSecretSharing.fromHumanReadableList(keys);
      } catch (e) {
        throw SecurityException('Invalid share format: ${e.toString()}. Please copy the shares exactly as shown during upload.');
      }
      
      // Get stored shares and threshold
      final storedShares = await _keyService.getShamirShares(fileId);
      final threshold = await _keyService.getShamirThreshold(fileId);
      
      // Combine user shares with stored shares
      final allShares = [...userShares, ...storedShares];
      
      // Check if we have enough shares
      if (allShares.length < threshold) {
        throw SecurityException('Insufficient shares: need $threshold, have ${allShares.length}');
      }
      
      // Remove duplicate shares (same index)
      final uniqueShares = <int, ShamirShare>{};
      for (final share in allShares) {
        uniqueShares[share.index] = share;
      }
      final deduplicatedShares = uniqueShares.values.toList();
      
      // Check if we still have enough unique shares
      if (deduplicatedShares.length < threshold) {
        throw SecurityException('Insufficient unique shares: need $threshold, have ${deduplicatedShares.length}');
      }
      
      // Take any threshold number of shares (order doesn't matter for SSS)
      final requiredShares = deduplicatedShares.take(threshold).toList();
      
      // Reconstruct the AES key
      final aesKey = ShamirSecretSharing.combine(requiredShares);
      
      // Read encrypted file
      final encrypted = await _storage.readEncrypted(fileId);
      
      // Decrypt file with reconstructed key
      final decrypted = _crypto.decryptWithKey(encrypted, aesKey);
      
      // Verify integrity
      if (!_crypto.verifyIntegrity(decrypted, meta.hash)) {
        throw TamperException('File integrity check failed - file may be tampered');
      }

      return decrypted;
    } else if (meta.isHighSecurity) {
      // Legacy HIGH security mode (3-key system)
      if (keys == null || keys.length != 3) {
        throw SecurityException('High security mode requires 3 keys');
      }
      
      final keysValid = await _keyService.verifyKeys(fileId, keys);
      if (!keysValid) {
        throw SecurityException('Wrong keys');
      }
      
      // Read encrypted file
      final encrypted = await _storage.readEncrypted(fileId);
      
      // Decrypt file
      final decrypted = _crypto.decrypt(encrypted, password);
      
      // Verify integrity
      if (!_crypto.verifyIntegrity(decrypted, meta.hash)) {
        throw TamperException('File integrity check failed - file may be tampered');
      }

      return decrypted;
    } else {
      // NORMAL security mode (password only)
      // Read encrypted file
      final encrypted = await _storage.readEncrypted(fileId);
      
      // Decrypt file
      final decrypted = _crypto.decrypt(encrypted, password);
      
      // Verify integrity
      if (!_crypto.verifyIntegrity(decrypted, meta.hash)) {
        throw TamperException('File integrity check failed - file may be tampered');
      }

      return decrypted;
    }
  }

  /// Secure delete (remove all traces)
  Future<void> secureDelete(String fileId) async {
    // Delete encrypted file
    await _storage.deleteEncrypted(fileId);
    
    // Delete keys if they exist (legacy mode)
    if (await _keyService.hasKeys(fileId)) {
      await _keyService.deleteKeys(fileId);
    }
    
    // Delete Shamir shares if they exist (SSS mode)
    if (await _keyService.hasShamirShares(fileId)) {
      await _keyService.deleteShamirShares(fileId);
    }
    
    // Remove metadata
    await _storage.removeMeta(fileId);
  }

  /// Verify password for existing file
  Future<bool> verifyFilePassword(String fileId, String password) async {
    final meta = await _storage.getMetaById(fileId);
    if (meta == null) return false;
    return _crypto.verifyPassword(password, meta.pwdHash);
  }

  /// Get password strength feedback
  String getPasswordStrengthFeedback(String password) {
    if (password.length < minPasswordLength) {
      return 'Too short (min $minPasswordLength characters)';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Add uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Add lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Add number';
    }
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      return 'Add special character';
    }
    return 'Strong';
  }
}

/// Security exception
class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);

  @override
  String toString() => message;
}

/// Tamper detection exception
class TamperException implements Exception {
  final String message;
  TamperException(this.message);

  @override
  String toString() => message;
}