// student_controller.dart
// Controller GetX untuk semua fitur dashboard dan aktivitas siswa.

import 'package:get/get.dart';
import '../models/class_model.dart';
import '../models/assignment_model.dart';
import '../models/submission_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../services/firestore_service.dart';
import '../../../core/utils/helpers.dart';
import '../../../app/routes.dart';
import 'package:flutter/material.dart';

class StudentController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthController _authController = Get.find<AuthController>();

  // ========================
  // STATE
  // ========================

  /// List kelas yang diikuti siswa
  final RxList<ClassModel> myClasses = <ClassModel>[].obs;

  /// List semua tugas dari semua kelas
  final RxList<AssignmentModel> allAssignments = <AssignmentModel>[].obs;

  /// List nilai/submission siswa
  final RxList<SubmissionModel> mySubmissions = <SubmissionModel>[].obs;

  /// Status loading
  final RxBool isLoading = false.obs;

  /// Kode kelas yang diinput saat join
  final RxString joinClassCode = ''.obs;

  /// Kelas yang sedang dilihat detail-nya
  final Rx<ClassModel?> selectedClass = Rx<ClassModel?>(null);

  /// Tugas yang sedang dilihat
  final Rx<AssignmentModel?> selectedAssignment = Rx<AssignmentModel?>(null);

  // ========================
  // LIFECYCLE
  // ========================

  @override
  void onInit() {
    super.onInit();
    // Muat data saat pengguna tersedia
    if (_authController.currentUser.value != null) {
      loadDashboardData();
    }

    // Pantau perubahan user (misal: login atau refresh data profil)
    ever(_authController.currentUser, (user) {
      if (user != null) {
        loadDashboardData();
      } else {
        myClasses.clear();
        mySubmissions.clear();
        allAssignments.clear();
      }
    });

    // Update selectedClass jika ada pembaruan dari stream myClasses
    ever(myClasses, (classes) {
      if (selectedClass.value != null) {
        final updatedClass = classes.firstWhereOrNull((c) => c.id == selectedClass.value!.id);
        if (updatedClass != null && updatedClass.studentIds.length != selectedClass.value!.studentIds.length) {
          selectedClass.value = updatedClass;
        } else if (updatedClass != null) {
           selectedClass.value = updatedClass;
        }
      }
      
      // Reload tugas saat kelas berubah (misal join kelas baru)
      _loadAllAssignments(classes);
    });
  }

  // ========================
  // LOAD DATA
  // ========================

  /// Muat semua data untuk dashboard siswa.
  Future<void> loadDashboardData() async {
    isLoading.value = true;
    try {
      final studentId = _authController.currentUser.value?.uid;
      if (studentId == null) return;

      // Bind streams for real-time updates
      myClasses.bindStream(_firestoreService.streamStudentClasses(studentId));
      
      // Ambil nilai secara manual (atau bisa pakai stream jika dibuatkan di FirestoreService)
      final submissions = await _firestoreService.getStudentSubmissions(studentId);
      mySubmissions.assignAll(submissions);

      // _loadAllAssignments akan dipanggil otomatis oleh ever(myClasses, ...)

    } catch (e) {
      debugPrint("Error loading student dashboard: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Ambil semua tugas dari semua kelas yang diikuti.
  Future<void> _loadAllAssignments(List<ClassModel> classes) async {
    final List<AssignmentModel> assignments = [];

    for (final classItem in classes) {
      final classAssignments = await _firestoreService.getClassAssignments(
        classItem.id,
      );
      assignments.addAll(classAssignments);
    }

    allAssignments.assignAll(assignments);
  }

  /// Ambil tugas untuk kelas tertentu.
  Future<List<AssignmentModel>> getClassAssignments(String classId) async {
    return await _firestoreService.getClassAssignments(classId);
  }

  // ========================
  // JOIN CLASS
  // ========================

  Future<String?> joinClass(String code) async {
    isLoading.value = true;

    try {
      final studentId = _authController.currentUser.value?.uid;
      if (studentId == null) return 'Sesi tidak ditemukan';

      final result = await _firestoreService.joinClass(
        studentId: studentId,
        classCode: code.trim().toUpperCase(),
      );

      // 1. JIKA GAGAL BERGABUNG
      if (result.error != null) {
        Get.snackbar(
          'Gagal Bergabung',
          result.error ?? 'Terjadi kesalahan.',
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          icon: const Icon(Icons.error_outline, color: Colors.white),
        );
        return result.error;
      }

      // 2. JIKA BERHASIL: Tidak perlu add manual ke list lokal
      // karena sudah pakai bindStream, Firestore akan otomatis update myClasses
      // myClasses.add(result.classData!);
      // await _loadAllAssignments(myClasses);

      // 3. TAMPILKAN SNACKBAR BERHASIL
      Get.snackbar(
        'Berhasil!',
        'Anda telah bergabung ke kelas ${result.classData?.name ?? ""}',
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      );

      // 4. PINDAH KE HALAMAN DETAIL KELAS SECARA OTOMATIS
      // Kita set selectedClass agar data di halaman detail sinkron
      selectedClass.value = result.classData;

      // Gunakan Get.offNamed agar halaman 'Join Class' ditutup dan digantikan halaman Detail
      Get.offNamed(
          AppRoutes.classDetail,
          arguments: result.classData
      );

      return null;

    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan sistem.',
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
      );
      return e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Keluar dari kelas.
  Future<void> leaveClass(ClassModel classData) async {
    final studentId = _authController.currentUser.value?.uid;
    if (studentId == null) return;

    // Tampilkan dialog konfirmasi
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Keluar Kelas'),
        content: Text('Apakah Anda yakin ingin keluar dari kelas ${classData.name}? Riwayat nilai Anda tetap tersimpan, namun Anda tidak bisa mengakses tugas di kelas ini lagi.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    isLoading.value = true;
    try {
      final error = await _firestoreService.leaveClass(
        studentId: studentId,
        classId: classData.id,
      );

      if (error != null) {
        Get.snackbar('Gagal', error, backgroundColor: Colors.red, colorText: Colors.white);
      } else {
        Get.back(); // Kembali dari screen detail kelas
        Get.snackbar(
          'Berhasil',
          'Anda telah keluar dari kelas ${classData.name}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan sistem', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // ========================
  // CEK STATUS TUGAS
  // ========================

  /// Cek apakah siswa sudah mengerjakan tugas ini.
  bool hasSubmitted(String assignmentId) {
    return mySubmissions.any((s) => s.assignmentId == assignmentId);
  }

  /// Ambil submission untuk tugas tertentu.
  SubmissionModel? getSubmission(String assignmentId) {
    try {
      return mySubmissions.firstWhere((s) => s.assignmentId == assignmentId);
    } catch (e) {
      return null;
    }
  }

  // ========================
  // TUGAS DEADLINE DEKAT
  // ========================

  /// Ambil tugas yang deadline-nya dalam 3 hari ke depan.
  List<AssignmentModel> get upcomingDeadlines {
    return allAssignments.where((a) {
      if (hasSubmitted(a.id)) return false; // Skip yang sudah dikerjakan
      return Helpers.isDeadlineNear(a.deadline) && !a.isExpired;
    }).toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  // ========================
  // STATISTIK NILAI
  // ========================

  /// Hitung rata-rata nilai dari semua submission.
  double get averageScore {
    if (mySubmissions.isEmpty) return 0;
    final total = mySubmissions.map((s) => s.score).reduce((a, b) => a + b);
    return total / mySubmissions.length;
  }

  /// Jumlah tugas yang sudah selesai dikerjakan.
  int get completedCount => mySubmissions.length;

  // ========================
  // NAVIGASI
  // ========================

  /// Buka halaman detail kelas.
  void openClassDetail(ClassModel classData) {
    selectedClass.value = classData;
    Get.toNamed(AppRoutes.classDetail, arguments: classData);
  }

  /// Buka halaman ujian untuk suatu tugas.
  void openExam(AssignmentModel assignment) {
    Get.toNamed(
      AppRoutes.exam,
      arguments: {
        'assignment': assignment,
        'student': _authController.currentUser.value,
      },
    );
  }
}