# 🔐 Secure PII Wallet

A military-grade encrypted personal information wallet built with Flutter. Protect your sensitive documents with dual-layer security, AES-256 encryption, and Shamir's Secret Sharing.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-blue.svg)](https://flutter.dev)

## 📱 Screenshots

[Screenshots will be added here]

## ✨ Features

### 🛡️ Dual Security System
- **Master Password**: Strong password (10+ characters) for critical operations
  - Uppercase, lowercase, numbers, and special characters required
  - Password strength indicator
  - Used for factory reset and system reset
  
- **PIN Lock**: Quick 4 or 6-digit PIN for app unlock
  - Fast daily access
  - Failed attempt tracking
  - Auto-lock after 5 failed attempts

### 🔒 Military-Grade Encryption
- **AES-256-CBC** encryption for all files
- **PBKDF2** key derivation
- **SHA-256** hashing for credentials
- Zero-knowledge architecture

### 🎯 Shamir's Secret Sharing (SSS)
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

### ⚙️ Advanced Settings
- **Theme**: Dark/Light mode toggle
- **Auto-Lock**: Configurable timer (1-30 minutes)
- **Backup/Export**: Encrypted vault export
- **Import**: Restore from backup
- **Factory Reset**: Clear files (keeps credentials)
- **Lock & Reset**: Complete system reset (deletes everything)

### 🔍 Security Features
- PII detection and warnings
- Access logs tracking
- Security score assessment
- Session management
- Failed attempt monitoring

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
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
```bash
# For Android
flutter run

# For Web
flutter run -d chrome

# For iOS
flutter run -d ios
```

### Building APK

```bash
# Build release APK
flutter build apk --release

# Build split APKs per ABI
flutter build apk --split-per-abi

# APK location: build/app/outputs/flutter-apk/app-release.apk
```

## 📖 User Guide

### First-Time Setup

1. **Onboarding**: Learn about app features through 6 informative slides
2. **Master Password Setup**: Create a strong password for critical operations
3. **PIN Setup**: Choose a 4 or 6-digit PIN for quick access
4. **Dashboard**: Start securing your files!

### Uploading Files

1. Navigate to **Dashboard**
2. Tap **Upload File** button
3. Choose security mode:
   - **Standard**: Password-based encryption
   - **High Security**: Shamir's Secret Sharing
4. For High Security:
   - Configure total shares (3-10)
   - Set threshold (2 to total)
   - Save shares securely in different locations
5. Upload your file

### Accessing Files

**Standard Security:**
- Enter the file password
- View or download the file

**High Security:**
- Enter the required number of shares (threshold)
- Shares can be entered in any order
- System reconstructs the key automatically
- View or download the file

### Reset Options

#### Factory Reset
- Deletes: All files and data
- Keeps: PIN and master password
- Use when: You want to clear files but keep credentials

#### Lock & Reset (Complete System Reset)
- Deletes: Everything (files, PIN, master password, settings)
- Result: App restarts from onboarding
- Use when: Maximum security cleanup needed

## 🏗️ Architecture

### 10-Layer Architecture

1. **UI Layer**: Flutter widgets and screens
2. **Navigation Layer**: GoRouter for routing
3. **State Management**: Riverpod for reactive state
4. **Controllers**: Business logic handlers
5. **Security Engine**: Core security operations
6. **Cryptography Layer**: AES-256, SSS, hashing
7. **Storage Layer**: Encrypted file storage
8. **Key Management**: Secure key handling
9. **Data Models**: Type-safe data structures
10. **Defense Layer**: Security validations

### Project Structure

```
lib/
├── core/
│   ├── crypto/           # Encryption, SSS, Galois Field
│   ├── keys/             # Key management
│   ├── security/         # Security engine
│   ├── storage/          # Storage services
│   ├── theme/            # App theming
│   └── utils/            # Utilities
├── features/
│   ├── auth/             # Authentication (Master Password, PIN)
│   ├── backup/           # Backup/restore services
│   ├── files/            # File management
│   ├── logs/             # Access logs
│   ├── navigation/       # Bottom navigation
│   ├── onboarding/       # Onboarding flow
│   ├── security/         # Security dashboard
│   └── settings/         # App settings
├── providers/            # Riverpod providers
├── routing/              # App routing
└── main.dart             # Entry point
```

## 🔐 Security Details

### Encryption Specifications
- **Algorithm**: AES-256-CBC
- **Key Size**: 256 bits
- **Block Size**: 128 bits
- **Mode**: Cipher Block Chaining (CBC)
- **Padding**: PKCS7

### Shamir's Secret Sharing
- **Field**: Galois Field GF(256)
- **Polynomial**: Lagrange interpolation
- **Shares**: 3-10 configurable
- **Threshold**: 2 to total shares
- **Security**: Information-theoretic security

### Key Derivation
- **Function**: PBKDF2
- **Hash**: SHA-256
- **Iterations**: 10,000+
- **Salt**: Unique per encryption

### Credential Storage
- **Platform**: FlutterSecureStorage (mobile), localStorage (web)
- **Hashing**: SHA-256 with salt
- **Protection**: OS-level encryption

## 🛠️ Technologies Used

