// grade_report_screen.dart
// Halaman laporan nilai siswa: list nilai, rata-rata, bar chart, export PDF/Excel.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/student_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../services/export_service.dart';

class GradeReportScreen extends StatelessWidget {
  const GradeReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final StudentController controller = Get.find<StudentController>();
    final ExportService exportService = ExportService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.gradeReportTitle),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Obx(() {
        final submissions = controller.mySubmissions;

        if (submissions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.grade_outlined,
                    size: 64.sp, color: AppColors.textTertiary),
                SizedBox(height: 16.h),
                Text(
                  'Belum ada nilai',
                  style: AppStyles.headingS.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Kerjakan tugas untuk melihat nilai',
                  style: AppStyles.bodyM.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ====== SUMMARY CARD ======
              _buildSummaryCard(controller),

              SizedBox(height: 24.h),

              // ====== BAR CHART ======
              Text('Nilai per Tugas', style: AppStyles.headingS),

              SizedBox(height: 12.h),

              _buildBarChart(controller),

              SizedBox(height: 24.h),

              // ====== LIST NILAI ======
              Text('Riwayat Nilai', style: AppStyles.headingS),

              SizedBox(height: 12.h),

              ...submissions.map((s) => _GradeCard(submission: s)),

              SizedBox(height: 24.h),

              // ====== TOMBOL EXPORT ======
              Row(
                children: [
                   Expanded(
                    child: PrimaryButton(
                      text: AppStrings.gradeExportPDF,
                      height: 48.h,
                      fontSize: 12.sp,
                      onPressed: () async {
                        final error = await exportService.exportToPdf(
                          submissions: controller.mySubmissions,
                          assignmentTitle: 'Laporan Keseluruhan',
                          className: 'Laporan Pribadi',
                        );
                        if (error != null) {
                          Get.snackbar('Error', error,
                              backgroundColor: AppColors.error,
                              colorText: Colors.white);
                        }
                      },
                      leadingIcon: Icons.picture_as_pdf_rounded,
                      backgroundColor: AppColors.error,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: PrimaryButton(
                      text: AppStrings.gradeExportExcel,
                      height: 48.h,
                      fontSize: 12.sp,
                      onPressed: () async {
                        final error = await exportService.exportToExcel(
                          submissions: controller.mySubmissions,
                          assignmentTitle: 'Laporan Keseluruhan',
                          className: 'Laporan Pribadi',
                        );
                        if (error != null) {
                          Get.snackbar('Error', error,
                              backgroundColor: AppColors.error,
                              colorText: Colors.white);
                        }
                      },
                      leadingIcon: Icons.table_chart_rounded,
                      backgroundColor: AppColors.success,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.h),
            ],
          ),
        );
      }),
    );
  }

  /// Card summary rata-rata dan total tugas.
  Widget _buildSummaryCard(StudentController controller) {
    final average = controller.averageScore;
    final total = controller.completedCount;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                Helpers.formatScore(average),
                style: AppStyles.headingXL.copyWith(
                  color: Colors.white,
                  fontSize: 40.sp,
                ),
              ),
              Text(
                AppStrings.gradeAverage,
                style: AppStyles.bodyM.copyWith(color: Colors.white70),
              ),
            ],
          ),
          Container(width: 1, height: 60.h, color: Colors.white30),
          Column(
            children: [
              Text(
                '$total',
                style: AppStyles.headingXL.copyWith(
                  color: Colors.white,
                  fontSize: 40.sp,
                ),
              ),
              Text(
                AppStrings.gradeCompleted,
                style: AppStyles.bodyM.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Bar chart nilai per tugas menggunakan fl_chart.
  Widget _buildBarChart(StudentController controller) {
    final submissions = controller.mySubmissions;

    // Batasi hanya tampilkan 5 tugas terakhir agar chart tidak terlalu padat
    final displayedSubmissions = submissions.take(5).toList();

    return Container(
      height: 200.h,
      padding: EdgeInsets.all(16.w),
      decoration: AppStyles.cardDecoration,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            // Sumbu Y (nilai)
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: AppStyles.bodyS,
                  );
                },
                interval: 25,
              ),
            ),
            // Sumbu X (nomor tugas)
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < displayedSubmissions.length) {
                    return Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text(
                        'T${index + 1}',
                        style: AppStyles.bodyS,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.border,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(displayedSubmissions.length, (index) {
            final score = displayedSubmissions[index].score;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: score,
                  color: AppColors.gradeColor(score),
                  width: 20.w,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _GradeCard extends StatelessWidget {
  final dynamic submission;

  const _GradeCard({required this.submission});

  @override
  Widget build(BuildContext context) {
    final scoreColor = AppColors.gradeColor(submission.score.toDouble());

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: AppStyles.cardDecorationLight,
      child: Row(
        children: [
          // Grade badge
          Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Text(
                submission.grade,
                style: AppStyles.headingS.copyWith(color: scoreColor),
              ),
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tugas ${submission.assignmentId.substring(0, 6)}',
                  style: AppStyles.labelL,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  Helpers.formatDateShort(submission.submittedAt),
                  style: AppStyles.bodyS,
                ),
              ],
            ),
          ),

          Text(
            submission.score.toStringAsFixed(1),
            style: AppStyles.headingS.copyWith(color: scoreColor),
          ),
        ],
      ),
    );
  }
}
