// docx_parser_service.dart
// Service untuk mengekstrak teks dari file .docx dan mem-parsing soal pilihan ganda
// menggunakan aturan Regex (Rule-Based Parsing).
//
// PERBAIKAN v2:
// - _cleanLine(): Normalisasi karakter tersembunyi dari Microsoft Word
//   (non-breaking space \u00A0, zero-width chars, smart quotes, dsb.)
// - Regex diperbarui agar toleran terhadap Tab (\t) sebagai separator,
//   yang dihasilkan oleh fitur Numbered List bawaan Word.
// - Tambah processDocxBytes() untuk menerima Uint8List langsung (tanpa path file).
// - Debug logging saat parsing gagal total.

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:docx_to_text/docx_to_text.dart';

/// Model sementara untuk menyimpan hasil parsing satu soal.
class ParsedQuestion {
  final String questionText;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer;

  const ParsedQuestion({
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
  });
}

/// Hasil dari proses parsing dokumen Word.
class DocxParseResult {
  final List<ParsedQuestion> questions;
  final int failedCount;
  final String? error;

  const DocxParseResult({
    required this.questions,
    this.failedCount = 0,
    this.error,
  });
}

class DocxParserService {
  // ========================
  // NORMALISASI TEKS
  // ========================

  /// Membersihkan satu baris dari karakter tersembunyi yang dihasilkan
  /// oleh Microsoft Word saat dokumen .docx diekstrak ke teks mentah.
  ///
  /// Karakter yang dibersihkan:
  /// - \u00A0 : Non-breaking space (spasi khusus Word)
  /// - \u200B : Zero-width space
  /// - \uFEFF : Byte Order Mark (BOM)
  /// - \u200C : Zero-width non-joiner
  /// - \u200D : Zero-width joiner
  /// - \u2019, \u2018 : Smart single quotes (' ')
  /// - \u201C, \u201D : Smart double quotes (" ")
  /// - \uFF21-\uFF44 : Huruf A-D full-width (Ａ, Ｂ, Ｃ, Ｄ)
  /// - \t : Tab dikonversi ke satu spasi
  static String _cleanLine(String line) {
    return line
        // Hapus karakter tak terlihat
        .replaceAll('\u200B', '')
        .replaceAll('\uFEFF', '')
        .replaceAll('\u200C', '')
        .replaceAll('\u200D', '')
        // Ganti non-breaking space dengan spasi biasa
        .replaceAll('\u00A0', ' ')
        // Ganti smart quotes dengan kutip biasa
        .replaceAll('\u2018', "'")
        .replaceAll('\u2019', "'")
        .replaceAll('\u201C', '"')
        .replaceAll('\u201D', '"')
        // Ganti full-width A-D dengan huruf ASCII biasa
        .replaceAll('\uFF21', 'A')
        .replaceAll('\uFF22', 'B')
        .replaceAll('\uFF23', 'C')
        .replaceAll('\uFF24', 'D')
        .replaceAll('\uFF41', 'a')
        .replaceAll('\uFF42', 'b')
        .replaceAll('\uFF43', 'c')
        .replaceAll('\uFF44', 'd')
        // Ganti tab dengan spasi tunggal
        .replaceAll('\t', ' ')
        // Hapus \r (carriage return)
        .replaceAll('\r', '')
        // Trim spasi di awal dan akhir
        .trim();
  }

  // ========================
  // EKSTRAK TEKS
  // ========================

  /// Mengekstrak teks mentah dari bytes file .docx.
  String extractText(Uint8List bytes) {
    return docxToText(bytes, handleNumbering: true);
  }

  // ========================
  // PARSING SOAL
  // ========================