- **Framework**: Flutter 3.0+
- **Language**: Dart 3.0+
- **State Management**: Riverpod
- **Routing**: GoRouter
- **Encryption**: crypto package
- **Storage**: flutter_secure_storage
- **File Picking**: file_picker
- **UI**: Material Design 3

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.0
  go_router: ^12.0.0
  crypto: ^3.0.3
  flutter_secure_storage: ^9.0.0
  file_picker: ^6.0.0
  path_provider: ^2.1.0
```

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔒 Security Best Practices

### For Users

1. **Master Password**
   - Use a unique, strong password
   - Store it in a password manager
   - Never share it with anyone
   - Cannot be recovered if forgotten

2. **PIN**
   - Avoid obvious patterns (1234, 0000)
   - Change regularly
   - Don't reuse from other apps

3. **Backups**
   - Export vault regularly
   - Store backups securely offline
   - Use strong backup passwords
   - Test restore process

4. **High Security Files**
   - Use SSS for sensitive documents
   - Store shares in different physical locations
   - Keep threshold reasonable (not too low)
   - Document share locations securely

5. **General**
   - Keep app updated
   - Use auto-lock feature
   - Review access logs regularly
   - Perform factory reset before device transfer

### For Developers

1. **Code Security**
   - Never log sensitive data
   - Use secure random generators
   - Validate all inputs
   - Follow OWASP guidelines

2. **Cryptography**
   - Use established libraries
   - Never implement custom crypto
   - Keep dependencies updated
   - Use proper key sizes

3. **Storage**
   - Encrypt all sensitive data
   - Use platform secure storage
   - Clear sensitive data from memory
   - Implement secure deletion

## 🐛 Known Issues

- **APK Build Issue**: Currently experiencing compilation errors with the `web` package dependency (version 1.1.1) when building Android APK. This is a known Flutter issue with web dependencies in Android builds. 
  - **Workaround**: The app runs perfectly in debug mode (`flutter run`)
  - **Fix in progress**: Working on dependency resolution
  - **Web version**: Works perfectly with `flutter run -d chrome`
- iOS requires additional setup for secure storage
- Large files (>100MB) may cause performance issues

## 📥 Download

### Current Status: APK Build Issue

**Important Notice**: We're currently experiencing a known Flutter/Dart SDK compatibility issue when building Android APK files. The `web` package (required by `flutter_secure_storage_web`) has type incompatibilities with Dart 3.11.1.

**The app works perfectly in:**
- ✅ Debug mode: `flutter run` (Android device/emulator)
- ✅ Web mode: `flutter run -d chrome`
- ✅ iOS mode: `flutter run -d ios` (with proper setup)

**Workarounds for Android Installation:**

#### Option 1: Build from Source (Recommended)
```bash
# Clone the repository
git clone https://github.com/kathirvel-p22/Secure-PII_Wallet.git
cd Secure-PII_Wallet/secure_pii_wallet

# Install dependencies
flutter pub get

# Connect your Android device via USB (enable USB debugging)
# OR start an Android emulator

# Run directly on device (works perfectly)
flutter run
```

#### Option 2: Wait for Fix
We're actively working on resolving this issue. Solutions being explored:
- Downgrading to compatible Flutter/Dart SDK versions
- Replacing `flutter_secure_storage` with alternative secure storage
- Creating platform-specific builds without web dependencies

#### Option 3: Use Web Version
```bash
# Run the web version (fully functional)
flutter run -d chrome
```

### Technical Details

**Error**: The `web` package versions (both 0.5.1 and 1.1.1) have type definition issues (`JSObject`, `JSAny`, `JSArray` types not recognized) when compiling for Android with Dart SDK 3.11.1.

**Root Cause**: `flutter_secure_storage` pulls in `flutter_secure_storage_web` as a transitive dependency, which requires the `web` package. This creates a conflict when building for Android.

**Attempted Solutions**:
- ✗ Dependency override with `web: 0.5.1`
- ✗ Removing Syncfusion PDF viewer
- ✗ Building debug APK instead of release

**Next Steps**: We'll update this README once a working APK is available.

## 🗺️ Roadmap

- [ ] Biometric authentication (fingerprint, face ID)
- [ ] Cloud backup with end-to-end encryption
- [ ] File sharing with encrypted links
- [ ] Multi-language support
- [ ] Desktop support (Windows, macOS, Linux)
- [ ] Hardware security key support
- [ ] Audit logging export
- [ ] Custom encryption algorithms selection

## 📞 Support

For issues, questions, or suggestions:
- **GitHub Issues**: [Create an issue](https://github.com/kathirvel-p22/Secure-PII_Wallet/issues)
- **Email**: [Your Email]
- **Documentation**: [Wiki](https://github.com/kathirvel-p22/Secure-PII_Wallet/wiki)

## 👨‍💻 Author

**Kathirvel P**
- GitHub: [@kathirvel-p22](https://github.com/kathirvel-p22)
- LinkedIn: [Your LinkedIn]

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Riverpod for state management
- Crypto community for security best practices
- Open source contributors

## ⚠️ Disclaimer

This application is provided "as is" without warranty of any kind. While we implement industry-standard security practices, no system is 100% secure. Users are responsible for:
- Keeping their master password and PIN secure
- Regularly backing up their data
- Understanding the risks of digital storage
- Complying with local laws and regulations

**Important**: This app is designed for personal use. For enterprise or commercial use, please conduct a thorough security audit.

---

**Made with ❤️ and 🔐 by Kathirvel P**

**Version**: 1.0.0  
**Last Updated**: April 27, 2026
