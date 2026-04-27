import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import 'galois_field.dart';

/// Shamir's Secret Sharing implementation over GF(256)
class ShamirSecretSharing {
  static final Random _secureRandom = Random.secure();

  /// Split a secret into n shares with threshold k
  static List<ShamirShare> split({
    required Uint8List secret,
    required int threshold,
    required int totalShares,
  }) {
    if (threshold < 2) {
      throw ArgumentError('Threshold must be at least 2');
    }
    if (threshold > totalShares) {
      throw ArgumentError('Threshold cannot exceed total shares');
    }
    if (totalShares > 255) {
      throw ArgumentError('Maximum 255 shares supported');
    }

    List<ShamirShare> shares = [];
    
    // Initialize shares with indices
    for (int i = 1; i <= totalShares; i++) {
      shares.add(ShamirShare(index: i, data: Uint8List(secret.length)));
    }

    // Process each byte of the secret
    for (int byteIndex = 0; byteIndex < secret.length; byteIndex++) {
      int secretByte = secret[byteIndex];
      
      // Generate random coefficients for polynomial
      List<int> coefficients = [secretByte]; // a0 = secret
      for (int i = 1; i < threshold; i++) {
        coefficients.add(_secureRandom.nextInt(256)); // a1, a2, ..., ak-1
      }
      
      // Evaluate polynomial at each share index
      for (int shareIndex = 0; shareIndex < totalShares; shareIndex++) {
        int x = shareIndex + 1; // Share indices start from 1
        int y = GaloisField.evaluatePolynomial(coefficients, x);
        shares[shareIndex].data[byteIndex] = y;
      }
    }

    return shares;
  }

  /// Combine k shares to reconstruct the secret
  static Uint8List combine(List<ShamirShare> shares) {
    if (shares.isEmpty) {
      throw ArgumentError('No shares provided');
    }
    
    if (shares.length < 2) {
      throw ArgumentError('At least 2 shares required for reconstruction');
    }
    
    // Validate shares
    int secretLength = shares.first.data.length;
    Set<int> indices = {};
    
    for (var share in shares) {
      if (share.data.length != secretLength) {
        throw ArgumentError('All shares must have the same length');
      }
      if (indices.contains(share.index)) {
        throw ArgumentError('Duplicate share index: ${share.index}');
      }
      if (share.index <= 0) {
        throw ArgumentError('Share index must be positive: ${share.index}');
      }
      indices.add(share.index);
    }

    Uint8List secret = Uint8List(secretLength);

    // Reconstruct each byte of the secret
    for (int byteIndex = 0; byteIndex < secretLength; byteIndex++) {
      List<MapEntry<int, int>> points = [];
      
      // Collect points (x, y) for this byte position
      for (var share in shares) {
        points.add(MapEntry(share.index, share.data[byteIndex]));
      }
      
      try {
        // Use Lagrange interpolation to find f(0) = secret byte
        int secretByte = GaloisField.lagrangeInterpolation(points);
        secret[byteIndex] = secretByte;
      } catch (e) {
        throw ArgumentError('Failed to reconstruct secret at byte $byteIndex: $e');
      }
    }

    return secret;
  }

  /// Generate a random secret of specified length
  static Uint8List generateRandomSecret(int length) {
    Uint8List secret = Uint8List(length);
    for (int i = 0; i < length; i++) {
      secret[i] = _secureRandom.nextInt(256);
    }
    return secret;
  }

