# 🔐 Secure PII Wallet

A military-grade encrypted personal information wallet built with Flutter. Protect your sensitive documents with dual-layer security, AES-256 encryption, and Shamir's Secret Sharing.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-lightgrey.svg)

## 📱 Screenshots

> Add screenshots here after building the app

## ✨ Features

### 🛡️ Dual Security System
- **Master Password**: Strong password (10+ characters) for critical operations
  - Uppercase, lowercase, numbers, and special characters required
  - Password strength indicator
  - Real-time validation
- **PIN Lock**: Quick 4 or 6-digit PIN for app unlock
  - Failed attempt tracking
  - Temporary lock after 5 failed attempts
  - Secure storage with SHA-256 hashing

### 🔒 Military-Grade Encryption
- **AES-256-CBC** encryption for all files
- **PBKDF2** key derivation
- **SHA-256** hashing for credentials
- Zero-knowledge architecture

### 🔑 Shamir's Secret Sharing (SSS)
- Mathematical security over Galois Field GF(256)
- Configurable shares (3-10 total shares)
- Flexible threshold (2 to total shares required)
- Shares can be entered in any order
- Perfect for high-security documents

### 📁 File Management
- Upload any file type
- Encrypted storage
- Password verification for deletion
- Download with password protection
- File metadata tracking

### 🎨 Modern UI
- Cybersecurity-themed design
- Dark/Light mode support
- Responsive layout
- Smooth animations
- Bottom navigation

### ⚙️ Advanced Settings
- Auto-lock timer (1-30 minutes)
- Theme customization
- Backup & restore vault
- Export encrypted vault
- Import from backup

### 🔄 Reset Options
1. **Factory Reset**: Delete all files (keeps PIN & master password)
2. **Lock & Reset**: Complete system reset (deletes everything, restarts from onboarding)

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/kathirvel-p22/Secure-PII_Wallet.git
cd Secure-PII_Wallet/secure_pii_wallet
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**

For Android:
```bash
flutter run
```

For Web:
```bash
flutter run -d chrome
```

For iOS:
```bash
flutter run -d ios
```

### Building APK

**Note**: There's currently a known issue with the `web` package dependency. To build the APK, you may need to:

1. Update Flutter to the latest version:
```bash
flutter upgrade
```

2. Clean and rebuild:
```bash
flutter clean
flutter pub get
flutter build apk --release
```

The APK will be available at: `build/app/outputs/flutter-apk/app-release.apk`

## 📖 User Guide

### First-Time Setup

1. **Onboarding**: Learn about app features through 6 informative slides
2. **Master Password Setup**: Create a strong password for critical operations
3. **PIN Setup**: Choose a 4 or 6-digit PIN for quick app unlock
4. **Dashboard**: Start using the app

### Uploading Files

1. Navigate to **Dashboard**
2. Tap the **Upload** button
3. Choose security mode:
   - **Standard**: Password-based encryption
   - **High Security**: Shamir's Secret Sharing
4. For High Security:
   - Configure total shares (3-10)
   - Set threshold (2 to total)
5. Select file and upload

### Unlocking Files

**Standard Security:**
- Enter the password used during upload

**High Security:**
- Enter the required number of shares (threshold)
- Shares can be entered in any order
- System reconstructs the key automatically

### Backup & Restore

**Export Vault:**
1. Go to **Settings** → **Storage** → **Export Vault**
2. Enter a strong backup password
3. Download the encrypted backup file

**Import Vault:**
1. Go to **Settings** → **Storage** → **Import Vault**
2. Select backup file
3. Enter backup password
4. Files will be restored

### Reset Options

**Factory Reset** (Keeps credentials):
1. Go to **Settings** → **Danger Zone** → **Factory Reset**
2. Enter master password
3. Confirm deletion
4. All files deleted, PIN and master password remain

**Lock & Reset** (Complete reset):
1. Go to **Settings** → **Danger Zone** → **Lock & Reset**
2. Enter master password
3. Confirm complete reset
4. App restarts from onboarding

