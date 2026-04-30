# 📁 File Picker Testing Guide

## ✅ What's Fixed

### v1.0.1 Changes
- ✅ **File picker code enabled** - No longer commented out
- ✅ **Storage permissions added** to AndroidManifest.xml
- ✅ **All file types supported** - Using `FileType.any`
- ✅ **Build compatibility fixed** - win32 5.1.1, Jetifier disabled
- ✅ **APK built successfully** - 53.2 MB

---

## 🚀 How to Test

### Option 1: Install on Emulator (Recommended)

#### Step 1: Start Your Emulator
```bash
# List available emulators
C:\Users\lapto\AppData\Local\Android\sdk\emulator\emulator.exe -list-avds

# Start an emulator (replace with your AVD name)
C:\Users\lapto\AppData\Local\Android\sdk\emulator\emulator.exe -avd Pixel_5_API_34
```

#### Step 2: Run the Install Script
```bash
cd C:\Users\lapto\Downloads\Secure-PII\secure_pii_wallet
install_and_run.bat
```

This script will:
1. Check for connected devices
2. Uninstall old version (if exists)
3. Install new APK with storage permissions
4. Launch the app automatically

### Option 2: Manual Installation

```bash
# Navigate to project
cd C:\Users\lapto\Downloads\Secure-PII\secure_pii_wallet

# Uninstall old version
C:\Users\lapto\AppData\Local\Android\sdk\platform-tools\adb.exe uninstall com.example.secure_pii_wallet

# Install new APK
C:\Users\lapto\AppData\Local\Android\sdk\platform-tools\adb.exe install -r build\app\outputs\flutter-apk\app-release.apk

# Launch app
C:\Users\lapto\AppData\Local\Android\sdk\platform-tools\adb.exe shell am start -n com.example.secure_pii_wallet/.MainActivity
```

---

## 🧪 Testing the File Picker

### Test Case 1: First Time Upload (Permission Request)

1. **Open the app** on emulator
2. **Complete onboarding** (if first time)
3. **Set Master Password** and **PIN**
4. **Navigate to Dashboard**
5. **Tap "Upload File"** button
6. **Tap "Tap to select file"** area
7. **EXPECTED**: App requests storage permission
8. **Grant permission** → "Allow"
9. **EXPECTED**: File picker opens showing device files

### Test Case 2: Upload Different File Types

Test with various file types to ensure `FileType.any` works:

#### PDF Files
- Select a PDF document
- Verify file name and size display
- Complete upload with password

#### Images
- Select JPG, PNG, or other image formats
- Check PII detection (may detect faces)
- Upload successfully

#### Documents
- Try DOCX, TXT, CSV files
- Verify encryption works
- Download and verify content

#### Videos
- Select MP4 or other video files
- Check file size display (MB)
- Ensure upload completes

#### Other Files
- ZIP archives
- APK files
- Any other format

### Test Case 3: High Security Mode with SSS

1. **Upload a file**
2. **Select "High Secure" mode**
3. **Tap "GENERATE"** to create shares
4. **Save the shares** (copy them somewhere)
5. **Tap "SECURE UPLOAD"**
6. **Enter password**
7. **Verify upload succeeds**

### Test Case 4: File Access

1. **Go to Dashboard**
2. **Tap on uploaded file**
3. **Enter password** (or shares for high security)
4. **Verify file opens/downloads correctly**

---

## 🔍 Verification Checklist

### Before Testing
- [ ] Emulator is running
- [ ] Old app version uninstalled
- [ ] New APK (53.2 MB) installed
- [ ] App launches successfully

### During Testing
- [ ] File picker opens when tapping "Select file"
- [ ] Can browse device storage
- [ ] Can select files of any type
- [ ] File name displays correctly
- [ ] File size shows in KB/MB
- [ ] Upload button becomes active
- [ ] Password validation works
- [ ] Upload completes successfully
- [ ] File appears in dashboard

### After Upload
- [ ] File listed in dashboard
- [ ] Can tap to view file details
- [ ] Password required to access
- [ ] Can download file
- [ ] Downloaded file is decrypted correctly
- [ ] Can delete file (with password)

---

## 🐛 Troubleshooting

### Issue: File picker doesn't open

**Cause**: Storage permission not granted

**Solution**:
1. Go to Android Settings
2. Apps → Secure PII Wallet
3. Permissions → Storage
4. Grant "Allow"

### Issue: "Permission denied" error

**Cause**: App doesn't have storage permission

**Solution**:
```bash
# Grant permission manually via ADB
C:\Users\lapto\AppData\Local\Android\sdk\platform-tools\adb.exe shell pm grant com.example.secure_pii_wallet android.permission.READ_EXTERNAL_STORAGE
C:\Users\lapto\AppData\Local\Android\sdk\platform-tools\adb.exe shell pm grant com.example.secure_pii_wallet android.permission.WRITE_EXTERNAL_STORAGE
```

### Issue: App crashes on file selection

**Cause**: Old APK without permissions

**Solution**:
1. Uninstall completely
2. Reinstall new APK (53.2 MB)
3. Grant permissions when prompted

### Issue: Can't find files in picker

**Cause**: Emulator has no files

**Solution**:
```bash
# Push a test file to emulator
C:\Users\lapto\AppData\Local\Android\sdk\platform-tools\adb.exe push "C:\path\to\test.pdf" /sdcard/Download/test.pdf
```

---

## 📊 Expected Behavior

### ✅ Correct Behavior

1. **Tap "Select file"** → File picker opens immediately
2. **Browse folders** → Can navigate device storage
3. **Select any file** → File name and size display
4. **Upload** → Progress indicator → Success message
5. **Dashboard** → File appears in list
6. **Tap file** → Password prompt → File accessible

### ❌ Incorrect Behavior (Old Version)

1. **Tap "Select file"** → Nothing happens (code was commented out)
2. **No permission request** → File picker can't access storage
3. **Upload fails** → No files can be selected

---

## 🎯 Success Criteria

The file picker is working correctly if:

1. ✅ Tapping "Select file" opens the file picker
2. ✅ Can browse and select files from device storage
3. ✅ All file types are selectable (PDF, images, videos, etc.)
4. ✅ File name and size display correctly
5. ✅ Upload completes without errors
6. ✅ File can be accessed after upload
7. ✅ Downloaded file matches original

---

## 📝 Test Report Template

```
Date: ___________
Tester: ___________
Device: Emulator / Physical Device
Android Version: ___________

Test Results:
[ ] File picker opens
[ ] Storage permission granted
[ ] PDF upload works
[ ] Image upload works
[ ] Document upload works
[ ] Video upload works
[ ] File size displays correctly
[ ] Upload completes successfully
[ ] File accessible after upload
[ ] Download works correctly

Issues Found:
_________________________________
_________________________________

Notes:
_________________________________
_________________________________
```

---

## 🔗 Related Files

- **APK Location**: `build/app/outputs/flutter-apk/app-release.apk`
- **Install Script**: `install_and_run.bat`
- **Upload Screen Code**: `lib/features/files/views/upload_screen.dart`
- **Permissions**: `android/app/src/main/AndroidManifest.xml`
- **Build Config**: `pubspec.yaml`, `android/gradle.properties`

---

## 📞 Need Help?

If file picker still doesn't work:

1. Check this guide: `BUILD_AND_INSTALL.md`
2. Review: `RUN_APP_NOW.md`
3. Create GitHub issue with:
   - Device/emulator details
   - Android version
   - Error messages
   - Screenshots

---

**Last Updated**: April 30, 2026  
**Version**: 1.0.1
