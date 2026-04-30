// app_strings.dart
// File ini berisi semua teks, label, dan pesan yang digunakan di aplikasi.
// Tujuan: mudah diganti untuk multi-bahasa atau perubahan teks tanpa cari di banyak file.

class AppStrings {
  // Konstruktor private
  AppStrings._();

  // ========================
  // NAMA APLIKASI
  // ========================
  static const String appName = 'Trimbo';
  static const String appTagline = 'Belajar Lebih Terstruktur';

  // ========================
  // HALAMAN SPLASH
  // ========================
  static const String splashLoading = 'Memuat...';

  // ========================
  // HALAMAN LOGIN
  // ========================
  static const String loginTitle = 'Selamat Datang!';
  static const String loginSubtitle = 'Masuk untuk melanjutkan belajar';
  static const String loginEmail = 'Email';
  static const String loginEmailHint = 'contoh@email.com';
  static const String loginPassword = 'Kata Sandi';
  static const String loginPasswordHint = 'Masukkan kata sandi';
  static const String loginButton = 'Masuk';
  static const String loginNoAccount = 'Belum punya akun? ';
  static const String loginRegisterLink = 'Daftar';
  static const String loginForgotPassword = 'Lupa Kata Sandi?';

  // ========================
  // HALAMAN REGISTER
  // ========================
  static const String registerTitle = 'Buat Akun Baru';
  static const String registerSubtitle = 'Pilih peran Anda';
  static const String registerAsStudent = 'Saya Siswa';
  static const String registerAsTeacher = 'Saya Guru';
  static const String registerFullName = 'Nama Lengkap';
  static const String registerFullNameHint = 'Masukkan nama lengkap';
  static const String registerNUPTK = 'NUPTK';
  static const String registerNUPTKHint = 'Nomor Unik Pendidik & Tenaga Kependidikan';
  static const String registerInstitution = 'Tempat Mengajar';
  static const String registerInstitutionHint = 'Nama instansi/sekolah';
  static const String registerEmail = 'Email';
  static const String registerEmailHint = 'Masukkan alamat email';
  static const String registerPassword = 'Kata Sandi';
  static const String registerPasswordHint = 'Minimal 8 karakter';
  static const String registerConfirmPassword = 'Konfirmasi Kata Sandi';
  static const String registerConfirmPasswordHint = 'Ulangi kata sandi';
  static const String registerButton = 'Daftar Sekarang';
  static const String registerHaveAccount = 'Sudah punya akun? ';
  static const String registerLoginLink = 'Masuk';

  // ========================
  // HALAMAN VERIFIKASI EMAIL (PENGGANTI OTP)
  // ========================
  static const String verificationTitle = 'Verifikasi Email';
  static const String verificationSubtitle = 'Link akses telah dikirim ke email';
  static const String verificationWaitMessage = 'Silakan periksa kotak masuk atau folder spam Anda dan klik link yang dikirimkan untuk menyelesaikan registrasi.';
  static const String verificationSuccessTitle = 'Registrasi Berhasil!';
  static const String verificationSuccessSubtitle = 'Akun Anda telah aktif. Silakan masuk untuk melanjutkan.';
  static const String verificationCheckStatus = 'Mengecek status verifikasi...';
  static const String verificationResend = 'Kirim Ulang Link Verifikasi';

  // ========================
  // HALAMAN LUPA PASSWORD
  // ========================
  static const String forgotPasswordTitle = 'Lupa Kata Sandi?';
  static const String forgotPasswordStep1Subtitle = 'Masukkan email Anda untuk mendapatkan link reset kata sandi';
  static const String forgotPasswordStep2Subtitle = 'Link reset password telah dikirim ke email Anda';
  static const String forgotPasswordStep3Subtitle = 'Buat kata sandi baru yang kuat';
  static const String forgotPasswordSendLink = 'Kirim Link Reset';
  static const String forgotPasswordVerify = 'Sudah Reset? Masuk';
  static const String forgotPasswordNewPassword = 'Kata Sandi Baru';
  static const String forgotPasswordConfirmNew = 'Konfirmasi Kata Sandi Baru';
  static const String forgotPasswordReset = 'Reset Kata Sandi';

