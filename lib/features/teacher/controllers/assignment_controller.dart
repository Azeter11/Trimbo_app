// assignment_controller.dart
// Controller GetX untuk alur 2-step pembuatan tugas oleh guru:
// Step 1: Info tugas (judul, deskripsi, deadline, durasi)
// Step 2: Buat soal (pertanyaan + 4 pilihan + jawaban benar)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../student/models/assignment_model.dart';
import '../models/question_model.dart';
import '../../../services/firestore_service.dart';
import '../../../services/notification_service.dart';
import '../../../app/routes.dart';

class AssignmentController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final NotificationService _notificationService = Get.find<NotificationService>();

  // ========================
  // STATE
  // ========================

  /// Tugas yang sedang dibuat (setelah step 1 selesai)
  final Rx<AssignmentModel?> currentAssignment = Rx<AssignmentModel?>(null);

  /// List soal yang sudah dibuat
  final RxList<QuestionModel> questions = <QuestionModel>[].obs;

  /// Loading state
  final RxBool isLoading = false.obs;

  /// Step saat ini (1 = info tugas, 2 = buat soal)
  final RxInt currentStep = 1.obs;

  // ========================
  // FORM STEP 1: INFO TUGAS
  // ========================

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final GlobalKey<FormState> assignmentFormKey = GlobalKey<FormState>();

  /// Deadline yang dipilih
  final Rx<DateTime?> selectedDeadline = Rx<DateTime?>(null);

  /// Durasi ujian dalam menit (default 60 menit)
  final RxInt durationMinutes = 60.obs;

  // ========================
  // FORM STEP 2: BUAT SOAL
  // ========================

  final TextEditingController questionTextController = TextEditingController();
  final TextEditingController optionAController = TextEditingController();
  final TextEditingController optionBController = TextEditingController();
  final TextEditingController optionCController = TextEditingController();
  final TextEditingController optionDController = TextEditingController();
  final GlobalKey<FormState> questionFormKey = GlobalKey<FormState>();

  /// Jawaban benar yang dipilih ('A', 'B', 'C', atau 'D')
  final RxString selectedCorrectAnswer = 'A'.obs;

  // ========================
  // LIFECYCLE
  // ========================

  @override
  void onClose() {
    titleController.dispose();
    descController.dispose();
    questionTextController.dispose();
    optionAController.dispose();
    optionBController.dispose();
    optionCController.dispose();
    optionDController.dispose();
    super.onClose();
  }

  // ========================
  // STEP 1: SIMPAN INFO TUGAS
  // ========================

  /// Simpan info dasar tugas ke Firestore (draft, belum diterbitkan).
  Future<void> saveAssignmentInfo(String classId, String teacherId) async {
    if (!assignmentFormKey.currentState!.validate()) return;

    if (selectedDeadline.value == null) {
      Get.snackbar(
        'Oops!',
        'Pilih batas waktu pengumpulan terlebih dahulu',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final result = await _firestoreService.createAssignment(
        classId: classId,
        teacherId: teacherId,
        title: titleController.text,
        description: descController.text,
        deadline: selectedDeadline.value!,
        durationMinutes: durationMinutes.value,
      );

      if (result.error != null) {
        Get.snackbar(
          'Gagal',
          result.error!,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
        );
        return;
      }

      // Simpan assignment sementara
      currentAssignment.value = result.assignment;

      // Pindah ke step 2 (buat soal)
      Get.toNamed(AppRoutes.createQuestion, arguments: {
        'assignment': result.assignment,
      });

    } finally {
      isLoading.value = false;
    }
  }

  // ========================
  // STEP 2: TAMBAH SOAL
  // ========================

  /// Simpan soal baru ke Firestore.
  Future<void> addQuestion() async {
    if (!questionFormKey.currentState!.validate()) return;

    if (currentAssignment.value == null) return;

    isLoading.value = true;

    try {
      final orderNumber = questions.length + 1; // Nomor soal berikutnya

      final result = await _firestoreService.addQuestion(
        assignmentId: currentAssignment.value!.id,
        orderNumber: orderNumber,
        questionText: questionTextController.text,
        optionA: optionAController.text,
        optionB: optionBController.text,
        optionC: optionCController.text,
        optionD: optionDController.text,
        correctAnswer: selectedCorrectAnswer.value,
      );

      if (result.error != null) {
        Get.snackbar('Gagal', result.error!);
        return;
      }

      // Tambahkan soal ke list lokal
      questions.add(result.question!);

      // Bersihkan form soal untuk input berikutnya
      _clearQuestionForm();

      Get.snackbar(
        'Berhasil',
        'Soal nomor $orderNumber berhasil disimpan',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );

    } finally {
      isLoading.value = false;
    }
  }

  /// Hapus soal dari list (dan update nomor urut).
  Future<void> deleteQuestion(int index) async {
    // Tampilkan konfirmasi dulu
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Soal?'),
        content: Text('Soal nomor ${index + 1} akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      questions.removeAt(index);
    }
  }

  // ========================
  // TERBITKAN TUGAS
  // ========================

  /// Selesai membuat soal dan terbitkan tugas.
  Future<void> publishAssignment() async {
    if (questions.isEmpty) {
      Get.snackbar(
        'Oops!',
        'Tambahkan minimal 1 soal sebelum menerbitkan',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final error = await _firestoreService.publishAssignment(
        currentAssignment.value!.id,
        questions.length,
      );

      if (error != null) {
        Get.snackbar('Gagal', error);
        return;
      }

      // Kirim notifikasi FCM ke semua mahasiswa di kelas tersebut
      await _notificationService.sendNotificationToTopic(
        topic: 'class_${currentAssignment.value!.classId}',
        title: 'Tugas Baru: ${currentAssignment.value!.title}',
        body: 'Dosen telah menerbitkan tugas baru. Segera kerjakan sebelum deadline!',
      );

      Get.snackbar(
        'Berhasil!',
        'Tugas "${currentAssignment.value!.title}" telah diterbitkan',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );

      // Kembali ke halaman manajemen kelas
      Get.until((route) => route.settings.name == AppRoutes.classManagement);

    } finally {
      isLoading.value = false;
    }
  }

  // ========================
  // HELPER
  // ========================

  /// Bersihkan semua field form soal.
  void _clearQuestionForm() {
    questionTextController.clear();
    optionAController.clear();
    optionBController.clear();
    optionCController.clear();
    optionDController.clear();
    selectedCorrectAnswer.value = 'A'; // Reset ke pilihan A
  }

  /// Pilih tanggal deadline menggunakan DateTimePicker.
  Future<void> pickDeadline(BuildContext context) async {
    final now = DateTime.now();

    // Pilih tanggal
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF4F46E5),
          ),
        ),
        child: child!,
      ),
    );

    if (date == null) return;

    // Pilih jam
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 23, minute: 59),
    );

    if (time == null) return;

    // Gabungkan tanggal + jam
    selectedDeadline.value = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }
}
