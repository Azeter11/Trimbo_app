// class_management_screen.dart
// Halaman manajemen kelas guru: info kelas, daftar tugas, daftar siswa.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/teacher_controller.dart';
import '../controllers/assignment_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../student/models/class_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/helpers.dart';
import '../../../app/routes.dart';

class ClassManagementScreen extends StatefulWidget {
  const ClassManagementScreen({super.key});

  @override
  State<ClassManagementScreen> createState() => _ClassManagementScreenState();
}

class _ClassManagementScreenState extends State<ClassManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ClassModel classData = Get.arguments as ClassModel;
    final TeacherController controller = Get.find<TeacherController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 180.h,
            pinned: true,
            backgroundColor: AppColors.secondary,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.secondary, AppColors.primary],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 80.h, 24.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(classData.name,
                          style: AppStyles.headingM
                              .copyWith(color: Colors.white)),
                      SizedBox(height: 4.h),
                      Text(classData.description,
                          style: AppStyles.bodyS
                              .copyWith(color: Colors.white70),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      SizedBox(height: 10.h),
                      // Kode kelas + tombol copy
                      Row(
                        children: [
                          Icon(Icons.vpn_key_rounded,
                              size: 14.sp, color: Colors.white70),
                          SizedBox(width: 6.w),
                          Text(classData.classCode,
                              style: AppStyles.labelL.copyWith(
                                  color: Colors.white,
                                  letterSpacing: 2)),
                          SizedBox(width: 8.w),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                  ClipboardData(text: classData.classCode));
                              Get.snackbar('Disalin!',
                                  'Kode kelas disalin ke clipboard',
                                  backgroundColor: AppColors.success,
                                  colorText: Colors.white,
                                  duration: const Duration(seconds: 2));
                            },
                            child: Icon(Icons.copy_rounded,
                                size: 16.sp, color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: [
                Tab(text: AppStrings.classManagementAssignments),
                Tab(text: '${AppStrings.classManagementStudents} (${classData.totalStudents})'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Daftar Tugas
            _buildAssignmentsTab(controller, classData),
            // Tab 2: Daftar Siswa
            _buildStudentsTab(classData),
          ],
        ),
      ),

      // FAB buat tugas baru
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Pastikan AssignmentController terdaftar sebelum navigasi
          Get.put(AssignmentController());
          Get.toNamed(AppRoutes.createAssignment, arguments: {
            'classId': classData.id,
            'teacherId': Get.find<AuthController>().currentUser.value?.uid,
          });
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          AppStrings.createNewAssignment,
          style: AppStyles.buttonText.copyWith(fontSize: 13.sp),
        ),
      ),
    );
  }

  Widget _buildAssignmentsTab(
      TeacherController controller, ClassModel classData) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final assignments = controller.classAssignments;

      if (assignments.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_outlined,
                    size: 64.sp, color: AppColors.textTertiary),
                SizedBox(height: 16.h),
                Text(AppStrings.noAssignmentsYet,
                    style: AppStyles.bodyM
                        .copyWith(color: AppColors.textSecondary)),
                SizedBox(height: 8.h),
                Text('Tekan + untuk membuat tugas baru',
                    style: AppStyles.bodyS),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 80.h),
        itemCount: assignments.length,
        itemBuilder: (context, index) {
          final assignment = assignments[index];
          return GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.studentGrades,
                arguments: assignment),
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
                          child: Text(
                            assignment.title,
                            style: AppStyles.headingS,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                      if (assignment.isExpired)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSecondary,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text('Selesai',
                              style: AppStyles.labelS.copyWith(
                                  color: AppColors.textSecondary)),
                        ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 13.sp, color: AppColors.textSecondary),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          'Deadline: ${Helpers.formatDateTime(assignment.deadline)}',
                          style: AppStyles.bodyS,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.people_outline_rounded,
                          size: 13.sp, color: AppColors.textSecondary),
                      SizedBox(width: 4.w),
                      Text('0 ${AppStrings.submissions}',
                          style: AppStyles.bodyS),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildStudentsTab(ClassModel classData) {
    if (classData.studentIds.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline_rounded,
                  size: 64.sp, color: AppColors.textTertiary),
              SizedBox(height: 16.h),
              Text(AppStrings.noStudentsYet,
                  style: AppStyles.bodyM
                      .copyWith(color: AppColors.textSecondary)),
              SizedBox(height: 8.h),
              Text('Bagikan kode: ${classData.classCode}',
                  style: AppStyles.labelL.copyWith(color: AppColors.primary)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: classData.studentIds.length,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.all(14.w),
          decoration: AppStyles.cardDecorationLight,
          child: Row(
            children: [
              // Avatar nomor urut
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: AppStyles.labelL.copyWith(color: AppColors.primary),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Siswa ${index + 1}',
                        style: AppStyles.labelL),
                    Text(
                        'ID: ${classData.studentIds[index].substring(0, 8)}...',
                        style: AppStyles.bodyS),
                  ],
                ),
              ),
              Icon(Icons.person_rounded,
                  color: AppColors.textTertiary, size: 18.sp),
            ],
          ),
        );
      },
    );
  }
}
