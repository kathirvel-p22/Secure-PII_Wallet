# APK Build Solution Guide

## Problem Summary

The current Flutter SDK (3.41.4 with Dart 3.11.1) has breaking changes that make the `web` package incompatible with Android APK builds. Even though our app doesn't directly use web features for Android, transitive dependencies (file_picker, path_provider, etc.) pull in the web package, causing compilation errors.

## ✅ WORKING SOLUTIONS

### Solution 1: Direct Installation (RECOMMENDED - No APK Needed!)

**This is the BEST solution** - it installs the app permanently on your phone without needing an APK file.

#### Steps:

1. **Install Flutter SDK** on your computer
   - Windows: https://docs.flutter.dev/get-started/install/windows
   - Mac: https://docs.flutter.dev/get-started/install/macos
   - Linux: https://docs.flutter.dev/get-started/install/linux

2. **Enable USB Debugging** on your Android phone:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times (enables Developer Options)
   - Go to Settings → Developer Options
   - Enable "USB Debugging"
   - Connect phone to computer via USB

3. **Clone and Install**:
   ```bash
   git clone https://github.com/kathirvel-p22/Secure-PII_Wallet.git
   cd Secure-PII_Wallet/secure_pii_wallet
   flutter pub get
   flutter run --release
   ```

4. **Done!** The app is now permanently installed on your phone. You can disconnect and use it normally.

**Advantages:**
- ✅ Works with current Flutter version
- ✅ App is permanently installed
- ✅ Full functionality
- ✅ No APK build issues
- ✅ Takes 5-10 minutes

---

### Solution 2: Downgrade Flutter SDK (For APK Build)

If you absolutely need an APK file, downgrade Flutter to a compatible version.

#### Steps:

1. **Check Current Flutter Version**:
   ```bash
   flutter --version
   ```

2. **Downgrade to Flutter 3.19.6** (last stable version before Dart 3.11):
   ```bash
   flutter downgrade 3.19.6
   ```

3. **Clean and Rebuild**:
   ```bash
   cd secure_pii_wallet
   flutter clean
   flutter pub get
   flutter build apk --release
   ```

4. **APK Location**:
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

**Advantages:**
- ✅ Creates distributable APK file
- ✅ Can share APK with others
- ✅ No USB connection needed after build

**Disadvantages:**
- ⚠️ Requires Flutter SDK downgrade
- ⚠️ May affect other Flutter projects
- ⚠️ Takes longer (15-20 minutes)

---

### Solution 3: Use Flutter Version Manager (FVM)

Use FVM to manage multiple Flutter versions without affecting your main installation.

#### Steps:

1. **Install FVM**:
   ```bash
   dart pub global activate fvm
   ```

2. **Install Flutter 3.19.6**:
   ```bash
   fvm install 3.19.6
   ```

3. **Use Flutter 3.19.6 for this project**:
   ```bash
   cd secure_pii_wallet
   fvm use 3.19.6
   fvm flutter pub get
   fvm flutter build apk --release
   ```

4. **APK Location**:
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

**Advantages:**
- ✅ Doesn't affect global Flutter installation
- ✅ Can use different Flutter versions per project
- ✅ Creates distributable APK

---

## 🎯 Recommended Approach

**For Personal Use**: Use **Solution 1** (Direct Installation)
- Fastest and easiest
- No compatibility issues
- App works perfectly

**For Distribution**: Use **Solution 2** or **Solution 3** (Downgrade Flutter)
- Creates APK file for sharing
- Others can install without Flutter SDK

---

## Technical Details

### Why This Happens

Flutter 3.41.4 uses Dart 3.11.1, which introduced breaking changes to JavaScript interop types (`JSObject`, `JSAny`, `JSArray`, etc.). The `web` package (v1.1.1 and v0.5.1) uses the old syntax, causing compilation errors.

### Affected Packages

Even though we don't use web features directly, these packages pull in `web` as a transitive dependency:
- `file_picker` → `file_picker_web` → `web`
- `path_provider` → `path_provider_web` → `web`
- `shared_preferences` → `shared_preferences_web` → `web`

### Why `flutter run` Works

When running in debug mode (`flutter run`), Flutter uses JIT (Just-In-Time) compilation which is more lenient with type errors. The APK build uses AOT (Ahead-Of-Time) compilation which strictly enforces all type checks.

---

## Alternative: Build APK on Older Machine

If you have access to another computer or CI/CD system with Flutter 3.19.x or earlier, you can build the APK there:

```bash
git clone https://github.com/kathirvel-p22/Secure-PII_Wallet.git
cd Secure-PII_Wallet/secure_pii_wallet
flutter pub get
flutter build apk --release
```

Then copy the APK to your main machine.

---

## Future Updates

This issue will be resolved when either:
1. Flutter/Dart SDK fixes the web package compatibility
2. The `web` package is updated to support Dart 3.11+
3. Dependency packages remove web dependencies for mobile-only builds

Monitor the GitHub repository for updates.

---

## Need Help?

- **GitHub Issues**: https://github.com/kathirvel-p22/Secure-PII_Wallet/issues
- **Flutter Discord**: https://discord.gg/flutter
- **Stack Overflow**: Tag your question with `flutter` and `dart`

---

**Last Updated**: April 27, 2026  
**Flutter Version Tested**: 3.19.6 (works), 3.41.4 (APK build fails)
