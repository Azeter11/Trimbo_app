// teacher_profile_screen.dart
// Halaman profil guru: data diri, daftar kelas, ganti password, logout.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/teacher_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_styles.dart';
import 'supervised_students_screen.dart';

class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final TeacherController teacherController = Get.find<TeacherController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.profileTitle),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Obx(() {
        final user = authController.currentUser.value;
        if (user == null) return const SizedBox.shrink();

        return SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              // ====== AVATAR & INFO ======
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: AppStyles.cardDecoration,
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 80.w,
                      height: 80.h,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.secondary, AppColors.primary],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(user.initials,
                            style: AppStyles.headingL
                                .copyWith(color: Colors.white)),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    Text(user.fullName, style: AppStyles.headingS),

                    SizedBox(height: 4.h),

                    Text(user.email,
                        style: AppStyles.bodyM
                            .copyWith(color: AppColors.textSecondary)),

                    SizedBox(height: 12.h),

                    // Badge guru
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryLight,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.school_rounded,
                              size: 14.sp, color: AppColors.secondary),
                          SizedBox(width: 6.w),
                          Text(AppStrings.profileRoleTeacher,
                              style: AppStyles.labelS
                                  .copyWith(color: AppColors.secondary)),
                        ],
                      ),
                    ),

                    if (user.nuptk != null || user.institution != null) ...[
                      SizedBox(height: 16.h),
                      Divider(color: AppColors.border),
                      SizedBox(height: 12.h),

                      if (user.nuptk != null)
                        _ProfileRow(
                            label: AppStrings.profileNUPTK,
                            value: user.nuptk!),
                      if (user.institution != null) ...[
                        SizedBox(height: 8.h),
                        _ProfileRow(
                            label: AppStrings.profileInstitution,
                            value: user.institution!),
                      ],
                    ],
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // ====== DAFTAR KELAS ======
              Container(
                decoration: AppStyles.cardDecorationLight,
                child: ExpansionTile(
                  leading: Icon(Icons.class_rounded,
                      color: AppColors.secondary, size: 22.sp),
                  title: Text(
                      'Kelas Saya (${teacherController.myClasses.length})',
                      style: AppStyles.labelL),
                  children: teacherController.myClasses
                      .map((c) => ListTile(
                            leading: Icon(Icons.class_outlined,
                                size: 18.sp, color: AppColors.textSecondary),
                            title: Text(c.name, style: AppStyles.bodyM),
                            subtitle: Text('${c.totalStudents} siswa',
                                style: AppStyles.bodyS),
                          ))
                      .toList(),
                ),
              ),

              SizedBox(height: 16.h),

              // ====== LIHAT MAHASISWA BIMBINGAN (Monitoring Skripsi) ======
              _SettingTile(
                icon: Icons.people_alt_rounded,
                title: 'Lihat Mahasiswa Bimbingan',
                subtitle: 'Data dari sistem monitoring skripsi',
                onTap: () => Get.to(
                  () => const SupervisedStudentsScreen(),
                  transition: Transition.rightToLeft,
                ),
                showBadge: true,
              ),

              SizedBox(height: 8.h),

              // ====== SETTINGS ======
              _SettingTile(
                icon: Icons.lock_outline_rounded,
                title: AppStrings.profileChangePassword,
                onTap: () => _showChangePasswordDialog(context, authController),
              ),

              SizedBox(height: 8.h),

              _SettingTile(
                icon: Icons.logout_rounded,
                title: AppStrings.profileLogout,
                isDestructive: true,
                onTap: () => Get.dialog(AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: Text(AppStrings.profileLogoutConfirmTitle),
                  content: Text(AppStrings.profileLogoutConfirmMessage),
                  actions: [
                    TextButton(
                        onPressed: () => Get.back(),
                        child: Text(AppStrings.buttonCancel)),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        authController.logout();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error),
                      child: Text(AppStrings.profileLogoutConfirmYes),
                    ),
                  ],
                )),
              ),

              SizedBox(height: 32.h),
            ],
          ),
        );
      }),
    );
  }

  /// Tampilkan dialog ganti password.
  void _showChangePasswordDialog(
      BuildContext context, AuthController authController) {
    Get.dialog(
      AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title:
            Text(AppStrings.profileChangePassword, style: AppStyles.headingS),
        content: SingleChildScrollView(
          child: Form(
            key: authController.changePasswordFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: authController.currentPasswordController,
                  obscureText: true,
                  style: AppStyles.bodyM,
                  decoration: InputDecoration(
                    labelText: 'Kata Sandi Lama',
                    labelStyle: AppStyles.bodyS,
                    hintText: 'Masukkan kata sandi saat ini',
                    hintStyle: AppStyles.bodyS.copyWith(color: AppColors.textTertiary),
                  ),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Wajib diisi' : null,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: authController.newPasswordController,
                  obscureText: true,
                  style: AppStyles.bodyM,
                  decoration: InputDecoration(
                    labelText: 'Kata Sandi Baru',
                    labelStyle: AppStyles.bodyS,
                    hintText: 'Minimal 8 karakter',
                    hintStyle: AppStyles.bodyS.copyWith(color: AppColors.textTertiary),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Wajib diisi';
                    if (value.length < 8) return 'Minimal 8 karakter';
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: authController.confirmNewPasswordController,
                  obscureText: true,
                  style: AppStyles.bodyM,
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Kata Sandi Baru',
                    labelStyle: AppStyles.bodyS,
                  ),
                  validator: (value) {
                    if (value != authController.newPasswordController.text) {
                      return 'Konfirmasi tidak sesuai';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              authController.currentPasswordController.clear();
              authController.newPasswordController.clear();
              authController.confirmNewPasswordController.clear();
              Get.back();
            },
            child: Text(AppStrings.buttonCancel),
          ),
          Obx(() => ElevatedButton(
                onPressed: authController.isLoading.value
                    ? null
                    : () => authController.changePassword(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: authController.isLoading.value
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(AppStrings.buttonSave),
              )),
        ],
      ),
      barrierDismissible: false,
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: AppStyles.bodyS
                .copyWith(color: AppColors.textSecondary)),
        const Spacer(),
        Text(value, style: AppStyles.labelL),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool showBadge;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.isDestructive = false,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isDestructive ? AppColors.error : AppColors.textPrimary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: AppStyles.cardDecorationLight,
        child: Row(
          children: [
            // Icon dengan badge opsional
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: showBadge ? AppColors.primary : color, size: 22.sp),
                if (showBadge)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 8.w,
                      height: 8.h,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyles.labelL.copyWith(
                      color: showBadge ? AppColors.primary : color,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle!,
                      style: AppStyles.bodyS.copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.sp,
              color: isDestructive
                  ? AppColors.error
                  : showBadge
                      ? AppColors.primary
                      : AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
