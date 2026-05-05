param(
  [switch]$SkipAndroid,
  [switch]$SkipWeb
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

Write-Host "== TravelReview release build ==" -ForegroundColor Yellow
flutter pub get
flutter analyze
flutter test

if (-not $SkipWeb) {
  Write-Host "== Build Web ==" -ForegroundColor Yellow
  flutter build web --release --base-href /
  Write-Host "Web artifact: build/web" -ForegroundColor Green
}

if (-not $SkipAndroid) {
  Write-Host "== Build Android APK ==" -ForegroundColor Yellow
  flutter build apk --release
  Write-Host "APK: build/app/outputs/flutter-apk/app-release.apk" -ForegroundColor Green

  Write-Host "== Build Android App Bundle ==" -ForegroundColor Yellow
  flutter build appbundle --release
  Write-Host "AAB: build/app/outputs/bundle/release/app-release.aab" -ForegroundColor Green
}

Write-Host "== Done ==" -ForegroundColor Green

