# 📤 How to Upload APK to Google Drive

## Step-by-Step Guide

### Step 1: Locate Your APK File

The APK file is located at:
```
C:\Users\lapto\Downloads\Secure-PII\secure_pii_wallet\build\app\outputs\flutter-apk\app-release.apk
```

**File Details:**
- Name: `app-release.apk`
- Size: 21.8 MB
- Type: Android Application Package

---

### Step 2: Upload to Google Drive

1. **Open Google Drive**
   - Go to https://drive.google.com
   - Sign in with your Google account

2. **Create a Folder (Optional but Recommended)**
   - Click "New" → "New folder"
   - Name it "Secure PII Wallet" or "App Releases"
   - Open the folder

3. **Upload the APK**
   - Click "New" → "File upload"
   - Navigate to: `C:\Users\lapto\Downloads\Secure-PII\secure_pii_wallet\build\app\outputs\flutter-apk\`
   - Select `app-release.apk`
   - Click "Open"
   - Wait for the upload to complete (should take 30-60 seconds)

---

### Step 3: Make the File Public

1. **Right-click** on the uploaded `app-release.apk` file
2. Click **"Share"** or **"Get link"**
3. Under "General access", click **"Restricted"**
4. Change it to **"Anyone with the link"**
5. Make sure it says **"Viewer"** (not Editor)
6. Click **"Copy link"**

Your link will look like:
```
https://drive.google.com/file/d/1a2b3c4d5e6f7g8h9i0j/view?usp=sharing
```

---

### Step 4: Extract the File ID

From your Google Drive link, extract the FILE_ID:

**Example:**
```
https://drive.google.com/file/d/1a2b3c4d5e6f7g8h9i0j/view?usp=sharing
                              ^^^^^^^^^^^^^^^^^^^^
                              This is your FILE_ID
```

---

### Step 5: Update the README

1. **Open** `secure_pii_wallet/README.md`

2. **Find this line** (around line 300):
   ```markdown
   - 📥 [Download from Google Drive](https://drive.google.com/file/d/YOUR_FILE_ID/view?usp=sharing)
   ```

3. **Replace** `YOUR_FILE_ID` with your actual file ID:
   ```markdown
   - 📥 [Download from Google Drive](https://drive.google.com/file/d/1a2b3c4d5e6f7g8h9i0j/view?usp=sharing)
   ```

4. **Save** the file

---

### Step 6: Commit and Push Changes

```bash
cd C:\Users\lapto\Downloads\Secure-PII\secure_pii_wallet
git add README.md
git commit -m "Update README with Google Drive APK download link"
git push origin main
```

---

## 🎉 Done!

Your APK is now available for download! Users can:
1. Click the Google Drive link in your README
2. Click "Download" on Google Drive
3. Install the APK on their Android phone

---

## 📱 Testing the Download

To test if it works:

1. Open the README on GitHub: https://github.com/kathirvel-p22/Secure-PII_Wallet
2. Click the Google Drive link
3. You should see a preview of the APK file
4. Click the "Download" button (top-right corner)
5. The APK should download to your device

---

## 🔄 Alternative: Direct Download Link

If you want a direct download link (bypasses the preview page):

**Format:**
```
https://drive.google.com/uc?export=download&id=YOUR_FILE_ID
```

**Example:**
```
https://drive.google.com/uc?export=download&id=1a2b3c4d5e6f7g8h9i0j
```

This link will start the download immediately when clicked.

---

## ⚠️ Important Notes

1. **Keep the link public** - Don't change it back to "Restricted"
2. **Don't delete the file** - Users won't be able to download it
3. **Check storage** - Make sure you have enough Google Drive space
4. **Update version** - When you release a new version, upload the new APK and update the link

---

## 🆘 Troubleshooting

### "File not found" error
- Make sure the file is set to "Anyone with the link"
- Check that the FILE_ID is correct

### Download is slow
- Google Drive might throttle downloads for large files
- Consider using GitHub Releases as an alternative

### Can't upload file
- Check your Google Drive storage space
- Try compressing the APK (though not recommended for apps)

---

## 📊 Google Drive vs GitHub Releases

| Feature | Google Drive | GitHub Releases |
|---------|-------------|-----------------|
| **Speed** | Fast | Fast |
| **Ease of Use** | Very Easy | Moderate |
| **Storage Limit** | 15 GB free | Unlimited |
| **Professional** | Good | Better |
| **Version Control** | Manual | Automatic |
| **Recommended For** | Quick sharing | Official releases |

**Recommendation**: Use Google Drive for quick sharing, but also create a GitHub Release for professional distribution.

---

**Need help?** Open an issue on GitHub or contact the repository owner.
