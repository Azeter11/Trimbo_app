// essay_exam_controller.dart
// Controller GetX untuk halaman pengerjaan soal essay.
// Menangani pengambilan file PDF dan pengumpulan jawaban essay.

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../models/assignment_model.dart';
import '../../teacher/models/question_model.dart';
import '../../../services/firestore_service.dart';
import '../../../services/firebase_storage_service.dart';
import '../../../app/routes.dart';

class EssayExamController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  late AssignmentModel assignment;
  late dynamic student;

  final RxList<QuestionModel> questions = <QuestionModel>[].obs;
  final RxBool isLoadingQuestions = true.obs;
  final RxBool isSubmitting = false.obs;

  final Rx<File?> selectedPdfFile = Rx<File?>(null);
  final RxString pdfFileName = ''.obs;
  Uint8List? _pdfBytes;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    assignment = args['assignment'];
    student = args['student'];
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final qList = await _firestoreService.getAssignmentQuestions(assignment.id);
      questions.assignAll(qList);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat soal essay');
    } finally {
      isLoadingQuestions.value = false;
    }
  }

  Future<void> pickPdfFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null) {
        if (result.files.single.bytes != null) {
          _pdfBytes = result.files.single.bytes;
        } else if (result.files.single.path != null) {
          _pdfBytes = await File(result.files.single.path!).readAsBytes();
        }

        if (result.files.single.path != null) {
          selectedPdfFile.value = File(result.files.single.path!);
        } else {
          // Fallback if path is null but we have bytes (e.g. web/some platforms)
          selectedPdfFile.value = File('virtual_path.pdf'); 
        }
        
        pdfFileName.value = result.files.single.name;
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memilih file PDF');
    }
  }

  Future<void> clearSelectedFile() async {
    selectedPdfFile.value = null;
    pdfFileName.value = '';
    _pdfBytes = null;
  }

  void showSubmitConfirmation() {
    if (selectedPdfFile.value == null) {
      Get.snackbar('Perhatian', 'Pilih file PDF terlebih dahulu sebelum mengumpulkan!');
      return;
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Kumpulkan Jawaban?'),
        content: const Text('Pastikan file PDF yang Anda pilih sudah benar. Jawaban tidak dapat diubah setelah dikumpulkan.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _submitAnswers();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            child: const Text('Kumpulkan'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAnswers() async {
    if (selectedPdfFile.value == null) return;
    
    isSubmitting.value = true;

    try {
      final String fileName = '${assignment.id}_${student.uid}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      
      if (_pdfBytes == null || _pdfBytes!.isEmpty) {
        Get.snackbar('Error', 'Gagal membaca isi file PDF atau file kosong.');
        isSubmitting.value = false;
        return;
      }

      String? downloadUrl = await FirebaseStorageService.uploadPDF(
        fileName: fileName,
        file: selectedPdfFile.value?.path == 'virtual_path.pdf' ? null : selectedPdfFile.value,
        bytes: _pdfBytes,
        folder: 'essay_submissions',
      );

      if (downloadUrl == null) {
        isSubmitting.value = false;
        return; // FirebaseStorageService sudah memunculkan snackbar error
      }

      // Buat data answers kosong (karena essay)
      final Map<int, String> answers = {};
      for (var i = 0; i < questions.length; i++) {
        answers[i + 1] = 'Essay File Uploaded'; 
      }

      final error = await _firestoreService.submitAnswers(
        assignmentId: assignment.id,
        assignmentTitle: assignment.title,
        studentId: student.uid,
        studentName: student.displayName ?? 'Siswa',
        answers: answers,
        questions: questions, // Pass dummy to avoid issues
        warningCount: 0,
        isAutoSubmitted: false,
        fileUrl: downloadUrl,
      );

      if (error != null) {
        Get.snackbar('Gagal', error);
        return;
      }

      Get.offNamed(AppRoutes.result, arguments: {
        'score': 0.0, // Skor 0 untuk essay, dinilai manual oleh dosen
        'correct': 0,
        'wrong': 0,
        'skipped': 0,
        'assignment': assignment,
      });

    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan sistem saat mengunggah file. Coba lagi.');
    } finally {
      isSubmitting.value = false;
    }
  }
}
