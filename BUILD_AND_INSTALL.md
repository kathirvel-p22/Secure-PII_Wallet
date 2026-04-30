# 🔧 Build and Install App with Storage Permissions

## ⚠️ Issue

The app is running but file picker doesn't work because storage permissions aren't included in the installed APK.

## ✅ Solution

Build a fresh APK and install it manually.

---

## 📝 Step-by-Step Instructions

### Step 1: Open CMD

Press `Win + R`, type `cmd`, press Enter

### Step 2: Navigate to Project

```cmd
cd C:\Users\lapto\Downloads\Secure-PII\secure_pii_wallet
```

### Step 3: Clean Build

```cmd
C:\Users\lapto\fvm\versions\3.19.6\bin\flutter.bat clean
```

Wait for it to complete (10-20 seconds)

### Step 4: Get Dependencies

```cmd
C:\Users\lapto\fvm\versions\3.19.6\bin\flutter.bat pub get
```

Wait for it to complete (10-20 seconds)

### Step 5: Build APK

```cmd
C:\Users\lapto\fvm\versions\3.19.6\bin\flutter.bat build apk --release
```

Wait for it to complete (2-3 minutes)

You should see: `✓ Built build\app\outputs\flutter-apk\app-release.apk`

### Step 6: Uninstall Old App

```cmd
C:\Users\lapto\AppData\Local\Android\Sdk\platform-tools\adb.exe -s emulator-5554 uninstall com.example.secure_pii_wallet
```

### Step 7: Install New APK

```cmd
C:\Users\lapto\AppData\Local\Android\Sdk\platform-tools\adb.exe -s emulator-5554 install build\app\outputs\flutter-apk\app-release.apk
```

### Step 8: Launch App

```cmd
C:\Users\lapto\AppData\Local\Android\Sdk\platform-tools\adb.exe -s emulator-5554 shell am start -n com.example.secure_pii_wallet/.MainActivity
```

---

## 🧪 Test File Picker

1. **Complete onboarding** (first time):
   - Master Password: `MySecure@Pass123`
   - PIN: `1234`

2. **Drag a file** onto emulator window

3. **Tap "Upload File"**

4. **Tap "Tap to select file"**

5. **File picker should open!** ✅

---

## 🔍 Verify Permissions

After installing, check permissions:

```cmd
C:\Users\lapto\AppData\Local\Android\Sdk\platform-tools\adb.exe -s emulator-5554 shell dumpsys package com.example.secure_pii_wallet | findstr "permission"
```

You should see:
- `android.permission.READ_EXTERNAL_STORAGE`
- `android.permission.WRITE_EXTERNAL_STORAGE`
- `android.permission.READ_MEDIA_IMAGES`
- etc.

---

## 📋 All Commands in One Block

Copy and paste this entire block into CMD:

```cmd
cd C:\Users\lapto\Downloads\Secure-PII\secure_pii_wallet
C:\Users\lapto\fvm\versions\3.19.6\bin\flutter.bat clean
C:\Users\lapto\fvm\versions\3.19.6\bin\flutter.bat pub get
C:\Users\lapto\fvm\versions\3.19.6\bin\flutter.bat build apk --release
C:\Users\lapto\AppData\Local\Android\Sdk\platform-tools\adb.exe -s emulator-5554 uninstall com.example.secure_pii_wallet
C:\Users\lapto\AppData\Local\Android\Sdk\platform-tools\adb.exe -s emulator-5554 install build\app\outputs\flutter-apk\app-release.apk
C:\Users\lapto\AppData\Local\Android\Sdk\platform-tools\adb.exe -s emulator-5554 shell am start -n com.example.secure_pii_wallet/.MainActivity
```

---

## ✅ Expected Result

After following these steps:
- ✅ App installed with storage permissions
- ✅ File picker opens when tapping "Tap to select file"
- ✅ Can browse and select files
- ✅ File upload works

---

**This will definitely work!** The issue is just that the old APK doesn't have the permissions we added.
