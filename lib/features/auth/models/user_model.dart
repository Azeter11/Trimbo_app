// user_model.dart
// Model data untuk pengguna aplikasi EduTask.
// Mendukung 2 role: 'student' (siswa) dan 'teacher' (guru).

class UserModel {
  final String uid;           // ID unik dari Firebase Auth
  final String fullName;      // Nama lengkap pengguna
  final String email;         // Alamat email
  final String role;          // Role: 'student' atau 'teacher'
  final String? nuptk;        // Khusus guru: Nomor Unik Pendidik & Tenaga Kependidikan
  final String? institution;  // Khusus guru: nama instansi/sekolah
  final DateTime createdAt;   // Tanggal mendaftar
  final bool isEmailVerified; // Status verifikasi email

  const UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    required this.createdAt,
    this.nuptk,
    this.institution,
    this.isEmailVerified = false,
  });

  // ========================
  // GETTER HELPER
  // ========================

  /// Cek apakah pengguna adalah siswa
  bool get isStudent => role == 'student';

  /// Cek apakah pengguna adalah guru
  bool get isTeacher => role == 'teacher';

  /// Ambil inisial nama: "Ahmad Budi" → "AB"
  String get initials {
    final words = fullName.trim().split(' ');
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      return words[0].substring(0, words[0].length > 1 ? 2 : 1).toUpperCase();
    }
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  // ========================
  // KONVERSI KE/DARI MAP (FIRESTORE)
  // ========================

  /// Konversi data Firestore (Map) ke UserModel
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'student',
      nuptk: map['nuptk'] ?? map['nidn'], // Dukung migrasi data lama
      institution: map['institution'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate() // Firestore Timestamp → DateTime
          : DateTime.now(),
      isEmailVerified: map['isEmailVerified'] ?? false,
    );
  }

  /// Konversi UserModel ke Map untuk disimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'role': role,
      'nuptk': nuptk,
      'institution': institution,
      'createdAt': createdAt,
      'isEmailVerified': isEmailVerified,
    };
  }

  /// Buat salinan UserModel dengan beberapa field yang diubah
  UserModel copyWith({
    String? fullName,
    String? email,
    String? nuptk,
    String? institution,
    bool? isEmailVerified,
  }) {
    return UserModel(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role,
      nuptk: nuptk ?? this.nuptk,
      institution: institution ?? this.institution,
      createdAt: createdAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}
