/// File metadata model for Normal Security files
/// Note: This is ONLY used for Normal Security mode, NOT for SSS files
class FileMetadata {
  final String id;
  final String fileName;
  final String filePath;
  final int fileSize;
  final String fileType;
  final String category;
  final List<String> tags;
  final String? description;
  final DateTime uploadedAt;
  final DateTime lastAccessedAt;
  final int accessCount;
  final bool isFavorite;
  final bool isSecurityModeSSS;

  FileMetadata({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.fileType,
    required this.category,
    required this.tags,
    this.description,
    required this.uploadedAt,
    required this.lastAccessedAt,
    required this.accessCount,
    required this.isFavorite,
    required this.isSecurityModeSSS,
  });

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fileName': fileName,
      'filePath': filePath,
      'fileSize': fileSize,
      'fileType': fileType,
      'category': category,
      'tags': tags.join(','),
      'description': description,
      'uploadedAt': uploadedAt.toIso8601String(),
      'lastAccessedAt': lastAccessedAt.toIso8601String(),
      'accessCount': accessCount,
      'isFavorite': isFavorite ? 1 : 0,
      'isSecurityModeSSS': isSecurityModeSSS ? 1 : 0,
    };
  }

  // Create from Map (from database)
  factory FileMetadata.fromMap(Map<String, dynamic> map) {
    return FileMetadata(
      id: map['id'] as String,
      fileName: map['fileName'] as String,
      filePath: map['filePath'] as String,
      fileSize: map['fileSize'] as int,
      fileType: map['fileType'] as String,
      category: map['category'] as String,
      tags: (map['tags'] as String).split(',').where((t) => t.isNotEmpty).toList(),
      description: map['description'] as String?,
      uploadedAt: DateTime.parse(map['uploadedAt'] as String),
      lastAccessedAt: DateTime.parse(map['lastAccessedAt'] as String),
      accessCount: map['accessCount'] as int,
      isFavorite: map['isFavorite'] == 1,
      isSecurityModeSSS: map['isSecurityModeSSS'] == 1,
    );
  }

  // Copy with updated fields
  FileMetadata copyWith({
    String? id,
    String? fileName,
    String? filePath,
    int? fileSize,
    String? fileType,
    String? category,
    List<String>? tags,
    String? description,
    DateTime? uploadedAt,
    DateTime? lastAccessedAt,
    int? accessCount,
    bool? isFavorite,
    bool? isSecurityModeSSS,
  }) {
    return FileMetadata(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      fileType: fileType ?? this.fileType,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      accessCount: accessCount ?? this.accessCount,
      isFavorite: isFavorite ?? this.isFavorite,
      isSecurityModeSSS: isSecurityModeSSS ?? this.isSecurityModeSSS,
    );
  }

  // Get file size in human readable format
  String get fileSizeFormatted {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(2)} KB';
    } else if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  // Get file extension
  String get fileExtension {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toUpperCase() : 'FILE';
  }

  // Auto-detect category based on file type
  static String detectCategory(String fileType) {
    final type = fileType.toLowerCase();
    
    if (type.contains('pdf') || 
        type.contains('doc') || 
        type.contains('txt') || 
        type.contains('xls') || 
        type.contains('ppt')) {
      return 'Documents';
    } else if (type.contains('jpg') || 
               type.contains('jpeg') || 
               type.contains('png') || 
               type.contains('gif') || 
               type.contains('bmp') || 
               type.contains('svg')) {
      return 'Photos';
    } else if (type.contains('mp4') || 
               type.contains('avi') || 
               type.contains('mov') || 
               type.contains('mkv') || 
               type.contains('wmv')) {
      return 'Videos';
    } else if (type.contains('mp3') || 
               type.contains('wav') || 
               type.contains('aac') || 
               type.contains('flac') || 
               type.contains('m4a')) {
      return 'Audio';
    } else {
      return 'Others';
    }
  }

  @override
  String toString() {
    return 'FileMetadata(id: $id, fileName: $fileName, category: $category, size: $fileSizeFormatted)';
  }
}

/// Category model
class FileCategory {
  final int? id;
  final String name;
  final String color;
  final String icon;
  final DateTime createdAt;

  FileCategory({
    this.id,
    required this.name,
    required this.color,
    required this.icon,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'color': color,
      'icon': icon,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FileCategory.fromMap(Map<String, dynamic> map) {
    return FileCategory(
      id: map['id'] as int?,
      name: map['name'] as String,
      color: map['color'] as String,
      icon: map['icon'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

/// Tag model
class FileTag {
  final int? id;
  final String name;
  final String color;
  final DateTime createdAt;

  FileTag({
    this.id,
    required this.name,
    required this.color,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FileTag.fromMap(Map<String, dynamic> map) {
    return FileTag(
      id: map['id'] as int?,
      name: map['name'] as String,
      color: map['color'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
