import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../features/files/models/file_meta.dart';

/// Storage service for encrypted files and metadata
class StorageService {
  static const String _encryptedDir = 'encrypted';
  static const String _metadataFile = 'metadata.json';

  /// Get app data directory
  Future<Directory> _getAppDataDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/secure_pii_wallet');
  }

  /// Get encrypted files directory
  Future<Directory> _getEncryptedDir() async {
    final appDir = await _getAppDataDir();
    final encDir = Directory('${appDir.path}/$_encryptedDir');
    if (!await encDir.exists()) {
      await encDir.create(recursive: true);
    }
    return encDir;
  }

  /// Get metadata file
  Future<File> _getMetadataFile() async {
    final appDir = await _getAppDataDir();
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    return File('${appDir.path}/$_metadataFile');
  }

  /// Save encrypted file
  Future<void> writeEncrypted(String fileId, EncryptedPayload payload) async {
    final encDir = await _getEncryptedDir();
    
    // Save cipher
    final cipherFile = File('${encDir.path}/$fileId.bin');
    await cipherFile.writeAsBytes(payload.cipher);
    
    // Save IV
    final ivFile = File('${encDir.path}/$fileId.iv');
    await ivFile.writeAsBytes(payload.iv);
  }

  /// Read encrypted file
  Future<EncryptedPayload> readEncrypted(String fileId) async {
    final encDir = await _getEncryptedDir();
    
    final cipherFile = File('${encDir.path}/$fileId.bin');
    final ivFile = File('${encDir.path}/$fileId.iv');
    
    if (!await cipherFile.exists() || !await ivFile.exists()) {
      throw StorageException('Encrypted file not found');
    }
    
    final cipher = await cipherFile.readAsBytes();
    final iv = await ivFile.readAsBytes();
    
    return EncryptedPayload(cipher: cipher, iv: iv);
  }

  /// Delete encrypted file
  Future<void> deleteEncrypted(String fileId) async {
    final encDir = await _getEncryptedDir();
    
    final cipherFile = File('${encDir.path}/$fileId.bin');
    final ivFile = File('${encDir.path}/$fileId.iv');
    
    if (await cipherFile.exists()) {
      await cipherFile.delete();
    }
    if (await ivFile.exists()) {
      await ivFile.delete();
    }
  }

  /// Load all metadata
  Future<List<FileMeta>> loadMeta() async {
    final metaFile = await _getMetadataFile();
    
    if (!await metaFile.exists()) {
      return [];
    }
    
    try {
      final content = await metaFile.readAsString();
      final List<dynamic> jsonList = jsonDecode(content);
      return jsonList.map((json) => FileMeta.fromJson(json)).toList();
    } catch (e) {
      throw StorageException('Failed to load metadata: $e');
    }
  }

  /// Save all metadata
  Future<void> saveMeta(List<FileMeta> metaList) async {
    final metaFile = await _getMetadataFile();
    final jsonList = metaList.map((meta) => meta.toJson()).toList();
    await metaFile.writeAsString(jsonEncode(jsonList));
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
    final encDir = await _getEncryptedDir();
    final cipherFile = File('${encDir.path}/$fileId.bin');
    return await cipherFile.exists();
  }

  /// Get storage path for display
  Future<String> getStoragePath() async {
    final appDir = await _getAppDataDir();
    return appDir.path;
  }

  /// Read secure data (for access logs)
  Future<String?> readSecure(String key) async {
    try {
      final appDir = await _getAppDataDir();
      final file = File('${appDir.path}/$key.json');
      if (!await file.exists()) return null;
      return await file.readAsString();
    } catch (e) {
      return null;
    }
  }

  /// Write secure data (for access logs)
  Future<void> writeSecure(String key, String value) async {
    final appDir = await _getAppDataDir();
    final file = File('${appDir.path}/$key.json');
    await file.writeAsString(value);
  }
}

/// Custom exception for storage operations
class StorageException implements Exception {
  final String message;
  StorageException(this.message);

  @override
  String toString() => message;
}
