// assignment_list_screen.dart
// Halaman untuk menampilkan semua tugas dari semua kelas yang diikuti siswa.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/student_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/helpers.dart';
import '../models/assignment_model.dart';

class AssignmentListScreen extends StatelessWidget {
  const AssignmentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final StudentController controller = Get.find<StudentController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Semua Tugas'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Obx(() {
        final assignments = controller.allAssignments;

        if (assignments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_outlined,
                    size: 64.sp, color: AppColors.textTertiary),
                SizedBox(height: 16.h),
                Text(
                  'Belum ada tugas',
                  style: AppStyles.headingS.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Bergabunglah ke kelas untuk melihat tugas',
                  style: AppStyles.bodyM.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadDashboardData,
          color: AppColors.primary,
          child: ListView.builder(
            padding: EdgeInsets.all(20.w),
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              final assignment = assignments[index];
              final hasSubmitted = controller.hasSubmitted(assignment.id);
              
              return _AssignmentItem(
                assignment: assignment,
                hasSubmitted: hasSubmitted,
                onTap: () => controller.openExam(assignment),
              );
            },
          ),
        );
      }),
    );
  }
}

class _AssignmentItem extends StatelessWidget {
  final AssignmentModel assignment;
  final bool hasSubmitted;
  final VoidCallback onTap;

  const _AssignmentItem({
    required this.assignment,
    required this.hasSubmitted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isExpired = assignment.isExpired;

    return GestureDetector(
      onTap: hasSubmitted || isExpired ? null : onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: AppStyles.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(assignment.title, style: AppStyles.labelL),
                ),
                _StatusBadge(hasSubmitted: hasSubmitted, isExpired: isExpired),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.timer_outlined, size: 14.sp, color: AppColors.textSecondary),
                SizedBox(width: 4.w),
                Text('${assignment.durationMinutes} menit', style: AppStyles.bodyS),
                SizedBox(width: 16.w),
                Icon(Icons.quiz_outlined, size: 14.sp, color: AppColors.textSecondary),
                SizedBox(width: 4.w),
                Text('${assignment.totalQuestions} soal', style: AppStyles.bodyS),
              ],
            ),
            SizedBox(height: 10.h),
            Divider(color: AppColors.border, height: 1),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Batas: ${Helpers.formatDateTime(assignment.deadline)}',
                  style: AppStyles.bodyS.copyWith(
                    color: isExpired ? AppColors.error : AppColors.textSecondary,
                  ),
                ),
                if (!hasSubmitted && !isExpired)
                  Icon(Icons.arrow_forward_rounded, size: 16.sp, color: AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool hasSubmitted;
  final bool isExpired;

  const _StatusBadge({required this.hasSubmitted, required this.isExpired});

  @override
  Widget build(BuildContext context) {
    String text = 'Tersedia';
    Color color = AppColors.primary;
    Color bgColor = AppColors.primaryLight;

    if (hasSubmitted) {
      text = 'Selesai';
      color = AppColors.success;
      bgColor = AppColors.successLight;
    } else if (isExpired) {
      text = 'Terlewat';
      color = AppColors.textSecondary;
      bgColor = AppColors.surfaceSecondary;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: AppStyles.labelS.copyWith(color: color, fontSize: 10.sp),
      ),
    );
  }
}
