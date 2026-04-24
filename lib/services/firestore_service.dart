// firestore_service.dart
// Service untuk semua operasi CRUD ke database Firestore.
// Mencakup: kelas, tugas, soal, dan pengumpulan jawaban.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/student/models/class_model.dart';
import '../features/student/models/assignment_model.dart';
import '../features/student/models/submission_model.dart';
import '../features/teacher/models/question_model.dart';
import '../core/utils/helpers.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ========================
  // KOLEKSI FIRESTORE
  // ========================
  // Nama koleksi disimpan sebagai konstanta agar tidak typo
  static const String _classesCollection = 'classes';
  static const String _assignmentsCollection = 'assignments';
  static const String _questionsCollection = 'questions';
  static const String _submissionsCollection = 'submissions';

  // ========================
  // OPERASI KELAS
  // ========================

  /// Buat kelas baru oleh guru.
  Future<({ClassModel? classData, String? error})> createClass({
    required String teacherId,
    required String teacherName,
    required String name,
    required String description,
  }) async {
    try {
      // Generate kode kelas unik
      String classCode = Helpers.generateClassCode();

      // Pastikan kode tidak duplikat (cek Firestore)
      bool codeExists = true;
      while (codeExists) {
        final query = await _db
            .collection(_classesCollection)
            .where('classCode', isEqualTo: classCode)
            .limit(1)
            .get();
        if (query.docs.isEmpty) {
          codeExists = false;
        } else {
          classCode = Helpers.generateClassCode(); // Generate ulang jika duplikat
        }
      }

      // Simpan ke Firestore
      final docRef = await _db.collection(_classesCollection).add({
        'name': name.trim(),
        'description': description.trim(),
        'teacherId': teacherId,
        'teacherName': teacherName,
        'classCode': classCode,
        'studentIds': [],
        'createdAt': FieldValue.serverTimestamp(),
      });

      final classData = ClassModel(
        id: docRef.id,
        name: name.trim(),
        description: description.trim(),
        teacherId: teacherId,
        teacherName: teacherName,
        classCode: classCode,
        createdAt: DateTime.now(),
      );

      return (classData: classData, error: null);

    } catch (e) {
      return (classData: null, error: 'Gagal membuat kelas. Coba lagi.');
    }
  }

  /// Siswa bergabung ke kelas menggunakan kode kelas.
  Future<({ClassModel? classData, String? error})> joinClass({
    required String studentId,
    required String classCode,
  }) async {
    try {
      // Cari kelas dengan kode ini
      final query = await _db
          .collection(_classesCollection)
          .where('classCode', isEqualTo: classCode.toUpperCase())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return (classData: null, error: 'Kode kelas tidak valid atau tidak ditemukan');
      }

      final classDoc = query.docs.first;
      final classData = ClassModel.fromMap(classDoc.data(), classDoc.id);

      // Cek apakah siswa sudah bergabung
      if (classData.studentIds.contains(studentId)) {
        return (classData: null, error: 'Anda sudah terdaftar di kelas ini');
      }

      // Tambahkan studentId ke array studentIds di Firestore
      await _db.collection(_classesCollection).doc(classDoc.id).update({
        'studentIds': FieldValue.arrayUnion([studentId]),
      });

      final updatedClass = classData.copyWith(
        studentIds: [...classData.studentIds, studentId],
      );

      return (classData: updatedClass, error: null);

    } catch (e) {
      return (classData: null, error: 'Gagal bergabung kelas. Coba lagi.');
    }
  }

  /// Ambil semua kelas yang dimiliki guru berdasarkan teacherId.
  Future<List<ClassModel>> getTeacherClasses(String teacherId) async {
    try {
      final query = await _db
          .collection(_classesCollection)
          .where('teacherId', isEqualTo: teacherId)
          .get();

      final classes = query.docs
          .map((doc) => ClassModel.fromMap(doc.data(), doc.id))
          .toList();

      // Sortir secara lokal untuk menghindari kebutuhan index komposit
      classes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return classes;
    } catch (e) {
      print('Firestore error (getTeacherClasses): $e');
      return [];
    }
  }

  /// Ambil semua kelas yang diikuti siswa berdasarkan studentId.
  Future<List<ClassModel>> getStudentClasses(String studentId) async {
    try {
      final query = await _db
          .collection(_classesCollection)
          .where('studentIds', arrayContains: studentId)
          .get();

      final classes = query.docs
          .map((doc) => ClassModel.fromMap(doc.data(), doc.id))
          .toList();

      // Sortir secara lokal
      classes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return classes;
    } catch (e) {
      print('Firestore error (getStudentClasses): $e');
      return [];
    }
  }

  /// Ambil satu kelas berdasarkan ID.
  Future<ClassModel?> getClassById(String classId) async {
    try {
      final doc = await _db.collection(_classesCollection).doc(classId).get();
      if (!doc.exists) return null;
      return ClassModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      return null;
    }
  }

  // ========================
  // OPERASI TUGAS
  // ========================

  /// Buat tugas baru di sebuah kelas.
  Future<({AssignmentModel? assignment, String? error})> createAssignment({
    required String classId,
    required String teacherId,
    required String title,
    required String description,
    required DateTime deadline,
    required int durationMinutes,
  }) async {
    try {
      final docRef = await _db.collection(_assignmentsCollection).add({
        'classId': classId,
        'teacherId': teacherId,
        'title': title.trim(),
        'description': description.trim(),
        'deadline': Timestamp.fromDate(deadline),
        'durationMinutes': durationMinutes,
        'totalQuestions': 0,
        'isPublished': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final assignment = AssignmentModel(
        id: docRef.id,
        classId: classId,
        teacherId: teacherId,
        title: title.trim(),
        description: description.trim(),
        deadline: deadline,
        durationMinutes: durationMinutes,
        totalQuestions: 0,
        createdAt: DateTime.now(),
      );

      return (assignment: assignment, error: null);

    } catch (e) {
      return (assignment: null, error: 'Gagal membuat tugas. Coba lagi.');
    }
  }

  /// Terbitkan tugas setelah semua soal selesai dibuat.
  Future<String?> publishAssignment(String assignmentId, int totalQuestions) async {
    try {
      await _db.collection(_assignmentsCollection).doc(assignmentId).update({
        'isPublished': true,
        'totalQuestions': totalQuestions,
      });
      return null;
    } catch (e) {
      return 'Gagal menerbitkan tugas. Coba lagi.';
    }
  }

  /// Ambil semua tugas dalam sebuah kelas.
  Future<List<AssignmentModel>> getClassAssignments(String classId) async {
    try {
      final query = await _db
          .collection(_assignmentsCollection)
          .where('classId', isEqualTo: classId)
          .where('isPublished', isEqualTo: true)
          .get();

      final assignments = query.docs
          .map((doc) => AssignmentModel.fromMap(doc.data(), doc.id))
          .toList();

      // Sortir secara lokal
      assignments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return assignments;
    } catch (e) {
      print('Firestore error (getClassAssignments): $e');
      return [];
    }
  }

  // ========================
  // OPERASI SOAL
  // ========================

  /// Tambah soal ke sebuah tugas.
  Future<({QuestionModel? question, String? error})> addQuestion({
    required String assignmentId,
    required int orderNumber,
    required String questionText,
    required String optionA,
    required String optionB,
    required String optionC,
    required String optionD,
    required String correctAnswer,
    String? explanation,
  }) async {
    try {
      final docRef = await _db.collection(_questionsCollection).add({
        'assignmentId': assignmentId,
        'orderNumber': orderNumber,
        'questionText': questionText.trim(),
        'optionA': optionA.trim(),
        'optionB': optionB.trim(),
        'optionC': optionC.trim(),
        'optionD': optionD.trim(),
        'correctAnswer': correctAnswer.toUpperCase(),
        'explanation': explanation?.trim(),
      });

      final question = QuestionModel(
        id: docRef.id,
        assignmentId: assignmentId,
        orderNumber: orderNumber,
        questionText: questionText.trim(),
        optionA: optionA.trim(),
        optionB: optionB.trim(),
        optionC: optionC.trim(),
        optionD: optionD.trim(),
        correctAnswer: correctAnswer.toUpperCase(),
        explanation: explanation?.trim(),
      );

      return (question: question, error: null);

    } catch (e) {
      return (question: null, error: 'Gagal menyimpan soal. Coba lagi.');
    }
  }

  /// Ambil semua soal untuk sebuah tugas (diurutkan berdasarkan nomor).
  Future<List<QuestionModel>> getAssignmentQuestions(String assignmentId) async {
    try {
      final query = await _db
          .collection(_questionsCollection)
          .where('assignmentId', isEqualTo: assignmentId)
          .get();

      final questions = query.docs
          .map((doc) => QuestionModel.fromMap(doc.data(), doc.id))
          .toList();

      // Sortir berdasarkan nomor urut secara lokal
      questions.sort((a, b) => a.orderNumber.compareTo(b.orderNumber));
      return questions;
    } catch (e) {
      print('Firestore error (getAssignmentQuestions): $e');
      return [];
    }
  }

  // ========================
  // OPERASI SUBMISSION
  // ========================

  /// Simpan jawaban siswa setelah selesai ujian.
  Future<String?> submitAnswers({
    required String assignmentId,
    required String assignmentTitle,
    required String studentId,
    required String studentName,
    required Map<int, String> answers,
    required List<QuestionModel> questions,
    required int warningCount,
    required bool isAutoSubmitted,
  }) async {
    try {
      // Hitung nilai
      int correct = 0;
      int skipped = 0;

      for (int i = 0; i < questions.length; i++) {
        final questionNumber = i + 1;
        final studentAnswer = answers[questionNumber];

        if (studentAnswer == null || studentAnswer.isEmpty) {
          skipped++;
        } else if (questions[i].isCorrect(studentAnswer)) {
          correct++;
        }
      }

      final wrong = questions.length - correct - skipped;
      final score = Helpers.calculateScore(correct, questions.length);

      await _db.collection(_submissionsCollection).add({
        'assignmentId': assignmentId,
        'assignmentTitle': assignmentTitle,
        'studentId': studentId,
        'studentName': studentName,
        'answers': answers.map((k, v) => MapEntry(k.toString(), v)),
        'score': score,
        'correctCount': correct,
        'wrongCount': wrong,
        'skippedCount': skipped,
        'warningCount': warningCount,
        'isAutoSubmitted': isAutoSubmitted,
        'submittedAt': FieldValue.serverTimestamp(),
      });

      return null; // null = sukses

    } catch (e) {
      return 'Gagal mengumpulkan jawaban. Coba lagi.';
    }
  }

  /// Cek apakah siswa sudah mengerjakan tugas ini.
  Future<SubmissionModel?> getStudentSubmission({
    required String assignmentId,
    required String studentId,
  }) async {
    try {
      final query = await _db
          .collection(_submissionsCollection)
          .where('assignmentId', isEqualTo: assignmentId)
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      return SubmissionModel.fromMap(query.docs.first.data(), query.docs.first.id);
    } catch (e) {
      return null;
    }
  }

  /// Ambil semua submission untuk sebuah tugas (untuk guru).
  Future<List<SubmissionModel>> getAssignmentSubmissions(String assignmentId) async {
    try {
      final query = await _db
          .collection(_submissionsCollection)
          .where('assignmentId', isEqualTo: assignmentId)
          .get();

      final submissions = query.docs
          .map((doc) => SubmissionModel.fromMap(doc.data(), doc.id))
          .toList();

      // Sortir berdasarkan skor tertinggi
      submissions.sort((a, b) => b.score.compareTo(a.score));
      return submissions;
    } catch (e) {
      print('Firestore error (getAssignmentSubmissions): $e');
      return [];
    }
  }

  /// Ambil semua submission seorang siswa (untuk laporan nilai).
  Future<List<SubmissionModel>> getStudentSubmissions(String studentId) async {
    try {
      final query = await _db
          .collection(_submissionsCollection)
          .where('studentId', isEqualTo: studentId)
          .get();

      final submissions = query.docs
          .map((doc) => SubmissionModel.fromMap(doc.data(), doc.id))
          .toList();

      // Sortir berdasarkan waktu pengumpulan terbaru
      submissions.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      return submissions;
    } catch (e) {
      print('Firestore error (getStudentSubmissions): $e');
      return [];
    }
  }
}
