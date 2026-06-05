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

### 🛡️ Anti-Cheat Ujian Lanjutan
Sistem keamanan ujian untuk mencegah kecurangan siswa saat mengerjakan tugas.
- **Fullscreen mode**: Menggunakan antarmuka layar penuh.
- **Deteksi Keluar Aplikasi (App Lifecycle)**: Terdeteksi jika siswa berpindah aplikasi.
- **Deteksi Screenshot**: Sistem dapat mendeteksi percobaan screenshot layar (menggunakan `screenshot_callback`).
- **3 Strike System**: Jika siswa keluar aplikasi atau melakukan screenshot hingga 3 kali, ujian akan **otomatis dikumpulkan (auto-submit)** dengan nilai 0.
- **Auto-submit Timer**: Jika waktu habis, ujian otomatis terkirim.

### 🔔 Notifikasi Real-time (Firebase Cloud Messaging)
- Siswa mendapatkan notifikasi *push* otomatis setiap kali guru menerbitkan tugas (assignment) baru.

### 🤖 Chatbot AI Assistant
- Tersedia fitur Chatbot (pada dashboard siswa) untuk membantu menjawab pertanyaan atau memberikan panduan seputar pelajaran dan penggunaan aplikasi.

### 👨‍🏫 Monitoring Mahasiswa Bimbingan (Dosen)
- Fitur khusus dosen untuk memantau mahasiswa bimbingan skripsi (mengambil data dari database Firebase eksternal secara real-time).

### 📊 Analitik & Export Nilai (PDF/Excel)
- Guru dapat melihat grafik performa siswa dan mengekspor rekapitulasi nilai kelas ke format PDF maupun Excel.

### ⏱️ Timer Countdown Ujian
- Format MM:SS, berubah merah jika waktu tersisa < 60 detik.

### 🔐 Manajemen Profil & Ganti Password
- Fitur ganti password secara aman menggunakan re-autentikasi Firebase di halaman profil.

### 🚪 Keluar Kelas (Leave Class)
- Siswa dapat keluar dari kelas yang sudah tidak diikuti melalui halaman detail kelas.

### 🔑 Kode Kelas Unik
- Auto-generate 6 karakter bebas ambigu (O, I, 0, 1) untuk bergabung ke kelas.

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

## 👥 Cara Penggunaan

### 🎓 Siswa
1. **Pendaftaran**: Register → Verifikasi email → Login.
2. **Dashboard**: Di layar utama, siswa bisa mengakses Chatbot AI untuk bertanya.
3. **Manajemen Kelas**: Klik tombol Gabung Kelas (+), masukkan kode unik dari guru. Jika ingin keluar, tekan tombol **Leave Class** di dalam detail kelas.
4. **Mengerjakan Tugas/Ujian**:
   - Terima notifikasi saat ada tugas baru.
   - Buka tugas dan mulai kerjakan.
   - **Perhatian**: Jangan mencoba *screenshot* atau pindah aplikasi, batas peringatan adalah 3 kali sebelum nilai otomatis 0 (Anti-Cheat).
5. **Melihat Hasil**: Cek hasil ujian di Result Screen dan rekapitulasi nilai di Grade Report.
6. **Profil**: Ubah data atau ganti password melalui halaman profil.

### 👨‍🏫 Guru / Dosen
1. **Pendaftaran**: Register menggunakan NIDN → Login.
2. **Membuat Kelas**: Pada Dashboard, pilih buat kelas dan bagikan 6 karakter kode unik ke siswa.
3. **Membuat Tugas**: 
   - Masuk ke kelas, pilih "Buat Tugas".
   - Isi informasi tugas, lalu "Tambah Soal".
   - Setelah selesai, "Terbitkan" agar siswa mendapat notifikasi.
4. **Monitoring Nilai & Analitik**:
   - Lihat statistik jawaban benar/salah pada Analytics Screen.
   - Lihat daftar nilai seluruh siswa (Student Grades) dan Export ke PDF/Excel.
5. **Monitoring Mahasiswa Bimbingan**: Akses tab "Bimbingan" di menu Profil untuk memantau status pengerjaan skripsi mahasiswa bimbingan secara real-time.
6. **Profil**: Kelola akun dan ganti kata sandi.

---

*EduTask — Belajar Lebih Terstruktur* 🎓

---

## 📱 Implementasi Google AdMob

### 📖 Penjelasan Lengkap AdMob

Aplikasi ini menggunakan **Google AdMob** untuk menampilkan iklan dan menghasilkan revenue. Ada dua jenis iklan yang diimplementasikan:

