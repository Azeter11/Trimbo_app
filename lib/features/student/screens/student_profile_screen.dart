// student_profile_screen.dart
// Halaman profil siswa: avatar, data diri, panduan penggunaan, logout.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../app/routes.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.profileTitle),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Obx(
        () {
          final user = authController.currentUser.value;
          if (user == null) return const SizedBox.shrink();

          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                // ====== AVATAR & INFO PENGGUNA ======
                _buildProfileHeader(user),

                SizedBox(height: 24.h),

                // ====== PANDUAN PENGGUNAAN (EXPANDABLE) ======
                _buildGuideSection(),

                SizedBox(height: 16.h),

                // ====== SETTING ======
                _buildSettingsSection(authController),

                SizedBox(height: 32.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: AppStyles.cardDecoration,
      child: Column(
        children: [
          // Avatar inisial
          Container(
            width: 80.w,
            height: 80.h,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.initials,
                style: AppStyles.headingL.copyWith(color: Colors.white),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Nama
          Text(user.fullName, style: AppStyles.headingS),

          SizedBox(height: 4.h),

          // Email
          Text(
            user.email,
            style: AppStyles.bodyM.copyWith(color: AppColors.textSecondary),
          ),

          SizedBox(height: 12.h),

          // Badge role
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_rounded,
                    size: 14.sp, color: AppColors.primary),
                SizedBox(width: 6.w),
                Text(
                  AppStrings.profileRoleStudent,
                  style:
                      AppStyles.labelS.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideSection() {
    return Container(
      decoration: AppStyles.cardDecorationLight,
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        leading: Icon(Icons.menu_book_rounded,
            color: AppColors.primary, size: 22.sp),
        title: Text(AppStrings.profileGuide, style: AppStyles.labelL),
        children: [
          _GuideItem(
            title: AppStrings.profileGuideJoinClass,
            content: AppStrings.guideJoinClassContent,
          ),
          SizedBox(height: 12.h),
          _GuideItem(
            title: AppStrings.profileGuideDoAssignment,
            content: AppStrings.guideDoAssignmentContent,
          ),
          SizedBox(height: 12.h),
          _GuideItem(
            title: AppStrings.profileGuideViewGrades,
            content: AppStrings.guideViewGradesContent,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(AuthController authController) {
    return Column(
      children: [
        // Bantuan & Chatbot
        _SettingsTile(
          icon: Icons.chat_bubble_outline_rounded,
          title: 'Bantuan & FAQ',
          subtitle: 'Tanya Trimbo Assistant',
          onTap: () => Get.toNamed(AppRoutes.chatbot),
        ),

        SizedBox(height: 8.h),

        // Ganti Password
        _SettingsTile(
          icon: Icons.lock_outline_rounded,
          title: AppStrings.profileChangePassword,
          onTap: () => _showChangePasswordDialog(authController),
        ),

        SizedBox(height: 8.h),

        // Logout
        _SettingsTile(
          icon: Icons.logout_rounded,
          title: AppStrings.profileLogout,
          isDestructive: true,
          onTap: () => _showLogoutDialog(authController),
        ),
      ],
    );
  }

  void _showChangePasswordDialog(AuthController controller) {
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppStrings.profileChangePassword),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPassCtrl,
              obscureText: true,
              decoration: AppStyles.inputDecoration(label: 'Kata Sandi Lama'),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: newPassCtrl,
              obscureText: true,
              decoration: AppStyles.inputDecoration(label: 'Kata Sandi Baru'),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: confirmPassCtrl,
              obscureText: true,
              decoration:
                  AppStyles.inputDecoration(label: 'Konfirmasi Kata Sandi Baru'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPassCtrl.text != confirmPassCtrl.text) {
                Get.snackbar('Error', AppStrings.errorPasswordNotMatch,
                    backgroundColor: AppColors.error,
                    colorText: Colors.white);
                return;
              }
              Get.back();
              Get.snackbar(
                'Berhasil',
                'Kata sandi berhasil diubah',
                backgroundColor: AppColors.success,
                colorText: Colors.white,
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(AuthController controller) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppStrings.profileLogoutConfirmTitle),
        content: Text(AppStrings.profileLogoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(AppStrings.buttonCancel),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(AppStrings.profileLogoutConfirmYes),
          ),
        ],
      ),
    );
  }
}

class _GuideItem extends StatelessWidget {
  final String title;
  final String content;

  const _GuideItem({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppStyles.labelL.copyWith(color: AppColors.primary)),
          SizedBox(height: 6.h),
          Text(content, style: AppStyles.bodyM),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;
    final iconBg = isDestructive
        ? AppColors.errorLight
        : subtitle != null
            ? AppColors.primaryLight
            : AppColors.surfaceSecondary;
    final iconColor = isDestructive
        ? AppColors.error
        : subtitle != null
            ? AppColors.primary
            : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: AppStyles.cardDecorationLight,
        child: Row(
          children: [
            // Icon container
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: iconColor, size: 20.sp),
            ),
            SizedBox(width: 14.w),
            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppStyles.labelL.copyWith(color: color)),
                  if (subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle!,
                      style: AppStyles.bodyS.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.sp,
              color: isDestructive ? AppColors.error : AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
