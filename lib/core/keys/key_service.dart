import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../crypto/shamir_secret_sharing.dart';

/// Key management service for SSS-style 3-key system
class KeyService {
  static const String _boxName = 'keys_box';
  late final Box _box;

  KeyService._();

  static Future<KeyService> create() async {
    final service = KeyService._();
    service._box = await Hive.openBox(_boxName);
    return service;
  }

  /// Empty/placeholder instance used while KeyService is loading
  static KeyService empty() {
    final service = KeyService._();
    // _box will be assigned lazily - this instance should not be used for real ops
    return service;
  }

  /// Generate 3 random keys (8 characters each, alphanumeric)
  List<String> generateKeys() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();

    return List.generate(3, (_) {
      return List.generate(8, (_) => chars[random.nextInt(chars.length)])
          .join();
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

    await _box.put(
      'keys_$fileId',
      jsonEncode(record.toJson()),
    );
  }

  /// Verify keys for a file
  Future<bool> verifyKeys(String fileId, List<String> inputKeys) async {
    final storedData = _box.get('keys_$fileId');
    if (storedData == null) return false;

    final record = KeyRecord.fromJson(jsonDecode(storedData));
    final inputHashes = inputKeys.map((k) => _hashKey(k)).toList();

    // All hashes must match
    if (record.keyHashes.length != inputHashes.length) return false;

    for (int i = 0; i < record.keyHashes.length; i++) {
      if (record.keyHashes[i] != inputHashes[i]) return false;
    }

    return true;
  }

  /// Delete keys for a file
  Future<void> deleteKeys(String fileId) async {
    await _box.delete('keys_$fileId');
  }

  /// Check if keys exist for a file
  Future<bool> hasKeys(String fileId) async {
    return _box.containsKey('keys_$fileId');
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
  Future<void> storeShamirShares(
      String fileId, List<ShamirShare> shares, int threshold) async {
    final shareData = {
      'threshold': threshold,
      'totalShares': shares.length,
      'shares': shares.map((s) => s.toJson()).toList(),
    };

    await _box.put(
      'shamir_$fileId',
      jsonEncode(shareData),
    );
  }

  /// Get Shamir shares for a file
  Future<List<ShamirShare>> getShamirShares(String fileId) async {
    final storedData = _box.get('shamir_$fileId');
    if (storedData == null) {
      throw KeyException('Shamir shares not found for file');
    }

    final shareData = jsonDecode(storedData);
    final sharesList = shareData['shares'] as List;

    return sharesList.map((s) => ShamirShare.fromJson(s)).toList();
  }

  /// Get threshold for Shamir shares
  Future<int> getShamirThreshold(String fileId) async {
    final storedData = _box.get('shamir_$fileId');
    if (storedData == null) {
      throw KeyException('Shamir shares not found for file');
    }

    final shareData = jsonDecode(storedData);
    return shareData['threshold'] as int;
  }

  /// Delete Shamir shares for a file
  Future<void> deleteShamirShares(String fileId) async {
    await _box.delete('shamir_$fileId');
  }

  /// Check if Shamir shares exist for a file
  Future<bool> hasShamirShares(String fileId) async {
    return _box.containsKey('shamir_$fileId');
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
