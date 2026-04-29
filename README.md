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

## 📁 Struktur Proyek (Project Structure)

Proyek ini menggunakan arsitektur berbasis fitur (Feature-First Architecture) yang memisahkan logika, tampilan, dan data ke dalam folder fitur yang spesifik. Berikut adalah penjelasan fungsi dari struktur folder dan file di dalam proyek:

### 1. Struktur Root (File Penting)

File dan folder di luar folder `lib/` memiliki peran penting dalam konfigurasi dan build aplikasi:

- `pubspec.yaml`: Jantung dari proyek Flutter. Berisi metadata proyek (nama, deskripsi, versi), daftar *dependencies* (library pihak ketiga seperti `get`, `firebase_core`, dsb.), *dev_dependencies* (alat bantu development), serta konfigurasi aset seperti gambar dan ikon.
- `android/`, `ios/`, `web/`, `macos/`, `windows/`, `linux/`: Folder spesifik platform. Berisi native code dan konfigurasi build untuk masing-masing platform. (misalnya: file `AndroidManifest.xml` ada di dalam folder `android/`).
- `analysis_options.yaml`: File konfigurasi linting Dart. Digunakan untuk menentukan aturan penulisan kode agar seragam dan mendeteksi potensi error (best practices).
- `assets/`: Folder tempat menyimpan sumber daya statis seperti gambar, ikon, dan font lokal.

### 2. Struktur Folder `lib/` (Kode Utama)

Seluruh logika bisnis, tampilan, dan integrasi aplikasi berada di folder `lib/`. 

```text
lib/
├── main.dart                    # Titik awal (entry point) aplikasi. Inisialisasi Firebase dan menjalankan GetMaterialApp.
├── app/                         # Konfigurasi level aplikasi.
│   ├── app.dart                 # Konfigurasi GetMaterialApp, tema global, dan routing awal.
│   └── routes.dart              # Konstanta dan definisi seluruh rute/navigasi halaman (GetPages).
├── core/                        # Komponen yang dapat digunakan ulang di seluruh aplikasi (Reusable resources).
│   ├── constants/               # Nilai konstan: warna (app_colors.dart), teks, dan style.
│   ├── utils/                   # Fungsi bantuan/helpers: validasi form, format tanggal.
│   └── widgets/                 # UI Komponen global: CustomButton, CustomTextField, LoadingOverlay.
├── features/                    # Fitur-fitur utama aplikasi, dipecah menjadi modul independen.
│   ├── auth/                    # Modul Autentikasi (Login, Register, OTP, Lupa Password).
│   │   ├── controllers/         # Logika bisnis: AuthController mengelola state login/register.
│   │   ├── models/              # Struktur data: UserModel.
│   │   └── screens/             # Tampilan UI autentikasi.
│   ├── student/                 # Modul khusus Siswa.
│   │   ├── controllers/         # Logika siswa: StudentController, ExamController (timer, anti-cheat).
│   │   ├── models/              # Struktur data siswa (ClassModel, AssignmentModel, SubmissionModel).
│   │   └── screens/             # Tampilan siswa (Dashboard, ExamScreen, GradeReportScreen, dll).
│   └── teacher/                 # Modul khusus Guru/Dosen.
│       ├── controllers/         # Logika guru: TeacherController, AssignmentController.
│       ├── models/              # Struktur data tambahan (QuestionModel).
│       └── screens/             # Tampilan guru (Dashboard, CreateClass, CreateAssignment, Analytics).
└── services/                    # Layanan terpusat untuk interaksi sistem eksternal/backend.
    ├── firebase_auth_service.dart # Komunikasi dengan Firebase Authentication.
    ├── firestore_service.dart     # Operasi CRUD ke Firestore Database.
    ├── notification_service.dart  # Pengaturan push notification/notifikasi lokal.
    └── export_service.dart        # Fungsi untuk export data ke PDF dan Excel.
```

- **`features/`**: Folder ini sangat penting karena setiap sub-foldernya (`auth`, `student`, `teacher`) berdiri sendiri dengan arsitektur MVC/GetX (Model, View/Screen, Controller). Hal ini membuat kode lebih terstruktur, mudah dikelola, dan menghindari konflik saat bekerja dalam tim.

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

