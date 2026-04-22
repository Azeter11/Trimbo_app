# trimbo_app

A new Flutter project.

## Getting Started

## 🚀 Cara Setup Proyek

### 1. Prasyarat
Pastikan sudah terinstal:
- Flutter SDK >= 3.0.0
- Dart >= 3.0.0
- Android Studio / VS Code
- Firebase CLI

### 2. Clone & Install Dependencies
```bash
# Clone proyek
git clone <url-repo>
cd edutask

# Install semua package
flutter pub get
```

### 3. Setup Firebase

#### a. Buat Proyek Firebase
1. Buka [console.firebase.google.com](https://console.firebase.google.com)
2. Klik **"Add Project"** → beri nama `edutask`
3. Aktifkan **Google Analytics** (opsional)

#### b. Tambahkan Aplikasi Android
1. Di Firebase Console, klik **"Add app"** → pilih Android
2. Isi **Package name**: `com.example.edutask`
3. Download file `google-services.json`
4. Letakkan di: `android/app/google-services.json`

#### c. Tambahkan Aplikasi iOS (jika perlu)
1. Klik **"Add app"** → pilih iOS
2. Isi **Bundle ID**: `com.example.edutask`
3. Download `GoogleService-Info.plist`
4. Letakkan di: `ios/Runner/GoogleService-Info.plist`

#### d. Aktifkan Firebase Services
Di Firebase Console, aktifkan:
- **Authentication** → Email/Password
- **Cloud Firestore** → buat database (mode test)
- **Cloud Messaging** (untuk push notification)

#### e. Setup FlutterFire CLI (Cara Modern)
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Konfigurasi otomatis (lebih mudah)
flutterfire configure --project=edutask
```
Ini akan otomatis membuat file `lib/firebase_options.dart`.

Lalu update `main.dart`:
```dart
import 'firebase_options.dart';

await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### 4. Setup Firestore Rules
Di Firebase Console → Firestore → Rules, paste:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User hanya bisa baca/tulis data sendiri
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Kelas: guru bisa buat, semua authenticated user bisa baca
    match /classes/{classId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Tugas: semua authenticated user bisa baca
    match /assignments/{assignmentId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Soal: semua authenticated user bisa baca
    match /questions/{questionId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Submission: siswa bisa buat, guru bisa baca
    match /submissions/{submissionId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 5. Buat Folder Assets
```bash
mkdir -p assets/images assets/icons
```

### 6. Jalankan Aplikasi
```bash
flutter run
```

---

## 📁 Struktur Proyek

```
lib/
├── main.dart                    # Entry point
├── app/
│   ├── app.dart                 # GetMaterialApp + semua route
│   └── routes.dart              # Konstanta nama route
├── core/
│   ├── constants/
│   │   ├── app_colors.dart      # Semua warna aplikasi
│   │   ├── app_strings.dart     # Semua teks/label
│   │   └── app_styles.dart      # TextStyle + ThemeData
│   ├── utils/
│   │   ├── validators.dart      # Validasi form
│   │   └── helpers.dart         # Fungsi bantu (format tanggal, hitung nilai)
│   └── widgets/
│       ├── custom_button.dart   # PrimaryButton, OutlineButton, TextLinkButton
│       ├── custom_textfield.dart# CustomTextField, PasswordTextField, OtpTextField
│       └── loading_overlay.dart # LoadingOverlay, EmptyStateWidget, ErrorStateWidget
├── features/
│   ├── auth/
│   │   ├── controllers/auth_controller.dart
│   │   ├── models/user_model.dart
│   │   └── screens/
│   │       ├── splash_screen.dart
│   │       ├── login_screen.dart
│   │       ├── register_student_screen.dart
│   │       ├── register_teacher_screen.dart
│   │       ├── otp_screen.dart
│   │       └── forgot_password_screen.dart
│   ├── student/
│   │   ├── controllers/
│   │   │   ├── student_controller.dart
│   │   │   └── exam_controller.dart    # ⭐ Anti-cheat, timer, auto-submit
│   │   ├── models/
│   │   │   ├── class_model.dart
│   │   │   ├── assignment_model.dart
│   │   │   └── submission_model.dart
│   │   └── screens/
│   │       ├── student_dashboard_screen.dart
│   │       ├── join_class_screen.dart
│   │       ├── class_detail_screen.dart
│   │       ├── exam_screen.dart        # ⭐ Fullscreen, anti-cheat
│   │       ├── result_screen.dart
│   │       ├── grade_report_screen.dart
│   │       └── student_profile_screen.dart
│   └── teacher/
│       ├── controllers/
│       │   ├── teacher_controller.dart
│       │   └── assignment_controller.dart
│       ├── models/question_model.dart
│       └── screens/
│           ├── teacher_dashboard_screen.dart
│           ├── create_class_screen.dart
│           ├── class_management_screen.dart
│           ├── create_assignment_screen.dart
│           ├── create_question_screen.dart
│           ├── student_grades_screen.dart
│           ├── analytics_screen.dart
│           └── teacher_profile_screen.dart
└── services/
    ├── firebase_auth_service.dart
    ├── firestore_service.dart
    ├── notification_service.dart
    └── export_service.dart
```

---

## ⭐ Fitur Unggulan

### Anti-Cheat Ujian
File: `exam_controller.dart` + `exam_screen.dart`

- **Fullscreen mode**: `SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive)`
- **Deteksi keluar layar**: `WidgetsBindingObserver` + `didChangeAppLifecycleState`
- **3 strike system**: Keluar 3x → auto-submit
- **Auto-submit**: Timer habis → auto-submit dengan animasi

### Timer Countdown
- Format MM:SS
- Warna merah jika < 60 detik
- Auto-submit saat 00:00

### Kode Kelas
- Auto-generate kode unik 6 karakter
- Menghindari karakter ambigu (O, I, 0, 1)
- Cek duplikat otomatis di Firestore

---

## 🎨 Design System

| Token | Value |
|-------|-------|
| Primary | `#4F46E5` (Indigo) |
| Secondary | `#7C3AED` (Purple) |
| Success | `#10B981` (Green) |
| Warning | `#F59E0B` (Amber) |
| Error | `#EF4444` (Red) |
| Background | `#F8FAFC` |
| Font | Inter (Google Fonts) |
| Border Radius | 12-16px |

---

## 📦 Package Utama

| Package | Fungsi |
|---------|--------|
| `get` | State management, navigation, DI |
| `firebase_auth` | Autentikasi |
| `cloud_firestore` | Database |
| `firebase_messaging` | Push notification |
| `flutter_screenutil` | Responsive UI |
| `google_fonts` | Font Inter |
| `fl_chart` | Chart analitik |
| `pdf` | Export PDF |
| `excel` | Export Excel |
| `share_plus` | Bagikan file |

---

## 🐛 Troubleshooting

### Error: `google-services.json` tidak ditemukan
→ Download dari Firebase Console dan letakkan di `android/app/`

### Error: `MissingPluginException`
→ Jalankan `flutter clean && flutter pub get`, lalu restart

### Firebase Auth tidak berfungsi
→ Pastikan **Email/Password** provider sudah diaktifkan di Firebase Console

### Firestore permission denied
→ Periksa Firestore Security Rules (lihat bagian Setup di atas)

---

## 👥 Alur Penggunaan

### Siswa
1. Register → Verifikasi email → Login
2. Gabung kelas (dengan kode dari guru)
3. Lihat daftar tugas
4. Kerjakan ujian (fullscreen, anti-cheat)
5. Lihat hasil dan nilai

### Guru
1. Register (dengan NIDN) → Login
2. Buat kelas → Bagikan kode kelas ke siswa
3. Buat tugas (info + soal)
4. Terbitkan tugas
5. Monitor nilai & analitik kelas

---

*EduTask — Belajar Lebih Terstruktur* 🎓