  // ========================
  // DASHBOARD SISWA
  // ========================
  static const String studentDashboardGreeting = 'Selamat datang,';
  static const String studentDashboardSubtitle = 'Apa yang ingin kamu pelajari hari ini?';
  static const String myClasses = 'Kelas Saya';
  static const String myAssignments = 'Tugas';
  static const String myGrades = 'Nilai';
  static const String upcomingDeadlines = 'Deadline Mendekat';
  static const String noUpcomingDeadlines = 'Tidak ada deadline dalam 3 hari ke depan';

  // ========================
  // BERGABUNG KELAS
  // ========================
  static const String joinClassTitle = 'Gabung Kelas';
  static const String joinClassSubtitle = 'Masukkan kode kelas dari guru Anda';
  static const String classCodeLabel = 'Kode Kelas';
  static const String classCodeHint = 'Contoh: ABC123';
  static const String joinClassButton = 'Gabung Kelas';
  static const String joinClassSuccess = 'Berhasil bergabung ke kelas!';
  static const String joinClassInvalid = 'Kode kelas tidak valid atau tidak ditemukan';
  static const String joinClassAlready = 'Anda sudah terdaftar di kelas ini';

  // ========================
  // DETAIL KELAS
  // ========================
  static const String classDetailAssignments = 'Daftar Tugas';
  static const String classDetailInfo = 'Informasi Kelas';
  static const String classCode = 'Kode Kelas';
  static const String classCreatedBy = 'Dibuat oleh';
  static const String classTotalStudents = 'Total Siswa';

  // ========================
  // TUGAS & STATUS
  // ========================
  static const String assignmentDeadline = 'Deadline';
  static const String assignmentDuration = 'Durasi';
  static const String assignmentQuestions = 'Soal';
  static const String assignmentNotStarted = 'Belum Dikerjakan';
  static const String assignmentCompleted = 'Sudah Dikerjakan';
  static const String assignmentExpired = 'Waktu Habis';
  static const String assignmentMinutes = ' menit';

  // ========================
  // UJIAN (EXAM SCREEN)
  // ========================
  static const String examPrepTitle = 'Persiapan Ujian';
  static const String examInstructions = 'Instruksi Ujian';
  static const String examInstructionList =
      '1. Pastikan koneksi internet stabil\n'
      '2. Jangan keluar dari aplikasi saat ujian\n'
      '3. Waktu akan terus berjalan\n'
      '4. Keluar 3x akan otomatis mengumpulkan\n'
      '5. Jawaban tersimpan otomatis';
  static const String examStartButton = 'Mulai Ujian';
  static const String examQuestion = 'Pertanyaan';
  static const String examOf = ' dari ';
  static const String examPrev = 'Sebelumnya';
  static const String examNext = 'Berikutnya';
  static const String examFinish = 'Selesai';
  static const String examSubmitEarly = 'Kumpulkan Sekarang';

  // Dialog konfirmasi selesai
  static const String examConfirmTitle = 'Kumpulkan Jawaban?';
  static const String examConfirmMessage = 'Yakin ingin mengumpulkan?';
  static const String examUnanswered = ' soal belum dijawab.';
  static const String examCancel = 'Batal';
  static const String examSubmit = 'Ya, Kumpulkan';

  // Peringatan anti-cheating
  static const String examWarningTitle = '⚠️ Peringatan!';
  static const String examWarningMessage =
      'Anda keluar dari layar ujian.\n'
      'Waktu tetap berjalan.\n'
      'Keluar sebanyak 3x akan otomatis mengumpulkan jawaban.';
  static const String examWarningCount = 'Peringatan ke-';
  static const String examWarningOf = ' dari 3';
  static const String examWarningOk = 'Mengerti, Kembali Ujian';

  // Auto submit
  static const String examTimeUp = 'Waktu Habis!';
  static const String examAutoSubmit = 'Jawaban dikumpulkan otomatis';

