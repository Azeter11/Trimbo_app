// supervised_students_screen.dart
// Layar "Lihat Mahasiswa Bimbingan" pada profil dosen.
// Mengambil data dari Firebase eksternal (monitoring skripsi)
// berdasarkan NIDN/NUPTK dan email dosen yang login.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../services/skripsi_monitoring_service.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/helpers.dart';

class SupervisedStudentsScreen extends StatefulWidget {
  const SupervisedStudentsScreen({super.key});

  @override
  State<SupervisedStudentsScreen> createState() => _SupervisedStudentsScreenState();
}

class _SupervisedStudentsScreenState extends State<SupervisedStudentsScreen> {
  final SkripsiMonitoringService _service = Get.find<SkripsiMonitoringService>();
  final AuthController _authController = Get.find<AuthController>();

  List<SkripsiStudent> _students = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final user = _authController.currentUser.value;
    if (user == null) {
      setState(() {
        _error = 'Sesi tidak ditemukan. Silakan login ulang.';
        _isLoading = false;
      });
      return;
    }

    final nidn = user.nuptk ?? '';
    final email = user.email;

    if (nidn.isEmpty && email.isEmpty) {
      setState(() {
        _error = 'Data profil Anda (NIDN/Email) tidak lengkap. Silakan lengkapi profil terlebih dahulu.';
        _isLoading = false;
      });
      return;
    }

