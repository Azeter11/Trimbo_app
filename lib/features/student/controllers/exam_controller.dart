// exam_controller.dart
// Controller untuk logika ujian siswa.
// Fitur UTAMA: timer countdown, anti-cheat (deteksi keluar layar), auto-submit.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/assignment_model.dart';
import '../models/submission_model.dart';
import '../../auth/models/user_model.dart';
import '../../teacher/models/question_model.dart';
import '../../../services/firestore_service.dart';
import '../../../core/utils/helpers.dart';
import '../../../app/routes.dart';
import 'student_controller.dart';

class ExamController extends GetxController with WidgetsBindingObserver {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  // ========================
  // DATA UJIAN
  // ========================

  /// Tugas yang sedang dikerjakan
  late AssignmentModel assignment;

  /// Data siswa yang sedang ujian
  late UserModel student;

  /// List soal yang diambil dari Firestore
  final RxList<QuestionModel> questions = <QuestionModel>[].obs;

  // ========================
  // STATE UJIAN
  // ========================

  /// Nomor soal yang sedang ditampilkan (mulai dari 0)
  final RxInt currentQuestionIndex = 0.obs;

  /// Jawaban siswa: {nomor_soal(1-based): 'A'/'B'/'C'/'D'}
  final RxMap<int, String> answers = <int, String>{}.obs;

  /// Status loading soal dari Firestore
  final RxBool isLoadingQuestions = true.obs;

  /// Status submit (setelah ujian selesai)
  final RxBool isSubmitting = false.obs;

  /// Apakah ujian sudah dimulai
  final RxBool examStarted = false.obs;

  // ========================
  // TIMER
  // ========================

  /// Sisa waktu dalam detik
  final RxInt remainingSeconds = 0.obs;

  /// Timer Dart untuk countdown
  Timer? _countdownTimer;

  // ========================
  // ANTI-CHEAT
  // ========================

  /// Jumlah kali siswa keluar dari layar ujian
  final RxInt warningCount = 0.obs;

  /// Batas maksimal keluar layar sebelum auto-submit
  static const int maxWarnings = 3;

  /// Apakah ujian di-submit otomatis (karena anti-cheat / waktu habis)
  bool _isAutoSubmitted = false;

  // ========================
  // LIFECYCLE
  // ========================

  @override
  void onInit() {
    super.onInit();
    // Daftarkan observer lifecycle untuk deteksi app ke background
    WidgetsBinding.instance.addObserver(this);

    // Ambil data dari argumen navigasi
    final args = Get.arguments as Map<String, dynamic>;
    assignment = args['assignment'] as AssignmentModel;
    student = args['student'] as UserModel;

    // Set timer sesuai durasi tugas
    remainingSeconds.value = assignment.durationMinutes * 60;

    // Ambil soal dari Firestore
    _loadQuestions();
  }

  @override
  void onClose() {
    // Bersihkan resources saat controller dihapus
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    // Kembalikan UI system normal (non-fullscreen)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.onClose();
  }

  // ========================
  // DETEKSI ANTI-CHEAT
  // ========================

  /// Dipanggil otomatis oleh Flutter saat status lifecycle app berubah.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Hanya pantau saat ujian sudah dimulai
    if (!examStarted.value) return;

