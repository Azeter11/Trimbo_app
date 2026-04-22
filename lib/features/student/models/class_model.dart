// class_model.dart
// Model data untuk kelas/mata pelajaran di EduTask.

class ClassModel {
  final String id;            // ID dokumen Firestore
  final String name;          // Nama kelas: "Matematika XI A"
  final String description;   // Deskripsi kelas
  final String teacherId;     // UID guru pemilik kelas
  final String teacherName;   // Nama guru (disimpan agar tidak perlu fetch ulang)
  final String classCode;     // Kode 6 karakter untuk join kelas
  final List<String> studentIds; // List UID siswa yang sudah join
  final DateTime createdAt;

  const ClassModel({
    required this.id,
    required this.name,
    required this.description,
    required this.teacherId,
    required this.teacherName,
    required this.classCode,
    required this.createdAt,
    this.studentIds = const [],
  });

  /// Jumlah siswa yang terdaftar
  int get totalStudents => studentIds.length;

  /// Konversi Firestore → ClassModel
  factory ClassModel.fromMap(Map<String, dynamic> map, String id) {
    return ClassModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      classCode: map['classCode'] ?? '',
      studentIds: List<String>.from(map['studentIds'] ?? []),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  /// Konversi ClassModel → Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'classCode': classCode,
      'studentIds': studentIds,
      'createdAt': createdAt,
    };
  }

  ClassModel copyWith({
    String? name,
    String? description,
    List<String>? studentIds,
  }) {
    return ClassModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      teacherId: teacherId,
      teacherName: teacherName,
      classCode: classCode,
      studentIds: studentIds ?? this.studentIds,
      createdAt: createdAt,
    );
  }
}
