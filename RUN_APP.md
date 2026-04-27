# 🚀 Run Secure PII Wallet

## Quick Start (3 Steps)

### Step 1: Navigate to Project
```bash
cd secure_pii_wallet
```

### Step 2: Get Dependencies (if not done)
```bash
flutter pub get
```

### Step 3: Run the App
```bash
flutter run
```

That's it! The app will launch on your connected device or emulator.

---

## 📱 Platform-Specific Commands

### Android
```bash
flutter run -d android
```

### iOS (macOS only)
```bash
flutter run -d ios
```

### Windows
```bash
flutter run -d windows
```

### Web
```bash
flutter run -d chrome
```

---

## 🔧 Development Commands

### Run in Debug Mode (default)
```bash
flutter run
```

### Run in Release Mode (optimized)
```bash
flutter run --release
```

### Run with Hot Reload
- Press `r` in terminal to hot reload
- Press `R` to hot restart
- Press `q` to quit

### Clean Build (if issues)
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📋 Pre-Run Checklist

### ✅ Required
- [x] Flutter SDK installed
- [x] Device/emulator connected
- [x] Dependencies installed (`flutter pub get`)

### ⚠️ Optional (for perfect UI)
- [ ] Roboto fonts added to `assets/fonts/`
  - See `FONTS_SETUP.md` for instructions
  - App works without fonts (uses system fonts)

### 🔧 Platform Permissions (for production)

#### Android
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

#### iOS
Add to `ios/Runner/Info.plist`:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Need access to select files for secure storage</string>
<key>NSCameraUsageDescription</key>
<string>Need access to camera for document scanning</string>
```

---

## 🐛 Troubleshooting

### "No devices found"
```bash
# Check connected devices
flutter devices

# For Android emulator
flutter emulators
flutter emulators --launch <emulator_id>

# For iOS simulator (macOS)
open -a Simulator
```

### "Build failed"
```bash
flutter clean
flutter pub get
flutter run
```

### "Font not found" error
- Either add Roboto fonts (see `FONTS_SETUP.md`)
- Or comment out font references in `pubspec.yaml`

### "Permission denied" (Android)
- Enable storage permissions in device settings
- Or add permissions to AndroidManifest.xml

---

## 📊 Check App Status

### Verify Installation
```bash
flutter doctor
```

### Check Dependencies
```bash
flutter pub outdated
```

### Analyze Code
```bash
flutter analyze
```

---

## 🎯 First Run Experience

### What to Expect:

1. **Splash Screen** (2 seconds)
   - Shows app logo and loading

2. **Unlock Screen**
   - Tap "UNLOCK" to enter
   - No password needed on first launch

3. **Dashboard**
   - Empty state (no files yet)
   - Tap "UPLOAD" button to add first file

4. **Upload Your First File**
   - Select PDF or image
   - Choose security mode
   - Set password
   - (Optional) Generate keys for High Security
   - Tap "SECURE UPLOAD"

5. **View Your File**
   - Tap file from dashboard
   - Enter password (and keys if High Security)
   - File opens securely!

---

## 🔐 Test Credentials

### For Testing:

**Secure Mode:**
- Password: `TestPass@123`

**High Security Mode:**
- Password: `TestPass@123`
- Key 1: `ABC12345`
- Key 2: `XYZ67890`
- Key 3: `QWE09876`

---

## 📱 Recommended Test Flow

1. ✅ Launch app
2. ✅ Unlock (tap button)
3. ✅ Upload file (Secure mode)
4. ✅ View file (enter password)
5. ✅ Delete file
6. ✅ Upload file (High Security mode)
7. ✅ View file (enter password + keys)
8. ✅ Test wrong password (should deny)
9. ✅ Test wrong keys (should deny)
10. ✅ Lock app (tap lock icon)

---

## 🎨 UI Preview

### Expected Screens:
- 🌟 **Splash**: Dark background, neon lock icon
- 🔓 **Unlock**: Cyber theme, unlock button
- 📂 **Dashboard**: File list or empty state
- 📤 **Upload**: Mode selection, password, keys
- 👁️ **Viewer**: PDF/image display

### Color Scheme:
- Background: Dark blue (`#0A0F1C`)
- Accent: Neon green (`#00FF9C`)
- Cards: Dark (`#121A2B`)

---

## 🚀 Performance Tips

### For Best Performance:
- Use physical device (faster than emulator)
- Run in release mode for production testing
- Close other apps to free memory

### For Development:
- Use debug mode for hot reload
- Keep terminal open for logs
- Use Flutter DevTools for debugging

---

## 📞 Need Help?

### Resources:
- **Quick Start**: `QUICKSTART.md`
- **Full Docs**: `README.md`
- **Architecture**: `ARCHITECTURE.md`
- **Troubleshooting**: `QUICKSTART.md` (troubleshooting section)

### Common Issues:
- Fonts not showing → See `FONTS_SETUP.md`
- Build errors → Run `flutter clean`
- No devices → Check `flutter devices`
- Permissions → Add to manifest files

---

## ✅ Success Indicators

### App is Working When:
✅ Splash screen appears
✅ Can navigate to dashboard
✅ Can upload files
✅ Files are encrypted (check storage)
✅ Can view files with password
✅ Can delete files
✅ Session lock works

---

## 🎉 You're Ready!

```bash
cd secure_pii_wallet
flutter run
```

**Enjoy your military-grade secure PII wallet! 🛡️**

---

**Built with Flutter 💙 | Secured with AES-256 🔐 | Ready to Use 🚀**