    // Deteksi saat app ke background atau pause
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _handleCheatingAttempt();
    }
  }

  /// Handle saat siswa ketahuan keluar dari layar ujian.
  void _handleCheatingAttempt() {
    // Jangan proses jika ujian sudah di-submit / sudah dieliminasi
    if (_isAutoSubmitted || isSubmitting.value) return;

    warningCount.value++;

    if (warningCount.value >= maxWarnings) {
      // Sudah 3x keluar → auto-submit langsung (tanpa tunggu input user)
      _autoSubmitDueToCheat();
    } else {
      // Tampilkan dialog peringatan
      _showWarningDialog();
    }
  }

  /// Tampilkan dialog peringatan anti-cheat.
  void _showWarningDialog() {
    Get.dialog(
      WillPopScope(
        // Mencegah dialog ditutup dengan tombol back
        onWillPop: () async => false,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('⚠️ Peringatan!'),
          content: Text(
            'Anda keluar dari layar ujian.\n'
            'Waktu tetap berjalan.\n\n'
            'Peringatan ke-${warningCount.value} dari $maxWarnings.\n'
            'Keluar ${maxWarnings - warningCount.value}x lagi akan otomatis mengumpulkan jawaban.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Get.back(); // Tutup dialog
                // Aktifkan kembali fullscreen mode
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
              },
              child: const Text('Mengerti, Kembali Ujian'),
            ),
          ],
        ),
      ),
      barrierDismissible: false, // Tidak bisa ditutup dengan tap di luar
    );
  }

  // ========================
  // MULAI UJIAN
  // ========================

  /// Mulai ujian: aktifkan fullscreen + timer.
  void startExam() {
    examStarted.value = true;

    // Aktifkan mode fullscreen (sembunyikan status bar dan navigation bar)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // Mulai countdown timer
    _startCountdown();
  }

  // ========================
  // COUNTDOWN TIMER
  // ========================

  /// Mulai timer countdown.
  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value <= 0) {
        // Waktu habis → auto submit
        timer.cancel();
        _autoSubmitDueToTimeout();
      } else {
        remainingSeconds.value--;
      }
    });
  }

  /// Cek apakah waktu kurang dari 1 menit (untuk ubah warna timer ke merah).
  bool get isTimerWarning => remainingSeconds.value < 60;

  /// Format sisa waktu untuk ditampilkan: "MM:SS"
  String get formattedTime => Helpers.formatCountdown(remainingSeconds.value);

  // ========================
  // NAVIGASI SOAL
  // ========================

  /// Pindah ke soal berikutnya.
  void nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
    }
  }

  /// Kembali ke soal sebelumnya.
  void previousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
    }
  }

  /// Loncat ke soal tertentu (dari dot indicator).
  void goToQuestion(int index) {
    currentQuestionIndex.value = index;
  }

  // ========================
  // JAWABAN
  // ========================

  /// Simpan jawaban siswa untuk soal tertentu.
  void selectAnswer(int questionNumber, String answer) {
    answers[questionNumber] = answer;
  }

  /// Cek apakah soal sudah dijawab.
  bool isAnswered(int questionNumber) {
    return answers.containsKey(questionNumber) &&
        answers[questionNumber]!.isNotEmpty;
  }

  /// Ambil jawaban yang dipilih untuk soal tertentu (null jika belum dijawab).
  String? getSelectedAnswer(int questionNumber) => answers[questionNumber];

  /// Hitung jumlah soal yang belum dijawab.
  int get unansweredCount {
    int answered = 0;
    for (int i = 1; i <= questions.length; i++) {
      if (isAnswered(i)) answered++;
    }
    return questions.length - answered;
  }

  // ========================
  // SUBMIT UJIAN
  // ========================

  /// Tampilkan dialog konfirmasi sebelum submit manual.
  void showSubmitConfirmation() {
    final unanswered = unansweredCount;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Kumpulkan Jawaban?'),
        content: Text(
          unanswered > 0
              ? 'Masih ada $unanswered soal belum dijawab.\nYakin ingin mengumpulkan?'
              : 'Semua soal sudah dijawab.\nYakin ingin mengumpulkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              submitExam(isAuto: false);
            },
            child: const Text('Ya, Kumpulkan'),
          ),
        ],
      ),
    );
  }

  /// Submit ujian (manual atau otomatis).
  Future<void> submitExam({required bool isAuto}) async {
    // Cegah submit ganda
    if (isSubmitting.value) return;
    isSubmitting.value = true;

    // Hentikan timer
    _countdownTimer?.cancel();

    // Kembalikan UI system normal
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    try {
      final error = await _firestoreService.submitAnswers(
        assignmentId: assignment.id,
        assignmentTitle: assignment.title,
        studentId: student.uid,
        studentName: student.fullName,
        answers: Map<int, String>.from(answers),
        questions: questions,
        warningCount: warningCount.value,
        isAutoSubmitted: isAuto,
      );

      if (error != null) {
        Get.snackbar('Error', error);
        isSubmitting.value = false;
        return;
      }

      // Refresh data dashboard siswa agar status tugas terupdate
      if (Get.isRegistered<StudentController>()) {
        await Get.find<StudentController>().loadDashboardData();
      }

      // Hitung hasil untuk ditampilkan di result screen
      int correct = 0;
      for (int i = 0; i < questions.length; i++) {
        final questionNumber = i + 1;
        final studentAnswer = answers[questionNumber];
        if (studentAnswer != null && questions[i].isCorrect(studentAnswer)) {
          correct++;
        }
      }

      final score = Helpers.calculateScore(correct, questions.length);

      // Arahkan ke halaman hasil
      Get.offNamed(
        AppRoutes.result,
        arguments: {
          'score': score,
          'correct': correct,
          'wrong': questions.length - correct - unansweredCount,
          'skipped': unansweredCount,
          'totalQuestions': questions.length,
          'assignmentTitle': assignment.title,
        },
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Auto-submit karena waktu habis.
  void _autoSubmitDueToTimeout() {
    if (isSubmitting.value) return;
    _isAutoSubmitted = true;

    Get.snackbar(
      'Waktu Habis!',
      'Jawaban dikumpulkan otomatis',
      backgroundColor: const Color(0xFFEF4444),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );

    Future.delayed(const Duration(seconds: 2), () {
      submitExam(isAuto: true);
    });
  }

  /// Auto-submit karena terlalu banyak keluar layar.
  /// Langsung submit TANPA menunggu interaksi user agar tidak bisa dikerjakan lagi.
  void _autoSubmitDueToCheat() {
    if (_isAutoSubmitted || isSubmitting.value) return;
    _isAutoSubmitted = true;

    // Hentikan timer segera
    _countdownTimer?.cancel();

    // Kembalikan UI system normal
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Tutup dialog peringatan yang mungkin masih terbuka
    if (Get.isDialogOpen ?? false) Get.back();

    // Tampilkan snackbar eliminasi
    Get.snackbar(
      '❌ Ujian Dihentikan',
      'Anda telah keluar layar 3x. Nilai otomatis 0.',
      backgroundColor: const Color(0xFFEF4444),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
    );

    // Submit dengan nilai 0 (jawaban dikosongkan agar hitungan skor = 0)
    Future.delayed(const Duration(milliseconds: 500), () async {
      if (isSubmitting.value) return;
      isSubmitting.value = true;

      try {
        // Kirim submission ke Firestore dengan skor paksa 0
        await _firestoreService.submitAnswers(
          assignmentId: assignment.id,
          assignmentTitle: assignment.title,
          studentId: student.uid,
          studentName: student.fullName,
          answers: const {}, // kosongkan jawaban → skor 0
          questions: questions,
          warningCount: warningCount.value,
          isAutoSubmitted: true,
        );

        // Refresh data dashboard siswa agar status tugas terupdate
        if (Get.isRegistered<StudentController>()) {
          await Get.find<StudentController>().loadDashboardData();
        }
      } catch (_) {
        // Tetap navigasi keluar meski error Firestore
      } finally {
        isSubmitting.value = false;
      }

      // Navigasi ke result screen dengan nilai 0
      // Gunakan offAllNamed agar tidak bisa back ke screen soal
      Get.offAllNamed(
        AppRoutes.result,
        arguments: {
          'score': 0.0,
          'correct': 0,
          'wrong': questions.length,
          'skipped': questions.length,
          'totalQuestions': questions.length,
          'assignmentTitle': assignment.title,
          'isEliminatedByCheat': true,
        },
      );
    });
  }

  // ========================
  // LOAD DATA
  // ========================

  /// Ambil soal dari Firestore.
  Future<void> _loadQuestions() async {
    isLoadingQuestions.value = true;
    try {
      final loadedQuestions = await _firestoreService.getAssignmentQuestions(
        assignment.id,
      );
      // Mengacak urutan soal untuk setiap user
      loadedQuestions.shuffle();
      questions.assignAll(loadedQuestions);
    } finally {
      isLoadingQuestions.value = false;
    }
  }
}
