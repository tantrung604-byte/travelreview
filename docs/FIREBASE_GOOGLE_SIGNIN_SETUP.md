# 🔐 Bật Google Sign-In + Email Verification trên Firebase

> Hướng dẫn từng bước để tính năng đăng nhập Google + xác thực email hoạt động trên Web, Android và iOS.

---

## 1️⃣ Bật providers trong Firebase Console

1. Mở https://console.firebase.google.com → chọn project `travelreview_app` (hoặc tên project hiện tại).
2. **Build → Authentication → Sign-in method**.
3. Bật các provider sau:

   | Provider | Trạng thái cần | Ghi chú |
   |----------|---------------|---------|
   | **Email/Password** | Enable | Đã bật từ trước. Bật thêm "Email link (passwordless)" nếu muốn. |
   | **Google** | Enable | Chọn **Project support email** (gmail của bạn). Lưu. |
   | **Anonymous** | Enable | Cho phép user duyệt + thêm giỏ hàng không cần đăng nhập. |

4. Tab **Templates** → kiểm tra mẫu **Email address verification**:
   - Có thể đổi *Sender name*, *Reply-to* (nên: `noreply@travelreview.vn`).
   - Đổi ngôn ngữ sang **Tiếng Việt** ở dropdown trên cùng nếu muốn email gửi cho user là tiếng Việt.

---

## 2️⃣ Cấu hình WEB (Flutter Web → Chrome / production)

### a. Authorized domains
**Authentication → Settings → Authorized domains** → bấm **Add domain** và thêm:
- `localhost` (đã có sẵn — kiểm tra)
- Domain production của bạn, ví dụ: `travelreview.vn`, `travelreview-app.web.app`, `travelreview-app.firebaseapp.com`

### b. Web Client ID (Google)
- Sau khi bật Google provider, Firebase tự tạo **Web client ID** dưới dạng `xxxxx.apps.googleusercontent.com`.
- Bạn **không cần** thêm vào code: `signInWithPopup(GoogleAuthProvider())` tự dùng client ID của project.
- Nếu muốn dùng One-Tap (FedCM) trên web, vào **Google Cloud Console → APIs & Services → Credentials**, mở Web client → thêm origin `http://localhost:5000`, `https://travelreview.vn` vào **Authorized JavaScript origins**.

### c. Test
```powershell
flutter run -d chrome
```
→ Bấm **"Tiếp tục với Google"** → popup chọn account → quay về app, đã đăng nhập. ✅

---

## 3️⃣ Cấu hình ANDROID

### a. SHA fingerprint của máy bạn (đã lấy được tự động)

```
SHA1   = 03:DF:83:3A:5F:A6:46:DE:DC:4E:F3:EA:44:A7:65:EE:11:A5:E6:A3
SHA256 = 78:B0:2B:D2:83:EE:3E:DA:C0:4E:0C:A1:23:7E:8F:38:6B:FD:93:66:09:77:86:E0:48:75:2D:F0:7B:27:0E:9F
```

> ⚠️ Đây là **debug** fingerprint của keystore mặc định trên máy Windows này. Khi build release **PHẢI** thêm tiếp SHA của release keystore (xem mục `c.` bên dưới).

### b. Thêm fingerprint vào Firebase Console
1. **Project settings** (bánh răng) → tab **General** → kéo xuống **Your apps** → chọn Android app `com.example.travelreview_app` (hoặc tên hiện tại).
2. Bấm **Add fingerprint** → dán **SHA1** ở trên → Save.
3. Lặp lại bấm **Add fingerprint** → dán **SHA256** → Save.
4. Bấm **Download `google-services.json`** mới → đặt vào `android/app/google-services.json` (đè file cũ).
5. Đảm bảo `android/app/build.gradle.kts` đã apply plugin `com.google.gms.google-services`. Nếu chưa, mình có thể thêm hộ — báo lại.

### c. Lấy SHA của release keystore (khi sắp publish)
```powershell
& "C:\Program Files\Java\jdk-17\bin\keytool.exe" -list -v `
  -keystore "<đường-dẫn-tới-release.jks>" `
  -alias <alias-của-bạn>
# Nhập password keystore khi được hỏi
```
→ Copy 2 dòng `SHA1` và `SHA-256` → thêm vào Firebase Console giống bước b.

