import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/security/access_logger.dart';
import '../../../providers/providers.dart';
import '../models/file_meta.dart';

/// File controller - orchestrates file operations
class FileController {
  final Ref ref;

  FileController(this.ref);

  /// Upload file handler
  Future<FileMeta> upload({
    required File file,
    required String password,
    required bool highSecurity,
    List<String>? keys,
  }) async {
    final security = ref.read(securityProvider);

    // Prepare and store (includes all validation and encryption)
    final meta = await security.prepareAndStore(
      file,
      password,
      highSecurity,
      keys,
    );

    // Update state
    ref.read(filesProvider.notifier).addFile(meta);

    return meta;
  }

  /// Access file handler
  Future<Uint8List> access({
    required String fileId,
    required String password,
    List<String>? keys,
  }) async {
    final security = ref.read(securityProvider);
    final storage = ref.read(storageProvider);
    final logger = AccessLogger(storage);

    // Get file metadata for logging
    final meta = await storage.getMetaById(fileId);
    final fileName = meta?.name ?? 'Unknown';

    try {
      // Access with full verification
      final fileBytes = await security.access(fileId, password, keys);

      // Log successful access
      await logger.logFileAccess(
        fileId: fileId,
        fileName: fileName,
        accessType: AccessType.view,
        success: true,
      );

      return fileBytes;
    } catch (e) {
      // Log failed access
      await logger.logFileAccess(
        fileId: fileId,
        fileName: fileName,
        accessType: AccessType.view,
        success: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Delete file handler
  Future<void> delete(String fileId) async {
    final security = ref.read(securityProvider);
    final storage = ref.read(storageProvider);
    final logger = AccessLogger(storage);

    // Get file metadata for logging
    final meta = await storage.getMetaById(fileId);
    final fileName = meta?.name ?? 'Unknown';

    try {
      // Secure delete
      await security.secureDelete(fileId);

      // Log successful deletion
      await logger.logFileAccess(
        fileId: fileId,
        fileName: fileName,
        accessType: AccessType.delete,
        success: true,
      );

      // Update state
      ref.read(filesProvider.notifier).removeFile(fileId);
    } catch (e) {
      // Log failed deletion
      await logger.logFileAccess(
        fileId: fileId,
        fileName: fileName,
        accessType: AccessType.delete,
        success: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Download file handler (same as access but logs as download)
  Future<Uint8List> download({
    required String fileId,
    required String password,
    List<String>? keys,
  }) async {
    final security = ref.read(securityProvider);
    final storage = ref.read(storageProvider);
    final logger = AccessLogger(storage);

    // Get file metadata for logging
    final meta = await storage.getMetaById(fileId);
    final fileName = meta?.name ?? 'Unknown';

    try {
      // Access with full verification
      final fileBytes = await security.access(fileId, password, keys);

      // Log successful download
      await logger.logFileAccess(
        fileId: fileId,
        fileName: fileName,
        accessType: AccessType.download,
        success: true,
      );

      return fileBytes;
    } catch (e) {
      // Log failed download
      await logger.logFileAccess(
        fileId: fileId,
        fileName: fileName,
        accessType: AccessType.download,
        success: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Refresh files list
  Future<void> refreshFiles() async {
    await ref.read(filesProvider.notifier).refresh();
  }

  /// Get file metadata
  Future<FileMeta?> getFileMeta(String fileId) async {
    final storage = ref.read(storageProvider);
    return await storage.getMetaById(fileId);
  }
}

// Provider for file controller
final fileControllerProvider = Provider<FileController>((ref) {
  return FileController(ref);
});
