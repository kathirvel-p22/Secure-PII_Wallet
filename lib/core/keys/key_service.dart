import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../crypto/shamir_secret_sharing.dart';

/// Key management service for SSS-style 3-key system
class KeyService {
  final FlutterSecureStorage _secureStorage;

  KeyService(this._secureStorage);

  /// Generate 3 random keys (8 characters each, alphanumeric)
  List<String> generateKeys() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    
    return List.generate(3, (_) {
      return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
    });
  }

  /// Hash a single key
  String _hashKey(String key) {
    final bytes = utf8.encode(key);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Store keys for a file (stores hashes only)
  Future<void> storeKeys(String fileId, List<String> keys) async {
    if (keys.length != 3) {
      throw KeyException('Exactly 3 keys required');
    }

    final keyHashes = keys.map((k) => _hashKey(k)).toList();
    final record = KeyRecord(fileId: fileId, keyHashes: keyHashes);
    
    await _secureStorage.write(
      key: 'keys_$fileId',
      value: jsonEncode(record.toJson()),
    );
  }

  /// Verify keys for a file
  Future<bool> verifyKeys(String fileId, List<String> inputKeys) async {
    if (inputKeys.length != 3) {
      return false;
    }

    final storedData = await _secureStorage.read(key: 'keys_$fileId');
    if (storedData == null) {
      throw KeyException('Keys not found for file');
    }

    final record = KeyRecord.fromJson(jsonDecode(storedData));
    
    // Verify each key hash matches
    for (int i = 0; i < 3; i++) {
      if (_hashKey(inputKeys[i]) != record.keyHashes[i]) {
        return false;
      }
    }
    
    return true;
  }

  /// Delete keys for a file
  Future<void> deleteKeys(String fileId) async {
    await _secureStorage.delete(key: 'keys_$fileId');
  }

  /// Check if keys exist for a file
  Future<bool> hasKeys(String fileId) async {
    final data = await _secureStorage.read(key: 'keys_$fileId');
    return data != null;
  }

  /// Validate key format (8 alphanumeric characters)
  bool validateKeyFormat(String key) {
    final regex = RegExp(r'^[A-Z0-9]{8}$');
    return regex.hasMatch(key);
  }

  /// Validate all keys format
  bool validateKeysFormat(List<String> keys) {
    if (keys.length != 3) return false;
    return keys.every((k) => validateKeyFormat(k));
  }

  /// Store Shamir shares for a file
  Future<void> storeShamirShares(String fileId, List<ShamirShare> shares, int threshold) async {
    final shareData = {
      'threshold': threshold,
      'totalShares': shares.length,
      'shares': shares.map((s) => s.toJson()).toList(),
    };
    
    await _secureStorage.write(
      key: 'shamir_$fileId',
      value: jsonEncode(shareData),
    );
  }

  /// Get Shamir shares for a file
  Future<List<ShamirShare>> getShamirShares(String fileId) async {
    final storedData = await _secureStorage.read(key: 'shamir_$fileId');
    if (storedData == null) {
      throw KeyException('Shamir shares not found for file');
    }

    final shareData = jsonDecode(storedData);
    final sharesList = shareData['shares'] as List;
    
    return sharesList.map((s) => ShamirShare.fromJson(s)).toList();
  }

  /// Get threshold for Shamir shares
  Future<int> getShamirThreshold(String fileId) async {
    final storedData = await _secureStorage.read(key: 'shamir_$fileId');
    if (storedData == null) {
      throw KeyException('Shamir shares not found for file');
    }

    final shareData = jsonDecode(storedData);
    return shareData['threshold'] as int;
  }

  /// Delete Shamir shares for a file
  Future<void> deleteShamirShares(String fileId) async {
    await _secureStorage.delete(key: 'shamir_$fileId');
  }

  /// Check if Shamir shares exist for a file
  Future<bool> hasShamirShares(String fileId) async {
    final data = await _secureStorage.read(key: 'shamir_$fileId');
    return data != null;
  }
}

/// Custom exception for key operations
class KeyException implements Exception {
  final String message;
  KeyException(this.message);

  @override
  String toString() => message;
}

/// Key record for storage
class KeyRecord {
  final String fileId;
  final List<String> keyHashes;

  KeyRecord({
    required this.fileId,
    required this.keyHashes,
  });

  Map<String, dynamic> toJson() {
    return {
      'fileId': fileId,
      'keyHashes': keyHashes,
    };
  }

  factory KeyRecord.fromJson(Map<String, dynamic> json) {
    return KeyRecord(
      fileId: json['fileId'] as String,
      keyHashes: List<String>.from(json['keyHashes']),
    );
  }
}