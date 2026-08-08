import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'file_database.dart';
import 'models/file_metadata.dart';

/// Database service for managing Normal Security files
/// Note: This service is ONLY for Normal Security mode, NOT for SSS files
class DatabaseService {
  final FileDatabase _db = FileDatabase.instance;

  // Insert file metadata (only for Normal Security)
  Future<void> addFile(FileMetadata file) async {
    if (file.isSecurityModeSSS) {
      throw Exception('SSS files should not be stored in database');
    }
    await _db.insertFile(file.toMap());
  }

  // Get all normal security files
  Future<List<FileMetadata>> getAllFiles() async {
    final maps = await _db.getAllFiles();
    return maps.map((map) => FileMetadata.fromMap(map)).toList();
  }

  // Get files by category
  Future<List<FileMetadata>> getFilesByCategory(String category) async {
    final maps = await _db.getFilesByCategory(category);
    return maps.map((map) => FileMetadata.fromMap(map)).toList();
  }

  // Get favorite files
  Future<List<FileMetadata>> getFavoriteFiles() async {
    final maps = await _db.getFavoriteFiles();
    return maps.map((map) => FileMetadata.fromMap(map)).toList();
  }

  // Get recently accessed files
  Future<List<FileMetadata>> getRecentFiles({int limit = 10}) async {
    final maps = await _db.getRecentFiles(limit: limit);
    return maps.map((map) => FileMetadata.fromMap(map)).toList();
  }

  // Get most accessed files
  Future<List<FileMetadata>> getMostAccessedFiles({int limit = 10}) async {
    final maps = await _db.getMostAccessedFiles(limit: limit);
    return maps.map((map) => FileMetadata.fromMap(map)).toList();
  }

  // Search files
  Future<List<FileMetadata>> searchFiles(String query) async {
    final maps = await _db.searchFiles(query);
    return maps.map((map) => FileMetadata.fromMap(map)).toList();
  }

  // Search by tag
  Future<List<FileMetadata>> searchFilesByTag(String tag) async {
    final maps = await _db.searchFilesByTag(tag);
    return maps.map((map) => FileMetadata.fromMap(map)).toList();
  }

  // Update file
  Future<void> updateFile(String id, FileMetadata file) async {
    await _db.updateFile(id, file.toMap());
  }

  // Update access info (called when file is opened)
  Future<void> recordFileAccess(String id) async {
    await _db.updateAccessInfo(id);
  }

  // Toggle favorite
  Future<void> toggleFavorite(String id) async {
    await _db.toggleFavorite(id);
  }

  // Delete file
  Future<void> deleteFile(String id) async {
    await _db.deleteFile(id);
  }

  // Get statistics
  Future<Map<String, dynamic>> getFileStats() async {
    return await _db.getFileStats();
  }

  // Get categories
  Future<List<FileCategory>> getAllCategories() async {
    final maps = await _db.getAllCategories();
    return maps.map((map) => FileCategory.fromMap(map)).toList();
  }

  // Get tags
  Future<List<FileTag>> getAllTags() async {
    final maps = await _db.getAllTags();
    return maps.map((map) => FileTag.fromMap(map)).toList();
  }

  // Add category
  Future<int> addCategory(FileCategory category) async {
    return await _db.addCategory(category.toMap());
  }

  // Add tag
  Future<int> addTag(FileTag tag) async {
    return await _db.addTag(tag.toMap());
  }

  // Clear all data (for factory reset)
  Future<void> clearAllData() async {
    await _db.clearAllData();
  }

  // Close database
  Future<void> close() async {
    await _db.close();
  }
}

// Riverpod provider for database service
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

// Provider for all files
final allFilesProvider = FutureProvider<List<FileMetadata>>((ref) async {
  final service = ref.watch(databaseServiceProvider);
  return await service.getAllFiles();
});

// Provider for favorite files
final favoriteFilesProvider = FutureProvider<List<FileMetadata>>((ref) async {
  final service = ref.watch(databaseServiceProvider);
  return await service.getFavoriteFiles();
});

// Provider for recent files
final recentFilesProvider = FutureProvider<List<FileMetadata>>((ref) async {
  final service = ref.watch(databaseServiceProvider);
  return await service.getRecentFiles(limit: 10);
});

// Provider for file statistics
final fileStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(databaseServiceProvider);
  return await service.getFileStats();
});

// Provider for categories
final categoriesProvider = FutureProvider<List<FileCategory>>((ref) async {
  final service = ref.watch(databaseServiceProvider);
  return await service.getAllCategories();
});

// Provider for tags
final tagsProvider = FutureProvider<List<FileTag>>((ref) async {
  final service = ref.watch(databaseServiceProvider);
  return await service.getAllTags();
});
