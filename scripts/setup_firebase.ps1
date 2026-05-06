# =============================================================================
#  setup_firebase.ps1 — Tự động hoá tối đa việc bật Google Sign-In + verify email
#  trên Firebase cho project travelreview_app.
#
#  Script sẽ:
#   1. Kiểm tra/cài flutterfire CLI và firebase CLI
#   2. Mở các trang Firebase Console cần config thủ công (đúng thứ tự)
#   3. Pause cho bạn click → enable provider / paste SHA / add domain
#   4. Chạy `flutterfire configure` → tự DOWNLOAD `google-services.json`
#      và `GoogleService-Info.plist` về đúng vị trí, đồng thời cập nhật
#      `lib/firebase_options.dart`.
#   5. Tự đọc REVERSED_CLIENT_ID từ GoogleService-Info.plist và DÁN VÀO
#      `ios/Runner/Info.plist` thay placeholder.
#   6. Deploy `firestore.rules`.
#
#  CHẠY:    powershell -ExecutionPolicy Bypass -File scripts\setup_firebase.ps1
# =============================================================================

$ErrorActionPreference = 'Stop'
$root = Resolve-Path "$PSScriptRoot\.."
Set-Location $root

function Section($t) { Write-Host "`n=========== $t ===========" -ForegroundColor Cyan }
function Pause-Step($msg) {
  Write-Host "`n>>> $msg" -ForegroundColor Yellow
  Read-Host "    Bấm Enter khi đã xong"
}
function Open-Url($url) {
  Write-Host "    🌐 $url" -ForegroundColor Gray
  Start-Process $url
}

# ---- 0. Kiểm tra CLI ----
Section "0. Kiểm tra CLI"
try { firebase --version | Out-Host } catch {
  Write-Host "✗ firebase CLI chưa cài. Cài bằng: npm install -g firebase-tools" -ForegroundColor Red
  exit 1
}

$flutterfireBin = "$env:LOCALAPPDATA\Pub\Cache\bin\flutterfire.bat"
if (-not (Test-Path $flutterfireBin)) {
  Write-Host "Cài flutterfire CLI..." -ForegroundColor Yellow
  dart pub global activate flutterfire_cli
}
Write-Host "✓ flutterfire: $flutterfireBin" -ForegroundColor Green

# ---- 1. Login Firebase ----
Section "1. Đăng nhập Firebase"
firebase login --no-localhost
firebase projects:list

$projectId = Read-Host "`nNhập Project ID Firebase (vd: travelreview-app)"
firebase use $projectId

# ---- 2. SHA fingerprint Android ----
Section "2. SHA fingerprint Android"
$keytool = "C:\Program Files\Java\jdk-17\bin\keytool.exe"
if (Test-Path $keytool) {
  & $keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" `
    -alias androiddebugkey -storepass android -keypass android 2>&1 |
    Select-String -Pattern "SHA1:|SHA256:" |
    ForEach-Object { Write-Host "    $_" -ForegroundColor Magenta }
} else {
  Write-Host "✗ Không tìm thấy keytool tại $keytool" -ForegroundColor Red
}

# ---- 3. Hướng dẫn enable providers ----
Section "3. Bật Auth providers"
Open-Url "https://console.firebase.google.com/project/$projectId/authentication/providers"
Pause-Step "Bật **Email/Password**, **Google** (chọn project support email), **Anonymous** → Save"

Section "4. Authorized domains"
Open-Url "https://console.firebase.google.com/project/$projectId/authentication/settings"
Pause-Step "Add domain: localhost (đã có), domain prod của bạn"

Section "5. Add SHA fingerprints (Android)"
Open-Url "https://console.firebase.google.com/project/$projectId/settings/general"
Pause-Step "Vào Android app → Add fingerprint → dán cả SHA1 + SHA256 ở trên"

# ---- 6. Chạy flutterfire configure ----
Section "6. flutterfire configure (tự download config files)"
Write-Host "Chạy: flutterfire configure --project=$projectId" -ForegroundColor Yellow
& $flutterfireBin configure --project=$projectId

# ---- 7. Tự inject REVERSED_CLIENT_ID vào Info.plist ----
Section "7. Inject REVERSED_CLIENT_ID vào ios/Runner/Info.plist"
$gPlist  = "$root\ios\Runner\GoogleService-Info.plist"
$infoPl  = "$root\ios\Runner\Info.plist"
if (Test-Path $gPlist) {
  $content   = Get-Content $gPlist -Raw
  $matches   = [regex]::Match($content, '<key>REVERSED_CLIENT_ID</key>\s*<string>([^<]+)</string>')
  if ($matches.Success) {
    $reversed = $matches.Groups[1].Value
    Write-Host "  REVERSED_CLIENT_ID = $reversed" -ForegroundColor Green
    $info = Get-Content $infoPl -Raw
    if ($info -match 'PASTE_REVERSED_CLIENT_ID_HERE') {
      $info = $info -replace 'PASTE_REVERSED_CLIENT_ID_HERE', [regex]::Escape($reversed).Replace('\','')
      Set-Content $infoPl $info -Encoding UTF8 -NoNewline
      Write-Host "  ✓ Đã chèn vào Info.plist" -ForegroundColor Green
    } else {
      Write-Host "  ⚠ Không tìm thấy placeholder PASTE_REVERSED_CLIENT_ID_HERE — có thể bạn đã chèn rồi." -ForegroundColor Yellow
    }
  } else {
    Write-Host "  ✗ Không parse được REVERSED_CLIENT_ID" -ForegroundColor Red
  }
} else {
  Write-Host "  (Bỏ qua iOS — chưa có $gPlist)" -ForegroundColor Gray
}

# ---- 8. Deploy Firestore rules ----
Section "8. Deploy Firestore rules"
$ans = Read-Host "Deploy firestore.rules ngay? [Y/n]"
if ($ans -ne 'n') {
  firebase deploy --only firestore:rules
}

# ---- Done ----
Section "✅ HOÀN TẤT"
Write-Host @"
Bước tiếp theo:
  flutter pub get
  flutter run -d chrome    # test Google Sign-In Web
  flutter run -d <android> # test Google Sign-In Android (cần SHA đã add)

Nếu lỗi:
  • Web 'popup-closed-by-user'    → check Authorized domains
  • Android 'ApiException: 10'    → SHA chưa add hoặc google-services.json cũ
  • iOS app crash khi bấm Google  → REVERSED_CLIENT_ID chưa vào Info.plist
"@ -ForegroundColor Cyan

