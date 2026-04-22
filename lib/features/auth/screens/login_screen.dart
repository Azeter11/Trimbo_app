// login_screen.dart
// Halaman login untuk masuk ke aplikasi EduTask.
// Fitur: validasi form, loading state, navigasi ke register & lupa password.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../app/routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil controller yang sudah terdaftar di GetX
    final AuthController controller = Get.find<AuthController>();

    return Obx(
      () => LoadingOverlay(
        isLoading: controller.isLoading.value,
        message: 'Sedang masuk...',
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Form(
                key: controller.loginFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 48.h),

                    // ====== HEADER ======
                    _buildHeader(),

                    SizedBox(height: 40.h),

                    // ====== FORM LOGIN ======
                    _buildLoginForm(controller),

                    SizedBox(height: 24.h),

                    // ====== TOMBOL LOGIN ======
                    PrimaryButton(
                      text: AppStrings.loginButton,
                      onPressed: controller.login,
                      isLoading: controller.isLoading.value,
                    ),

                    SizedBox(height: 16.h),

                    // ====== LINK LUPA PASSWORD ======
                    Center(
                      child: TextLinkButton(
                        text: AppStrings.loginForgotPassword,
                        onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                        color: AppColors.textSecondary,
                      ),
                    ),

                    SizedBox(height: 40.h),

                    // ====== DIVIDER ======
                    Row(
                      children: [
                        Expanded(child: Divider(color: AppColors.border)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            'atau',
                            style: AppStyles.bodyS,
                          ),
                        ),
                        Expanded(child: Divider(color: AppColors.border)),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // ====== TOMBOL GOOGLE ======
                    OutlineButton(
                      text: 'Masuk dengan Google',
                      onPressed: controller.loginWithGoogle,
                      leading: const _GoogleIcon(size: 20),
                      borderColor: AppColors.border,
                      textColor: AppColors.textPrimary,
                    ),

                    SizedBox(height: 24.h),

                    // ====== TOMBOL DAFTAR ======
                    _buildRegisterSection(),

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Widget bagian header (logo + judul)
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mini logo
        Container(
          width: 56.w,
          height: 56.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Image.asset(
              'assets/icons/TrimboIcon.png',
              fit: BoxFit.cover,
            ),
          ),
        ),

        SizedBox(height: 24.h),

        // Judul
        Text(AppStrings.loginTitle, style: AppStyles.headingL),

        SizedBox(height: 8.h),

        // Sub-judul
        Text(
          AppStrings.loginSubtitle,
          style: AppStyles.bodyM.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  /// Widget form input email dan password
  Widget _buildLoginForm(AuthController controller) {
    return Column(
      children: [
        // Input Email
        CustomTextField(
          label: AppStrings.loginEmail,
          hint: AppStrings.loginEmailHint,
          controller: controller.loginEmailController,
          keyboardType: TextInputType.emailAddress,
          validator: Validators.email,
          prefixIcon: Icon(
            Icons.email_outlined,
            color: AppColors.textSecondary,
            size: 20.sp,
          ),
          textInputAction: TextInputAction.next,
        ),

        SizedBox(height: 16.h),

        // Input Password
        PasswordTextField(
          label: AppStrings.loginPassword,
          controller: controller.loginPasswordController,
          validator: Validators.password,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  /// Widget bagian link daftar akun baru
  Widget _buildRegisterSection() {
    return Column(
      children: [
        // Label
        Center(
          child: Text(
            'Belum punya akun? Daftar sebagai:',
            style: AppStyles.bodyM.copyWith(color: AppColors.textSecondary),
          ),
        ),

        SizedBox(height: 12.h),

        // Dua tombol: Siswa dan Guru
        Row(
          children: [
            // Tombol daftar sebagai siswa
            Expanded(
              child: OutlineButton(
                text: AppStrings.registerAsStudent,
                onPressed: () => Get.toNamed(AppRoutes.registerStudent),
                leadingIcon: Icons.person_outline_rounded,
              ),
            ),

            SizedBox(width: 12.w),

            // Tombol daftar sebagai guru
            Expanded(
              child: OutlineButton(
                text: AppStrings.registerAsTeacher,
                onPressed: () => Get.toNamed(AppRoutes.registerTeacher),
                leadingIcon: Icons.school_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ========================
// GOOGLE ICON (CustomPainter)
// ========================

/// Widget ikon Google 'G' berwarna resmi, digambar dengan CustomPainter.
/// Tidak memerlukan aset gambar — murni vektor Flutter, tajam di semua resolusi.
class _GoogleIcon extends StatelessWidget {
  final double size;
  const _GoogleIcon({this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // ---- Latar bulat putih (opsional background, dikomentari agar transparan) ----

    // === Lingkaran merah ===
    final paintRed = Paint()..color = const Color(0xFFEA4335);
    // === Lingkaran biru ===
    final paintBlue = Paint()..color = const Color(0xFF4285F4);
    // === Lingkaran hijau ===
    final paintGreen = Paint()..color = const Color(0xFF34A853);
    // === Lingkaran kuning ===
    final paintYellow = Paint()..color = const Color(0xFFFBBC05);

    // Gambar arc untuk membentuk huruf G menggunakan path
    // (Simplified 4-color G logo)

    // Biru: kiri atas → sudut 210° ke 330° (area biru kanan)
    final path = Path();

    // Garis biru horizontal kanan (bar tengah G)
    final barY = cy - r * 0.05;
    final barRight = cx + r;
    final barLeft = cx + r * 0.08;
    final barH = r * 0.3;

    // Gambar arc lingkaran luar dengan 4 warna
    // Merah: 270° → 360° + sedikit (atas dan kanan atas)
    // Kuning: kiri bawah
    // Hijau: bawah
    // Biru: kiri atas + bar

    // Gunakan arc segment
    void drawArc(Paint paint, double startDeg, double sweepDeg) {
      final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.95);
      final p = Path()
        ..moveTo(cx, cy)
        ..arcTo(
          rect,
          startDeg * (3.14159 / 180),
          sweepDeg * (3.14159 / 180),
          false,
        )
        ..close();
      canvas.drawPath(p, paint);
    }

    // Merah: atas (315° → 45° = 90° span)
    drawArc(paintRed, -45, 90);
    // Kuning: kiri atas (45° → 135°)
    drawArc(paintYellow, 45, 90);
    // Hijau: bawah (135° → 225°)
    drawArc(paintGreen, 135, 90);
    // Biru: kiri bawah + bar (225° → 315°)
    drawArc(paintBlue, 225, 90);

    // Lubang tengah (warna putih untuk membentuk huruf G)
    final hole = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), r * 0.55, hole);

    // Bar horizontal biru (kanan)
    final barPaint = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTRB(cx - r * 0.05, barY, barRight, barY + barH),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
