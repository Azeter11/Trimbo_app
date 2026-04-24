// teacher_controller.dart
// Controller GetX untuk semua fitur dashboard dan aktivitas guru.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/question_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../student/models/class_model.dart';
import '../../student/models/assignment_model.dart';
import '../../student/models/submission_model.dart';
import '../../../services/firestore_service.dart';
import '../../../app/routes.dart';

class TeacherController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthController _authController = Get.find<AuthController>();

  // ========================
  // STATE
  // ========================

  /// Semua kelas yang dimiliki guru
  final RxList<ClassModel> myClasses = <ClassModel>[].obs;

  /// Kelas yang sedang dikelola
  final Rx<ClassModel?> selectedClass = Rx<ClassModel?>(null);

  /// Tugas dari kelas yang dipilih
  final RxList<AssignmentModel> classAssignments = <AssignmentModel>[].obs;

  /// Semua tugas dari semua kelas guru
  final RxList<AssignmentModel> allAssignments = <AssignmentModel>[].obs;

  /// Submission untuk tugas yang dipilih (untuk laporan nilai)
  final RxList<SubmissionModel> assignmentSubmissions = <SubmissionModel>[].obs;

  /// Loading state
  final RxBool isLoading = false.obs;

  /// Total tugas aktif dari semua kelas
  final RxInt activeAssignmentsCount = 0.obs;

  // ========================
  // FORM BUAT KELAS
  // ========================

  final TextEditingController classNameController = TextEditingController();
  final TextEditingController classDescController = TextEditingController();
  final GlobalKey<FormState> createClassFormKey = GlobalKey<FormState>();

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

    // Pantau perubahan user
    ever(_authController.currentUser, (user) {
      if (user != null) {
        loadDashboardData();
      } else {
        myClasses.clear();
        allAssignments.clear();
      }
    });

    // Hitung total tugas aktif setiap kali allAssignments berubah
    ever(allAssignments, (assignments) {
      activeAssignmentsCount.value =
          assignments.where((a) => !a.isExpired).length;
    });

    // Update selectedClass jika ada pembaruan dari stream myClasses
    ever(myClasses, (classes) {
      if (selectedClass.value != null) {
        final updatedClass =
            classes.firstWhereOrNull((c) => c.id == selectedClass.value!.id);
        if (updatedClass != null &&
            updatedClass.studentIds.length !=
                selectedClass.value!.studentIds.length) {
          selectedClass.value = updatedClass;
        } else if (updatedClass != null) {
          selectedClass.value = updatedClass;
        }
      }
    });
  }

  @override
  void onClose() {
    classNameController.dispose();
    classDescController.dispose();
    super.onClose();
  }

  // ========================
  // LOAD DATA
  // ========================

  /// Inisialisasi stream untuk dashboard realtime.
  Future<void> loadDashboardData() async {
    final teacherId = _authController.currentUser.value?.uid;
    if (teacherId == null) return;

    isLoading.value = true;
    try {
      // Bind streams for realtime updates
      myClasses.bindStream(_firestoreService.streamTeacherClasses(teacherId));
      allAssignments
          .bindStream(_firestoreService.streamTeacherAssignments(teacherId));
      await Future.delayed(const Duration(
          milliseconds: 500)); // Untuk efek loading pada RefreshIndicator
    } catch (e) {
      debugPrint("Error init streams: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Muat tugas untuk kelas tertentu secara realtime.
  void loadClassAssignments(String classId) {
    isLoading.value = true;
    try {
      classAssignments
          .bindStream(_firestoreService.streamClassAssignments(classId));
    } finally {
      isLoading.value = false;
    }
  }

  /// Muat nilai siswa untuk tugas tertentu.
  Future<void> loadAssignmentSubmissions(String assignmentId) async {
    isLoading.value = true;
    try {
      final submissions =
          await _firestoreService.getAssignmentSubmissions(assignmentId);
      assignmentSubmissions.assignAll(submissions);
    } finally {
      isLoading.value = false;
    }
  }

  // ========================
  // STATISTIK DASHBOARD
  // ========================

  /// Total seluruh siswa dari semua kelas (bisa duplikat jika siswa di banyak kelas).
  int get totalStudents {
    return myClasses.fold(0, (sum, c) => sum + c.totalStudents);
  }

  /// Jumlah kelas yang dimiliki.
  int get totalClasses => myClasses.length;

  // ========================
  // BUAT KELAS
  // ========================

  /// Buat kelas baru.
  Future<({String? classCode, String? error})> createClass() async {
    if (!createClassFormKey.currentState!.validate()) {
      return (classCode: null, error: null);
    }

    isLoading.value = true;

    try {
      final teacher = _authController.currentUser.value;
      if (teacher == null)
        return (classCode: null, error: 'Sesi tidak ditemukan');

      final result = await _firestoreService.createClass(
        teacherId: teacher.uid,
        teacherName: teacher.fullName,
        name: classNameController.text,
        description: classDescController.text,
      );

      if (result.error != null) {
        return (classCode: null, error: result.error);
      }

      // Karena sudah menggunakan bindStream, tidak perlu lagi menambahkan ke list lokal secara manual
      // myClasses.add(result.classData!);

      // Bersihkan form
      classNameController.clear();
      classDescController.clear();

      return (classCode: result.classData!.classCode, error: null);
    } finally {
      isLoading.value = false;
    }
  }

  // ========================
  // HAPUS KELAS & TUGAS
  // ========================

  /// Hapus kelas dengan konfirmasi.
  Future<void> deleteClass(ClassModel classData) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Hapus Kelas'),
        content: Text(
            'Apakah Anda yakin ingin menghapus kelas ${classData.name}? Semua tugas di dalamnya akan ikut terhapus (histori nilai siswa tetap aman). Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    isLoading.value = true;
    try {
      final error = await _firestoreService.deleteClass(classData.id);

      if (error != null) {
        Get.snackbar('Gagal', error,
            backgroundColor: Colors.red, colorText: Colors.white);
      } else {
        Get.back(); // Kembali ke halaman sebelumnya
        Get.snackbar(
          'Berhasil',
          'Kelas ${classData.name} berhasil dihapus',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan sistem',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// Hapus tugas dengan konfirmasi.
  Future<void> deleteAssignment(AssignmentModel assignment) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Hapus Tugas'),
        content: Text(
            'Apakah Anda yakin ingin menghapus tugas ${assignment.title}? (Histori nilai siswa tetap aman). Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    isLoading.value = true;
    try {
      final error = await _firestoreService.deleteAssignment(assignment.id);

      if (error != null) {
        Get.snackbar('Gagal', error,
            backgroundColor: Colors.red, colorText: Colors.white);
      } else {
        // Jika sedang di halaman detail tugas, mungkin perlu Get.back() tapi tidak bisa dipastikan di sini
        // Biasanya controller dipanggil dari list atau detail. Kalau dari detail, kita perlu balik.
        Get.snackbar(
          'Berhasil',
          'Tugas ${assignment.title} berhasil dihapus',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan sistem',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // ========================
  // NAVIGASI
  // ========================

  /// Buka halaman manajemen kelas.
  void openClassManagement(ClassModel classData) {
    selectedClass.value = classData;
    loadClassAssignments(classData.id);
    Get.toNamed(AppRoutes.classManagement, arguments: classData);
  }
}
