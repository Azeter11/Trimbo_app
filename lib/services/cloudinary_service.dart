import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class CloudinaryService {
  static const String cloudName = 'drm5xenjq';
  static const String uploadPreset = 'trimbo_preset';
  
  // Endpoint auto akan otomatis mendeteksi tipe file (image/raw/video)
  static const String apiUrl = 'https://api.cloudinary.com/v1_1/$cloudName/auto/upload';

  /// Upload file ke Cloudinary
  static Future<String?> uploadFile({
    required String fileName,
    File? file,
    Uint8List? bytes,
    String folder = 'general',
  }) async {
    try {
      if (file == null && bytes == null) {
        throw Exception('File atau bytes harus disediakan');
      }

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = 'trimbo_app/$folder';
      
      if (bytes != null) {
        request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName));
      } else if (file != null) {
        request.files.add(await http.MultipartFile.fromPath('file', file.path, filename: fileName));
      }

      debugPrint('Mulai mengunggah ke Cloudinary...');
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = json.decode(response.body);
        String secureUrl = responseData['secure_url'];
        debugPrint('File berhasil diupload ke Cloudinary: $secureUrl');
        return secureUrl;
      } else {
        debugPrint('Cloudinary Error: ${response.statusCode} - ${response.body}');
        Get.snackbar('Upload Gagal', 'Gagal menyimpan file ke Cloudinary. Kode: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Cloudinary Exception: $e');
      Get.snackbar('Upload Gagal', 'Terjadi kesalahan sistem saat upload file.');
      return null;
    }
  }

  /// Upload gambar ke Cloudinary
  static Future<String?> uploadImage({
    required String fileName,
    File? file,
    Uint8List? bytes,
    String folder = 'images',
  }) async {
    return await uploadFile(
      fileName: fileName,
      file: file,
      bytes: bytes,
      folder: folder,
    );
  }

  /// Upload PDF ke Cloudinary
  static Future<String?> uploadPDF({
    required String fileName,
    File? file,
    Uint8List? bytes,
    String folder = 'documents',
  }) async {
    return await uploadFile(
      fileName: fileName,
      file: file,
      bytes: bytes,
      folder: folder,
    );
  }

  /// Upload Word document ke Cloudinary
  static Future<String?> uploadWordDocument({
    required String fileName,
    File? file,
    Uint8List? bytes,
    String folder = 'word_documents',
  }) async {
    return await uploadFile(
      fileName: fileName,
      file: file,
      bytes: bytes,
      folder: folder,
    );
  }

  // Dummy method untuk kompatibilitas, karena unsigned preset tidak bisa menghapus file
  static Future<bool> deleteFile(String downloadUrl) async {
    debugPrint('Simulasi hapus file Cloudinary diabaikan untuk unsigned preset.');
    return true;
  }
}