  /// Mem-parsing teks mentah menjadi daftar soal pilihan ganda.
  ///
  /// Format yang didukung:
  /// ```
  /// 1. Teks pertanyaan?
  /// A. Pilihan A
  /// B. Pilihan B
  /// C. Pilihan C
  /// D. Pilihan D
  /// Jawaban: A
  /// ```
  ///
  /// Variasi yang didukung:
  /// - Nomor soal  : `1.` atau `1)` atau `1 ` (dari Numbered List Word)
  /// - Pilihan     : `A.` atau `A)` (case-insensitive, termasuk full-width)
  /// - Kunci jawaban: `Jawaban: A`, `jawaban a`, `Kunci: A`, `Kunci Jawaban: A`
  DocxParseResult parseQuestions(String rawText) {
    if (rawText.trim().isEmpty) {
      return const DocxParseResult(
        questions: [],
        error: 'Dokumen Word kosong atau tidak berisi teks.',
      );
    }

    // Split dengan \n atau \r\n, lalu bersihkan setiap baris
    final lines = rawText
        .split(RegExp(r'\r?\n'))
        .map(_cleanLine)
        .toList();

    final List<ParsedQuestion> parsedQuestions = [];
    int failedCount = 0;

    // ---- REGEX PATTERNS ----
    // Mendukung: "1. teks", "1) teks", "1 teks" (dari Numbered List Word yang
    // kadang menghasilkan "1\tteks" → setelah _cleanLine menjadi "1 teks")
    final questionStartRegex = RegExp(r'^\d+[\.\)\s]\s*(.+)');

    // Mendukung: "A. teks", "A) teks" dan juga "1. teks" (karena fitur auto-numbering
    // MS Word seringkali dikonversi menjadi "1. " oleh library docx_to_text)
    final optionARegex = RegExp(r'^([Aa]|1)[\.\)]\s*(.+)');
    final optionBRegex = RegExp(r'^([Bb]|2)[\.\)]\s*(.+)');
    final optionCRegex = RegExp(r'^([Cc]|3)[\.\)]\s*(.+)');
    final optionDRegex = RegExp(r'^([Dd]|4)[\.\)]\s*(.+)');

    // Mendukung berbagai format kunci jawaban (case-insensitive):
    // "Jawaban: A", "jawaban a", "Kunci: B", "Kunci Jawaban: C", dll.
    // Juga mendukung format angka (1=A, 2=B, 3=C, 4=D) jika user salah ketik akibat auto-numbering.
    final answerRegex = RegExp(
      r'^(?:kunci\s*jawaban|jawaban|kunci)\s*[:=\-]?\s*([A-Da-d1-4])',
      caseSensitive: false,
    );

    bool isOptionOrAnswer(String line) {
      if (line.isEmpty) return false;
      return optionARegex.hasMatch(line) ||
          optionBRegex.hasMatch(line) ||
          optionCRegex.hasMatch(line) ||
          optionDRegex.hasMatch(line) ||
          answerRegex.hasMatch(line);
    }

    int i = 0;
    while (i < lines.length) {
      // Lewati baris kosong sebelum mencari soal baru
      if (lines[i].isEmpty) {
        i++;
        continue;
      }

      // Cari awal soal (nomor soal)
      final questionMatch = questionStartRegex.firstMatch(lines[i]);
      if (questionMatch == null) {
        i++;
        continue;
      }

      // Ambil teks pertanyaan (bisa multi-baris)
      final questionTextParts = <String>[questionMatch.group(1)!.trim()];
      i++;

      // Kumpulkan baris-baris pertanyaan lanjutan (sebelum pilihan A)
      while (i < lines.length &&
          !isOptionOrAnswer(lines[i]) &&
          !questionStartRegex.hasMatch(lines[i])) {
        if (lines[i].isNotEmpty) {
          questionTextParts.add(lines[i]);
        }
        i++;
      }

      final questionText = questionTextParts.join('\n').trim();

      // Helper untuk parsing satu opsi (A, B, C, atau D), mendukung multiline
      String? parseOption(RegExp regex) {
        // Lewati baris kosong
        while (i < lines.length && lines[i].isEmpty) { i++; }
        if (i >= lines.length) return null;

        final match = regex.firstMatch(lines[i]);
        if (match == null) return null;

        // match.group(1) adalah huruf opsi (A/B/C/D) atau angka (1/2/3/4)
        // match.group(2) adalah teks pilihannya
        final parts = <String>[match.group(2)!.trim()];
        i++;

        // Kumpulkan baris lanjutan dari pilihan ini
        while (i < lines.length &&
            !isOptionOrAnswer(lines[i]) &&
            !questionStartRegex.hasMatch(lines[i])) {
          if (lines[i].isNotEmpty) {
            parts.add(lines[i]);
          }
          i++;
        }
        return parts.join('\n').trim();
      }

      // Parsing opsi secara berurutan A → B → C → D
      final String? optA = parseOption(optionARegex);
      final String? optB = parseOption(optionBRegex);
      final String? optC = parseOption(optionCRegex);
      final String? optD = parseOption(optionDRegex);

      // Lewati baris kosong sebelum kunci jawaban
      while (i < lines.length && lines[i].isEmpty) { i++; }

      // Parsing kunci jawaban
      String? correctAnswer;
      if (i < lines.length) {
        final matchAnswer = answerRegex.firstMatch(lines[i]);
        if (matchAnswer != null) {
          String ans = matchAnswer.group(1)!.toUpperCase();
          // Konversi angka kembali ke huruf jika user menggunakan angka 1-4 untuk jawaban
          if (ans == '1') ans = 'A';
          else if (ans == '2') ans = 'B';
          else if (ans == '3') ans = 'C';
          else if (ans == '4') ans = 'D';
          
          correctAnswer = ans;
          i++;
        }
      }

      // Validasi kelengkapan soal
      if (questionText.isNotEmpty &&
          optA != null && optA.isNotEmpty &&
          optB != null && optB.isNotEmpty &&
          optC != null && optC.isNotEmpty &&
          optD != null && optD.isNotEmpty &&
          correctAnswer != null) {
        parsedQuestions.add(ParsedQuestion(
          questionText: questionText,
          optionA: optA,
          optionB: optB,
          optionC: optC,
          optionD: optD,
          correctAnswer: correctAnswer,
        ));
      } else {
        // Soal tidak lengkap, hitung sebagai gagal
        failedCount++;
        debugPrint(
          '[DocxParser] Soal gagal diparsing:\n'
          '  Pertanyaan: "$questionText"\n'
          '  A: "$optA" | B: "$optB" | C: "$optC" | D: "$optD"\n'
          '  Jawaban: "$correctAnswer"',
        );
      }
    }

    // Jika tidak ada soal sama sekali, tampilkan debug awal teks
    if (parsedQuestions.isEmpty && failedCount == 0) {
      final previewText = rawText.length > 200
          ? rawText.substring(0, 200)
          : rawText;
      debugPrint(
        '[DocxParser] Tidak ada soal terdeteksi.\n'
        '  Preview 200 karakter pertama teks:\n$previewText',
      );
      return const DocxParseResult(
        questions: [],
        error: 'Tidak ditemukan soal pilihan ganda dalam dokumen.\n'
            'Pastikan format sesuai dengan aturan penulisan.',
      );
    }

    return DocxParseResult(
      questions: parsedQuestions,
      failedCount: failedCount,
    );
  }

  // ========================
  // ENTRY POINTS
  // ========================

  /// Proses lengkap dari bytes: ekstrak teks → parsing soal.
  /// Gunakan ini jika sudah memiliki bytes (misal dari FilePicker.withData: true).
  Future<DocxParseResult> processDocxBytes(Uint8List bytes) async {
    try {
      final rawText = extractText(bytes);
      return parseQuestions(rawText);
    } catch (e) {
      debugPrint('[DocxParser] processDocxBytes error: $e');
      return DocxParseResult(
        questions: [],
        error: 'Gagal memproses file Word: ${e.toString()}',
      );
    }
  }

  /// Proses lengkap dari path file: baca file → ekstrak teks → parsing soal.
  /// Gunakan ini jika memiliki path file (mobile/desktop).
  Future<DocxParseResult> processDocxFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return const DocxParseResult(
          questions: [],
          error: 'File tidak ditemukan.',
        );
      }

      final bytes = await file.readAsBytes();
      return processDocxBytes(bytes);
    } catch (e) {
      debugPrint('[DocxParser] processDocxFile error: $e');
      return DocxParseResult(
        questions: [],
        error: 'Gagal membaca file Word: ${e.toString()}',
      );
    }
  }
}
