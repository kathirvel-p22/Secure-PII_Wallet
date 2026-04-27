import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import '../../features/files/models/file_meta.dart';

/// Cryptography service for AES-256 encryption/decryption
class CryptoService {
  /// Derive encryption key from password using SHA-256
  Uint8List deriveKey(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return Uint8List.fromList(hash.bytes);
  }

  /// Hash password for storage (never store raw password)
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Hash file content for integrity verification
  String hashFile(Uint8List fileBytes) {
    final hash = sha256.convert(fileBytes);
    return hash.toString();
  }

  /// Encrypt file using AES-256-CBC
  Future<EncryptedPayload> encrypt(Uint8List data, String password) async {
    try {
      final key = deriveKey(password);
      final iv = enc.IV.fromSecureRandom(16);
      
      final encrypter = enc.Encrypter(
        enc.AES(enc.Key(key), mode: enc.AESMode.cbc),
      );
      
      final encrypted = encrypter.encryptBytes(data, iv: iv);
      
      return EncryptedPayload(
        cipher: encrypted.bytes,
        iv: iv.bytes,
      );
    } catch (e) {
      throw CryptoException('Encryption failed: $e');
    }
  }

  /// Decrypt file using AES-256-CBC
  Uint8List decrypt(EncryptedPayload payload, String password) {
    try {
      final key = deriveKey(password);
      final iv = enc.IV(Uint8List.fromList(payload.iv));
      
      final encrypter = enc.Encrypter(
        enc.AES(enc.Key(key), mode: enc.AESMode.cbc),
      );
      
      final decrypted = encrypter.decryptBytes(
        enc.Encrypted(Uint8List.fromList(payload.cipher)),
        iv: iv,
      );
      
      return Uint8List.fromList(decrypted);
    } catch (e) {
      throw CryptoException('Decryption failed: Wrong password or corrupted file');
    }
  }

  /// Encrypt file using provided AES key
  Future<EncryptedPayload> encryptWithKey(Uint8List data, Uint8List key) async {
    try {
      if (key.length != 32) {
        throw CryptoException('AES key must be 32 bytes (256 bits)');
      }
      
      final iv = enc.IV.fromSecureRandom(16);
      
      final encrypter = enc.Encrypter(
        enc.AES(enc.Key(key), mode: enc.AESMode.cbc),
      );
      
      final encrypted = encrypter.encryptBytes(data, iv: iv);
      
      return EncryptedPayload(
        cipher: encrypted.bytes,
        iv: iv.bytes,
      );
    } catch (e) {
      throw CryptoException('Encryption failed: $e');
    }
  }

  /// Decrypt file using provided AES key
  Uint8List decryptWithKey(EncryptedPayload payload, Uint8List key) {
    try {
      if (key.length != 32) {
        throw CryptoException('AES key must be 32 bytes (256 bits)');
      }
      
      final iv = enc.IV(Uint8List.fromList(payload.iv));
      
      final encrypter = enc.Encrypter(
        enc.AES(enc.Key(key), mode: enc.AESMode.cbc),
      );
      
      final decrypted = encrypter.decryptBytes(
        enc.Encrypted(Uint8List.fromList(payload.cipher)),
        iv: iv,
      );
      
      return Uint8List.fromList(decrypted);
    } catch (e) {
      throw CryptoException('Decryption failed: Wrong key or corrupted file');
    }
  }

  /// Verify password against stored hash
  bool verifyPassword(String inputPassword, String storedHash) {
    final inputHash = hashPassword(inputPassword);
    return inputHash == storedHash;
  }

  /// Verify file integrity
  bool verifyIntegrity(Uint8List fileBytes, String storedHash) {
    final currentHash = hashFile(fileBytes);
    return currentHash == storedHash;
  }
}

/// Custom exception for crypto operations
class CryptoException implements Exception {
  final String message;
  CryptoException(this.message);

  @override
  String toString() => message;
}