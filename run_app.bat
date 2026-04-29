@echo off
echo.
echo ========================================
echo   Starting Secure PII Wallet
echo ========================================
echo.

REM Check if pubspec.yaml exists
if not exist "pubspec.yaml" (
    echo ERROR: pubspec.yaml not found!
    echo Please run this script from the project root directory.
    pause
    exit /b 1
)

echo [OK] Found pubspec.yaml
echo.

echo Checking for devices...
C:\Users\lapto\fvm\versions\3.19.6\bin\flutter.bat devices
echo.

echo Starting app with Hot Reload...
echo.
echo Commands:
echo   r - Hot reload
echo   R - Hot restart  
echo   q - Quit
echo.

C:\Users\lapto\fvm\versions\3.19.6\bin\flutter.bat run

pause
