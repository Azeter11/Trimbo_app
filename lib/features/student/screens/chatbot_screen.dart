// chatbot_screen.dart
// Halaman chatbot penuh untuk bantuan pengguna.
// Fitur: quick reply, input teks, typing indicator, animasi bubble.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';

// ========================
// MODEL
// ========================

enum _Sender { user, bot }

class _Msg {
  final String text;
  final _Sender sender;
  final DateTime time;
  _Msg(this.text, this.sender) : time = DateTime.now();
}

class _QA {
  final String icon;
  final String label;
  final String question;
  final String answer;
  _QA(this.icon, this.label, this.question, this.answer);
}

// ========================
// DATA FAQ STATIS
// ========================

final List<_QA> _faqs = [
  _QA(
    '📚', 'Gabung Kelas',
    'Bagaimana cara bergabung ke kelas?',
    'Berikut langkah bergabung ke kelas:\n\n'
        '1️⃣  Buka Dashboard → tekan tombol "+" atau "Gabung Kelas".\n'
        '2️⃣  Masukkan kode kelas yang diberikan oleh gurumu.\n'
        '3️⃣  Tekan "Gabung" dan kamu sudah masuk ke kelas! 🎉\n\n'
        'Pastikan kode yang dimasukkan benar ya!',
  ),
  _QA(
    '📝', 'Kerjakan Tugas',
    'Bagaimana cara mengerjakan tugas?',
    'Cara mengerjakan tugas:\n\n'
        '1️⃣  Buka Dashboard / menu Kelas.\n'
        '2️⃣  Pilih kelas yang ingin dibuka → tab "Tugas".\n'
        '3️⃣  Klik tugas yang tersedia → tekan "Mulai Kerjakan".\n'
        '4️⃣  Jawab semua soal dengan teliti.\n'
        '5️⃣  Tekan "Kirim" sebelum deadline berakhir. ⏰\n\n'
        'Tugas yang sudah dikirim tidak bisa diubah kembali!',
  ),
  _QA(
    '🏆', 'Lihat Nilai',
    'Bagaimana cara melihat nilai saya?',
    'Nilai kamu bisa dilihat di beberapa tempat:\n\n'
        '📊  Dashboard → bagian "Nilai & Progres".\n'
        '📋  Menu Kelas → pilih kelas → tab "Nilai".\n'
        '📁  Menu "Laporan Nilai" di sidebar.\n\n'
        'Nilai akan muncul setelah guru selesai menilai tugasmu. ✅',
  ),
  _QA(
    '⏰', 'Cek Deadline',
    'Dimana saya bisa melihat deadline tugas?',
    'Deadline tugas bisa dilihat di:\n\n'
        '🗓️  Dashboard → kartu "Tugas Mendatang" (diurutkan terdekat).\n'
        '📌  Detail Kelas → tab Tugas → tertera batas waktu di setiap tugas.\n\n'
        'Kami sarankan mengecek dashboard setiap hari agar tidak terlewat! ⚡',
  ),
  _QA(
    '🔑', 'Lupa Sandi',
    'Saya lupa kata sandi, bagaimana cara reset?',
    'Cara reset kata sandi:\n\n'
        '1️⃣  Di halaman Login → tekan "Lupa Kata Sandi?".\n'
        '2️⃣  Masukkan alamat email akunmu.\n'
        '3️⃣  Buka email → klik tautan reset yang dikirim.\n'
        '4️⃣  Buat kata sandi baru yang kuat.\n'
        '5️⃣  Login kembali dengan kata sandi baru. 🔐\n\n'
        'Cek folder SPAM jika email tidak masuk.',
  ),
  _QA(
    '📊', 'Progres Belajar',
    'Bagaimana cara melihat progres belajar saya?',
    'Progres belajarmu bisa dipantau di:\n\n'
        '📈  Dashboard → grafik performa nilai.\n'
        '✅  Tab "Tugas" di setiap kelas → berapa tugas sudah selesai.\n'
        '🏅  Laporan Nilai → statistik lengkap per mata pelajaran.\n\n'
        'Terus semangat dan pertahankan progresmu! 💪',
  ),
  _QA(
    '⚠️', 'Tugas Hilang',
    'Tugas saya tidak muncul, kenapa?',
    'Jika tugas tidak muncul, coba langkah berikut:\n\n'
        '1️⃣  Pastikan kamu sudah bergabung ke kelas yang benar.\n'
        '2️⃣  Tarik layar ke bawah untuk refresh data.\n'
        '3️⃣  Periksa koneksi internet kamu.\n'
        '4️⃣  Tutup dan buka ulang aplikasi.\n'
        '5️⃣  Jika masih bermasalah, hubungi gurumu! 👩‍🏫\n\n'
        'Kemungkinan tugas belum dipublikasikan oleh guru.',
  ),
  _QA(
    '👤', 'Ubah Profil',
    'Bagaimana cara mengubah data profil?',
    'Untuk mengubah kata sandi:\n'
        '→ Profil → "Ganti Kata Sandi".\n\n'
        'Untuk nama dan data lainnya, saat ini masih belum bisa diubah langsung. '
        'Silakan hubungi administrator atau guru kelasmu untuk perubahan data. 🏫\n\n'
        'Fitur edit profil lengkap akan hadir di update berikutnya! 🚀',
  ),
];

