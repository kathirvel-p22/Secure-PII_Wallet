# APK Build Failure - Root Cause Analysis

## Problem Summary
**APK build fails with hundreds of `JSObject`, `JSArray`, `JSString`, `JSAny` type errors**

## Root Cause
The `web` package (versions 0.3.0 through 0.5.1) uses new Dart JS interop types that are **incompatible with the Dart SDK** in both:
- Flutter 3.41.4 (Dart 3.11.1) ❌
- Flutter 3.19.6 (Dart 3.3.4) ❌

## Dependency Chain
```
secure_pii_wallet
  └── shared_preferences: ^2.2.3
        └── shared_preferences_web: 2.4.1
              └── web: 0.4.2 (or 0.5.1)  ← PROBLEM HERE
```

## What We Tried (All Failed)
1. ✗ Downgrading Flutter to 3.19.6 via FVM
2. ✗ Using `web: 0.5.1` override
3. ✗ Using `web: 0.4.2` override
4. ✗ Using `web: 0.4.0` override
5. ✗ Using `web: 0.3.0` override
6. ✗ Removing `file_picker` dependency
7. ✗ Cleaning pub cache and rebuilding

## Why It Fails
The `web` package uses types like:
- `JSObject`
- `JSArray`
- `JSString`
- `JSAny`
- `JSArrayBuffer`
- `JSDataView`

These types **do not exist** in the Dart SDK versions we have access to, causing compilation to fail with:
```
Error: 'JSObject' isn't a type.
Error: 'JSArray' isn't a type.
...
```

## Solutions

### Option 1: Remove `shared_preferences` (RECOMMENDED)
Replace `shared_preferences` with a different storage solution that doesn't depend on `web`:

**Replace with:**
- `hive` or `hive_flutter` (local database, no web dependency)
- `sqflite` (SQLite database, Android/iOS only)
- Direct use of `path_provider` + file I/O

**Steps:**
1. Remove `shared_preferences: ^2.2.3` from `pubspec.yaml`
2. Replace all `SharedPreferences` usage with alternative storage
3. Rebuild APK

### Option 2: Wait for Dart SDK Update
Wait for a Dart SDK version that includes the new JS interop types. This may require:
- Upgrading to a future Flutter version (3.25+?)
- Waiting for ecosystem compatibility

### Option 3: Use Older Flutter Version with Compatible Web Package
Try Flutter 3.10 or earlier with `web: 0.2.x` (untested, may have other issues)

## Recommended Action
**Implement Option 1**: Replace `shared_preferences` with `hive_flutter`

### Migration Steps:
1. Add to `pubspec.yaml`:
   ```yaml
   dependencies:
     hive: ^2.2.3
     hive_flutter: ^1.1.0
   ```

2. Replace `SharedPreferences` code:
   ```dart
   // OLD
   final prefs = await SharedPreferences.getInstance();
   await prefs.setString('key', 'value');
   final value = prefs.getString('key');
   
   // NEW
   await Hive.initFlutter();
   final box = await Hive.openBox('myBox');
   await box.put('key', 'value');
   final value = box.get('key');
   ```

3. Clean and rebuild:
   ```bash
   flutter clean
   flutter pub get
   flutter build apk --release
   ```

## Current Status
- ❌ APK build: **BLOCKED** by `web` package incompatibility
- ✅ App functionality: **WORKING** in debug mode (`flutter run`)
- ✅ All features: **FUNCTIONAL** (encryption, PIN, file management, etc.)

## Files Using SharedPreferences
Search for `SharedPreferences` usage in:
- `lib/features/auth/services/master_password_service.dart`
- `lib/features/pin/services/pin_service.dart`
- `lib/features/settings/views/settings_screen.dart`
- Any other files using `prefs`

## Conclusion
The APK build failure is **NOT a code issue** - it's a **dependency ecosystem incompatibility**. The only viable solution is to replace `shared_preferences` with an alternative storage solution that doesn't depend on the `web` package.
