// assignment_model.dart
// Model data untuk tugas/ujian yang dibuat oleh guru.

class AssignmentModel {
  final String id;           // ID dokumen Firestore
  final String classId;      // ID kelas tempat tugas ini berada
  final String title;        // Judul tugas: "UTS Bab 1-3"
  final String description;  // Deskripsi materi yang diujikan
  final DateTime deadline;   // Batas waktu pengumpulan
  final int durationMinutes; // Durasi ujian dalam menit
  final int totalQuestions;  // Jumlah soal (dihitung otomatis)
  final String teacherId;    // UID guru pembuat
  final DateTime createdAt;
  final bool isPublished;    // Sudah diterbitkan atau masih draft

  const AssignmentModel({
    required this.id,
    required this.classId,
    required this.title,
    required this.description,
    required this.deadline,
    required this.durationMinutes,
    required this.totalQuestions,
    required this.teacherId,
    required this.createdAt,
    this.isPublished = false,
  });

  /// Cek apakah deadline sudah lewat
  bool get isExpired => DateTime.now().isAfter(deadline);

  /// Durasi dalam format string: "60 menit"
  String get durationText => '$durationMinutes menit';

  factory AssignmentModel.fromMap(Map<String, dynamic> map, String id) {
    return AssignmentModel(
      id: id,
      classId: map['classId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      deadline: map['deadline'] != null
          ? (map['deadline'] as dynamic).toDate()
          : DateTime.now(),
      durationMinutes: map['durationMinutes'] ?? 60,
      totalQuestions: map['totalQuestions'] ?? 0,
      teacherId: map['teacherId'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
      isPublished: map['isPublished'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'classId': classId,
      'title': title,
      'description': description,
      'deadline': deadline,
      'durationMinutes': durationMinutes,
      'totalQuestions': totalQuestions,
      'teacherId': teacherId,
      'createdAt': createdAt,
      'isPublished': isPublished,
    };
  }

  AssignmentModel copyWith({
    String? title,
    String? description,
    DateTime? deadline,
    int? durationMinutes,
    int? totalQuestions,
    bool? isPublished,
  }) {
    return AssignmentModel(
      id: id,
      classId: classId,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      teacherId: teacherId,
      createdAt: createdAt,
      isPublished: isPublished ?? this.isPublished,
    );
  }
}
