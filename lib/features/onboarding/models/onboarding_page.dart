class OnboardingPage {
  final String title;
  final String description;
  final String imagePath;
  final String icon;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.icon,
  });
}

class OnboardingData {
  static const List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'Military-Grade Security',
      description: 'Protect your sensitive files with AES-256 encryption and Shamir\'s Secret Sharing technology used by government agencies.',
      imagePath: '',
      icon: '🛡️',
    ),
    OnboardingPage(
      title: 'Shamir\'s Secret Sharing',
      description: 'Split your encryption keys into multiple shares. You only need a threshold number of shares to unlock your files.',
      imagePath: '',
      icon: '🔐',
    ),
    OnboardingPage(
      title: 'PII Detection',
      description: 'Automatic detection of personally identifiable information with smart security recommendations.',
      imagePath: '',
      icon: '🔍',
    ),
    OnboardingPage(
      title: 'Secure File Storage',
      description: 'Upload PDFs, images, and documents with multiple security levels. Your files are encrypted locally.',
      imagePath: '',
      icon: '📁',
    ),
    OnboardingPage(
      title: 'Access Control',
      description: 'Password verification, failed attempt tracking, and auto-lock features keep your data secure.',
      imagePath: '',
      icon: '🚪',
    ),
    OnboardingPage(
      title: 'Ready to Start',
      description: 'Set up your PIN to secure the app and start protecting your sensitive information.',
      imagePath: '',
      icon: '🚀',
    ),
  ];
}