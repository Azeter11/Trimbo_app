// skripsi_monitoring_service.dart
// Service untuk menghubungkan Trimbo dengan Firebase eksternal
// aplikasi monitoring skripsi milik dosen.
// Membaca data mahasiswa yang telah memilih dosen tertentu
// berdasarkan email atau NIDN/NUPTK dosen.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Model data mahasiswa dari aplikasi monitoring skripsi eksternal.
class SkripsiStudent {
  final String uid;
  final String nama;
  final String email;
  final String nim;
  final String judulSkripsi;
  final String statusBimbingan;
  final String nidnPembimbing;
  final String? emailPembimbing;
  final DateTime? tanggalDaftar;

  const SkripsiStudent({
    required this.uid,
    required this.nama,
    required this.email,
    required this.nim,
    required this.judulSkripsi,
    required this.statusBimbingan,
    required this.nidnPembimbing,
    this.emailPembimbing,
    this.tanggalDaftar,
  });

  factory SkripsiStudent.fromMap(Map<String, dynamic> map, String uid) {
    return SkripsiStudent(
      uid: uid,
      // Coba berbagai kemungkinan nama field yang dipakai di Firebase eksternal
      nama: map['nama_mahasiswa'] ??
          map['nama_mhs'] ??
          map['nama'] ??
          map['fullName'] ??
          map['name'] ??
          map['namaLengkap'] ??
          map['displayName'] ??
          '',
      email: map['email'] ?? map['email_mahasiswa'] ?? '',
      nim: map['nim'] ??
          map['NIM'] ??
          map['npm'] ??
          map['studentId'] ??
          map['username'] ??
          '',
      judulSkripsi: map['judul'] ??
          map['judulSkripsi'] ??
          map['judul_skripsi'] ??
          map['title'] ??
          '-',
      statusBimbingan: map['status'] ??
          map['statusBimbingan'] ??
          map['status_bimbingan'] ??
          'Aktif',
      nidnPembimbing: (map['id_dosbing'] ??
              map['nidn'] ??
              map['nidnPembimbing'] ??
              map['nuptk'] ??
              map['nidnDosenPembimbing'] ??
              map['pembimbing_id'] ??
              map['id_dosen'] ??
              '')
          .toString(),
      emailPembimbing: map['emailPembimbing'] ??
          map['dosenEmail'] ??
          map['emailDosen'] ??
          map['email_dosen'],
      tanggalDaftar: _parseDate(map['tanggalDaftar'] ??
          map['createdAt'] ??
          map['registeredAt'] ??
          map['date']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
    } catch (_) {}
    return null;
  }
}

/// Service untuk mengambil data dari Firebase eksternal (monitoring skripsi).
class SkripsiMonitoringService {
  // Instance Firebase sekunder (terhubung ke project monitoring skripsi)
  FirebaseApp? _secondaryApp;
  FirebaseFirestore? _externalDb;

  // ========================
  // KONFIGURASI FIREBASE EKSTERNAL
  // ========================

  /// Konfigurasi Firebase dari aplikasi monitoring skripsi milik dosen.
  static const _externalFirebaseConfig = {
    'apiKey': 'AIzaSyDDtS6-DEUzJYIgp3F0d-v6pZUz4Lv8kFw',
    'authDomain': 'academic-atelier-4c514.firebaseapp.com',
    'projectId': 'academic-atelier-4c514',
    'storageBucket': 'academic-atelier-4c514.firebasestorage.app',
    'messagingSenderId': '448832513908',
    'appId': '1:448832513908:web:912ac6e8ee647e35a1ae21',
  };

  static const String _appName = 'skripsi_monitoring';

  // ========================
  // INISIALISASI
  // ========================

