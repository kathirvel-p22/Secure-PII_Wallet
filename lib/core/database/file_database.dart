import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Database for managing Normal Security Files metadata
/// Note: This is ONLY for Normal Security mode, NOT for SSS (High Security) files
class FileDatabase {
  static final FileDatabase instance = FileDatabase._init();
  static Database? _database;

  FileDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('secure_files.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const boolType = 'INTEGER NOT NULL';

    // Table for Normal Security Files metadata
    await db.execute('''
      CREATE TABLE files (
        id $idType,
        fileName $textType,
        filePath $textType,
        fileSize $integerType,
        fileType $textType,
        category $textType,
        tags $textType,
        description TEXT,
        uploadedAt $textType,
        lastAccessedAt $textType,
        accessCount $integerType,
        isFavorite $boolType,
        isSecurityModeSSS $boolType
      )
    ''');

    // Table for Categories
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name $textType,
        color $textType,
        icon $textType,
        createdAt $textType
      )
    ''');

    // Table for Tags
    await db.execute('''
      CREATE TABLE tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name $textType,
        color $textType,
        createdAt $textType
      )
    ''');

    // Insert default categories
    await db.insert('categories', {
      'name': 'Documents',
      'color': '#2196F3',
      'icon': 'description',
      'createdAt': DateTime.now().toIso8601String(),
    });

    await db.insert('categories', {
      'name': 'Photos',
      'color': '#4CAF50',
      'icon': 'image',
      'createdAt': DateTime.now().toIso8601String(),
    });

    await db.insert('categories', {
      'name': 'Videos',
      'color': '#F44336',
      'icon': 'videocam',
      'createdAt': DateTime.now().toIso8601String(),
    });

    await db.insert('categories', {
      'name': 'Audio',
      'color': '#FF9800',
      'icon': 'audiotrack',
      'createdAt': DateTime.now().toIso8601String(),
    });

    await db.insert('categories', {
      'name': 'Others',
      'color': '#9E9E9E',
      'icon': 'folder',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // Insert file metadata (only for Normal Security files)
  Future<void> insertFile(Map<String, dynamic> file) async {
    final db = await instance.database;
    await db.insert('files', file, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Get all normal security files
  Future<List<Map<String, dynamic>>> getAllFiles() async {
    final db = await instance.database;
    return await db.query(
      'files',
      where: 'isSecurityModeSSS = ?',
      whereArgs: [0],
      orderBy: 'uploadedAt DESC',
    );
  }

  // Get files by category
  Future<List<Map<String, dynamic>>> getFilesByCategory(String category) async {
    final db = await instance.database;
    return await db.query(
      'files',
      where: 'category = ? AND isSecurityModeSSS = ?',
      whereArgs: [category, 0],
      orderBy: 'uploadedAt DESC',
    );
  }

  // Get favorite files
  Future<List<Map<String, dynamic>>> getFavoriteFiles() async {
    final db = await instance.database;
    return await db.query(
      'files',
      where: 'isFavorite = ? AND isSecurityModeSSS = ?',
      whereArgs: [1, 0],
      orderBy: 'uploadedAt DESC',
    );
  }

  // Get recently accessed files
  Future<List<Map<String, dynamic>>> getRecentFiles({int limit = 10}) async {
    final db = await instance.database;
    return await db.query(
      'files',
      where: 'isSecurityModeSSS = ?',
      whereArgs: [0],
      orderBy: 'lastAccessedAt DESC',
      limit: limit,
    );
  }

  // Get most accessed files
  Future<List<Map<String, dynamic>>> getMostAccessedFiles({int limit = 10}) async {
    final db = await instance.database;
    return await db.query(
      'files',
      where: 'isSecurityModeSSS = ?',
      whereArgs: [0],
      orderBy: 'accessCount DESC',
      limit: limit,
    );
  }

  // Search files by name
  Future<List<Map<String, dynamic>>> searchFiles(String query) async {
    final db = await instance.database;
    return await db.query(
      'files',
      where: 'fileName LIKE ? AND isSecurityModeSSS = ?',
      whereArgs: ['%$query%', 0],
      orderBy: 'uploadedAt DESC',
    );
  }

  // Search files by tags
  Future<List<Map<String, dynamic>>> searchFilesByTag(String tag) async {
    final db = await instance.database;
    return await db.query(
      'files',
      where: 'tags LIKE ? AND isSecurityModeSSS = ?',
      whereArgs: ['%$tag%', 0],
      orderBy: 'uploadedAt DESC',
    );
  }

  // Update file metadata
  Future<void> updateFile(String id, Map<String, dynamic> file) async {
    final db = await instance.database;
    await db.update(
      'files',
      file,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update last accessed time and increment access count
  Future<void> updateAccessInfo(String id) async {
    final db = await instance.database;
    final file = await db.query(
      'files',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (file.isNotEmpty) {
      final accessCount = file.first['accessCount'] as int;
      await db.update(
        'files',
        {
          'lastAccessedAt': DateTime.now().toIso8601String(),
          'accessCount': accessCount + 1,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  // Toggle favorite status
  Future<void> toggleFavorite(String id) async {
    final db = await instance.database;
    final file = await db.query(
      'files',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (file.isNotEmpty) {
      final isFavorite = file.first['isFavorite'] as int;
      await db.update(
        'files',
        {'isFavorite': isFavorite == 1 ? 0 : 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  // Delete file metadata
  Future<void> deleteFile(String id) async {
    final db = await instance.database;
    await db.delete(
      'files',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get file statistics
  Future<Map<String, dynamic>> getFileStats() async {
    final db = await instance.database;
    
    final totalFiles = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM files WHERE isSecurityModeSSS = 0'),
    ) ?? 0;

    final totalSize = Sqflite.firstIntValue(
      await db.rawQuery('SELECT SUM(fileSize) FROM files WHERE isSecurityModeSSS = 0'),
    ) ?? 0;

    final categories = await db.rawQuery('''
      SELECT category, COUNT(*) as count 
      FROM files 
      WHERE isSecurityModeSSS = 0 
      GROUP BY category
    ''');

    final fileTypes = await db.rawQuery('''
      SELECT fileType, COUNT(*) as count 
      FROM files 
      WHERE isSecurityModeSSS = 0 
      GROUP BY fileType
    ''');

    return {
      'totalFiles': totalFiles,
      'totalSize': totalSize,
      'byCategory': categories,
      'byFileType': fileTypes,
    };
  }

  // Get all categories
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final db = await instance.database;
    return await db.query('categories', orderBy: 'name ASC');
  }

  // Get all tags
  Future<List<Map<String, dynamic>>> getAllTags() async {
    final db = await instance.database;
    return await db.query('tags', orderBy: 'name ASC');
  }

  // Add new category
  Future<int> addCategory(Map<String, dynamic> category) async {
    final db = await instance.database;
    return await db.insert('categories', category);
  }

  // Add new tag
  Future<int> addTag(Map<String, dynamic> tag) async {
    final db = await instance.database;
    return await db.insert('tags', tag);
  }

  // Close database
  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }

  // Clear all data (for factory reset)
  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('files');
    await db.delete('categories');
    await db.delete('tags');
    
    // Re-insert default categories
    await _createDB(db, 1);
  }
}
