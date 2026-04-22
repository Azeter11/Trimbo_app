// submission_model.dart
// Model data untuk jawaban yang dikumpulkan siswa setelah mengerjakan ujian.

class SubmissionModel {
  final String id;                    // ID dokumen Firestore
  final String assignmentId;          // ID tugas yang dikerjakan
  final String studentId;             // UID siswa
  final String studentName;           // Nama siswa
  final Map<int, String> answers;     // Jawaban: {nomor_soal: 'A'/'B'/'C'/'D'}
  final double score;                 // Nilai akhir (0-100)
  final int correctCount;             // Jumlah jawaban benar
  final int wrongCount;               // Jumlah jawaban salah
  final int skippedCount;             // Jumlah soal tidak dijawab
  final DateTime submittedAt;         // Waktu pengumpulan
  final bool isAutoSubmitted;         // true jika dikumpulkan otomatis (waktu habis/anti-cheat)
  final int warningCount;             // Jumlah kali keluar dari layar ujian

  const SubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.studentName,
    required this.answers,
    required this.score,
    required this.correctCount,
    required this.wrongCount,
    required this.skippedCount,
    required this.submittedAt,
    this.isAutoSubmitted = false,
    this.warningCount = 0,
  });

  /// Grade huruf berdasarkan nilai
  String get grade {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'E';
  }

  factory SubmissionModel.fromMap(Map<String, dynamic> map, String id) {
    // Konversi answers dari Map<String, dynamic> ke Map<int, String>
    final rawAnswers = Map<String, dynamic>.from(map['answers'] ?? {});
    final answers = rawAnswers.map(
      (key, value) => MapEntry(int.parse(key), value.toString()),
    );

    return SubmissionModel(
      id: id,
      assignmentId: map['assignmentId'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      answers: answers,
      score: (map['score'] ?? 0).toDouble(),
      correctCount: map['correctCount'] ?? 0,
      wrongCount: map['wrongCount'] ?? 0,
      skippedCount: map['skippedCount'] ?? 0,
      submittedAt: map['submittedAt'] != null
          ? (map['submittedAt'] as dynamic).toDate()
          : DateTime.now(),
      isAutoSubmitted: map['isAutoSubmitted'] ?? false,
      warningCount: map['warningCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    // Konversi answers ke Map<String, String> untuk Firestore
    final answersForDb = answers.map(
      (key, value) => MapEntry(key.toString(), value),
    );

    return {
      'assignmentId': assignmentId,
      'studentId': studentId,
      'studentName': studentName,
      'answers': answersForDb,
      'score': score,
      'correctCount': correctCount,
      'wrongCount': wrongCount,
      'skippedCount': skippedCount,
      'submittedAt': submittedAt,
      'isAutoSubmitted': isAutoSubmitted,
      'warningCount': warningCount,
    };
  }
}