    final result = await _service.getStudentsBySupervisor(
      nidn: nidn,
      email: email,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result.error != null) {
          _error = result.error;
        } else {
          _students = result.students;
        }
      });
    }
  }

  List<SkripsiStudent> get _filteredStudents {
    if (_searchQuery.isEmpty) return _students;
    final q = _searchQuery.toLowerCase();
    return _students.where((s) {
      return s.nama.toLowerCase().contains(q) ||
          s.nim.toLowerCase().contains(q) ||
          s.email.toLowerCase().contains(q) ||
          s.judulSkripsi.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Mahasiswa Bimbingan', style: AppStyles.headingS),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            color: AppColors.primary,
            tooltip: 'Refresh',
            onPressed: _loadStudents,
          ),
        ],
      ),
      body: Column(
        children: [
          // ====== INFO BANNER ======
          _buildInfoBanner(),

          // ====== SEARCH BAR ======
          if (!_isLoading && _error == null && _students.isNotEmpty)
            _buildSearchBar(),

          // ====== CONTENT ======
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    final user = _authController.currentUser.value;
    final nidn = user?.nuptk ?? '-';

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.hub_rounded, color: Colors.white, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Terhubung ke Monitoring Skripsi',
                  style: AppStyles.labelL.copyWith(color: Colors.white),
                ),
                SizedBox(height: 2.h),
                Text(
                  'NIDN/NUPTK: $nidn',
                  style: AppStyles.bodyS.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 8.w,
            height: 8.h,
            decoration: const BoxDecoration(
              color: Color(0xFF4ADE80),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: AppStyles.bodyM,
        decoration: InputDecoration(
          hintText: 'Cari nama, NIM, atau judul skripsi...',
          hintStyle: AppStyles.bodyS.copyWith(color: AppColors.textTertiary),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20.sp),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, size: 18.sp),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.cardBackground,
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
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) return _buildLoading();
    if (_error != null) return _buildError();
    if (_students.isEmpty) return _buildEmpty();

    final filtered = _filteredStudents;
    if (filtered.isEmpty) return _buildNoSearchResult();

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
      itemCount: filtered.length,
      itemBuilder: (_, i) => _buildStudentCard(filtered[i], i),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ),
          SizedBox(height: 16.h),
          Text(
            'Menghubungkan ke server\nmonitoring skripsi...',
            style: AppStyles.bodyM.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72.w,
              height: 72.h,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.cloud_off_rounded, size: 36.sp, color: AppColors.error),
            ),
            SizedBox(height: 16.h),
            Text('Gagal Terhubung', style: AppStyles.headingS),
            SizedBox(height: 8.h),
            Text(
              _error!,
              style: AppStyles.bodyM.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: _loadStudents,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Pastikan NIDN/NUPTK Anda sudah terdaftar\ndi aplikasi monitoring skripsi.',
              style: AppStyles.bodyS.copyWith(color: AppColors.textTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    final user = _authController.currentUser.value;
    final nidn = user?.nuptk ?? '';

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.school_outlined, size: 40.sp, color: AppColors.primary),
            ),
            SizedBox(height: 16.h),
            Text('Belum Ada Mahasiswa', style: AppStyles.headingS),
            SizedBox(height: 8.h),
            Text(
              nidn.isEmpty
                  ? 'NIDN/NUPTK Anda belum diisi di profil.\nSilakan lengkapi profil terlebih dahulu.'
                  : 'Belum ada mahasiswa yang memilih Anda\nsebagai dosen pembimbing skripsi\ndi aplikasi monitoring.',
              style: AppStyles.bodyM.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            OutlinedButton.icon(
              onPressed: _loadStudents,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 48.sp, color: AppColors.textTertiary),
          SizedBox(height: 12.h),
          Text(
            'Tidak ada hasil untuk\n"$_searchQuery"',
            style: AppStyles.bodyM.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(SkripsiStudent student, int index) {
    // Warna status bimbingan
    Color statusColor;
    IconData statusIcon;
    switch (student.statusBimbingan.toLowerCase()) {
      case 'aktif':
      case 'active':
      case 'berjalan':
        statusColor = const Color(0xFF22C55E);
        statusIcon = Icons.check_circle_outline_rounded;
        break;
      case 'selesai':
      case 'done':
      case 'lulus':
        statusColor = AppColors.primary;
        statusIcon = Icons.verified_rounded;
        break;
      case 'ditunda':
      case 'pending':
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Icons.pause_circle_outline_rounded;
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusIcon = Icons.info_outline_rounded;
    }

    // Warna avatar berdasarkan index
    final avatarColors = [
      [AppColors.primary, AppColors.secondary],
      [AppColors.secondary, const Color(0xFF8B5CF6)],
      [const Color(0xFF8B5CF6), const Color(0xFFEC4899)],
      [const Color(0xFFEC4899), AppColors.primary],
    ];
    final gradient = avatarColors[index % avatarColors.length];

    final initials = student.nama.isNotEmpty
        ? student.nama.trim().split(' ').take(2).map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join()
        : '?';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () => _showStudentDetail(student),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: AppStyles.labelL.copyWith(color: Colors.white),
                  ),
                ),
              ),

              SizedBox(width: 12.w),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama & status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            student.nama.isNotEmpty ? student.nama : '(Nama tidak tersedia)',
                            style: AppStyles.labelL,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 10.sp, color: statusColor),
                              SizedBox(width: 3.w),
                              Text(
                                student.statusBimbingan,
                                style: AppStyles.bodyS.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 4.h),

                    // NIM & Email
                    Text(
                      student.nim.isNotEmpty ? 'NIM: ${student.nim}' : student.email,
                      style: AppStyles.bodyS.copyWith(color: AppColors.textSecondary),
                    ),

                    SizedBox(height: 6.h),

                    // Judul Skripsi
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.article_outlined, size: 12.sp, color: AppColors.textTertiary),
                          SizedBox(width: 5.w),
                          Expanded(
                            child: Text(
                              student.judulSkripsi,
                              style: AppStyles.bodyS.copyWith(
                                color: AppColors.textSecondary,
                                fontStyle: student.judulSkripsi == '-'
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 4.w),
              Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20.sp),
            ],
          ),
        ),
      ),
    );
  }

  void _showStudentDetail(SkripsiStudent student) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 32.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 20.h),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              Text('Detail Mahasiswa', style: AppStyles.headingS),
              SizedBox(height: 20.h),

              _detailRow(Icons.person_outline_rounded, 'Nama Lengkap', student.nama.isNotEmpty ? student.nama : '-'),
              _detailRow(Icons.badge_outlined, 'NIM', student.nim.isNotEmpty ? student.nim : '-'),
              _detailRow(Icons.email_outlined, 'Email', student.email.isNotEmpty ? student.email : '-'),
              _detailRow(Icons.menu_book_outlined, 'Judul Skripsi', student.judulSkripsi),
              _detailRow(Icons.timeline_rounded, 'Status Bimbingan', student.statusBimbingan),
              if (student.tanggalDaftar != null)
                _detailRow(
                  Icons.calendar_today_outlined,
                  'Tanggal Mendaftar',
                  '${student.tanggalDaftar!.day}/${student.tanggalDaftar!.month}/${student.tanggalDaftar!.year}',
                ),

              SizedBox(height: 16.h),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text('Tutup', style: AppStyles.labelL.copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.sp, color: AppColors.primary),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppStyles.bodyS.copyWith(color: AppColors.textSecondary)),
                SizedBox(height: 2.h),
                Text(value, style: AppStyles.labelL),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
