// assignment_controller.dart
// Controller GetX untuk alur 2-step pembuatan tugas oleh guru:
// Step 1: Info tugas (judul, deskripsi, deadline, durasi)
// Step 2: Buat soal (pertanyaan + 4 pilihan + jawaban benar)

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../student/models/assignment_model.dart';
import '../models/question_model.dart';
import '../../../services/firestore_service.dart';
import '../../../services/firebase_storage_service.dart';
import '../../../services/notification_service.dart';
import '../../../services/docx_parser_service.dart';
import '../../../app/routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';

class AssignmentController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final NotificationService _notificationService = Get.find<NotificationService>();
  final DocxParserService _docxParserService = DocxParserService();

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
  
  /// Tipe tugas yang dipilih (quiz atau essay)
  final RxString selectedType = 'quiz'.obs;

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

  /// File gambar pendukung untuk soal (opsional)
  final Rx<File?> selectedImageFile = Rx<File?>(null);
  Uint8List? _imageBytes; // untuk web fallback

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
        type: selectedType.value,
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
      final isEssay = currentAssignment.value!.type == 'essay';
      
      String? imageUrl;
      
      // Upload gambar jika ada
      if (selectedImageFile.value != null || _imageBytes != null) {
        final String fileName = '${currentAssignment.value!.id}_q${orderNumber}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        
        imageUrl = await FirebaseStorageService.uploadImage(
          fileName: fileName,
          file: selectedImageFile.value?.path == 'virtual_path.jpg' ? null : selectedImageFile.value,
          bytes: _imageBytes,
          folder: 'question_images',
        );
      }

      final result = await _firestoreService.addQuestion(
        assignmentId: currentAssignment.value!.id,
        orderNumber: orderNumber,
        questionText: questionTextController.text,
        optionA: isEssay ? '' : optionAController.text,
        optionB: isEssay ? '' : optionBController.text,
        optionC: isEssay ? '' : optionCController.text,
        optionD: isEssay ? '' : optionDController.text,
        correctAnswer: isEssay ? 'A' : selectedCorrectAnswer.value,
        imageUrl: imageUrl,
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
  // IMPORT DARI WORD
  // ========================

  /// Menampilkan dialog panduan aturan format penulisan soal,
  /// lalu jika guru menekan 'Lanjutkan', memulai proses import.
  void showImportRulesDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Container(
          padding: EdgeInsets.all(24.w),
          constraints: BoxConstraints(maxHeight: 520.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(Icons.description_rounded,
                        color: AppColors.primary, size: 24.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Import dari Word',
                            style: AppStyles.headingS),
                        Text('Panduan format penulisan',
                            style: AppStyles.bodyS.copyWith(
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // Rules
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRuleItem('1',
                          'Setiap soal diawali dengan nomor diikuti titik atau kurung tutup.\nContoh: 1. atau 1)'),
                      _buildRuleItem('2',
                          'Pilihan jawaban diawali huruf A, B, C, D diikuti titik atau kurung tutup.\nContoh: A. atau A)'),
                      _buildRuleItem('3',
                          'Kunci jawaban ditulis di baris terakhir tiap soal.\nFormat: Jawaban: A'),
                      _buildRuleItem('4',
                          'Setiap soal harus memiliki tepat 4 pilihan (A, B, C, D).'),
                      _buildRuleItem('5',
                          'Pisahkan antar soal dengan baris kosong (opsional).'),

                      SizedBox(height: 12.h),

                      // Contoh format
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Contoh Format:',
                                style: AppStyles.labelS.copyWith(
                                    color: AppColors.primary)),
                            SizedBox(height: 8.h),
                            Text(
                              '1. Apa ibu kota Indonesia?\n'
                              'A. Bandung\n'
                              'B. Jakarta\n'
                              'C. Surabaya\n'
                              'D. Yogyakarta\n'
                              'Jawaban: B',
                              style: AppStyles.bodyS.copyWith(
                                fontFamily: 'monospace',
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: Text('Batal',
                          style: AppStyles.labelL
                              .copyWith(color: AppColors.textSecondary)),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        importQuestionsFromWord();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload_file_rounded,
                              color: Colors.white, size: 18.sp),
                          SizedBox(width: 8.w),
                          Text('Pilih File',
                              style: AppStyles.labelL
                                  .copyWith(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  /// Widget helper untuk satu item aturan dalam dialog.
  Widget _buildRuleItem(String number, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24.w,
            height: 24.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Center(
              child: Text(number,
                  style: AppStyles.labelS.copyWith(
                      color: Colors.white, fontSize: 11.sp)),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(text,
                style: AppStyles.bodyS.copyWith(height: 1.4)),
          ),
        ],
      ),
    );
  }

  /// Import soal dari file Word (.docx).
  /// 1. Buka file picker untuk pilih file .docx (dengan withData: true agar bytes
  ///    selalu tersedia, tidak bergantung pada path file)
  /// 2. Ekstrak teks dan parsing soal di sisi klien (tidak upload ke server)
  /// 3. Simpan HANYA hasil soal ke Firestore (bukan file Word-nya)
  /// 4. Navigasi ke layar preview
  Future<void> importQuestionsFromWord() async {
    // 1. Pilih file .docx — withData: true agar bytes selalu ada
    //    (mendukung semua platform termasuk Android, iOS, dan Web)
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['docx'],
      allowMultiple: false,
      withData: true, // Pastikan bytes tersedia
    );

    if (result == null || result.files.isEmpty) return;

    final pickedFile = result.files.single;

    // Validasi: harus ada bytes ATAU path file
    if (pickedFile.bytes == null && pickedFile.path == null) {
      Get.snackbar(
        'Error',
        'Tidak dapat mengakses isi file yang dipilih.',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return;
    }

    if (currentAssignment.value == null) return;

    isLoading.value = true;

    try {
      // 2. Parsing soal di sisi klien:
      //    - Prioritaskan bytes (lebih reliable, tidak bergantung izin path)
      //    - Fallback ke path jika bytes tidak tersedia
      DocxParseResult parseResult;
      if (pickedFile.bytes != null) {
        parseResult = await _docxParserService.processDocxBytes(pickedFile.bytes!);
      } else {
        parseResult = await _docxParserService.processDocxFile(pickedFile.path!);
      }

      if (parseResult.error != null) {
        Get.snackbar(
          'Gagal Membaca Dokumen',
          parseResult.error!,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        return;
      }

      if (parseResult.questions.isEmpty) {
        Get.snackbar(
          'Tidak Ada Soal Ditemukan',
          'Tidak ditemukan soal yang valid di dalam dokumen. '
          'Pastikan format sesuai aturan penulisan.',
          backgroundColor: const Color(0xFFF59E0B),
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        return;
      }

      // 3. Simpan HANYA hasil soal ke Firestore
      //    (File Word TIDAK diunggah ke Firebase Storage)
      final List<QuestionModel> savedQuestions = [];
      final startOrderNumber = questions.length + 1;

      for (int i = 0; i < parseResult.questions.length; i++) {
        final parsed = parseResult.questions[i];
        final orderNumber = startOrderNumber + i;

        final saveResult = await _firestoreService.addQuestion(
          assignmentId: currentAssignment.value!.id,
          orderNumber: orderNumber,
          questionText: parsed.questionText,
          optionA: parsed.optionA,
          optionB: parsed.optionB,
          optionC: parsed.optionC,
          optionD: parsed.optionD,
          correctAnswer: parsed.correctAnswer,
        );

        if (saveResult.error == null && saveResult.question != null) {
          savedQuestions.add(saveResult.question!);
          questions.add(saveResult.question!);
        }
      }

      // 4. Navigasi ke layar preview hasil import
      Get.toNamed(
        AppRoutes.previewImportedQuestions,
        arguments: {
          'importedQuestions': savedQuestions,
          'failedCount': parseResult.failedCount,
        },
      );

      if (savedQuestions.isNotEmpty) {
        Get.snackbar(
          'Berhasil!',
          '${savedQuestions.length} soal berhasil diimpor dari Word.',
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
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
    removeSelectedImage();
  }

  /// Memilih file gambar pendukung soal dari galeri
  Future<void> pickQuestionImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null) {
        if (result.files.single.bytes != null) {
          _imageBytes = result.files.single.bytes;
        } else if (result.files.single.path != null) {
          _imageBytes = await File(result.files.single.path!).readAsBytes();
        }

        if (result.files.single.path != null) {
          selectedImageFile.value = File(result.files.single.path!);
        } else {
          selectedImageFile.value = File('virtual_path.jpg'); 
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memilih gambar');
    }
  }

  /// Menghapus gambar pendukung soal yang sudah dipilih
  void removeSelectedImage() {
    selectedImageFile.value = null;
    _imageBytes = null;
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

    // Pastikan context masih valid setelah await pertama
    if (!context.mounted) return;

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