## 🏗️ Architecture

### Project Structure

```
lib/
├── core/
│   ├── crypto/              # Encryption & cryptography
│   │   ├── crypto_service.dart
│   │   ├── galois_field.dart
│   │   └── shamir_secret_sharing.dart
│   ├── keys/                # Key management
│   ├── security/            # Security engine
│   ├── storage/             # Storage services
│   ├── theme/               # App theming
│   └── utils/               # Utilities
├── features/
│   ├── auth/                # Authentication
│   │   ├── services/
│   │   ├── views/
│   │   └── widgets/
│   ├── files/               # File management
│   ├── onboarding/          # Onboarding flow
│   ├── pin/                 # PIN management
│   ├── settings/            # App settings
│   ├── security/            # Security dashboard
│   ├── backup/              # Backup & restore
│   └── navigation/          # Navigation
├── providers/               # Riverpod providers
├── routing/                 # App routing
└── main.dart               # Entry point
```

### Key Technologies

- **State Management**: Riverpod
- **Routing**: GoRouter
- **Storage**: FlutterSecureStorage, localStorage (web)
- **Encryption**: crypto package
- **File Handling**: file_picker
- **UI**: Material Design 3

## 🔐 Security Details

### Encryption Algorithms

- **Symmetric Encryption**: AES-256-CBC
- **Key Derivation**: PBKDF2 with 10,000 iterations
- **Hashing**: SHA-256
- **Secret Sharing**: Shamir's Secret Sharing over GF(256)

### Security Best Practices

1. **Master Password**:
   - Minimum 10 characters
   - Mix of uppercase, lowercase, numbers, special characters
   - Store safely (use password manager)
   - Cannot be recovered if forgotten

2. **PIN**:
   - Avoid obvious patterns (1234, 0000)
   - Change regularly
   - Don't share with others

3. **High Security Files**:
   - Use SSS for sensitive documents
   - Store shares in different locations
   - Keep threshold reasonable

4. **Backups**:
   - Export vault regularly
   - Use strong backup passwords
   - Store backups securely

### Data Storage

- **Mobile**: FlutterSecureStorage (encrypted keychain/keystore)
- **Web**: Browser localStorage (encrypted)
- **Zero-knowledge**: No data sent to external servers
- **Local-only**: All data stays on your device

## 🛠️ Development

### Running Tests

```bash
flutter test
```

### Code Generation

```bash
flutter pub run build_runner build
```

### Linting

```bash
flutter analyze
```

### Format Code

```bash
flutter format .
```

## 📝 Known Issues

1. **Web Package Compilation**: There's a known issue with the `web` package when building APK. Update Flutter to the latest version to resolve.

2. **CanvasKit CDN**: When running on web, you may encounter CanvasKit fetch errors. This is a network issue with Google's CDN.

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Kathirvel P**
- GitHub: [@kathirvel-p22](https://github.com/kathirvel-p22)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Riverpod for state management
- crypto package for encryption utilities
- All contributors and testers

## 📞 Support

For issues, questions, or suggestions:
- Open an issue on [GitHub](https://github.com/kathirvel-p22/Secure-PII_Wallet/issues)
- Email: [Your Email]

## 🔮 Future Enhancements

- [ ] Biometric authentication (fingerprint/face ID)
- [ ] Cloud backup (encrypted)
- [ ] Multi-language support
- [ ] File categories and tags
- [ ] Search functionality
- [ ] File preview
- [ ] Batch operations
- [ ] Password generator
- [ ] Security audit logs
- [ ] Two-factor authentication

## 📊 Version History

### v1.0.0 (Current)
- Initial release
- Dual security system (Master Password + PIN)
- AES-256 encryption
- Shamir's Secret Sharing
- File upload/download
- Backup & restore
- Factory reset & complete system reset
- Dark/Light theme
- Auto-lock timer

---

**⚠️ Security Notice**: This app is designed for personal use. While it implements strong encryption, no system is 100% secure. Always follow security best practices and keep your credentials safe.

**Made with ❤️ using Flutter**
