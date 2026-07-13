import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class FirebaseStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload file ke Firebase Storage
  /// [filePath] - lokasi folder di Firebase Storage (contoh: 'essay_submissions', 'question_images')
  /// [fileName] - nama file yang akan disimpan
  /// [file] - File object (untuk mobile/desktop)
  /// [bytes] - Uint8List bytes (untuk web atau fallback)
  /// [contentType] - MIME type file (contoh: 'application/pdf', 'image/jpeg')
  static Future<String?> uploadFile({
    required String filePath,
    required String fileName,
    File? file,
    Uint8List? bytes,
    String contentType = 'application/octet-stream',
  }) async {
    try {
      // Validasi input
      if (file == null && bytes == null) {
        throw Exception('File atau bytes harus disediakan');
      }

      if (fileName.isEmpty || filePath.isEmpty) {
        throw Exception('File path dan nama file tidak boleh kosong');
      }

      // Buat reference ke Firebase Storage
      final Reference storageRef = _storage.ref().child(filePath).child(fileName);
      
      // Setup metadata
      final SettableMetadata metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
          'uploadedBy': 'trimbo_app',
        },
      );

      // Upload berdasarkan platform
      UploadTask uploadTask;
      
      if (file != null && !kIsWeb) {
        // Upload menggunakan File (Android/iOS/Desktop)
        uploadTask = storageRef.putFile(file, metadata);
      } else if (bytes != null) {
        // Upload menggunakan bytes (Web atau fallback)
        uploadTask = storageRef.putData(bytes, metadata);
      } else {
        throw Exception('Tidak dapat menentukan method upload yang sesuai');
      }

      // Monitoring progress upload (optional)
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        debugPrint('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
      });

      // Tunggu hingga upload selesai
      final TaskSnapshot snapshot = await uploadTask;
      
      // Tunggu sedikit untuk memastikan file tersimpan di backend
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Ambil download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      debugPrint('File berhasil diupload: $downloadUrl');
      return downloadUrl;

    } on FirebaseException catch (e) {
      String errorMessage = 'Gagal upload file';
      
      switch (e.code) {
        case 'unauthorized':
          errorMessage = 'Akses ditolak. Periksa Firebase Storage Rules.';
          break;
        case 'canceled':
          errorMessage = 'Upload dibatalkan.';
          break;
        case 'invalid-argument':
          errorMessage = 'Argumen tidak valid.';
          break;
        case 'invalid-checksum':
          errorMessage = 'File rusak saat upload.';
          break;
        case 'retry-limit-exceeded':
          errorMessage = 'Batas percobaan upload terlampaui.';
          break;
        case 'invalid-url':
          errorMessage = 'URL Firebase Storage tidak valid.';
          break;
        case 'no-default-bucket':
          errorMessage = 'Bucket Firebase Storage belum dikonfigurasi.';
          break;
        case 'cannot-slice-blob':
          errorMessage = 'File terlalu besar atau rusak.';
          break;
        case 'server-file-wrong-size':
          errorMessage = 'Ukuran file tidak sesuai dengan yang diterima server.';
          break;
        default:
          errorMessage = 'Error Firebase Storage: ${e.message}';
      }
      
      debugPrint('FirebaseStorageService Error: ${e.code} - ${e.message}');
      Get.snackbar('Upload Gagal', errorMessage);
      return null;

    } catch (e) {
      debugPrint('FirebaseStorageService Unexpected Error: $e');
      Get.snackbar('Upload Gagal', 'Terjadi kesalahan: ${e.toString()}');
      return null;
    }
  }

  /// Upload gambar ke Firebase Storage
  static Future<String?> uploadImage({
    required String fileName,
    File? file,
    Uint8List? bytes,
    String folder = 'images',
  }) async {
    return await uploadFile(
      filePath: folder,
      fileName: fileName,
      file: file,
      bytes: bytes,
      contentType: 'image/jpeg',
    );
  }

  /// Upload PDF ke Firebase Storage
  static Future<String?> uploadPDF({
    required String fileName,
    File? file,
    Uint8List? bytes,
    String folder = 'documents',
  }) async {
    return await uploadFile(
      filePath: folder,
      fileName: fileName,
      file: file,
      bytes: bytes,
      contentType: 'application/pdf',
    );
  }

  /// Upload Word document ke Firebase Storage
  static Future<String?> uploadWordDocument({
    required String fileName,
    File? file,
    Uint8List? bytes,
    String folder = 'word_documents',
  }) async {
    return await uploadFile(
      filePath: folder,
      fileName: fileName,
      file: file,
      bytes: bytes,
      contentType: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    );
  }

  /// Hapus file dari Firebase Storage
  static Future<bool> deleteFile(String downloadUrl) async {
    try {
      final Reference fileRef = _storage.refFromURL(downloadUrl);
      await fileRef.delete();
      debugPrint('File berhasil dihapus: $downloadUrl');
      return true;
    } catch (e) {
      debugPrint('Gagal menghapus file: $e');
      return false;
    }
  }

  /// Cek apakah file exists di Firebase Storage
  static Future<bool> fileExists(String downloadUrl) async {
    try {
      final Reference fileRef = _storage.refFromURL(downloadUrl);
      await fileRef.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Dapatkan metadata file
  static Future<FullMetadata?> getFileMetadata(String downloadUrl) async {
    try {
      final Reference fileRef = _storage.refFromURL(downloadUrl);
      return await fileRef.getMetadata();
    } catch (e) {
      debugPrint('Gagal mendapatkan metadata: $e');
      return null;
    }
  }
}