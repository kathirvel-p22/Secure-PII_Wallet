# 📱 How to Install Secure PII Wallet on Your Android Phone

## The Easy Way (No APK Needed!)

You can install and use the app on your phone **without building an APK**. The app will work exactly the same as if you installed it from an APK file.

---

## Step-by-Step Installation Guide

### Step 1: Install Flutter on Your Computer

1. **Download Flutter SDK**:
   - Go to: https://docs.flutter.dev/get-started/install/windows
   - Download the Flutter SDK ZIP file
   - Extract it to `C:\flutter` (or any location you prefer)

2. **Add Flutter to PATH**:
   - Open "Edit the system environment variables"
   - Click "Environment Variables"
   - Under "User variables", find "Path" and click "Edit"
   - Click "New" and add: `C:\flutter\bin`
   - Click "OK" on all windows

3. **Verify Installation**:
   ```bash
   flutter doctor
   ```

### Step 2: Enable USB Debugging on Your Phone

1. **Enable Developer Options**:
   - Go to **Settings** → **About Phone**
   - Tap **Build Number** 7 times
   - You'll see "You are now a developer!"

2. **Enable USB Debugging**:
   - Go to **Settings** → **Developer Options**
   - Turn on **USB Debugging**
   - Turn on **Install via USB** (if available)

3. **Connect Your Phone**:
   - Connect your phone to computer via USB cable
   - On your phone, tap "Allow" when prompted for USB debugging

### Step 3: Install the App

1. **Open Command Prompt** (or PowerShell)

2. **Navigate to the project**:
   ```bash
   cd C:\Users\lapto\Downloads\Secure-PII\secure_pii_wallet
   ```

3. **Check if phone is connected**:
   ```bash
   flutter devices
   ```
   You should see your phone listed.

4. **Install the app**:
   ```bash
   flutter run --release
   ```

5. **Wait for installation** (takes 2-5 minutes first time)

6. **Done!** The app is now installed on your phone and will remain there even after you disconnect the USB cable.

---

## Alternative: Use Android Studio

If you have Android Studio installed:

1. Open Android Studio
2. Open the project folder: `secure_pii_wallet`
3. Connect your phone via USB
4. Click the green "Run" button (▶️)
5. Select your phone from the device list
6. Wait for installation

---

## What You Get

✅ **Full app functionality** - All features work perfectly  
✅ **Permanent installation** - App stays on your phone  
✅ **Same as APK** - Works exactly like an installed APK  
✅ **All data persists** - Your files and settings are saved  
✅ **Can use offline** - No computer needed after installation  

---

## Troubleshooting

### Phone Not Detected?

1. **Install USB Drivers**:
   - For Samsung: Install Samsung USB drivers
   - For other brands: Install manufacturer's USB drivers
   - Or use universal ADB drivers

2. **Try Different USB Cable**:
   - Some cables are charge-only
   - Use a data transfer cable

3. **Change USB Mode**:
   - On your phone, swipe down notification
   - Tap "USB for charging"
   - Select "File Transfer" or "MTP"

### Build Fails?

1. **Run Flutter Doctor**:
   ```bash
   flutter doctor
   ```
   Fix any issues it reports

2. **Get Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Clean and Rebuild**:
   ```bash
   flutter clean
   flutter run --release
   ```

### App Crashes?

1. **Check Logs**:
   ```bash
   flutter logs
   ```

2. **Reinstall**:
   ```bash
   flutter clean
   flutter run --release
   ```

---

## Why This Works

When you run `flutter run --release`, Flutter:
1. Compiles the app
2. Creates an APK internally
3. Installs it on your phone
4. Launches the app

The app **stays installed** on your phone permanently, just like any other app you download from the Play Store!

---

## After Installation

Once installed, you can:
- ✅ Disconnect your phone from the computer
- ✅ Use the app anytime, anywhere
- ✅ The app icon will be in your app drawer
- ✅ All your data is saved on your phone
- ✅ Works completely offline

---

## Need Help?

If you face any issues:
1. Check the troubleshooting section above
2. Run `flutter doctor` and fix any issues
3. Make sure USB debugging is enabled
4. Try a different USB cable
5. Restart both phone and computer

---

## Summary

**You don't need an APK file!** Just run `flutter run --release` with your phone connected, and the app will be installed permanently on your phone. It's that simple! 🎉