// ========================
// CHATBOT SCREEN
// ========================

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<_Msg> _messages = [];
  bool _isBotTyping = false;

  final ScrollController _scrollCtrl = ScrollController();
  final TextEditingController _inputCtrl = TextEditingController();
  final FocusNode _inputFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Pesan sambutan bot
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _messages.addAll([
            _Msg(
              'Halo! 👋 Selamat datang di Trimbo Assistant!\n\n'
              'Saya siap membantu menjawab pertanyaanmu seputar penggunaan aplikasi Trimbo.',
              _Sender.bot,
            ),
            _Msg(
              'Pilih topik bantuan di bawah atau ketik pertanyaanmu langsung. 😊',
              _Sender.bot,
            ),
          ]);
        });
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _inputCtrl.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  // ====== LOGIKA CHAT ======

  void _handleSend([String? text]) {
    final trimmed = (text ?? _inputCtrl.text).trim();
    if (trimmed.isEmpty) return;

    _inputCtrl.clear();
    _inputFocus.unfocus();

    setState(() {
      _messages.add(_Msg(trimmed, _Sender.user));
      _isBotTyping = true;
    });
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;

      // Cari jawaban yang cocok dari FAQ
      _QA? matched;
      for (final qa in _faqs) {
        if (trimmed.toLowerCase().contains(
              qa.label.toLowerCase(),
            ) ||
            trimmed.toLowerCase().contains(
              qa.question.split(' ').take(3).join(' ').toLowerCase(),
            )) {
          matched = qa;
          break;
        }
      }

      final answer = matched?.answer ??
          'Maaf, saya belum punya jawaban spesifik untuk pertanyaan tersebut. 🙏\n\n'
              'Coba pilih dari topik bantuan di bawah, atau hubungi guru / administrator sekolahmu ya!';

      setState(() {
        _isBotTyping = false;
        _messages.add(_Msg(answer, _Sender.bot));
      });
      _scrollToBottom();
    });
  }

  void _handleFaqTap(_QA qa) {
    setState(() {
      _messages.add(_Msg(qa.question, _Sender.user));
      _isBotTyping = true;
    });
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _isBotTyping = false;
        _messages.add(_Msg(qa.answer, _Sender.bot));
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ====== BUILD ======

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildMessageArea()),
          _buildQuickReplies(),
          _buildInputBar(),
        ],
      ),
    );
  }

  // -- HEADER --
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              // Tombol kembali
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                ),
              ),

              SizedBox(width: 12.w),

              // Avatar bot dengan animasi pulse
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 46.w,
                    height: 46.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text('🤖', style: TextStyle(fontSize: 24.sp)),
                    ),
                  ),
                  Container(
                    width: 13.w,
                    height: 13.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF34D399),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ],
              ),

              SizedBox(width: 12.w),

              // Info Bot
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trimbo Assistant',
                      style: AppStyles.headingS.copyWith(
                        color: Colors.white,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _isBotTyping ? 'Sedang mengetik...' : '● Online — siap membantu',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),

              // Tombol clear
              GestureDetector(
                onTap: _confirmClear,
                child: Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmClear() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Reset Percakapan?'),
        content: const Text('Pesan percakapan akan dihapus dan dimulai ulang.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              setState(() {
                _messages.clear();
                _messages.add(_Msg(
                  'Halo lagi! 👋 Ada yang bisa saya bantu?\nPilih topik di bawah atau ketik pertanyaanmu! 😊',
                  _Sender.bot,
                ));
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  // -- AREA PESAN --
  Widget _buildMessageArea() {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: _messages.length + (_isBotTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isBotTyping && index == _messages.length) {
          return _TypingIndicator();
        }
        final msg = _messages[index];
        final isBot = msg.sender == _Sender.bot;
        return _ChatBubble(msg: msg, isBot: isBot);
      },
    );
  }

  // -- QUICK REPLIES --
  Widget _buildQuickReplies() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Topik Bantuan',
            style: AppStyles.labelS.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            height: 78.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _faqs.length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (_, i) => _QuickReplyChip(
                qa: _faqs[i],
                onTap: () => _handleFaqTap(_faqs[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -- INPUT BAR --
  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Input field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2F8),
                  borderRadius: BorderRadius.circular(28.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _inputCtrl,
                  focusNode: _inputFocus,
                  maxLines: 3,
                  minLines: 1,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ketik pertanyaanmu di sini...',
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textTertiary,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 12.h,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: _handleSend,
                ),
              ),
            ),

            SizedBox(width: 10.w),

            // Tombol kirim
            GestureDetector(
              onTap: () => _handleSend(),
              child: Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 22.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================
// QUICK REPLY CHIP
// ========================

class _QuickReplyChip extends StatelessWidget {
  final _QA qa;
  final VoidCallback onTap;
  const _QuickReplyChip({required this.qa, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.secondary.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(qa.icon, style: TextStyle(fontSize: 22.sp)),
            SizedBox(height: 3.h),
            Text(
              qa.label,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================
// CHAT BUBBLE
// ========================

class _ChatBubble extends StatelessWidget {
  final _Msg msg;
  final bool isBot;
  const _ChatBubble({required this.msg, required this.isBot});

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          // Avatar bot
          if (isBot) ...[
            Container(
              width: 34.w,
              height: 34.h,
              margin: EdgeInsets.only(right: 8.w),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('🤖', style: TextStyle(fontSize: 16.sp)),
              ),
            ),
          ],

          // Bubble konten
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isBot ? Colors.white : AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18.r),
                      topRight: Radius.circular(18.r),
                      bottomLeft: Radius.circular(isBot ? 4.r : 18.r),
                      bottomRight: Radius.circular(isBot ? 18.r : 4.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isBot
                            ? Colors.black.withOpacity(0.08)
                            : AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: isBot
                        ? Border.all(color: AppColors.border, width: 1)
                        : null,
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      color:
                          isBot ? AppColors.textPrimary : Colors.white,
                      fontSize: 14.sp,
                      height: 1.55,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _formatTime(msg.time),
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),

          // Spacer user side
          if (!isBot) SizedBox(width: 8.w),
        ],
      ),
    );
  }
}

// ========================
// TYPING INDICATOR
// ========================

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<Animation<double>> _dots;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    _dots = List.generate(3, (i) {
      return Tween<double>(begin: 0, end: -6.0).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(
            i * 0.18,
            0.55 + i * 0.18,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 34.w,
            height: 34.h,
            margin: EdgeInsets.only(right: 8.w),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('🤖', style: TextStyle(fontSize: 16.sp)),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.r),
                topRight: Radius.circular(18.r),
                bottomRight: Radius.circular(18.r),
                bottomLeft: Radius.circular(4.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(color: AppColors.border),
            ),
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  return Transform.translate(
                    offset: Offset(0, _dots[i].value),
                    child: Container(
                      width: 8.w,
                      height: 8.h,
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
