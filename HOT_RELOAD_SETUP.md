# 🔥 Hot Reload Setup - Real-Time Development

## 🎯 What is Hot Reload?

Hot Reload lets you:
- ✅ Edit code on your laptop
- ✅ Press `r` in terminal
- ✅ See changes **instantly** on emulator (in 1-2 seconds!)
- ✅ No need to rebuild or reinstall the app

This is the **best developer experience** for Flutter!

---

## 📱 Step 1: Start the Emulator

### Option A: Using Android Studio (Easiest)

1. **Open Android Studio**
2. **Click** the device dropdown (top right)
3. **Select** "Medium_Phone" or any emulator
4. **Click** the play button ▶️
5. **Wait** for emulator to boot (1-2 minutes)

### Option B: Using Command Line

```bash
# In PowerShell or CMD:
C:\Users\lapto\fvm\versions\3.19.6\bin\flutter.bat emulators --launch Medium_Phone
```

**Wait until you see the Android home screen!**

---

## 🚀 Step 2: Run the App with Hot Reload

Once the emulator is running:

```bash
# Navigate to project
cd C:\Users\lapto\Downloads\Secure-PII\secure_pii_wallet

# Run the app
C:\Users\lapto\fvm\versions\3.19.6\bin\flutter.bat run
```

**You'll see:**
```
Launching lib\main.dart on sdk gphone64 x86 64 in debug mode...
Running Gradle task 'assembleDebug'...
✓ Built build\app\outputs\flutter-apk\app-debug.apk
Installing build\app\outputs\flutter-apk\app-debug.apk...
Syncing files to device sdk gphone64 x86 64...

Flutter run key commands.
r Hot reload. 🔥🔥🔥
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).
```

---

## 🔥 Step 3: Use Hot Reload

### Make Changes to Your Code

1. **Open any file** in VS Code (e.g., `lib/features/files/views/upload_screen.dart`)
2. **Make a change** (e.g., change button text, colors, layout)
3. **Save the file** (Ctrl+S)
4. **In the terminal**, press `r`
5. **Watch the emulator** - changes appear in 1-2 seconds! 🎉

### Example Changes to Try:

**Change button text:**
```dart
// In upload_screen.dart, line ~700
ElevatedButton(
  onPressed: _isUploading ? null : _upload,
  child: const Text('UPLOAD NOW'), // Changed from 'SECURE UPLOAD'
)
```

**Change colors:**
```dart
// In lib/core/theme/colors.dart
static const neon = Color(0xFF00FF00); // Change to green
```

**Change text:**
```dart
// In upload_screen.dart
Text('Select any file', ...) // Change any text
```

---

## ⚡ Hot Reload Commands

While the app is running, press these keys in the terminal:

| Key | Action | Description |
|-----|--------|-------------|
| `r` | **Hot Reload** | Apply code changes instantly (keeps app state) |
| `R` | **Hot Restart** | Restart app from scratch (resets state) |
| `p` | **Paint Debug** | Show widget boundaries |
| `o` | **Platform** | Switch between Android/iOS rendering |
| `q` | **Quit** | Stop the app |

---

## 🎯 What Can You Hot Reload?

### ✅ Works Instantly (Hot Reload with `r`):
- UI changes (text, colors, layouts)
- Widget modifications
- Function implementations
- Most code changes

### ⚠️ Needs Hot Restart (press `R`):
- Adding new files
- Changing app initialization
- Modifying `main()` function
- Adding new dependencies

### ❌ Needs Full Rebuild:
- Changing `pubspec.yaml` dependencies
- Modifying native Android/iOS code
- Changing app permissions

---

## 🐛 Troubleshooting

### Emulator Not Showing Up?

```bash
# Check if emulator is running
C:\Users\lapto\fvm\versions\3.19.6\bin\flutter.bat devices

# Should show:
# sdk gphone64 x86 64 (mobile) • emulator-5554 • android-x64 • Android XX
```

### Emulator Slow?

1. **Close other apps** to free RAM
2. **In Android Studio**: Tools → AVD Manager → Edit → Advanced Settings
3. **Increase RAM** to 4GB or more
4. **Enable Hardware Acceleration** (HAXM on Intel, WHPX on Windows)

### Hot Reload Not Working?

```bash
# Press R (capital R) for hot restart
R

# Or stop and restart:
q  # quit
C:\Users\lapto\fvm\versions\3.19.6\bin\flutter.bat run
```

### Build Errors?

```bash
# Clean and rebuild
C:\Users\lapto\fvm\versions\3.19.6\bin\flutter.bat clean
C:\Users\lapto\fvm\versions\3.19.6\bin\flutter.bat pub get
C:\Users\lapto\fvm\versions\3.19.6\bin\flutter.bat run
```

---

## 💡 Pro Tips

### 1. **Keep Terminal Visible**
- Split your screen: VS Code on left, Terminal on right
- You'll see hot reload feedback instantly

### 2. **Use VS Code Flutter Extension**
- Install "Flutter" extension
- Press `Ctrl+F5` to run with hot reload
- Press `Ctrl+Shift+P` → "Flutter: Hot Reload" to reload

### 3. **Multiple Devices**
- Run on emulator AND real phone simultaneously:
  ```bash
  flutter run -d all
  ```

### 4. **Performance Mode**
- For faster hot reload:
  ```bash
  flutter run --profile
  ```

---

## 🎬 Quick Start (Copy-Paste)

```bash
# 1. Start emulator (wait for home screen)
C:\Users\lapto\fvm\versions\3.19.6\bin\flutter.bat emulators --launch Medium_Phone

# 2. Wait 60 seconds, then run app
C:\Users\lapto\fvm\versions\3.19.6\bin\flutter.bat run

# 3. Make code changes in VS Code

# 4. Press 'r' in terminal to hot reload

# 5. See changes instantly! 🔥
```

---

## ✅ Current Status

- ✅ File picker fixed (supports all file types)
- ✅ Hot reload ready
- ✅ Emulator configured
- ✅ Development environment set up

**You're ready for real-time development!** 🚀

---

**Need help?** Check the troubleshooting section or run:
```bash
flutter doctor -v
```
