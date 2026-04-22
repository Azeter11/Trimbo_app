// student_dashboard_screen.dart
// Dashboard utama untuk siswa: sapaan, shortcut kelas/tugas/nilai, deadline mendekat.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/student_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../app/routes.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final StudentController controller = Get.put(StudentController());
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() => RefreshIndicator(
        onRefresh: controller.loadDashboardData,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // ====== HEADER ======
            SliverToBoxAdapter(
              child: _buildHeader(authController, controller),
            ),

            // ====== SHORTCUT CARDS ======
            SliverToBoxAdapter(
              child: _buildShortcutCards(controller),
            ),

            // ====== DEADLINE MENDEKAT ======
            SliverToBoxAdapter(
              child: _buildUpcomingDeadlines(controller),
            ),

            // ====== KELAS SAYA ======
            SliverToBoxAdapter(
              child: _buildMyClasses(controller),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 80.h)),
          ],
        ),
      )),

      // FAB untuk join kelas
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.joinClass),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Gabung Kelas',
          style: AppStyles.buttonText.copyWith(fontSize: 13.sp),
        ),
      ),
    );
  }

  /// Widget header dengan sapaan dan nama siswa.
  Widget _buildHeader(AuthController auth, StudentController controller) {
    final userName = auth.currentUser.value?.fullName ?? 'Siswa';
    final initials = auth.currentUser.value?.initials ?? '?';

    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 56.h, 24.w, 24.h),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.studentDashboardGreeting,
                  style: AppStyles.bodyM.copyWith(color: Colors.white70),
                ),
                Text(
                  userName.split(' ').first, // Tampilkan nama depan saja
                  style: AppStyles.headingL.copyWith(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  AppStrings.studentDashboardSubtitle,
                  style: AppStyles.bodyS.copyWith(color: Colors.white60),
                ),
              ],
            ),
          ),

          // Avatar inisial nama
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.studentProfile),
            child: Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white30, width: 2),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: AppStyles.headingS.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget 3 shortcut card: Kelas, Tugas, Nilai.
  Widget _buildShortcutCards(StudentController controller) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          // Kelas Saya
          Expanded(
            child: _ShortcutCard(
              icon: Icons.class_rounded,
              label: AppStrings.myClasses,
              value: '${controller.myClasses.length}',
              color: AppColors.primary,
              onTap: () {
                if (controller.myClasses.isNotEmpty) {
                  if (controller.myClasses.length == 1) {
                    controller.openClassDetail(controller.myClasses.first);
                  } else {
                    Get.snackbar(
                      'Pilih Kelas',
                      'Silakan pilih salah satu kelas dari daftar di bawah',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.primary,
                      colorText: Colors.white,
                    );
                  }
                } else {
                  Get.toNamed(AppRoutes.joinClass);
                }
              },
            ),
          ),
          SizedBox(width: 12.w),

          // Tugas
          Expanded(
            child: _ShortcutCard(
              icon: Icons.assignment_rounded,
              label: AppStrings.myAssignments,
              value: '${controller.allAssignments.length}',
              color: AppColors.warning,
              onTap: () => Get.toNamed(AppRoutes.assignmentList),
            ),
          ),
          SizedBox(width: 12.w),

          // Nilai
          Expanded(
            child: _ShortcutCard(
              icon: Icons.grade_rounded,
              label: AppStrings.myGrades,
              value: controller.mySubmissions.isEmpty
                  ? '-'
                  : Helpers.formatScore(controller.averageScore),
              color: AppColors.success,
              onTap: () => Get.toNamed(AppRoutes.gradeReport),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget list tugas dengan deadline mendekat (dalam 3 hari).
  Widget _buildUpcomingDeadlines(StudentController controller) {
    final upcoming = controller.upcomingDeadlines;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.alarm_rounded, size: 18.sp, color: AppColors.warning),
              SizedBox(width: 8.w),
              Text(AppStrings.upcomingDeadlines, style: AppStyles.headingS),
            ],
          ),

          SizedBox(height: 12.h),

          if (upcoming.isEmpty)
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: AppStyles.cardDecorationLight,
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline_rounded,
                      color: AppColors.success, size: 20.sp),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      AppStrings.noUpcomingDeadlines,
                      style: AppStyles.bodyM.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
          else
            ...upcoming.map((assignment) => _DeadlineCard(
                  assignment: assignment,
                  onTap: () => controller.openExam(assignment),
                )),

          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  /// Widget list kelas yang diikuti.
  Widget _buildMyClasses(StudentController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(Icons.school_rounded, size: 18.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              Text('Kelas Saya', style: AppStyles.headingS),
            ],
          ),

          SizedBox(height: 12.h),

          if (controller.myClasses.isEmpty)
            Center(
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  Icon(Icons.class_outlined,
                      size: 48.sp, color: AppColors.textTertiary),
                  SizedBox(height: 12.h),
                  Text(
                    'Belum ada kelas',
                    style: AppStyles.bodyM.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Tekan + untuk bergabung ke kelas',
                    style: AppStyles.bodyS,
                  ),
                ],
              ),
            )
          else
            ...controller.myClasses.map((classData) => _ClassCard(
                  classData: classData,
                  onTap: () => controller.openClassDetail(classData),
                )),
        ],
      ),
    );
  }
}

// ========================
// SUB-WIDGETS
// ========================

class _ShortcutCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _ShortcutCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(height: 8.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: AppStyles.headingM.copyWith(color: color),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: AppStyles.bodyS.copyWith(fontSize: 10.sp),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeadlineCard extends StatelessWidget {
  final dynamic assignment;
  final VoidCallback onTap;

  const _DeadlineCard({required this.assignment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.warningLight,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.warning.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.assignment_late_rounded,
                color: AppColors.warning, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assignment.title,
                    style: AppStyles.labelL,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Deadline: ${Helpers.getTimeRemaining(assignment.deadline)}',
                    style: AppStyles.bodyS.copyWith(color: AppColors.warning),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14.sp, color: AppColors.warning),
          ],
        ),
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final dynamic classData;
  final VoidCallback onTap;

  const _ClassCard({required this.classData, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: AppStyles.cardDecoration,
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.class_rounded,
                  color: AppColors.primary, size: 24.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classData.name,
                    style: AppStyles.labelL,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Oleh ${classData.teacherName}',
                    style: AppStyles.bodyS,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14.sp, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