  /// Inisialisasi koneksi ke Firebase eksternal.
  /// Dipanggil sekali sebelum menggunakan service ini.
  Future<void> initialize() async {
    if (_externalDb != null) return; // Sudah diinisialisasi

    try {
      // Cek apakah app dengan nama ini sudah pernah dibuat
      _secondaryApp = Firebase.app(_appName);
    } catch (_) {
      // Belum ada → buat baru
      _secondaryApp = await Firebase.initializeApp(
        name: _appName,
        options: FirebaseOptions(
          apiKey: _externalFirebaseConfig['apiKey']!,
          appId: _externalFirebaseConfig['appId']!,
          messagingSenderId: _externalFirebaseConfig['messagingSenderId']!,
          projectId: _externalFirebaseConfig['projectId']!,
          storageBucket: _externalFirebaseConfig['storageBucket'],
          authDomain: _externalFirebaseConfig['authDomain'],
        ),
      );
    }

    _externalDb = FirebaseFirestore.instanceFor(app: _secondaryApp!);
  }

  // ========================
  // AMBIL DATA MAHASISWA BIMBINGAN
  // ========================

  /// Ambil daftar mahasiswa yang memilih dosen berdasarkan NIDN/NUPTK.
  /// Ini adalah cara paling reliable karena NIDN/NUPTK adalah identifier unik dosen.
  Future<({List<SkripsiStudent> students, String? error})> getStudentsByNidn(
    String nidn,
  ) async {
    await initialize();

    try {
      final results = <SkripsiStudent>[];

      // Coba berbagai kemungkinan nama field dan koleksi
      final fieldNames = [
        'id_dosbing',
        'nidn',
        'nuptk',
        'nidnPembimbing',
        'nuptk_pembimbing',
        'nidnDosenPembimbing',
        'pembimbing_id',
        'id_dosen',
        'dosen_id',
        'nip'
      ];
      final collectionsToTry = [
        'Pengajuan_skripsi',
        'pendaftaran_skripsi',
        'bimbingan',
        'skripsi',
        'mahasiswa',
        'users',
        'supervision',
        'thesis',
        'dosbing',
        'pembimbing'
      ];

      for (final col in collectionsToTry) {
        for (final field in fieldNames) {
          try {
            // Coba kueri sebagai String
            var query = await _externalDb!
                .collection(col)
                .where(field, isEqualTo: nidn)
                .get();

            // Jika tidak ada hasil dan nidn bisa jadi angka, coba kueri sebagai Number
            if (query.docs.isEmpty && int.tryParse(nidn) != null) {
              query = await _externalDb!
                  .collection(col)
                  .where(field, isEqualTo: int.parse(nidn))
                  .get();
            }

            if (query.docs.isNotEmpty) {
              for (final doc in query.docs) {
                final student = SkripsiStudent.fromMap(doc.data(), doc.id);
                // Hanya masukkan jika ada nama atau NIM agar tidak muncul data kosong
                if (student.nama.isNotEmpty || student.nim.isNotEmpty) {
                  if (!results.any((s) => s.uid == student.uid)) {
                    results.add(student);
                  }
                }
              }
            }
          } catch (_) {
            continue;
          }
        }
        // Jangan langsung break agar bisa mencari di semua koleksi yang mungkin ada
      }

      return (students: results, error: null);
    } catch (e) {
      return (
        students: <SkripsiStudent>[],
        error: 'Gagal mengambil data dari server monitoring skripsi: $e'
      );
    }
  }

