# 🧪 Test File Picker - Step by Step

## ✅ Status: App Installed Successfully!

Great! The debug APK installed without errors. Now let's test the file picker functionality.

---

## 📱 Testing Steps

### Step 1: Launch the App

1. **Find the app** on your device: "secure_pii_wallet" 
2. **Tap to open** the app
3. **Expected**: App launches without crashes

### Step 2: Complete Onboarding (First Time Only)

If this is your first time opening the app:

1. **Onboarding slides** - Swipe through 6 slides
2. **Master Password Setup**:
   - Enter a strong password (min 10 characters)
   - Must include: uppercase, lowercase, number, special character
   - Example: `MySecure123!`
3. **PIN Setup**:
   - Choose 4 or 6 digits
   - Example: `1234` or `123456`
4. **Tap "Get Started"**

### Step 3: Navigate to File Upload

1. **Dashboard screen** should appear
2. **Tap "Upload File"** button (big blue button)
3. **Expected**: Upload screen opens

### Step 4: Test File Picker

1. **Tap "Tap to select file"** area (large gray box)
2. **CRITICAL TEST**: File picker should open immediately
3. **Expected behaviors**:
   - ✅ File picker opens (no "nothing happens")
   - ✅ Shows device folders and files
   - ✅ Can browse different folders
   - ✅ Shows all file types (not restricted)

### Step 5: Grant Storage Permission (First Time)

If prompted for storage permission:
1. **Tap "Allow"** or "Grant Permission"
2. **File picker should open** after granting permission

### Step 6: Select a File

Try selecting different file types:

#### Test PDF File
1. **Navigate** to Downloads or Documents folder
2. **Select a PDF file**
3. **Expected**: 
   - File name displays in the upload area
   - File size shows (e.g., "2.3 MB")
   - "PDF, Images, Documents, Videos & more" text

#### Test Image File
1. **Navigate** to Pictures or DCIM folder
2. **Select a JPG/PNG image**
3. **Expected**:
   - Image file name displays
   - File size shows
   - May trigger PII detection if faces detected

#### Test Any Other File
1. **Try selecting**: TXT, DOCX, MP4, ZIP, APK, etc.
2. **Expected**: All file types should be selectable

### Step 7: Upload the File

1. **Enter a password** in the password field
   - Must be strong: `TestPassword123!`
2. **Choose security mode**:
   - **Standard**: Just password
   - **High Security**: Password + Shamir shares (tap "GENERATE" first)
3. **Tap "SECURE UPLOAD"**
4. **Expected**:
   - Upload progress indicator
   - Success message: "✅ File encrypted and stored securely!"
   - Returns to dashboard

### Step 8: Verify File in Dashboard

1. **Back on dashboard**
2. **Expected**: Your uploaded file appears in the list
3. **Tap the file** to test access
4. **Enter password** to decrypt and view

---

## ✅ Success Indicators

The file picker is working correctly if:

- ✅ **Tapping "Select file" opens file picker immediately**
- ✅ **Can browse device folders**
- ✅ **Can see and select files of any type**
- ✅ **File name and size display after selection**
- ✅ **Upload completes successfully**
- ✅ **File appears in dashboard**
- ✅ **Can access file with password**

---

## ❌ Troubleshooting

### Issue: File picker doesn't open

**Cause**: Storage permission not granted

**Solution**:
1. Go to Android Settings
2. Apps → secure_pii_wallet
3. Permissions → Storage → Allow

### Issue: No files visible in picker

**Cause**: Emulator has no files

**Solution**: Create some test files or use a physical device

### Issue: "Permission denied" error

**Solution**: Grant storage permission manually via settings

---

## 📊 Test Results Template

Fill this out as you test:

```
Date: ___________
Device: Emulator / Physical Device
Android Version: ___________

✅ PASS / ❌ FAIL - App launches
✅ PASS / ❌ FAIL - Onboarding completes
✅ PASS / ❌ FAIL - Upload screen opens
✅ PASS / ❌ FAIL - File picker opens when tapping "Select file"
✅ PASS / ❌ FAIL - Storage permission granted
✅ PASS / ❌ FAIL - Can browse folders
✅ PASS / ❌ FAIL - Can select PDF files
✅ PASS / ❌ FAIL - Can select image files
✅ PASS / ❌ FAIL - Can select other file types
✅ PASS / ❌ FAIL - File name displays after selection
✅ PASS / ❌ FAIL - File size displays correctly
✅ PASS / ❌ FAIL - Upload completes successfully
✅ PASS / ❌ FAIL - File appears in dashboard
✅ PASS / ❌ FAIL - Can access file with password

Overall Result: ✅ PASS / ❌ FAIL

Notes:
_________________________________
_________________________________
```

---

## 🎯 What We're Testing

This test verifies that:

1. **File picker integration works** (was broken before)
2. **Storage permissions are properly configured**
3. **All file types are supported** (FileType.any)
4. **Upload and encryption functionality works**
5. **File management works end-to-end**

---

## 📞 Report Results

After testing, let me know:

1. **Did the file picker open?** (Most important!)
2. **Could you select files?**
3. **Did upload work?**
4. **Any errors or issues?**

If everything works: **🎉 SUCCESS! File picker is fully functional!**

If there are issues: Share the specific error messages or behaviors.

---

## 🚀 Next Steps After Successful Test

If file picker works perfectly:

1. **Create signed release APK** (for distribution)
2. **Upload to GitHub releases**
3. **Update README with working APK link**
4. **Share with users!**

---

**Ready to test?** Start with Step 1 above!

**Date**: April 30, 2026  
**APK**: Debug build (working version)  
**Status**: ✅ Ready for testing