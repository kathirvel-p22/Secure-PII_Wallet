import 'dart:typed_data';

/// PII Auto-Detection System - Smart classification of sensitive data
class PIIDetector {
  /// Detect PII in file content and suggest security level
  static PIIDetectionResult detectPII(String fileName, Uint8List? fileBytes) {
    final result = PIIDetectionResult();

    // Analyze filename patterns
    _analyzeFileName(fileName, result);

    // If we have file content, analyze it (for text files)
    if (fileBytes != null) {
      try {
        final content = String.fromCharCodes(fileBytes);
        _analyzeFileContent(content, result);
      } catch (e) {
        // Not a text file, skip content analysis
      }
    }

    return result;
  }

  static void _analyzeFileName(String fileName, PIIDetectionResult result) {
    final lowerName = fileName.toLowerCase();

    // Identity documents
    if (_containsAny(lowerName, [
      'aadhaar',
      'aadhar',
      'uid',
      'passport',
      'license',
      'driving',
    ])) {
      result.addDetection(
        PIIType.identity,
        'Identity document detected in filename',
      );
      result.suggestHighSecurity = true;
    }

    // Financial documents
    if (_containsAny(lowerName, [
      'pan',
      'tax',
      'bank',
      'statement',
      'salary',
      'payslip',
      'invoice',
    ])) {
      result.addDetection(
        PIIType.financial,
        'Financial document detected in filename',
      );
      result.suggestHighSecurity = true;
    }

    // Medical documents
    if (_containsAny(lowerName, [
      'medical',
      'health',
      'prescription',
      'report',
      'xray',
      'scan',
    ])) {
      result.addDetection(
        PIIType.medical,
        'Medical document detected in filename',
      );
      result.suggestHighSecurity = true;
    }

    // Personal documents
    if (_containsAny(lowerName, [
      'personal',
      'private',
      'confidential',
      'secret',
    ])) {
      result.addDetection(
        PIIType.personal,
        'Personal document detected in filename',
      );
      result.suggestHighSecurity = true;
    }
  }

  static void _analyzeFileContent(String content, PIIDetectionResult result) {
    // Aadhaar number pattern (12 digits with optional spaces/hyphens)
    if (RegExp(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}\b').hasMatch(content)) {
      result.addDetection(PIIType.identity, 'Aadhaar number pattern detected');
      result.suggestHighSecurity = true;
    }

    // PAN number pattern (5 letters, 4 digits, 1 letter)
    if (RegExp(r'\b[A-Z]{5}\d{4}[A-Z]\b').hasMatch(content)) {
      result.addDetection(PIIType.financial, 'PAN number pattern detected');
      result.suggestHighSecurity = true;
    }

    // Phone number patterns
    if (RegExp(r'\b(?:\+91[\s-]?)?[6-9]\d{9}\b').hasMatch(content)) {
      result.addDetection(PIIType.contact, 'Phone number detected');
    }

    // Email patterns
    if (RegExp(
      r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
    ).hasMatch(content)) {
      result.addDetection(PIIType.contact, 'Email address detected');
    }

    // Credit card patterns (basic)
    if (RegExp(
      r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b',
    ).hasMatch(content)) {
      result.addDetection(PIIType.financial, 'Credit card pattern detected');
      result.suggestHighSecurity = true;
    }

    // Bank account patterns (basic)
    if (RegExp(r'\b\d{9,18}\b').hasMatch(content)) {
      result.addDetection(
        PIIType.financial,
        'Bank account number pattern detected',
      );
      result.suggestHighSecurity = true;
    }

    // Address patterns (basic)
    if (RegExp(r'\b\d{6}\b').hasMatch(content)) {
      result.addDetection(PIIType.address, 'PIN code detected');
    }
  }

  static bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }
}

/// PII Detection Result
class PIIDetectionResult {
  final List<PIIDetection> detections = [];
  bool suggestHighSecurity = false;

  void addDetection(PIIType type, String description) {
    detections.add(PIIDetection(type, description));
  }

  bool get hasPII => detections.isNotEmpty;

  String get securityRecommendation {
    if (suggestHighSecurity) {
      return 'HIGH SECURITY recommended - Sensitive PII detected';
    } else if (hasPII) {
      return 'SECURE mode recommended - Personal information detected';
    } else {
      return 'SECURE mode sufficient - No sensitive data detected';
    }
  }

  List<String> get detectionSummary {
    return detections.map((d) => d.description).toList();
  }
}

/// Individual PII Detection
class PIIDetection {
  final PIIType type;
  final String description;

  PIIDetection(this.type, this.description);
}

/// Types of PII
enum PIIType {
  identity, // Aadhaar, Passport, License
  financial, // PAN, Bank, Credit Card
  medical, // Health records
  contact, // Phone, Email
  address, // Address, PIN
  personal, // General personal info
}

/// Extension for PIIType
extension PIITypeExtension on PIIType {
  String get displayName {
    switch (this) {
      case PIIType.identity:
        return 'Identity Document';
      case PIIType.financial:
        return 'Financial Information';
      case PIIType.medical:
        return 'Medical Record';
      case PIIType.contact:
        return 'Contact Information';
      case PIIType.address:
        return 'Address Information';
      case PIIType.personal:
        return 'Personal Information';
    }
  }

  String get icon {
    switch (this) {
      case PIIType.identity:
        return '🆔';
      case PIIType.financial:
        return '💳';
      case PIIType.medical:
        return '🏥';
      case PIIType.contact:
        return '📞';
      case PIIType.address:
        return '📍';
      case PIIType.personal:
        return '👤';
    }
  }
}