1. **Banner Ad** - Iklan banner yang ditampilkan di bagian bawah Dashboard Siswa
2. **Rewarded Ad** - Iklan video yang harus ditonton untuk membuka fitur ekspor (PDF/Excel)

---

### 🎯 Dimana Kode AdMob Bekerja?

#### 1. **Banner Ad (Iklan Banner)**
**Lokasi**: `lib/features/student/screens/student_dashboard_screen.dart`

**Cara Kerja**:
- Banner Ad dimuat saat halaman dashboard siswa dibuka (`initState`)
- Ditampilkan di bagian bawah layar menggunakan `bottomNavigationBar`
- Otomatis reload jika gagal

**Kode Penting**:
```dart
// Inisialisasi Banner Ad
BannerAd? _bannerAd;
bool _isAdLoaded = false;
final String _adUnitId = 'ca-app-pub-3940256099942544/9214589741'; // ID Test

// Load iklan saat screen dibuka
@override
void initState() {
  super.initState();
  _loadAd();
}

// Fungsi untuk load banner
void _loadAd() {
  _bannerAd = BannerAd(
    adUnitId: _adUnitId,
    size: AdSize.banner,
    request: const AdRequest(),
    listener: BannerAdListener(
      onAdLoaded: (ad) {
        setState(() => _isAdLoaded = true);
      },
      onAdFailedToLoad: (ad, error) {
        ad.dispose();
      },
    ),
  )..load();
}

// Tampilkan di bottomNavigationBar
bottomNavigationBar: _isAdLoaded && _bannerAd != null
    ? SafeArea(
        child: Container(
          width: double.infinity,
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      )
    : null,
```

---

#### 2. **Rewarded Ad (Iklan Video Reward)**
**Lokasi**: `lib/services/rewarded_ad_service.dart`

**Cara Kerja**:
- Service singleton yang dapat dipanggil dari mana saja
- Menampilkan dialog konfirmasi sebelum menampilkan iklan
- Iklan video harus ditonton hingga selesai
- Setelah selesai, callback `onRewardEarned` akan dijalankan (untuk ekspor file)
- Otomatis reload iklan baru setelah selesai

**Kode Penting**:
```dart
// Singleton service
class RewardedAdService {
  static final RewardedAdService _instance = RewardedAdService._internal();
  factory RewardedAdService() => _instance;
  
  RewardedAd? _rewardedAd;
  
  // Load rewarded ad
  void loadAd() {
    final String adUnitId = Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/5224354917'  // Test ID Android
        : 'ca-app-pub-3940256099942544/1712485313'; // Test ID iOS
    
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
        },
      ),
    );
  }
  
  // Tampilkan dialog konfirmasi + iklan
  void showAdConfirmationDialog({
    required VoidCallback onRewardEarned,
  }) {
    // Dialog konfirmasi
    Get.dialog(...);
    
    // Setelah konfirmasi, tampilkan iklan
    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        onRewardEarned(); // Panggil fungsi ekspor
      },
    );
  }
}
```

**Contoh Penggunaan** (di Student Grades Screen):
```dart
// Inisialisasi service di initState
final rewardedAdService = RewardedAdService();
rewardedAdService.loadAd();

// Panggil saat button ekspor ditekan
rewardedAdService.showAdConfirmationDialog(
  onRewardEarned: () {
    // Fungsi ekspor PDF/Excel dijalankan setelah iklan selesai
    ExportService.exportGradesToPDF(...);
  },
);
```

---

### 🔧 Setup AdMob di Proyek

#### 1. **Konfigurasi AndroidManifest.xml**
**Lokasi**: `android/app/src/main/AndroidManifest.xml`

Tambahkan App ID AdMob di dalam tag `<application>`:
```xml
<application ...>
    <!-- AdMob App ID -->
    <meta-data
        android:name="com.google.android.gms.ads.APPLICATION_ID"
        android:value="ca-app-pub-3940256099942544~3347511713"/>
    ...
</application>
```

⚠️ **PENTING**: `ca-app-pub-3940256099942544~3347511713` adalah **ID TEST** dari Google.

---

#### 2. **Dependency di pubspec.yaml**
**Lokasi**: `pubspec.yaml`

Pastikan package `google_mobile_ads` sudah ditambahkan:
```yaml
dependencies:
  google_mobile_ads: ^8.0.0
```

Jalankan:
```bash
flutter pub get
```

---

#### 3. **Inisialisasi AdMob di main.dart**
**Lokasi**: `lib/main.dart`

Tambahkan inisialisasi sebelum `runApp()`:
```dart
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi AdMob
  await MobileAds.instance.initialize();
  
  await Firebase.initializeApp(...);
  runApp(MyApp());
}
```