  /// Ambil daftar mahasiswa yang memilih dosen berdasarkan email.
  Future<({List<SkripsiStudent> students, String? error})> getStudentsByEmail(
    String email,
  ) async {
    await initialize();

    try {
      final results = <SkripsiStudent>[];
      final fieldNames = [
        'emailPembimbing',
        'emailDosen',
        'dosenEmail',
        'supervisorEmail'
      ];

      for (final col in [
        'Pengajuan_skripsi',
        'users',
        'mahasiswa',
        'skripsi',
        'bimbingan'
      ]) {
        for (final field in fieldNames) {
          try {
            final query = await _externalDb!
                .collection(col)
                .where(field, isEqualTo: email)
                .get();

            if (query.docs.isNotEmpty) {
              for (final doc in query.docs) {
                final student = SkripsiStudent.fromMap(doc.data(), doc.id);
                if (!results.any((s) => s.uid == student.uid)) {
                  results.add(student);
                }
              }
            }
          } catch (_) {
            continue;
          }
        }
        if (results.isNotEmpty) break;
      }

      return (students: results, error: null);
    } catch (e) {
      return (
        students: <SkripsiStudent>[],
        error: 'Gagal mengambil data dari server monitoring skripsi: $e'
      );
    }
  }

  /// Ambil mahasiswa berdasarkan NIDN/NUPTK DAN email menggunakan metode relasional 2 langkah
  /// Sesuai dengan struktur Firebase:
  /// 1. Cari user di koleksi 'users' yang punya email atau nim_nidn sesuai dengan guru Trimbo. Dapatkan Document ID-nya (misal 'rn4677335').
  /// 2. Cari di koleksi 'pengajuan_skripsi' di mana 'id_dosbing' == Document ID tersebut.
  Future<({List<SkripsiStudent> students, String? error})>
      getStudentsBySupervisor({
    required String nidn,
    required String email,
  }) async {
    await initialize();

    try {
      String? dosbingDocumentId;

      // LANGKAH 1: Cari ID Dosbing di koleksi 'users'
      // Coba cari berdasarkan email terlebih dahulu (paling akurat)
      if (email.isNotEmpty) {
        final userQuery = await _externalDb!
            .collection('users')
            .where('email', isEqualTo: email)
            .where('role', isEqualTo: 'dosbing') // Pastikan rolenya dosbing
            .get();

        if (userQuery.docs.isNotEmpty) {
          dosbingDocumentId = userQuery.docs.first.id; // contoh: 'rn4677335'
        }
      }

      // Jika tidak ketemu dengan email, coba dengan nim_nidn
      if (dosbingDocumentId == null && nidn.isNotEmpty) {
        final userQuery = await _externalDb!
            .collection('users')
            .where('nim_nidn', isEqualTo: nidn)
            .where('role', isEqualTo: 'dosbing')
            .get();

        if (userQuery.docs.isNotEmpty) {
          dosbingDocumentId = userQuery.docs.first.id;
        }
      }

      // Jika dosen tidak ditemukan di aplikasi monitoring, kembalikan pesan jelas
      if (dosbingDocumentId == null) {
        return (
          students: <SkripsiStudent>[],
          error:
              'Akun Anda tidak ditemukan di sistem monitoring skripsi.\nPastikan Email ($email) atau NIDN ($nidn) sama dengan yang didaftarkan di aplikasi tersebut.'
        );
      }

      // LANGKAH 2: Cari data mahasiswa di 'pengajuan_skripsi' berdasarkan ID Dosbing
      final skripsiQuery = await _externalDb!
          .collection('pengajuan_skripsi')
          .where('id_dosbing', isEqualTo: dosbingDocumentId)
          .get();

      final results = <SkripsiStudent>[];

      for (final doc in skripsiQuery.docs) {
        final student = SkripsiStudent.fromMap(doc.data(), doc.id);
        results.add(student);
      }

      return (students: results, error: null);
    } catch (e) {
      return (students: <SkripsiStudent>[], error: 'Gagal mengambil data: $e');
    }
  }

  /// Ambil semua koleksi yang ada (untuk debugging).
  Future<List<String>> listCollections() async {
    await initialize();
    try {
      // Firestore tidak punya API langsung untuk list koleksi dari client SDK,
      // tapi kita bisa coba beberapa koleksi umum
      return ['users', 'mahasiswa', 'skripsi', 'bimbingan', 'dosen'];
    } catch (_) {
      return [];
    }
  }
}
