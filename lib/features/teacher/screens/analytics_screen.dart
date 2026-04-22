// analytics_screen.dart
// Halaman analitik kelas: distribusi nilai, rata-rata per tugas, siswa aktif.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/teacher_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_styles.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TeacherController controller = Get.find<TeacherController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.analyticsTitle),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ====== DISTRIBUSI NILAI (PIE CHART) ======
            Text(AppStrings.gradeDistribution, style: AppStyles.headingS),

            SizedBox(height: 12.h),

            Container(
              padding: EdgeInsets.all(20.w),
              decoration: AppStyles.cardDecoration,
              child: Column(
                children: [
                  SizedBox(
                    height: 180.h,
                    child: PieChart(
                      PieChartData(
                        sections: _buildPieSections(),
                        centerSpaceRadius: 40.r,
                        sectionsSpace: 3,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Legend
                  Wrap(
                    spacing: 16.w,
                    runSpacing: 8.h,
                    alignment: WrapAlignment.center,
                    children: [
                      _LegendItem(label: 'A (≥90)', color: AppColors.success),
                      _LegendItem(label: 'B (≥80)', color: AppColors.info),
                      _LegendItem(label: 'C (≥70)', color: AppColors.warning),
                      _LegendItem(label: 'D (≥60)',
                          color: const Color(0xFFFF6B35)),
                      _LegendItem(label: 'E (<60)', color: AppColors.error),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // ====== RATA-RATA PER TUGAS (LINE CHART) ======
            Text(AppStrings.averagePerAssignment, style: AppStyles.headingS),

            SizedBox(height: 12.h),

            Container(
              height: 200.h,
              padding: EdgeInsets.all(16.w),
              decoration: AppStyles.cardDecoration,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _buildLineSpots(),
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                      dotData: FlDotData(show: true),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (v, _) =>
                            Text(v.toInt().toString(), style: AppStyles.bodyS),
                        interval: 25,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) => Text('T${v.toInt() + 1}',
                            style: AppStyles.bodyS),
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    getDrawingHorizontalLine: (v) =>
                        FlLine(color: AppColors.border, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // ====== SISWA AKTIF VS TIDAK AKTIF ======
            Obx(() {
              final totalStudents = controller.totalStudents;
              // Simulasi: anggap 70% aktif
              final activeCount = (totalStudents * 0.7).round();
              final inactiveCount = totalStudents - activeCount;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status Siswa', style: AppStyles.headingS),

                  SizedBox(height: 12.h),

                  Row(
                    children: [
                      Expanded(
                        child: _StatusCard(
                          label: AppStrings.activeStudents,
                          count: activeCount,
                          color: AppColors.success,
                          icon: Icons.person_rounded,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _StatusCard(
                          label: AppStrings.inactiveStudents,
                          count: inactiveCount,
                          color: AppColors.error,
                          icon: Icons.person_off_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  /// Data untuk pie chart distribusi nilai (contoh/dummy data).
  List<PieChartSectionData> _buildPieSections() {
    return [
      PieChartSectionData(
          value: 30, color: AppColors.success, title: '30%', radius: 50.r),
      PieChartSectionData(
          value: 25, color: AppColors.info, title: '25%', radius: 50.r),
      PieChartSectionData(
          value: 20, color: AppColors.warning, title: '20%', radius: 50.r),
      PieChartSectionData(
          value: 15,
          color: const Color(0xFFFF6B35),
          title: '15%',
          radius: 50.r),
      PieChartSectionData(
          value: 10, color: AppColors.error, title: '10%', radius: 50.r),
    ];
  }

  /// Data untuk line chart rata-rata per tugas (contoh/dummy data).
  List<FlSpot> _buildLineSpots() {
    return [
      const FlSpot(0, 72),
      const FlSpot(1, 68),
      const FlSpot(2, 75),
      const FlSpot(3, 82),
      const FlSpot(4, 79),
    ];
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 12.w,
            height: 12.h,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 4.w),
        Text(label, style: AppStyles.bodyS),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _StatusCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28.sp),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$count',
                  style: AppStyles.headingM.copyWith(color: color)),
              Text(label, style: AppStyles.bodyS),
            ],
          ),
        ],
      ),
    );
  }
}
