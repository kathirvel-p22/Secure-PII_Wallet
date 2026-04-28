# 📤 How to Upload New APK to GitHub Releases

## 🎯 Quick Steps

### Step 1: Locate Your APK
Your new APK with the custom icon is here:
```
C:\Users\lapto\Downloads\Secure-PII\secure_pii_wallet\build\app\outputs\flutter-apk\app-release.apk
```
- **Size**: 22.1 MB
- **Version**: 1.0.0
- **Features**: Custom logo, API 34 target, Google Play Protect compatible

---

### Step 2: Go to GitHub Releases

1. **Open your browser** and go to:
   ```
   https://github.com/kathirvel-p22/Secure-PII_Wallet/releases
   ```

2. **You'll see your existing v1.0.0 release** (if you created one earlier)

---

### Step 3: Update the Release

#### Option A: Edit Existing Release (Recommended)

1. **Click "Edit"** on the v1.0.0 release
2. **Scroll down to "Attach binaries"**
3. **Delete the old APK** (if present)
4. **Drag and drop** the new `app-release.apk` file
5. **Wait for upload** to complete (may take 1-2 minutes)
6. **Update release notes** (see below)
7. **Click "Update release"**

#### Option B: Create New Release

1. **Click "Draft a new release"**
2. **Tag version**: `v1.0.0` (or `v1.0.1` if v1.0.0 exists)
3. **Release title**: `Secure PII Wallet v1.0.0 - Custom Icon`
4. **Description**: (see suggested text below)
5. **Attach the APK**: Drag and drop `app-release.apk`
6. **Click "Publish release"**

---

### Step 4: Suggested Release Notes

Copy and paste this into your release description:

```markdown
# 🔐 Secure PII Wallet v1.0.0

## ✨ What's New

### 🎨 Custom App Icon
- Professional **Secure PII Wallet** logo
- Adaptive icons for modern Android devices
- Consistent branding across all platforms

### 🔒 Core Security Features
- **Military-grade AES-256-CBC encryption**
- **Dual security system**: Master Password + PIN Lock
- **Shamir's Secret Sharing** for high-security files
- **Zero-knowledge architecture**

### 📁 File Management
- Upload and encrypt any file type
- Password-protected downloads
- Secure file deletion
- Encrypted metadata storage

### ⚙️ Advanced Features
- Dark/Light theme toggle
- Auto-lock timer (1-30 minutes)
- Backup/Export encrypted vault
- Factory reset & complete system reset
- Access logs tracking

## 📱 Installation

### Requirements
- **Android**: 5.0 (Lollipop) or higher
- **Storage**: 50 MB free space
- **Permissions**: Storage access for file management

### Steps
1. **Download** the APK file below
2. **Open** the downloaded file on your Android phone
3. **Allow** installation from unknown sources if prompted:
   - Settings → Security → Unknown Sources → Enable
   - Or Settings → Apps → Install Unknown Apps → Enable for your browser
4. **Install** and start using the app!

### ✅ Google Play Protect Compatible
This APK targets Android API 34 and passes Google Play Protect security checks.

## 📥 Download

**File**: `app-release.apk`  
**Size**: 22.1 MB  
**Version**: 1.0.0  
**Build**: Release

Click the APK file below to download ⬇️

## 🔐 Security Notes

- All files are encrypted with AES-256
- Master password and PIN are hashed with SHA-256
- No data is sent to external servers
- Complete offline operation
- Open source - audit the code yourself!

## 📖 Documentation

- **README**: [View on GitHub](https://github.com/kathirvel-p22/Secure-PII_Wallet#readme)
- **Build Guide**: [APK_BUILD_SUCCESS.md](https://github.com/kathirvel-p22/Secure-PII_Wallet/blob/main/APK_BUILD_SUCCESS.md)
- **Security Details**: [FIX_GOOGLE_PLAY_PROTECT.md](https://github.com/kathirvel-p22/Secure-PII_Wallet/blob/main/FIX_GOOGLE_PLAY_PROTECT.md)

## 🐛 Known Issues

- Large files (>100MB) may cause performance issues on older devices
- iOS version requires additional setup (coming soon)

## 🙏 Feedback

Found a bug or have a suggestion? [Open an issue](https://github.com/kathirvel-p22/Secure-PII_Wallet/issues)

---

**Made with ❤️ and 🔐 by Kathirvel P**
```

---

### Step 5: Verify the Download Link

After publishing the release:

1. **Copy the download link** - it will be:
   ```
   https://github.com/kathirvel-p22/Secure-PII_Wallet/releases/download/v1.0.0/app-release.apk
   ```

2. **Test the link** in your browser - it should start downloading the APK

3. **The README.md already has this link** - no need to update it!

---

## 🎯 Quick Checklist

- [ ] Located the APK file on your computer
- [ ] Went to GitHub releases page
- [ ] Edited/created the v1.0.0 release
- [ ] Uploaded the new `app-release.apk` (22.1 MB)
- [ ] Added release notes (copy from above)
- [ ] Published the release
- [ ] Tested the download link
- [ ] Downloaded and installed on your phone
- [ ] Verified the custom icon appears

---

## 📱 After Upload

### Test on Your Phone

1. **Uninstall old version** (if installed)
2. **Download from GitHub releases**
3. **Install the new APK**
4. **Check the home screen** - you should see your custom logo! 🎨

### Share with Others

Your app is now ready to share! Anyone can:
1. Go to your GitHub releases page
2. Download the APK
3. Install on their Android device
4. Start using Secure PII Wallet with your custom branding!

---

## 🆘 Troubleshooting

### "404 Not Found" when downloading
- Make sure the release is **published** (not draft)
- Check the file name is exactly `app-release.apk`
- Try the direct link format above

### Upload taking too long
- File is 22.1 MB - may take 1-2 minutes on slow connections
- Don't close the browser tab during upload
- If it fails, try again

### Can't find the APK file
- Open File Explorer
- Navigate to: `C:\Users\lapto\Downloads\Secure-PII\secure_pii_wallet\build\app\outputs\flutter-apk\`
- Look for `app-release.apk` (22.1 MB)

---

**Need help?** Open an issue on GitHub or check the documentation!

🎉 **Your app with custom icon is ready to share with the world!**
