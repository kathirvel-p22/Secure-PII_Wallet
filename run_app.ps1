# Run Flutter App with Hot Reload
# Usage: .\run_app.ps1

Write-Host "🚀 Starting Secure PII Wallet..." -ForegroundColor Cyan
Write-Host ""

# Set Flutter path
$flutterPath = "C:\Users\lapto\fvm\versions\3.19.6\bin\flutter.bat"

# Check if we're in the right directory
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "❌ Error: pubspec.yaml not found!" -ForegroundColor Red
    Write-Host "Please run this script from the project root directory." -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Found pubspec.yaml" -ForegroundColor Green
Write-Host ""

# Check for devices
Write-Host "📱 Checking for devices..." -ForegroundColor Cyan
& cmd /c "$flutterPath devices"
Write-Host ""

# Run the app
Write-Host "🔥 Starting app with Hot Reload enabled..." -ForegroundColor Cyan
Write-Host "Press 'r' to hot reload, 'R' to hot restart, 'q' to quit" -ForegroundColor Yellow
Write-Host ""

& cmd /c "$flutterPath run"
