// export_service.dart
// Service untuk membuat dan mengekspor laporan nilai ke format PDF dan Excel.
// Digunakan oleh guru (laporan kelas) dan siswa (laporan pribadi).

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../features/student/models/submission_model.dart';
import '../core/utils/helpers.dart';

class ExportService {
  // ========================
  // EXPORT PDF
  // ========================

  /// Buat file PDF laporan nilai dan bagikan.
  /// [submissions] = list nilai siswa, [assignmentTitle] = nama tugas.
  Future<String?> exportToPdf({
    required List<SubmissionModel> submissions,
    required String assignmentTitle,
    required String className,
    bool isStudentReport = false,
  }) async {
    try {
      // Buat dokumen PDF baru
      final pdf = pw.Document();

      // Hitung rata-rata
      final scores = submissions.map((s) => s.score).toList();
      final average = Helpers.calculateAverage(scores);

      // Tambahkan halaman ke PDF
      pdf.addPage(
        pw.MultiPage(
          // Ukuran kertas A4
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),

          // Header halaman
          header: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'LAPORAN NILAI',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                isStudentReport ? 'Nama: $assignmentTitle' : 'Tugas: $assignmentTitle',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                'Kelas: $className',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                'Tanggal: ${Helpers.formatDate(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.Divider(),
              pw.SizedBox(height: 8),
            ],
          ),

          // Konten utama
          build: (context) => [
            // Summary rata-rata
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.indigo50,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Rata-rata: ${Helpers.formatScore(average)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    isStudentReport ? 'Jumlah Tugas: ${submissions.length}' : 'Jumlah Siswa: ${submissions.length}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Tabel nilai
            pw.TableHelper.fromTextArray(
              headers: ['No', isStudentReport ? 'Nama Tugas' : 'Nama Siswa', 'Nilai', 'Benar', 'Salah', 'Grade'],
              data: List.generate(submissions.length, (index) {
                final s = submissions[index];
                return [
                  '${index + 1}',
                  isStudentReport ? s.assignmentTitle : s.studentName,
                  Helpers.formatScore(s.score),
                  '${s.correctCount}',
                  '${s.wrongCount}',
                  s.grade,
                ];
              }),
              // Style tabel
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo),
              rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
              oddRowDecoration: pw.BoxDecoration(color: PdfColors.grey.shade(0.1)),
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FixedColumnWidth(30),
                1: const pw.FlexColumnWidth(3),
                2: const pw.FixedColumnWidth(50),
                3: const pw.FixedColumnWidth(45),
                4: const pw.FixedColumnWidth(45),
                5: const pw.FixedColumnWidth(45),
              },
            ),
          ],
        ),
      );

      // Simpan file PDF ke folder temporary
      final directory = await getTemporaryDirectory();
      final fileName = 'laporan_${assignmentTitle.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      // Bagikan file via share sheet
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Laporan Nilai - $assignmentTitle',
      );

      return null; // null = sukses

    } catch (e) {
      print('Export PDF Error: $e');
      return 'Gagal membuat PDF. Pastikan izin penyimpanan diberikan.';
    }
  }

  // ========================
  // EXPORT EXCEL
  // ========================

  /// Buat file Excel laporan nilai dan bagikan.
  Future<String?> exportToExcel({
    required List<SubmissionModel> submissions,
    required String assignmentTitle,
    required String className,
    bool isStudentReport = false,
  }) async {
    try {
      // Buat workbook Excel baru
      final excel = Excel.createExcel();
      final sheet = excel['Laporan Nilai'];

      // ====== BARIS HEADER ======
      // Judul laporan
      sheet.cell(CellIndex.indexByString('A1')).value =
          TextCellValue('LAPORAN NILAI - $assignmentTitle');
      sheet.cell(CellIndex.indexByString('A2')).value =
          TextCellValue('Kelas: $className');
      sheet.cell(CellIndex.indexByString('A3')).value =
          TextCellValue('Tanggal: ${Helpers.formatDate(DateTime.now())}');

      // Baris kosong
      // Row 4 = kosong

      // Header kolom tabel (row 5)
      final headers = ['No', isStudentReport ? 'Nama Tugas' : 'Nama Siswa', 'Nilai', 'Jawaban Benar', 'Jawaban Salah', 'Grade', 'Waktu Submit'];
      for (int i = 0; i < headers.length; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 4));
        cell.value = TextCellValue(headers[i]);
        // Style header (bold)
        cell.cellStyle = CellStyle(bold: true);
      }

      // ====== DATA SISWA ======
      for (int i = 0; i < submissions.length; i++) {
        final s = submissions[i];
        final rowIndex = i + 5; // Mulai dari row ke-6

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .value = IntCellValue(i + 1);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
            .value = TextCellValue(isStudentReport ? s.assignmentTitle : s.studentName);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
            .value = DoubleCellValue(s.score);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
            .value = IntCellValue(s.correctCount);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
            .value = IntCellValue(s.wrongCount);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
            .value = TextCellValue(s.grade);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
            .value = TextCellValue(Helpers.formatDateTime(s.submittedAt));
      }

      // Tambahkan summary di bawah (opsional)
      final summaryRow = submissions.length + 6;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: summaryRow)).value = 
          TextCellValue(isStudentReport ? 'Total Tugas: ${submissions.length}' : 'Total Siswa: ${submissions.length}');

      // Hapus sheet default yang kosong
      excel.delete('Sheet1');

      // Simpan file Excel
      final directory = await getTemporaryDirectory();
      final fileName = 'laporan_${assignmentTitle.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final file = File('${directory.path}/$fileName');
      
      final bytes = excel.encode();
      if (bytes == null) return 'Gagal memproses data Excel.';
      await file.writeAsBytes(bytes);

      // Bagikan file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Laporan Nilai - $assignmentTitle',
      );

      return null;

    } catch (e) {
      print('Export Excel Error: $e');
      return 'Gagal membuat Excel. Pastikan izin penyimpanan diberikan.';
    }
  }
}