  // ========================
  // HASIL UJIAN (RESULT)
  // ========================
  static const String resultTitle = 'Hasil Ujian';
  static const String resultScore = 'Nilai Anda';
  static const String resultCorrect = 'Benar';
  static const String resultWrong = 'Salah';
  static const String resultSkipped = 'Tidak Dijawab';
  static const String resultReview = 'Lihat Pembahasan';
  static const String resultBackToClass = 'Kembali ke Kelas';

  // ========================
  // LAPORAN NILAI
  // ========================
  static const String gradeReportTitle = 'Laporan Nilai';
  static const String gradeAverage = 'Rata-rata Nilai';
  static const String gradeCompleted = 'Tugas Selesai';
  static const String gradeExportPDF = 'Export PDF';
  static const String gradeExportExcel = 'Export Excel';

  // ========================
  // PROFIL
  // ========================
  static const String profileTitle = 'Profil';
  static const String profileName = 'Nama Lengkap';
  static const String profileEmail = 'Email';
  static const String profileRole = 'Peran';
  static const String profileRoleStudent = 'Siswa';
  static const String profileRoleTeacher = 'Guru';
  static const String profileNUPTK = 'NUPTK';
  static const String profileInstitution = 'Institusi';
  static const String profileGuide = 'Panduan Penggunaan';
  static const String profileGuideJoinClass = 'Cara Bergabung Kelas';
  static const String profileGuideDoAssignment = 'Cara Mengerjakan Tugas';
  static const String profileGuideViewGrades = 'Cara Melihat Nilai';
  static const String profileChangePassword = 'Ganti Kata Sandi';
  static const String profileLogout = 'Keluar';
  static const String profileLogoutConfirmTitle = 'Keluar dari Aplikasi?';
  static const String profileLogoutConfirmMessage = 'Anda akan keluar dari akun ini.';
  static const String profileLogoutConfirmYes = 'Ya, Keluar';

  // ========================
  // DASHBOARD GURU
  // ========================
  static const String teacherDashboardGreeting = 'Halo,';
  static const String teacherDashboardSubtitle = 'Kelola kelas dan tugas Anda';
  static const String totalClasses = 'Kelas';
  static const String totalStudents = 'Siswa';
  static const String activeAssignments = 'Tugas Aktif';
  static const String recentClasses = 'Kelas Terbaru';
  static const String viewAll = 'Lihat Semua';
  static const String createNewClass = 'Buat Kelas Baru';

  // ========================
  // BUAT KELAS
  // ========================
  static const String createClassTitle = 'Buat Kelas Baru';
  static const String createClassName = 'Nama Kelas';
  static const String createClassNameHint = 'Contoh: Matematika XI A';
  static const String createClassDescription = 'Deskripsi';
  static const String createClassDescriptionHint = 'Deskripsi singkat kelas';
  static const String createClassButton = 'Buat Kelas';
  static const String createClassSuccessTitle = 'Kelas Berhasil Dibuat!';
  static const String createClassCodeLabel = 'Kode Kelas:';
  static const String createClassCopyCode = 'Salin Kode';
  static const String createClassCodeCopied = 'Kode disalin!';

  // ========================
  // MANAJEMEN KELAS (GURU)
  // ========================
  static const String classManagementAssignments = 'Daftar Tugas';
  static const String classManagementStudents = 'Daftar Siswa';
  static const String createNewAssignment = 'Buat Tugas Baru';
  static const String noStudentsYet = 'Belum ada siswa yang bergabung';
  static const String noAssignmentsYet = 'Belum ada tugas dibuat';
  static const String submissions = 'pengumpulan';

  // ========================
  // BUAT TUGAS
  // ========================
  static const String createAssignmentTitle = 'Buat Tugas';
  static const String assignmentTitle = 'Judul Tugas';
  static const String assignmentTitleHint = 'Contoh: UTS Bab 1-3';
  static const String assignmentDescription = 'Deskripsi Tugas';
  static const String assignmentDescriptionHint = 'Jelaskan materi yang diujikan';
  static const String assignmentDeadlineLabel = 'Batas Waktu Pengumpulan';
  static const String assignmentDurationLabel = 'Durasi Ujian (menit)';
  static const String assignmentNextButton = 'Lanjut Buat Soal';
  static const String assignmentPublishButton = 'Selesai & Terbitkan Tugas';

