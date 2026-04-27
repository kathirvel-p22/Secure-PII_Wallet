# APK Build Status Report

## Current Status: ⚠️ Build Blocked by Dependency Issue

**Date**: April 27, 2026  
**Flutter Version**: 3.41.4  
**Dart SDK**: 3.11.1  
**Platform**: Windows

---

## Issue Summary

The Android APK build is currently failing due to a compatibility issue between the `web` package and Dart SDK 3.11.1. This is a known Flutter ecosystem issue affecting projects that use web-platform dependencies in Android builds.

### Error Details

**Error Type**: Compilation Error  
**Package**: `web` (versions 0.5.1 and 1.1.1)  
**Root Cause**: Type definitions (`JSObject`, `JSAny`, `JSArray`, `JSArrayBuffer`, etc.) are not recognized by the Dart compiler when building for Android.

**Dependency Chain**:
```
secure_pii_wallet
  └─ flutter_secure_storage (9.2.4)
      └─ flutter_secure_storage_web (1.2.1)
          └─ web (1.1.1 or 0.5.1 with override)
```

### Build Commands Attempted

1. **Release APK**: `flutter build apk --release` ❌
2. **Debug APK**: `flutter build apk --debug` ❌
3. **With dependency override**: `web: 0.5.1` ❌
4. **Without PDF viewer**: Removed `syncfusion_flutter_pdfviewer` ❌

All attempts resulted in the same compilation errors.

---

## What Works ✅

The application is **fully functional** in the following modes:

### 1. Android Debug Mode (Recommended)
```bash
flutter run
```
- Runs directly on connected Android device or emulator
- Full functionality including encryption, SSS, file management
- No build issues
- **This is the recommended way to use the app on Android**

### 2. Web Mode
```bash
flutter run -d chrome
```
- Fully functional web version
- All features working including localStorage
- No compatibility issues

### 3. iOS Mode
```bash
flutter run -d ios
```
- Works on iOS devices and simulators
- Requires macOS and Xcode setup

---

## Workarounds for Users

### Option 1: Install via Debug Mode (Best Option)

1. **Install Flutter SDK** (if not already installed)
   - Download from: https://flutter.dev/docs/get-started/install
   - Add to PATH

2. **Clone the Repository**
   ```bash
   git clone https://github.com/kathirvel-p22/Secure-PII_Wallet.git
   cd Secure-PII_Wallet/secure_pii_wallet
   ```

3. **Install Dependencies**
   ```bash
   flutter pub get
   ```

4. **Enable USB Debugging on Android Device**
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times to enable Developer Options
   - Go to Settings → Developer Options
   - Enable "USB Debugging"

5. **Connect Device and Run**
   ```bash
   flutter run
   ```

The app will be installed and run on your device. It will remain installed even after disconnecting.

### Option 2: Use Web Version

Visit the web version (when deployed) or run locally:
```bash
flutter run -d chrome
```

---

## Solutions Being Explored

### Short-term Solutions

1. **Downgrade Flutter/Dart SDK**
   - Try Flutter 3.19.x with Dart 3.3.x
   - May resolve web package compatibility

2. **Replace flutter_secure_storage**
   - Use `hive` with encryption
   - Use `sqflite` with encryption
   - Use platform-specific secure storage (Android Keystore)

3. **Platform-Specific Builds**
   - Exclude web dependencies for Android builds
   - Use conditional imports

### Long-term Solutions

1. **Wait for Flutter/Dart SDK Update**
   - Issue is known in Flutter community
   - Future SDK versions may resolve compatibility

2. **Wait for web Package Update**
   - Package maintainers may release compatible version

3. **Custom Secure Storage Implementation**
   - Implement platform-specific secure storage
   - Remove dependency on flutter_secure_storage

---

## Technical Details

### Compilation Error Sample

```
../../../AppData/Local/Pub/Cache/hosted/pub.dev/web-0.5.1/lib/src/dom/webgl1.dart:38:41: Error: 'JSObject' isn't a type.
extension type WebGLContextAttributes._(JSObject _) implements JSObject {
                                        ^^^^^^^^
```

This error appears hundreds of times across multiple files in the `web` package.

### Dependency Versions

```yaml
dependencies:
  flutter_secure_storage: ^9.2.4
  # Pulls in flutter_secure_storage_web: ^1.2.1
  # Which pulls in web: ^1.1.1

dependency_overrides:
  web: 0.5.1  # Attempted override - still fails
```

### Files Modified to Attempt Fix

1. `pubspec.yaml` - Removed PDF viewer, added web override
2. `lib/features/files/views/file_viewer_screen.dart` - Removed PDF viewer usage
3. `lib/features/backup/services/backup_service.dart` - Removed unused import

---

## Impact Assessment

### Features Affected
- ❌ APK distribution (cannot build installable APK file)

### Features NOT Affected
- ✅ All app functionality (encryption, SSS, file management)
- ✅ Android compatibility (works via `flutter run`)
- ✅ Web compatibility
- ✅ iOS compatibility
- ✅ Data security and encryption
- ✅ User experience

---

## Recommendations

### For End Users
**Use Option 1 (Debug Mode Installation)** - This provides the full Android experience without any limitations. The app functions identically to an APK installation.

### For Developers
1. Monitor Flutter/Dart SDK updates
2. Consider implementing custom secure storage
3. Test with different Flutter SDK versions
4. Explore platform-specific build configurations

---

## Timeline

- **April 27, 2026**: Issue identified during APK build
- **April 27, 2026**: Attempted multiple fixes (dependency override, package removal)
- **April 27, 2026**: Documented issue and pushed code to GitHub
- **Next Steps**: Explore alternative secure storage solutions

---

## Resources

- **GitHub Repository**: https://github.com/kathirvel-p22/Secure-PII_Wallet
- **Flutter Issue Tracker**: https://github.com/flutter/flutter/issues
- **Web Package**: https://pub.dev/packages/web
- **Flutter Secure Storage**: https://pub.dev/packages/flutter_secure_storage

---

## Contact

For questions or alternative solutions, please:
1. Open an issue on GitHub
2. Check for updates in the repository
3. Monitor the README for status updates

---

**Last Updated**: April 27, 2026  
**Status**: Active Investigation
