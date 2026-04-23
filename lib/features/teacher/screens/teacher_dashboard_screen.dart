// teacher_dashboard_screen.dart
// Dashboard utama guru: sapaan, stat card, daftar kelas, FAB buat kelas.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/teacher_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../app/routes.dart';
import '../../student/models/assignment_model.dart';
import '../../student/models/class_model.dart';
import '../../auth/models/user_model.dart';
import '../../../core/utils/helpers.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TeacherController controller = Get.put(TeacherController());
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(
        () => RefreshIndicator(
          onRefresh: controller.loadDashboardData,
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(authController, controller),
              ),
              SliverToBoxAdapter(
                child: _buildStatCards(controller),
              ),
              SliverToBoxAdapter(
                child: _buildRecentClasses(controller),
              ),
              SliverToBoxAdapter(
                child: _buildRecentAssignments(controller),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 100.h)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.createClass),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          AppStrings.createNewClass,
          style: AppStyles.buttonText.copyWith(fontSize: 13.sp),
        ),
      ),
    );
  }

  Widget _buildHeader(AuthController auth, TeacherController controller) {
    final user = auth.currentUser.value;
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 56.h, 24.w, 28.h),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.secondary, AppColors.primary],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.teacherDashboardGreeting,
                  style: AppStyles.bodyM.copyWith(color: Colors.white70),
                ),
                Text(
                  user?.fullName.split(' ').first ?? 'Guru',
                  style: AppStyles.headingL.copyWith(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
                if (user?.institution != null)
                  Text(
                    user!.institution!,
                    style: AppStyles.bodyS.copyWith(color: Colors.white60),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.teacherProfile),
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
                  user?.initials ?? '?',
                  style: AppStyles.headingS.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(TeacherController controller) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.class_rounded,
              label: AppStrings.totalClasses,
              value: '${controller.totalClasses}',
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _StatCard(
              icon: Icons.people_rounded,
              label: AppStrings.totalStudents,
              value: '${controller.totalStudents}',
              color: AppColors.secondary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _StatCard(
              icon: Icons.assignment_turned_in_rounded,
              label: AppStrings.activeAssignments,
              value: '${controller.activeAssignmentsCount.value}',
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentClasses(TeacherController controller) {
    final classes = controller.myClasses;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.recentClasses, style: AppStyles.headingS),
              if (classes.length > 5)
                TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.teacherClassList),
                  child: Text(
                    AppStrings.viewAll,
                    style: AppStyles.labelS.copyWith(color: AppColors.primary),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          if (classes.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(32.w),
                child: Column(
                  children: [
                    Icon(Icons.class_outlined,
                        size: 48.sp, color: AppColors.textTertiary),
                    SizedBox(height: 12.h),
                    Text(
                      'Belum ada kelas',
                      style: AppStyles.bodyM
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Tekan + untuk membuat kelas pertama',
                      style: AppStyles.bodyS,
                    ),
                  ],
                ),
              ),
            )
          else
            // Tampilkan maksimal 5 kelas terbaru
            ...classes.take(5).map((classData) => GestureDetector(
                  onTap: () => controller.openClassManagement(classData),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.all(16.w),
                    decoration: AppStyles.cardDecoration,
                    child: Row(
                      children: [
                        // Ikon kelas
                        Container(
                          width: 48.w,
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.class_rounded,
                            color: AppColors.primary,
                            size: 24.sp,
                          ),
                        ),

                        SizedBox(width: 12.w),

                        // Info kelas
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
                              SizedBox(height: 2.h),
                              Row(
                                children: [
                                  Icon(Icons.people_outlined,
                                      size: 14.sp,
                                      color: AppColors.textSecondary),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '${classData.totalStudents} siswa',
                                    style: AppStyles.bodyS,
                                  ),
                                  SizedBox(width: 8.w),
                                  // Kode kelas
                                  Flexible(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 6.w, vertical: 2.h),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight,
                                        borderRadius: BorderRadius.circular(4.r),
                                      ),
                                      child: Text(
                                        classData.classCode,
                                        style: AppStyles.labelS.copyWith(
                                          color: AppColors.primary,
                                          fontFamily: 'monospace',
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        Icon(Icons.arrow_forward_ios_rounded,
                            size: 14.sp, color: AppColors.textTertiary),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildRecentAssignments(TeacherController controller) {
    final assignments = controller.allAssignments;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          Text('Tugas Terbaru', style: AppStyles.headingS),
          SizedBox(height: 12.h),
          if (assignments.isEmpty)
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: AppStyles.cardDecorationLight,
              child: Text('Belum ada tugas yang diterbitkan',
                  style: AppStyles.bodyM),
            )
          else
            ...assignments.take(5).map((assignment) => GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.studentGrades,
                      arguments: assignment),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.all(16.w),
                    decoration: AppStyles.cardDecoration,
                    child: Row(
                      children: [
                        Icon(Icons.assignment_rounded,
                            color: AppColors.secondary, size: 24.sp),
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
                                'Deadline: ${Helpers.formatDateTime(assignment.deadline)}',
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
                )),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(height: 8.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: AppStyles.headingM.copyWith(color: color)),
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
    );
  }
}
