import 'package:intl/intl.dart';

/// Metadata for encrypted files
class FileMeta {
  final String id;
  final String name;
  final String path; // Path to encrypted file
  final String mode; // "NORMAL" or "HIGH"
  final String hash; // SHA-256 hash of original file
  final String pwdHash; // SHA-256 hash of password
  final DateTime createdAt;

  FileMeta({
    required this.id,
    required this.name,
    required this.path,
    required this.mode,
    required this.hash,
    required this.pwdHash,
    required this.createdAt,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'mode': mode,
      'hash': hash,
      'pwdHash': pwdHash,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory FileMeta.fromJson(Map<String, dynamic> json) {
    return FileMeta(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      mode: json['mode'] as String,
      hash: json['hash'] as String,
      pwdHash: json['pwdHash'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  String get formattedDate {
    return DateFormat('MMM dd, yyyy HH:mm').format(createdAt);
  }

  bool get isHighSecurity => mode == 'HIGH' || mode == 'HIGH_SSS';
  
  bool get isShamirMode => mode == 'HIGH_SSS';
}

/// Encrypted file payload
class EncryptedPayload {
  final List<int> cipher;
  final List<int> iv;

  EncryptedPayload({
    required this.cipher,
    required this.iv,
  });
}

/// Key record for high security mode
class KeyRecord {
  final String fileId;
  final List<String> keyHashes; // 3 SHA-256 hashes

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
      keyHashes: List<String>.from(json['keyHashes'] as List),
    );
  }
}
