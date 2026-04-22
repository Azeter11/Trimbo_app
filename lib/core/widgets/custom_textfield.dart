// custom_textfield.dart
// Widget input teks yang dipakai ulang di seluruh form aplikasi EduTask.
// Mendukung: password (dengan toggle visibility), multiline, dan OTP input.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

// ========================
// INPUT TEKS BIASA
// ========================

/// Input teks standard dengan label, hint, dan validasi.
class CustomTextField extends StatelessWidget {
  final String label;                        // Label di atas input
  final String? hint;                        // Teks placeholder
  final TextEditingController controller;    // Controller untuk baca/tulis nilai
  final String? Function(String?)? validator; // Fungsi validasi
  final TextInputType keyboardType;          // Tipe keyboard (email, angka, dll)
  final bool readOnly;                       // Hanya baca (tidak bisa diubah)
  final int? maxLines;                       // Jumlah baris (1 = single line)
  final int? maxLength;                      // Batas karakter
  final Widget? prefixIcon;                  // Ikon di kiri
  final Widget? suffixIcon;                  // Ikon di kanan
  final FocusNode? focusNode;                // Focus node untuk kontrol keyboard
  final VoidCallback? onTap;                 // Aksi saat input ditekan
  final Function(String)? onChanged;        // Aksi saat nilai berubah
  final TextInputAction? textInputAction;    // Tombol aksi di keyboard (next, done)
  final List<TextInputFormatter>? inputFormatters; // Format input (huruf kapital, dll)

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.focusNode,
    this.onTap,
    this.onChanged,
    this.textInputAction,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      readOnly: readOnly,
      maxLines: maxLines,
      maxLength: maxLength,
      focusNode: focusNode,
      onTap: onTap,
      onChanged: onChanged,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      style: AppStyles.bodyM.copyWith(color: AppColors.textPrimary),
      decoration: AppStyles.inputDecoration(
        label: label,
        hint: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

// ========================
// INPUT PASSWORD (DENGAN TOGGLE)
// ========================

/// Input kata sandi dengan tombol show/hide.
class PasswordTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  const PasswordTextField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.focusNode,
    this.textInputAction,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  /// Status apakah password ditampilkan (true) atau disembunyikan (false)
  bool _isPasswordVisible = false;

  /// Toggle visibilitas password
  void _toggleVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      focusNode: widget.focusNode,
      textInputAction: widget.textInputAction,
      // obscureText true = tampilkan sebagai ****
      obscureText: !_isPasswordVisible,
      style: AppStyles.bodyM.copyWith(color: AppColors.textPrimary),
      decoration: AppStyles.inputDecoration(
        label: widget.label,
        hint: 'Minimal 8 karakter',
        // Ikon gembok di kiri
        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          color: AppColors.textSecondary,
          size: 20.sp,
        ),
        // Tombol show/hide di kanan
        suffixIcon: GestureDetector(
          onTap: _toggleVisibility,
          child: Icon(
            // Tampilkan ikon sesuai status visibilitas
            _isPasswordVisible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppColors.textSecondary,
            size: 20.sp,
          ),
        ),
      ),
    );
  }
}

// ========================
// INPUT OTP (6 KOTAK)
// ========================

/// Input OTP dengan 6 kotak dan auto-focus ke kotak berikutnya.
class OtpTextField extends StatefulWidget {
  final Function(String) onCompleted; // Dipanggil saat 6 digit terisi semua
  final Function(String) onChanged;   // Dipanggil setiap ada perubahan

  const OtpTextField({
    super.key,
    required this.onCompleted,
    required this.onChanged,
  });

  @override
  State<OtpTextField> createState() => _OtpTextFieldState();
}

class _OtpTextFieldState extends State<OtpTextField> {
  // List controller untuk setiap kotak OTP
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  // List focus node untuk kontrol perpindahan fokus antar kotak
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    // Bersihkan memory saat widget dihapus
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  /// Ambil nilai OTP saat ini (gabungan semua kotak)
  String get _currentOtp =>
      _controllers.map((c) => c.text).join();

  /// Handle saat nilai kotak berubah
  void _onChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      // Auto-focus ke kotak berikutnya
      _focusNodes[index + 1].requestFocus();
    }

    widget.onChanged(_currentOtp);

    // Jika semua kotak terisi, panggil onCompleted
    if (_currentOtp.length == 6) {
      widget.onCompleted(_currentOtp);
    }
  }

  /// Handle backspace: kembali ke kotak sebelumnya
  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        6,
        (index) => _buildOtpBox(index),
      ),
    );
  }

  /// Build satu kotak OTP
  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 48.w,
      height: 56.h,
      child: KeyboardListener(
        focusNode: FocusNode(), // Listener terpisah untuk deteksi backspace
        onKeyEvent: (event) => _onKeyEvent(index, event),
        child: TextFormField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1, // Hanya boleh 1 karakter per kotak
          style: AppStyles.headingM.copyWith(color: AppColors.primary),
          onChanged: (value) => _onChanged(index, value),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly, // Hanya angka
          ],
          decoration: InputDecoration(
            counterText: '', // Sembunyikan counter "0/1"
            filled: true,
            fillColor: AppColors.surfaceSecondary,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}
