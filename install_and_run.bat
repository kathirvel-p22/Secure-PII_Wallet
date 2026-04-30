@echo off
echo ========================================
echo SECURE PII WALLET - INSTALL AND RUN
echo ========================================
echo.

echo Step 1: Checking for running emulator...
C:\Users\lapto\AppData\Local\Android\sdk\platform-tools\adb.exe devices
echo.

echo Step 2: Uninstalling old version (if exists)...
C:\Users\lapto\AppData\Local\Android\sdk\platform-tools\adb.exe uninstall com.example.secure_pii_wallet
echo.

echo Step 3: Installing new APK with storage permissions...
C:\Users\lapto\AppData\Local\Android\sdk\platform-tools\adb.exe install -r build\app\outputs\flutter-apk\app-release.apk
echo.

echo Step 4: Launching app...
C:\Users\lapto\AppData\Local\Android\sdk\platform-tools\adb.exe shell am start -n com.example.secure_pii_wallet/.MainActivity
echo.

echo ========================================
echo DONE! App should now be running on emulator
echo ========================================
echo.
echo IMPORTANT: When you tap "Select file", the app will now:
echo 1. Request storage permissions (grant them)
echo 2. Open file picker to select ANY file type
echo 3. Upload and encrypt your file securely
echo.
pause