### d. Test trên Android
```powershell
flutter run -d <device-id-android>
```
Bấm **"Tiếp tục với Google"** → bottom-sheet account chooser native của Android hiện ra. ✅

---

## 4️⃣ Cấu hình iOS

### a. File config
- Vào Firebase Console → **Project settings → Your apps**, chọn iOS app (nếu chưa có thì **Add app → iOS** với bundle ID `com.example.travelreviewApp` hoặc bundle hiện tại).
- Tải `GoogleService-Info.plist` → **kéo thả** vào Xcode dưới `Runner/Runner` (chọn **Copy items if needed**, target **Runner**). File phải nằm tại `ios/Runner/GoogleService-Info.plist`.

### b. URL scheme
- Mở `ios/Runner/GoogleService-Info.plist`, tìm key `REVERSED_CLIENT_ID`.
- Giá trị có dạng: `com.googleusercontent.apps.123456789-abcdefghi`.
- Mở `ios/Runner/Info.plist` (mình đã chèn sẵn block `CFBundleURLTypes` với placeholder), tìm `PASTE_REVERSED_CLIENT_ID_HERE` và **thay** bằng giá trị `REVERSED_CLIENT_ID` đó.

### c. Pod install
```powershell
cd ios
pod install --repo-update
cd ..
```

### d. Test
```powershell
flutter run -d <ios-device>
```

---

## 5️⃣ Sửa Firestore rules để cho phép user đã verify viết review/booking

Mở `firestore.rules` thêm/đảm bảo có:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Public read tour
    match /tours/{tourId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;

      // Reviews: chỉ user đã đăng nhập + email đã verify (hoặc Google) mới viết được
      match /reviews/{reviewId} {
        allow read: if true;
        allow create: if request.auth != null
                      && request.auth.token.email_verified == true
                      && request.resource.data.userId == request.auth.uid;
        allow update, delete: if request.auth != null
                              && resource.data.userId == request.auth.uid;
      }
    }

    // Bookings: chỉ owner đọc/ghi, admin đọc tất
    match /bookings/{bookingId} {
      allow read: if request.auth != null
                  && (resource.data.userId == request.auth.uid
                      || request.auth.token.admin == true);
      allow create: if request.auth != null
                    && request.resource.data.userId == request.auth.uid;
      allow update: if request.auth != null
                    && (resource.data.userId == request.auth.uid
                        || request.auth.token.admin == true);
    }

    // SEO: chỉ admin
    match /seo/{routeId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
  }
}
```

Deploy:
```powershell
firebase deploy --only firestore:rules
```

---

## 6️⃣ Checklist test cuối

- [ ] Đăng ký bằng email → nhận được email xác thực trong inbox (kiểm tra Spam).
- [ ] Click link trong email → quay lại app, vào `/account` → bấm **"Tôi đã xác thực"** → banner cam biến mất, hiện badge ✅ "Đã xác thực".
- [ ] Đăng nhập Google trên Web → popup → sau khi xong tự về trang trước.
- [ ] Đăng nhập Google trên Android → bottom-sheet account chooser native.
- [ ] Đăng xuất → đăng nhập lại bằng Google → vẫn lấy đúng tài khoản.
- [ ] User chưa verify email **không** viết được review (Firestore rules từ chối).
- [ ] Quên mật khẩu → nhận được email reset.

---

## 🐛 Troubleshooting

| Triệu chứng | Khắc phục |
|------------|-----------|
| `auth/operation-not-allowed` | Provider chưa được Enable trong Firebase Console |
| Popup Google đóng ngay tức khắc trên web | Thêm domain vào **Authorized domains** |
| Android: `ApiException: 10` | SHA-1 chưa thêm hoặc `google-services.json` cũ — tải lại và rebuild |
| Android: `ApiException: 12500` | Sai package name giữa `google-services.json` và `applicationId` trong `build.gradle.kts` |
| iOS: app crash khi bấm Google | Quên URL scheme `REVERSED_CLIENT_ID` trong `Info.plist` |
| Email xác thực không tới | Check Spam, hoặc Firebase Auth → Templates đang ở chế độ chưa active domain → thêm SPF/DKIM nếu dùng custom domain |