  /// Create multiple shares from human-readable strings with automatic index assignment
  static List<ShamirShare> fromHumanReadableList(List<String> shareStrings) {
    List<ShamirShare> shares = [];
    
    for (int i = 0; i < shareStrings.length; i++) {
      String shareString = shareStrings[i].trim();
      
      // Handle both formats: "1-hexdata" and just "hexdata"
      List<String> parts = shareString.split('-');
      
      int index;
      String dataHex;
      
      if (parts.length == 2) {
        // Format: "1-hexdata"
        try {
          index = int.parse(parts[0]);
          dataHex = parts[1];
        } catch (e) {
          throw ArgumentError('Invalid index in share ${i + 1}: ${parts[0]}');
        }
      } else if (parts.length == 1) {
        // Format: just "hexdata" - assign sequential index
        index = i + 1;
        dataHex = parts[0];
      } else {
        throw ArgumentError('Invalid share format for share ${i + 1}. Expected "index-hexdata" or "hexdata"');
      }
      
      // Clean the hex string (remove any whitespace)
      dataHex = dataHex.replaceAll(RegExp(r'\s+'), '');
      
      if (dataHex.isEmpty) {
        throw ArgumentError('Empty hex data in share ${i + 1}');
      }
      
      if (dataHex.length % 2 != 0) {
        throw ArgumentError('Invalid hex data length in share ${i + 1}: must be even number of characters');
      }
      
      // Validate hex characters
      if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(dataHex)) {
        throw ArgumentError('Invalid hex characters in share ${i + 1}');
      }
      
      Uint8List data = Uint8List(dataHex.length ~/ 2);
      for (int j = 0; j < data.length; j++) {
        String byteHex = dataHex.substring(j * 2, j * 2 + 2);
        try {
          data[j] = int.parse(byteHex, radix: 16);
        } catch (e) {
          throw ArgumentError('Invalid hex character in share ${i + 1} at position $j');
        }
      }
      
      shares.add(ShamirShare(index: index, data: data));
    }
    
    return shares;
  }

  /// Validate that shares can reconstruct a secret
  static bool validateShares(List<ShamirShare> shares) {
    if (shares.isEmpty) return false;
    
    try {
      // Check if all shares have the same data length
      int expectedLength = shares.first.data.length;
      for (var share in shares) {
        if (share.data.length != expectedLength) return false;
      }
      
      // Check for duplicate indices
      Set<int> indices = shares.map((s) => s.index).toSet();
      if (indices.length != shares.length) return false;
      
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Represents a single share in Shamir's Secret Sharing
class ShamirShare {
  final int index;
  final Uint8List data;

  ShamirShare({
    required this.index,
    required this.data,
  });

  /// Convert share to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'data': base64Encode(data),
    };
  }

  /// Create share from JSON
  factory ShamirShare.fromJson(Map<String, dynamic> json) {
    return ShamirShare(
      index: json['index'] as int,
      data: base64Decode(json['data'] as String),
    );
  }

  /// Convert share to human-readable string
  String toHumanReadable() {
    String dataHex = data.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
    return '$index-$dataHex';
  }

  /// Create share from human-readable string
  static ShamirShare fromHumanReadable(String shareString) {
    // Handle both formats: "1-hexdata" and just "hexdata"
    List<String> parts = shareString.split('-');
    
    int index;
    String dataHex;
    
    if (parts.length == 2) {
      // Format: "1-hexdata"
      try {
        index = int.parse(parts[0]);
        dataHex = parts[1];
      } catch (e) {
        throw ArgumentError('Invalid index in share format: ${parts[0]}');
      }
    } else if (parts.length == 1) {
      // Format: just "hexdata" - assign a default index
      dataHex = parts[0];
      index = dataHex.hashCode.abs() % 255 + 1; // Ensure positive and within valid range
    } else {
      throw ArgumentError('Invalid share format. Expected "index-hexdata" or "hexdata"');
    }
    
    // Clean the hex string (remove any whitespace)
    dataHex = dataHex.replaceAll(RegExp(r'\s+'), '');
    
    if (dataHex.isEmpty) {
      throw ArgumentError('Empty hex data in share');
    }
    
    if (dataHex.length % 2 != 0) {
      throw ArgumentError('Invalid hex data length: must be even number of characters');
    }
    
    // Validate hex characters
    if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(dataHex)) {
      throw ArgumentError('Invalid hex characters in share data');
    }
    
    Uint8List data = Uint8List(dataHex.length ~/ 2);
    for (int i = 0; i < data.length; i++) {
      String byteHex = dataHex.substring(i * 2, i * 2 + 2);
      try {
        data[i] = int.parse(byteHex, radix: 16);
      } catch (e) {
        throw ArgumentError('Invalid hex character in share data at position $i');
      }
    }
    
    return ShamirShare(index: index, data: data);
  }

  @override
  String toString() => 'ShamirShare(index: $index, length: ${data.length})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ShamirShare) return false;
    
    if (index != other.index || data.length != other.data.length) return false;
    
    for (int i = 0; i < data.length; i++) {
      if (data[i] != other.data[i]) return false;
    }
    
    return true;
  }

  @override
  int get hashCode => Object.hash(index, Object.hashAll(data));
}