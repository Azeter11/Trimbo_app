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
      }
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

      // Ambil semua kelas yang diikuti
      final classes = await _firestoreService.getStudentClasses(studentId);
      myClasses.assignAll(classes);

      // Ambil semua nilai/submission
      final submissions = await _firestoreService.getStudentSubmissions(studentId);
      mySubmissions.assignAll(submissions);

      // Ambil tugas dari semua kelas
      await _loadAllAssignments(classes);

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

  /// Bergabung ke kelas menggunakan kode kelas.
  Future<String?> joinClass(String code) async {
    isLoading.value = true;

    try {
      final studentId = _authController.currentUser.value?.uid;
      if (studentId == null) return 'Sesi tidak ditemukan';

      final result = await _firestoreService.joinClass(
        studentId: studentId,
        classCode: code.trim().toUpperCase(),
      );

      if (result.error != null) return result.error;

      // Tambahkan kelas baru ke list lokal
      myClasses.add(result.classData!);

      // Refresh tugas
      await _loadAllAssignments(myClasses);

      return null; // null = sukses

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
