import 'dart:typed_data';

/// Galois Field GF(256) implementation for Shamir's Secret Sharing
class GaloisField {
  // Pre-computed logarithm and antilogarithm tables for GF(256)
  static final Uint8List _logTable = Uint8List(256);
  static final Uint8List _antilogTable = Uint8List(256);
  static bool _initialized = false;

  /// Initialize the GF(256) tables
  static void _initializeTables() {
    if (_initialized) return;

    // Generator polynomial: x^8 + x^4 + x^3 + x^2 + 1 (0x11D)
    const int generator = 0x11D;
    
    int value = 1;
    for (int i = 0; i < 255; i++) {
      _antilogTable[i] = value;
      _logTable[value] = i;
      
      value <<= 1;
      if ((value & 0x100) != 0) {
        value ^= generator;
      }
    }
    
    _antilogTable[255] = 0;
    _logTable[0] = 0; // Special case for 0
    
    _initialized = true;
  }

  /// Add two elements in GF(256) (XOR operation)
  static int add(int a, int b) {
    return a ^ b;
  }

  /// Subtract two elements in GF(256) (same as add in GF(2^n))
  static int subtract(int a, int b) {
    return a ^ b;
  }

  /// Multiply two elements in GF(256)
  static int multiply(int a, int b) {
    _initializeTables();
    
    if (a == 0 || b == 0) return 0;
    
    int logA = _logTable[a];
    int logB = _logTable[b];
    int logResult = (logA + logB) % 255;
    
    return _antilogTable[logResult];
  }

  /// Divide two elements in GF(256)
  static int divide(int a, int b) {
    _initializeTables();
    
    if (a == 0) return 0;
    if (b == 0) throw ArgumentError('Division by zero in GF(256)');
    
    int logA = _logTable[a];
    int logB = _logTable[b];
    int logResult = (logA - logB + 255) % 255;
    
    return _antilogTable[logResult];
  }

  /// Raise element to a power in GF(256)
  static int power(int base, int exponent) {
    _initializeTables();
    
    if (base == 0) return 0;
    if (exponent == 0) return 1;
    
    int logBase = _logTable[base];
    int logResult = (logBase * exponent) % 255;
    
    return _antilogTable[logResult];
  }

  /// Evaluate polynomial at given x using Horner's method
  static int evaluatePolynomial(List<int> coefficients, int x) {
    if (coefficients.isEmpty) return 0;
    
    int result = coefficients.last;
    for (int i = coefficients.length - 2; i >= 0; i--) {
      result = add(multiply(result, x), coefficients[i]);
    }
    
    return result;
  }

  /// Lagrange interpolation to find f(0) given points
  static int lagrangeInterpolation(List<MapEntry<int, int>> points) {
    if (points.isEmpty) return 0;
    
    // Check for duplicate x-values
    Set<int> xValues = {};
    for (var point in points) {
      if (xValues.contains(point.key)) {
        throw ArgumentError('Duplicate x-values in interpolation points');
      }
      xValues.add(point.key);
    }
    
    int result = 0;
    
    for (int i = 0; i < points.length; i++) {
      int xi = points[i].key;
      int yi = points[i].value;
      
      int numerator = 1;
      int denominator = 1;
      
      for (int j = 0; j < points.length; j++) {
        if (i != j) {
          int xj = points[j].key;
          int diff = subtract(xj, xi);
          
          if (diff == 0) {
            throw ArgumentError('Division by zero: duplicate x-values at $xi');
          }
          
          numerator = multiply(numerator, xj);
          denominator = multiply(denominator, diff);
        }
      }
      
      if (denominator == 0) {
        throw ArgumentError('Division by zero in Lagrange interpolation');
      }
      
      int term = multiply(yi, divide(numerator, denominator));
      result = add(result, term);
    }
    
    return result;
  }
}