import 'dart:convert';

/// Access Logger - Audit trail for security monitoring
class AccessLogger {
  static const String _storageKey = 'access_logs';
  final dynamic _storage; // Can be StorageService or WebStorageService

  AccessLogger(this._storage);

  /// Log file access event
  Future<void> logFileAccess({
    required String fileId,
    required String fileName,
    required AccessType accessType,
    required bool success,
    String? errorMessage,
  }) async {
    final log = AccessLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileId: fileId,
      fileName: fileName,
      accessType: accessType,
      timestamp: DateTime.now(),
      success: success,
      errorMessage: errorMessage,
      deviceInfo: await _getDeviceInfo(),
    );

    await _saveLog(log);
  }

  /// Log authentication event
  Future<void> logAuthEvent({
    required AuthEventType eventType,
    required bool success,
    String? errorMessage,
  }) async {
    final log = AccessLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileId: null,
      fileName: null,
      accessType: AccessType.authentication,
      timestamp: DateTime.now(),
      success: success,
      errorMessage: errorMessage,
      deviceInfo: await _getDeviceInfo(),
      authEventType: eventType,
    );

    await _saveLog(log);
  }

  /// Get recent access logs
  Future<List<AccessLog>> getRecentLogs({int limit = 50}) async {
    try {
      final logsJson = await _storage.readSecure(_storageKey);
      if (logsJson == null) return [];

      final List<dynamic> logsList = jsonDecode(logsJson);
      final logs = logsList.map((json) => AccessLog.fromJson(json)).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return logs.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get logs for specific file
  Future<List<AccessLog>> getFileAccessLogs(String fileId) async {
    final allLogs = await getRecentLogs(limit: 1000);
    return allLogs.where((log) => log.fileId == fileId).toList();
  }

  /// Get failed access attempts
  Future<List<AccessLog>> getFailedAttempts({int hours = 24}) async {
    final allLogs = await getRecentLogs(limit: 1000);
    final cutoff = DateTime.now().subtract(Duration(hours: hours));

    return allLogs
        .where((log) => !log.success && log.timestamp.isAfter(cutoff))
        .toList();
  }

  /// Clear old logs (keep only recent ones)
  Future<void> cleanupOldLogs({int keepDays = 30}) async {
    final allLogs = await getRecentLogs(limit: 10000);
    final cutoff = DateTime.now().subtract(Duration(days: keepDays));

    final recentLogs = allLogs
        .where((log) => log.timestamp.isAfter(cutoff))
        .toList();

    await _saveLogs(recentLogs);
  }

  Future<void> _saveLog(AccessLog log) async {
    final existingLogs = await getRecentLogs(limit: 1000);
    existingLogs.insert(0, log);

    // Keep only the most recent 1000 logs
    final logsToKeep = existingLogs.take(1000).toList();
    await _saveLogs(logsToKeep);
  }

  Future<void> _saveLogs(List<AccessLog> logs) async {
    final logsJson = jsonEncode(logs.map((log) => log.toJson()).toList());
    await _storage.writeSecure(_storageKey, logsJson);
  }

  Future<String> _getDeviceInfo() async {
    // Simple device identification for web
    return 'Web Browser';
  }
}

/// Access Log Entry
class AccessLog {
  final String id;
  final String? fileId;
  final String? fileName;
  final AccessType accessType;
  final DateTime timestamp;
  final bool success;
  final String? errorMessage;
  final String deviceInfo;
  final AuthEventType? authEventType;

  AccessLog({
    required this.id,
    required this.fileId,
    required this.fileName,
    required this.accessType,
    required this.timestamp,
    required this.success,
    required this.errorMessage,
    required this.deviceInfo,
    this.authEventType,
  });

  factory AccessLog.fromJson(Map<String, dynamic> json) {
    return AccessLog(
      id: json['id'],
      fileId: json['fileId'],
      fileName: json['fileName'],
      accessType: AccessType.values.firstWhere(
        (e) => e.toString() == json['accessType'],
        orElse: () => AccessType.view,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      success: json['success'],
      errorMessage: json['errorMessage'],
      deviceInfo: json['deviceInfo'] ?? 'Unknown',
      authEventType: json['authEventType'] != null
          ? AuthEventType.values.firstWhere(
              (e) => e.toString() == json['authEventType'],
              orElse: () => AuthEventType.login,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileId': fileId,
      'fileName': fileName,
      'accessType': accessType.toString(),
      'timestamp': timestamp.toIso8601String(),
      'success': success,
      'errorMessage': errorMessage,
      'deviceInfo': deviceInfo,
      'authEventType': authEventType?.toString(),
    };
  }

  String get displayTime {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  String get displayAction {
    if (accessType == AccessType.authentication) {
      return authEventType?.displayName ?? 'Auth';
    }
    return accessType.displayName;
  }
}

/// Types of access
enum AccessType { view, download, delete, upload, authentication }

extension AccessTypeExtension on AccessType {
  String get displayName {
    switch (this) {
      case AccessType.view:
        return 'Viewed';
      case AccessType.download:
        return 'Downloaded';
      case AccessType.delete:
        return 'Deleted';
      case AccessType.upload:
        return 'Uploaded';
      case AccessType.authentication:
        return 'Authentication';
    }
  }

  String get icon {
    switch (this) {
      case AccessType.view:
        return '👁️';
      case AccessType.download:
        return '⬇️';
      case AccessType.delete:
        return '🗑️';
      case AccessType.upload:
        return '⬆️';
      case AccessType.authentication:
        return '🔐';
    }
  }
}

/// Authentication event types
enum AuthEventType { login, logout, lockout, unlock, failedAttempt }

extension AuthEventTypeExtension on AuthEventType {
  String get displayName {
    switch (this) {
      case AuthEventType.login:
        return 'Login';
      case AuthEventType.logout:
        return 'Logout';
      case AuthEventType.lockout:
        return 'Lockout';
      case AuthEventType.unlock:
        return 'Unlock';
      case AuthEventType.failedAttempt:
        return 'Failed Login';
    }
  }
}
