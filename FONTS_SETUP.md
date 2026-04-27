# Roboto Fonts Setup

## Required Fonts

You need to download and add the following Roboto font files to `assets/fonts/`:

1. **Roboto-Regular.ttf**
2. **Roboto-Medium.ttf**
3. **Roboto-Bold.ttf**

## Download Instructions

### Option 1: Google Fonts (Recommended)
1. Visit: https://fonts.google.com/specimen/Roboto
2. Click "Download family"
3. Extract the ZIP file
4. Copy these files to `assets/fonts/`:
   - `Roboto-Regular.ttf`
   - `Roboto-Medium.ttf`
   - `Roboto-Bold.ttf`

### Option 2: Direct Download
Download from Google Fonts GitHub:
- https://github.com/google/fonts/tree/main/apache/roboto

### Option 3: Use System Fonts (Temporary)
If you want to test without downloading fonts:
1. Comment out the `fonts:` section in `pubspec.yaml`
2. The app will use system default fonts
3. **Note**: This will affect the visual design

## Verification

After adding fonts:
1. Ensure files are in `assets/fonts/` directory
2. Run `flutter pub get`
3. Run `flutter clean` (if fonts don't appear)
4. Run `flutter run`

## File Structure

```
secure_pii_wallet/
├── assets/
│   └── fonts/
│       ├── Roboto-Regular.ttf
│       ├── Roboto-Medium.ttf
│       └── Roboto-Bold.ttf
└── pubspec.yaml (already configured)
```

## Troubleshooting

### Fonts not appearing
1. Run `flutter clean`
2. Run `flutter pub get`
3. Restart your IDE
4. Run `flutter run`

### File not found error
- Verify files are in `assets/fonts/` directory
- Check file names match exactly (case-sensitive)
- Ensure `pubspec.yaml` has correct indentation

## Alternative: Skip Fonts

If you want to run the app immediately without fonts:

1. Open `lib/core/theme/typography.dart`
2. Remove `fontFamily: 'Roboto',` from all TextStyle definitions
3. Open `lib/core/theme/app_theme.dart`
4. Remove `fontFamily: 'Roboto',` from ThemeData

The app will work with system fonts, but won't match the intended design.