---

### 🆔 Cara Mendapatkan Kode "ca-app-pub-..." yang Asli

Saat ini, aplikasi menggunakan **Ad Unit ID Test** dari Google. Untuk produksi (rilis), Anda harus mengganti dengan **ID asli** dari akun AdMob Anda.

#### **Langkah-langkah Lengkap**:

#### **Langkah 1: Buat Akun Google AdMob**
1. Buka [https://admob.google.com](https://admob.google.com)
2. Login dengan akun Google Anda
3. Klik **"Get Started"** atau **"Mulai"**
4. Setujui Terms of Service
5. Pilih negara dan timezone
6. Klik **"Continue to AdMob"**

---

#### **Langkah 2: Tambahkan Aplikasi Baru**
1. Di dashboard AdMob, klik **"Apps"** di sidebar
2. Klik **"Add App"** atau **"Tambah Aplikasi"**
3. Pilih **"No"** (karena aplikasi belum di Play Store/App Store)
4. Pilih platform: **Android** atau **iOS**
5. Masukkan nama aplikasi: **"Trimbo"** atau **"EduTask"**
6. Centang checkbox persetujuan
7. Klik **"Add"** atau **"Tambah"**

---

#### **Langkah 3: Dapatkan App ID**
Setelah aplikasi ditambahkan, Anda akan mendapatkan:
```
App ID: ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY
```

**Format**:
- `ca-app-pub-` = prefix tetap
- `XXXXXXXXXXXXXXXX` = ID unik akun AdMob Anda (16 digit angka)
- `~YYYYYYYYYY` = ID unik aplikasi Anda (10 digit angka)

**Contoh**:
```
ca-app-pub-1234567890123456~9876543210
```

⚠️ **PENTING**: Simpan App ID ini, Anda akan menggunakannya di `AndroidManifest.xml`

---

#### **Langkah 4: Buat Ad Unit (Unit Iklan)**
Setelah aplikasi dibuat, Anda perlu membuat **Ad Unit** untuk setiap jenis iklan:

##### **A. Banner Ad Unit**
1. Masuk ke aplikasi yang baru dibuat
2. Klik **"Ad units"** tab
3. Klik **"Add Ad Unit"** atau **"Tambah Unit Iklan"**
4. Pilih format: **"Banner"**
5. Beri nama: **"Student Dashboard Banner"**
6. Klik **"Create Ad Unit"** atau **"Buat Unit Iklan"**
7. **Salin Ad Unit ID yang muncul**:
   ```
   ca-app-pub-XXXXXXXXXXXXXXXX/1111111111
   ```

##### **B. Rewarded Ad Unit**
1. Klik **"Add Ad Unit"** lagi
2. Pilih format: **"Rewarded"** atau **"Iklan Berhadiah"**
3. Beri nama: **"Export Grades Reward"**
4. Klik **"Create Ad Unit"**
5. **Salin Ad Unit ID yang muncul**:
   ```
   ca-app-pub-XXXXXXXXXXXXXXXX/2222222222
   ```

---

### 🔄 Cara Mengganti ID Test dengan ID Asli

Setelah mendapatkan ID asli dari AdMob, ganti di 3 tempat:

#### **1. AndroidManifest.xml** (App ID)
**File**: `android/app/src/main/AndroidManifest.xml`

**Ganti**:
```xml
<!-- SEBELUM (Test ID) -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-3940256099942544~3347511713"/>
```

**Menjadi**:
```xml
<!-- SESUDAH (ID Asli Anda) -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
```

---

#### **2. student_dashboard_screen.dart** (Banner Ad Unit ID)
**File**: `lib/features/student/screens/student_dashboard_screen.dart`

**Cari baris ini** (sekitar baris 26):
```dart
final String _adUnitId = 'ca-app-pub-3940256099942544/9214589741';
```

**Ganti dengan Banner Ad Unit ID Anda**:
```dart
final String _adUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/1111111111';
```

---

#### **3. rewarded_ad_service.dart** (Rewarded Ad Unit ID)
**File**: `lib/services/rewarded_ad_service.dart`

**Cari baris ini** (sekitar baris 19-21):
```dart
final String adUnitId = Platform.isAndroid
    ? 'ca-app-pub-3940256099942544/5224354917'
    : 'ca-app-pub-3940256099942544/1712485313';
```

**Ganti dengan Rewarded Ad Unit ID Anda**:
```dart
final String adUnitId = Platform.isAndroid
    ? 'ca-app-pub-XXXXXXXXXXXXXXXX/2222222222'  // Android Rewarded
    : 'ca-app-pub-XXXXXXXXXXXXXXXX/3333333333'; // iOS Rewarded (jika ada)
```

---

### 📊 ID Test vs ID Asli

| Tipe | ID Test (Sampel) | ID Asli (Produksi) |
|------|------------------|-------------------|
| **App ID** | `ca-app-pub-3940256099942544~3347511713` | `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY` |
| **Banner Android** | `ca-app-pub-3940256099942544/9214589741` | `ca-app-pub-XXXXXXXXXXXXXXXX/1111111111` |
| **Rewarded Android** | `ca-app-pub-3940256099942544/5224354917` | `ca-app-pub-XXXXXXXXXXXXXXXX/2222222222` |
| **Rewarded iOS** | `ca-app-pub-3940256099942544/1712485313` | `ca-app-pub-XXXXXXXXXXXXXXXX/3333333333` |

---

### ⚠️ Penting untuk Diketahui

1. **Test ID hanya untuk Development**
   - Gunakan Test ID saat development dan testing
   - ❌ JANGAN gunakan Test ID di aplikasi yang sudah rilis ke Play Store/App Store
   - ✅ Ganti dengan ID asli sebelum build production/release

2. **Kebijakan Google AdMob**
   - ❌ JANGAN klik iklan Anda sendiri (bisa banned)
   - ❌ JANGAN minta user untuk klik iklan
   - ✅ Gunakan Test Ads saat development
   - ✅ Ikuti [AdMob Policies](https://support.google.com/admob/answer/6128543)

3. **Revenue/Pendapatan**
   - Iklan Test **TIDAK menghasilkan uang**
   - Hanya ID asli yang bisa menghasilkan revenue
   - Payment threshold: $100 (akan dibayar saat mencapai $100)

4. **Iklan Tidak Muncul?**
   - Pastikan internet aktif
   - Pastikan App ID dan Ad Unit ID sudah benar
   - AdMob butuh waktu 24-48 jam untuk aktivasi akun baru
   - Cek log error dengan: `flutter run --verbose`

---

### 🧪 Testing AdMob

#### **Test dengan Test ID (Recommended saat Development)**
```dart
// Banner Test ID
'ca-app-pub-3940256099942544/9214589741'

// Rewarded Test ID
'ca-app-pub-3940256099942544/5224354917'
```

#### **Test dengan ID Asli**
1. Tambahkan device testing Anda di AdMob Console:
   - Buka **Settings** > **Test Devices**
   - Tambah device ID Anda
2. Atau gunakan Test Ads mode:
   ```dart
   final adRequest = AdRequest(
     testDevices: ['YOUR_DEVICE_ID'], // Device ID dari log
   );
   ```

---

### 📝 Checklist Sebelum Rilis

- [ ] Buat akun Google AdMob
- [ ] Tambahkan aplikasi di AdMob Console
- [ ] Dapatkan App ID (`ca-app-pub-...~...`)
- [ ] Buat Banner Ad Unit dan dapatkan ID-nya
- [ ] Buat Rewarded Ad Unit dan dapatkan ID-nya
- [ ] Ganti App ID di `AndroidManifest.xml`
- [ ] Ganti Banner Ad Unit ID di `student_dashboard_screen.dart`
- [ ] Ganti Rewarded Ad Unit ID di `rewarded_ad_service.dart`
- [ ] Test iklan berfungsi dengan baik
- [ ] Pastikan tidak ada Test ID yang tersisa
- [ ] Build APK/AAB untuk production

---

### 🔗 Referensi & Resource

- [Google AdMob Official](https://admob.google.com)
- [AdMob Flutter Plugin Docs](https://pub.dev/packages/google_mobile_ads)
- [AdMob Policies](https://support.google.com/admob/answer/6128543)
- [Test Ads Documentation](https://developers.google.com/admob/android/test-ads)
- [AdMob Help Center](https://support.google.com/admob)

---

## 🔐 File Penting: ADMOB_IDs.md

File `ADMOB_IDs.md` berisi **ID AdMob Production** Anda yang asli. File ini:
- ✅ Sudah ditambahkan ke `.gitignore` (tidak akan ter-commit ke Git)
- ✅ Berisi ID Test dan Production untuk referensi
- ✅ Berisi panduan migrasi dari Test → Production
- ⚠️ **JANGAN share file ini ke publik**

**Saat ini aplikasi menggunakan Test ID** (aman untuk development).  
**Untuk rilis production**, ikuti panduan di file `ADMOB_IDs.md`.

---

*EduTask — Belajar Lebih Terstruktur* 🎓

