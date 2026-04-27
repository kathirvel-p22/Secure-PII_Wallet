# 🚀 Quick Start Guide

Get your Secure PII Wallet running in 5 minutes!

## ⚡ Fast Setup

### 1. Install Dependencies
```bash
cd secure_pii_wallet
flutter pub get
```

### 2. Add Fonts (Optional but Recommended)
Download Roboto fonts from: https://fonts.google.com/specimen/Roboto

Place in `assets/fonts/`:
- `Roboto-Regular.ttf`
- `Roboto-Medium.ttf`
- `Roboto-Bold.ttf`

**Skip fonts?** The app will work with system fonts. See `FONTS_SETUP.md` for details.

### 3. Run the App
```bash
flutter run
```

That's it! 🎉

## 📱 First Use

### Step 1: Unlock
- App opens to splash screen
- Tap **UNLOCK** button
- You're in!

### Step 2: Upload Your First File
1. Tap the **UPLOAD** button (bottom right)
2. Tap the upload area to select a file (PDF/Image)
3. Choose security mode:
   - **Secure**: Password only
   - **High Secure**: Password + 3 keys
4. Enter a strong password:
   - Min 10 characters
   - Mix of uppercase, lowercase, numbers, special chars
   - Example: `MySecure@Pass123`
5. If High Secure:
   - Tap **GENERATE** for automatic keys
   - **IMPORTANT**: Write down the 3 keys shown!
   - Or enter your own keys (8 chars each)
6. Tap **SECURE UPLOAD**

### Step 3: View Your File
1. Tap the file from dashboard
2. Enter your password
3. If High Secure: Enter your 3 keys
4. File opens securely!

### Step 4: Delete a File
1. Tap the delete icon (🗑️) on any file
2. Confirm deletion
3. All traces removed!

## 🎯 Key Features to Try

### Secure Mode (Password Only)
- Quick and simple
- Strong password protection
- Perfect for most files

### High Security Mode (Password + 3 Keys)
- Maximum security
- Requires password AND 3 keys
- Perfect for sensitive documents
- **Remember**: Save your keys!

### File Viewer
- PDF: Scrollable viewer
- Images: Pinch to zoom
- Files stay in memory only (never saved decrypted)

## 💡 Pro Tips

### Password Tips
✅ Use a password manager
✅ Make it unique per file
✅ Mix characters: `Secure@2024!PII`
❌ Don't use common words
❌ Don't reuse passwords

### Key Tips (High Security)
✅ Write keys on paper
✅ Store in safe place
✅ Take a photo (store securely)
✅ Use generated keys (more secure)
❌ Don't lose them (unrecoverable!)
❌ Don't share them

### Security Tips
✅ Lock app when not in use
✅ Use strong device password
✅ Enable device encryption
✅ Keep app updated
❌ Don't screenshot sensitive files
❌ Don't leave app unlocked

## 🔧 Troubleshooting

### App won't build
```bash
flutter clean
flutter pub get
flutter run
```

### Fonts not showing
1. Verify fonts are in `assets/fonts/`
2. Run `flutter clean`
3. Run `flutter pub get`
4. Restart IDE

### "Wrong password" error
- Check for typos (case-sensitive)
- Remove extra spaces
- Try again (max 3 attempts)

### "Wrong keys" error
- Keys are case-sensitive
- Must enter all 3 keys
- Check saved keys carefully
- Order matters!

### File won't open
- Supported: PDF, JPG, PNG
- Check file isn't corrupted
- Try re-uploading

## 📊 What's Happening Behind the Scenes?

### When You Upload:
1. ✅ Password validated (strength check)
2. ✅ File encrypted with AES-256
3. ✅ Hash generated for integrity
4. ✅ Keys stored securely (if High mode)
5. ✅ Original file never stored

### When You Access:
1. ✅ Password verified
2. ✅ Keys verified (if High mode)
3. ✅ File decrypted in memory
4. ✅ Integrity checked (tamper detection)
5. ✅ Displayed securely

### When You Delete:
1. ✅ Encrypted file removed
2. ✅ Keys removed
3. ✅ Metadata removed
4. ✅ All traces gone

## 🎨 Customization

### Change Theme Colors
Edit `lib/core/theme/colors.dart`:
```dart
static const Color neon = Color(0xFF00FF9C); // Change this!
```

### Adjust Security Settings
Edit `lib/core/security/security_engine.dart`:
```dart
static const int minPasswordLength = 10; // Change this!
static const int maxFailedAttempts = 3;   // Change this!
```

### Change Auto-Lock Time
Edit `lib/core/security/security_engine.dart`:
```dart
static const Duration lockDuration = Duration(minutes: 2); // Change this!
```

## 📚 Learn More

- **Full Documentation**: See `README.md`
- **Architecture Details**: See `ARCHITECTURE.md`
- **Font Setup**: See `FONTS_SETUP.md`

## 🆘 Need Help?

### Common Questions

**Q: Can I recover files if I forget password/keys?**
A: No. This is by design for security. Always save your credentials!

**Q: Are files backed up?**
A: No. Files are stored locally only. Back up manually if needed.

**Q: Can I use the same password for multiple files?**
A: Yes, but not recommended. Use unique passwords for better security.

**Q: What happens if I uninstall the app?**
A: All files are deleted. Export important files first!

**Q: Is this app open source?**
A: Yes! Review the code for security verification.

## ✅ Checklist

Before using in production:

- [ ] Tested upload/access/delete
- [ ] Saved test keys securely
- [ ] Understood password requirements
- [ ] Enabled device encryption
- [ ] Set up device lock screen
- [ ] Backed up important files elsewhere
- [ ] Read security considerations

## 🎉 You're Ready!

Your Secure PII Wallet is now set up and ready to protect your sensitive documents with military-grade encryption!

**Remember**: 
- Strong passwords
- Save your keys
- Lock when not in use

---

**Questions?** Check the full documentation in `README.md` and `ARCHITECTURE.md`
