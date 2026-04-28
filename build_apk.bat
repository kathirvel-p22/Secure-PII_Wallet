@echo off
echo Building APK with Flutter 3.19.6...
flutter build apk --release
echo.
echo Build complete!
echo APK location: build\app\outputs\flutter-apk\app-release.apk
pause
