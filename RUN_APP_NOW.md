# 🚀 Run App on Emulator - Quick Guide

## ✅ Current Status

- ✅ Emulator is running (emulator-5554)
- ✅ Storage permissions added
- ✅ File picker enabled
- ✅ All fixes committed and pushed

---

## 🎯 Run the App Now

### Option 1: Using CMD (Recommended)

1. **Open CMD** (Command Prompt)
2. **Copy and paste these commands**:

```cmd
cd C:\Users\lapto\Downloads\Secure-PII\secure_pii_wallet
C:\Users\lapto\fvm\versions\3.19.6\bin\flutter.bat run -d emulator-5554
```

3. **Wait** for the app to build (1-2 minutes)
4. **App will launch** on emulator with hot reload enabled!

### Option 2: Using run_app.bat

1. **Double-click** `run_app.bat` in the project folder
2. **Wait** for app to build and launch

### Option 3: Using VS Code

1. **Open** the project in VS Code
2. **Press** `F5` or click "Run and Debug"
3. **Select** "emulator-5554" when prompted
4. **App launches** with hot reload!

---

## 🧪 Test File Upload

Once the app is running:

### Step 1: Complete Onboarding (First Time)

1. **Swipe through** onboarding slides
2. **Set Master Password**: `MySecure@Pass123`
3. **Set PIN**: `1234`

### Step 2: Add a Test File to Emulator

**Drag and drop** any file from your computer onto the emulator window!
- The file will be saved to `/sdcard/Download/`
- You can then select it in the file picker

### Step 3: Upload a File

1. **Tap "Upload File"** button on dashboard
2. **Tap "Tap to select file"** → **File picker opens!** ✅
3. **Select the file** you dragged in
4. **Enter password**: `TestPass@123`
   - Must have: 10+ chars, uppercase, lowercase, number, special char
5. **Tap "SECURE UPLOAD"**
6. **Success!** ✅ "File encrypted and stored securely!"

---

## 🔥 Hot Reload Commands

While the app is running, in the terminal:

| Key | Action |
|-----|--------|
| `r` | **Hot reload** - Apply code changes instantly |
| `R` | **Hot restart** - Restart app from scratch |
| `p` | **Paint debug** - Show widget boundaries |
| `q` | **Quit** - Stop the app |

---

## 📝 What to Test

### ✅ File Picker

- [ ] Tap "Tap to select file"
- [ ] File picker opens
- [ ] Can browse folders
- [ ] Can select files

### ✅ File Upload (Normal Security)

- [ ] Select a file
- [ ] Enter strong password
- [ ] Tap "SECURE UPLOAD"
- [ ] Success message appears
- [ ] File appears in dashboard

### ✅ File Upload (High Security)

- [ ] Select a file
- [ ] Tap "High Secure" mode
- [ ] Tap "GENERATE" button
- [ ] Shares dialog appears
- [ ] Copy shares
- [ ] Tap "I HAVE SAVED ALL SHARES"
- [ ] Tap "SECURE UPLOAD"
- [ ] Success message appears

### ✅ File Access

- [ ] Tap on uploaded file
- [ ] Enter password (and shares if high security)
- [ ] File decrypts and displays

---

## 🐛 If File Picker Still Doesn't Open

### Check Permissions

On emulator:
1. **Settings** → **Apps** → **Secure PII Wallet**
2. **Permissions** → **Files and media**
3. Should be **Allowed**

If not, tap and select **Allow**

### Grant Permissions via ADB

```powershell
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
& $adb -s emulator-5554 shell pm grant com.example.secure_pii_wallet android.permission.READ_EXTERNAL_STORAGE
& $adb -s emulator-5554 shell pm grant com.example.secure_pii_wallet android.permission.WRITE_EXTERNAL_STORAGE
```

---

## 📊 Expected Behavior

### ✅ When Working:

1. **Tap "Tap to select file"**
2. **File picker opens** showing folders
3. **Can navigate** to different folders
4. **Can select** any file type
5. **File name and size** display after selection
6. **Upload button** works
7. **Success message** appears
8. **File appears** in dashboard list

### ❌ If Not Working:

- File picker doesn't open → Check permissions
- "Permission denied" error → Grant permissions via ADB
- No files visible → Drag-drop files onto emulator first
- Upload fails → Check password strength

---

## 🎉 Success Indicators

You'll know it's working when:

1. ✅ File picker opens (shows folders and files)
2. ✅ Can select files
3. ✅ File name displays after selection
4. ✅ Upload completes successfully
5. ✅ File appears in dashboard
6. ✅ Can decrypt and view file

---

## 📱 Current Emulator

- **Device**: emulator-5554
- **Status**: Running
- **Android**: API 36 (Android 16)
- **Permissions**: Storage permissions granted

---

## 🚀 Quick Start Command

**Copy and paste this into CMD:**

```cmd
cd C:\Users\lapto\Downloads\Secure-PII\secure_pii_wallet && C:\Users\lapto\fvm\versions\3.19.6\bin\flutter.bat run -d emulator-5554
```

Then wait for the app to launch and test file upload!

---

**The file picker is now fixed and ready to test!** 🎉
