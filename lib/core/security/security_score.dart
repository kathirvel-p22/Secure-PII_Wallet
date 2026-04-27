
/// Security Score Calculator - Intelligent security assessment
class SecurityScore {
  static const int maxScore = 100;

  /// Calculate overall security score based on multiple factors
  static int calculateScore({
    required String password,
    required bool usesHighSecurity,
    required bool usesShamir,
    required int failedAttempts,
    required int totalFiles,
    required int highSecurityFiles,
  }) {
    int score = 0;

    // Password strength (30 points max)
    score += _calculatePasswordScore(password);

    // Security mode usage (25 points max)
    score += _calculateSecurityModeScore(
      usesHighSecurity: usesHighSecurity,
      usesShamir: usesShamir,
    );

    // File security ratio (20 points max)
    score += _calculateFileSecurityScore(totalFiles, highSecurityFiles);

    // Access security (15 points max)
    score += _calculateAccessSecurityScore(failedAttempts);

    // Base security features (10 points)
    score += 10; // For using the app itself

    return score.clamp(0, maxScore);
  }

  static int _calculatePasswordScore(String password) {
    int score = 0;

    // Length (10 points max)
    if (password.length >= 10) score += 5;
    if (password.length >= 15) score += 3;
    if (password.length >= 20) score += 2;

    // Complexity (20 points max)
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 5;
    if (RegExp(r'[a-z]').hasMatch(password)) score += 5;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 5;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score += 5;

    return score;
  }

  static int _calculateSecurityModeScore({
    required bool usesHighSecurity,
    required bool usesShamir,
  }) {
    int score = 0;

    if (usesHighSecurity) {
      score += 15;
      if (usesShamir) {
        score += 10; // Bonus for using SSS
      }
    } else {
      score += 5; // Basic security
    }

    return score;
  }

  static int _calculateFileSecurityScore(
    int totalFiles,
    int highSecurityFiles,
  ) {
    if (totalFiles == 0) return 10; // Default score

    double ratio = highSecurityFiles / totalFiles;

    if (ratio >= 0.8) return 20; // 80%+ high security
    if (ratio >= 0.6) return 15; // 60%+ high security
    if (ratio >= 0.4) return 10; // 40%+ high security
    if (ratio >= 0.2) return 5; // 20%+ high security

    return 0;
  }

  static int _calculateAccessSecurityScore(int failedAttempts) {
    if (failedAttempts == 0) return 15;
    if (failedAttempts <= 2) return 10;
    if (failedAttempts <= 5) return 5;

    return 0;
  }

  /// Get security level description
  static String getSecurityLevel(int score) {
    if (score >= 90) return 'MAXIMUM';
    if (score >= 75) return 'HIGH';
    if (score >= 60) return 'GOOD';
    if (score >= 40) return 'MEDIUM';
    return 'BASIC';
  }

  /// Get security level color
  static String getSecurityColor(int score) {
    if (score >= 90) return '#00FF9C'; // Neon green
    if (score >= 75) return '#00D4AA'; // Green
    if (score >= 60) return '#FFD700'; // Gold
    if (score >= 40) return '#FFA500'; // Orange
    return '#FF4444'; // Red
  }

  /// Get improvement suggestions
  static List<String> getImprovementSuggestions(
    int score, {
    required String password,
    required bool usesHighSecurity,
    required bool usesShamir,
    required int totalFiles,
    required int highSecurityFiles,
  }) {
    List<String> suggestions = [];

    if (_calculatePasswordScore(password) < 25) {
      suggestions.add('Use a stronger password with more complexity');
    }

    if (!usesHighSecurity && totalFiles > 0) {
      suggestions.add('Consider using High Security mode for sensitive files');
    }

    if (usesHighSecurity && !usesShamir) {
      suggestions.add('Enable Shamir\'s Secret Sharing for maximum security');
    }

    if (totalFiles > 0 && highSecurityFiles / totalFiles < 0.5) {
      suggestions.add('Secure more files with High Security mode');
    }

    if (score < 60) {
      suggestions.add(
        'Enable biometric authentication for additional security',
      );
    }

    return suggestions;
  }
}