  // ========================
  // BUAT SOAL
  // ========================
  static const String createQuestionTitle = 'Buat Soal';
  static const String questionText = 'Pertanyaan';
  static const String questionTextHint = 'Tuliskan pertanyaan di sini...';
  static const String optionA = 'Pilihan A';
  static const String optionB = 'Pilihan B';
  static const String optionC = 'Pilihan C';
  static const String optionD = 'Pilihan D';
  static const String correctAnswer = 'Jawaban Benar';
  static const String saveQuestion = 'Simpan Soal';
  static const String addQuestion = 'Tambah Soal';
  static const String questionsList = 'Daftar Soal';

  // ========================
  // NILAI SISWA (GURU)
  // ========================
  static const String studentGradesTitle = 'Nilai Siswa';
  static const String selectAssignment = 'Pilih Tugas';
  static const String classAverage = 'Rata-rata Kelas';
  static const String exportReport = 'Export Laporan';

  // ========================
  // ANALITIK
  // ========================
  static const String analyticsTitle = 'Analitik Kelas';
  static const String gradeDistribution = 'Distribusi Nilai';
  static const String averagePerAssignment = 'Rata-rata per Tugas';
  static const String activeStudents = 'Siswa Aktif';
  static const String inactiveStudents = 'Siswa Tidak Aktif';

  // ========================
  // NOTIFIKASI
  // ========================
  static const String notifNewAssignment = '📚 Tugas Baru!';
  static const String notifDeadlineTomorrow = '⏰ Deadline Besok!';
  static const String notifNewAssignmentBody = 'telah ditambahkan';
  static const String notifDeadlineBody = 'Segera kerjakan';

  // ========================
  // PESAN ERROR UMUM
  // ========================
  static const String errorGeneral = 'Terjadi kesalahan. Silakan coba lagi.';
  static const String errorNoInternet = 'Tidak ada koneksi internet. Periksa pengaturan jaringan Anda.';
  static const String errorInvalidEmail = 'Format email tidak valid';
  static const String errorPasswordTooShort = 'Kata sandi minimal 8 karakter';
  static const String errorPasswordNotMatch = 'Kata sandi tidak cocok';
  static const String errorFieldRequired = 'Kolom ini wajib diisi';
  static const String errorInvalidCredentials = 'Email atau kata sandi salah';
  static const String errorEmailAlreadyUsed = 'Email sudah terdaftar';
  static const String errorUserNotFound = 'Akun tidak ditemukan';
  static const String errorWeakPassword = 'Kata sandi terlalu lemah';

  // ========================
  // TOMBOL UMUM
  // ========================
  static const String buttonOk = 'OK';
  static const String buttonCancel = 'Batal';
  static const String buttonSave = 'Simpan';
  static const String buttonDelete = 'Hapus';
  static const String buttonEdit = 'Edit';
  static const String buttonClose = 'Tutup';
  static const String buttonRetry = 'Coba Lagi';
  static const String buttonContinue = 'Lanjutkan';
  static const String buttonBack = 'Kembali';
  static const String loading = 'Memuat...';
  static const String noData = 'Tidak ada data';

  // ========================
  // PANDUAN PENGGUNAAN
  // ========================
  static const String guideJoinClassContent =
      '1. Klik tombol "+" di halaman utama\n'
      '2. Pilih "Gabung Kelas"\n'
      '3. Masukkan kode kelas dari guru\n'
      '4. Tekan "Gabung Kelas"';

  static const String guideDoAssignmentContent =
      '1. Buka kelas yang ingin dikerjakan\n'
      '2. Pilih tugas yang tersedia\n'
      '3. Baca instruksi dengan teliti\n'
      '4. Tekan "Mulai Ujian"\n'
      '5. Jawab semua soal sebelum waktu habis\n'
      '6. Tekan "Selesai" untuk mengumpulkan';

  static const String guideViewGradesContent =
      '1. Buka menu "Nilai" di dashboard\n'
      '2. Pilih kelas yang ingin dilihat\n'
      '3. Lihat nilai per tugas\n'
      '4. Ekspor laporan jika diperlukan';
}
