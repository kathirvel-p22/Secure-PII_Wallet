import 'dart:convert';
import 'package:web/web.dart' as web;
import '../../../features/files/models/file_meta.dart';

/// Web-compatible storage service using browser's localStorage and IndexedDB
class WebStorageService {
  static const String _metadataKey = 'secure_pii_metadata';
  static const String _filePrefix = 'secure_pii_file_';
  static const String _ivPrefix = 'secure_pii_iv_';

  /// Save encrypted file (stores in localStorage as base64)
  Future<void> writeEncrypted(String fileId, EncryptedPayload payload) async {
    try {
      // Convert to base64 for storage
      final cipherBase64 = base64Encode(payload.cipher);
      final ivBase64 = base64Encode(payload.iv);
      
      // Store in localStorage
      web.window.localStorage['$_filePrefix$fileId'] = cipherBase64;
      web.window.localStorage['$_ivPrefix$fileId'] = ivBase64;
    } catch (e) {
      throw StorageException('Failed to save encrypted file: $e');
    }
  }

  /// Read encrypted file
  Future<EncryptedPayload> readEncrypted(String fileId) async {
    try {
      final cipherBase64 = web.window.localStorage['$_filePrefix$fileId'];
      final ivBase64 = web.window.localStorage['$_ivPrefix$fileId'];
      
      if (cipherBase64 == null || ivBase64 == null) {
        throw StorageException('Encrypted file not found');
      }
      
      final cipher = base64Decode(cipherBase64);
      final iv = base64Decode(ivBase64);
      
      return EncryptedPayload(cipher: cipher, iv: iv);
    } catch (e) {
      throw StorageException('Failed to read encrypted file: $e');
    }
  }

  /// Delete encrypted file
  Future<void> deleteEncrypted(String fileId) async {
    web.window.localStorage.removeItem('$_filePrefix$fileId');
    web.window.localStorage.removeItem('$_ivPrefix$fileId');
  }

  /// Load all metadata
  Future<List<FileMeta>> loadMeta() async {
    try {
      final metaJson = web.window.localStorage[_metadataKey];
      
      if (metaJson == null || metaJson.isEmpty) {
        return [];
      }
      
      final List<dynamic> jsonList = jsonDecode(metaJson);
      return jsonList.map((json) => FileMeta.fromJson(json)).toList();
    } catch (e) {
      throw StorageException('Failed to load metadata: $e');
    }
  }

  /// Save all metadata
  Future<void> saveMeta(List<FileMeta> metaList) async {
    try {
      final jsonList = metaList.map((meta) => meta.toJson()).toList();
      web.window.localStorage[_metadataKey] = jsonEncode(jsonList);
    } catch (e) {
      throw StorageException('Failed to save metadata: $e');
    }
  }

  /// Add metadata entry
  Future<void> addMeta(FileMeta meta) async {
    final metaList = await loadMeta();
    metaList.add(meta);
    await saveMeta(metaList);
  }

  /// Remove metadata entry
  Future<void> removeMeta(String fileId) async {
    final metaList = await loadMeta();
    metaList.removeWhere((meta) => meta.id == fileId);
    await saveMeta(metaList);
  }

  /// Get metadata by ID
  Future<FileMeta?> getMetaById(String fileId) async {
    final metaList = await loadMeta();
    try {
      return metaList.firstWhere((meta) => meta.id == fileId);
    } catch (e) {
      return null;
    }
  }

  /// Check if file exists
  Future<bool> fileExists(String fileId) async {
    return web.window.localStorage.getItem('$_filePrefix$fileId') != null;
  }

  /// Get storage path for display
  Future<String> getStoragePath() async {
    return 'Browser Local Storage';
  }

  /// Read secure data (for access logs)
  Future<String?> readSecure(String key) async {
    return web.window.localStorage[key];
  }

  /// Write secure data (for access logs)
  Future<void> writeSecure(String key, String value) async {
    web.window.localStorage[key] = value;
  }

  /// Get all metadata (alias for loadMeta for backup service compatibility)
  Future<List<FileMeta>> getAllMeta() async {
    return await loadMeta();
  }

  /// Check if keys exist for a file
  Future<bool> hasKeys(String fileId) async {
    return web.window.localStorage.getItem('keys_$fileId') != null;
  }

  /// Get keys for a file
  Future<Map<String, dynamic>> getKeys(String fileId) async {
    final keysJson = web.window.localStorage['keys_$fileId'];
    if (keysJson == null) {
      throw StorageException('Keys not found for file $fileId');
    }
    return jsonDecode(keysJson) as Map<String, dynamic>;
  }

  /// Store keys for a file
  Future<void> storeKeys(String fileId, Map<String, dynamic> keys) async {
    web.window.localStorage['keys_$fileId'] = jsonEncode(keys);
  }

  /// Delete keys for a file
  Future<void> deleteKeys(String fileId) async {
    web.window.localStorage.removeItem('keys_$fileId');
  }

  /// Clear all data
  Future<void> clearAll() async {
    // Get all keys that belong to our app
    final keysToRemove = <String>[];
    
    for (int i = 0; i < web.window.localStorage.length; i++) {
      final key = web.window.localStorage.key(i);
      if (key != null && (key.startsWith('secure_pii_') || key.startsWith('keys_'))) {
        keysToRemove.add(key);
      }
    }
    
    // Remove all our keys
    for (final key in keysToRemove) {
      web.window.localStorage.removeItem(key);
    }
  }
}

/// Custom exception for storage operations
class StorageException implements Exception {
  final String message;
  StorageException(this.message);

  @override
  String toString() => message;
}
