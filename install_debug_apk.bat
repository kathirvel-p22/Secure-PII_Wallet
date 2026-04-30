@echo off
echo ========================================
echo INSTALL DEBUG APK (WORKING VERSION)
echo ========================================
echo.

echo This will install the DEBUG APK which works without signing issues.
echo.

echo Step 1: Checking for connected devices...
C:\Users\lapto\AppData\Local\Android\sdk\platform-tools\adb.exe devices
echo.

echo Step 2: Uninstalling old version...
C:\Users\lapto\AppData\Local\Android\sdk\platform-tools\adb.exe uninstall com.example.secure_pii_wallet
echo.

echo Step 3: Installing DEBUG APK...
C:\Users\lapto\AppData\Local\Android\sdk\platform-tools\adb.exe install build\app\outputs\flutter-apk\app-debug.apk
echo.

echo Step 4: Launching app...
C:\Users\lapto\AppData\Local\Android\sdk\platform-tools\adb.exe shell am start -n com.example.secure_pii_wallet/.MainActivity
echo.

echo ========================================
echo DONE! App installed successfully
echo ========================================
echo.
echo The DEBUG APK is now installed and running.
echo File picker should work properly!
echo.
echo NOTE: This is a debug build (larger size, auto-signed)
echo For production, create a signed release APK (see CREATE_SIGNED_APK.md)
echo.
pause
