// chatbot_widget.dart
// Widget chatbot statis untuk bantuan pengguna di halaman profil.
// Tampil sebagai floating popup — fix: Stack clipBehavior.none + input teks.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

// ========================
// MODEL & DATA
// ========================

enum _Sender { user, bot }

class _Msg {
  final String text;
  final _Sender sender;
  _Msg(this.text, this.sender);
}

class _QA {
  final String icon;
  final String question;
  final String answer;
  _QA(this.icon, this.question, this.answer);
}

final List<_QA> _faqs = [
  _QA(
    '📚',
    'Cara bergabung ke kelas?',
    'Untuk bergabung ke kelas:\n1. Buka menu "Kelas" di dashboard.\n2. Tekan tombol Gabung (+) di pojok kanan.\n3. Masukkan kode kelas dari guru.\n4. Tekan "Gabung" — selesai! 🎉',
  ),
  _QA(
    '📝',
    'Cara mengerjakan tugas?',
    'Cara mengerjakan tugas:\n1. Buka kelas di dashboard.\n2. Pilih tab "Tugas".\n3. Klik tugas yang tersedia → tekan "Mulai Kerjakan".\n4. Jawab soal dan tekan "Kirim" sebelum deadline. ⏰',
  ),
  _QA(
    '🏆',
    'Cara melihat nilai?',
    'Nilai kamu bisa dilihat di:\n• Dashboard — bagian ringkasan nilai.\n• Menu Kelas → pilih kelas → tab "Nilai".\n\nNilai tampil setelah guru selesai menilai tugasmu. ✅',
  ),
  _QA(
    '🔑',
    'Lupa kata sandi?',
    'Cara reset kata sandi:\n1. Di halaman Login → tekan "Lupa Kata Sandi?".\n2. Masukkan email akun kamu.\n3. Cek email untuk tautan reset.\n4. Ikuti langkah di email tersebut. 📧',
  ),
  _QA(
    '⏰',
    'Cek deadline tugas?',
    'Deadline tugas bisa dilihat di:\n• Dashboard — kartu "Tugas Mendatang".\n• Tab Tugas di detail kelas — tertera batas waktu pengumpulan.\n\nPastikan kamu mengumpulkan sebelum batas waktu! ⚡',
  ),
  _QA(
    '⚠️',
    'Tugas tidak muncul?',
    'Jika tugas tidak muncul:\n1. Pastikan kamu sudah bergabung ke kelas yang benar.\n2. Tarik layar ke bawah untuk refresh.\n3. Periksa koneksi internetmu.\n4. Hubungi gurumu jika masalah berlanjut. 🔄',
  ),
  _QA(
    '👤',
    'Cara mengubah profil?',
    'Saat ini perubahan nama & foto belum tersedia secara langsung di aplikasi. Untuk bantuan lebih lanjut, hubungi administrator sekolahmu ya! 🏫',
  ),
  _QA(
    '📊',
    'Cara melihat progres belajar?',
    'Progres belajarmu bisa dilihat di:\n• Halaman Dashboard — lihat statistik nilai & tugas.\n• Detail Kelas — persentase tugas selesai.\n\nTerus semangat belajar! 💪',
  ),
];

// ========================
// CONTROLLER STATE
// ========================

class _ChatbotState {
  bool isOpen;
  List<_Msg> messages;
  bool isTyping;
  _ChatbotState({
    this.isOpen = false,
    required this.messages,
    this.isTyping = false,
  });
}

// ========================
// MAIN WIDGET
// ========================

class ChatbotWidget extends StatefulWidget {
  const ChatbotWidget({super.key});

  @override
  State<ChatbotWidget> createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget>
    with TickerProviderStateMixin {
  bool _isOpen = false;
  bool _isBotTyping = false;
  final List<_Msg> _messages = [];
  final ScrollController _scrollCtrl = ScrollController();
  final TextEditingController _inputCtrl = TextEditingController();

  late final AnimationController _fabRotCtrl;
  late final AnimationController _popupCtrl;
  late final Animation<double> _fabRot;
  late final Animation<double> _popupScale;
  late final Animation<double> _popupFade;
  late final Animation<Offset> _popupSlide;

  @override
  void initState() {
    super.initState();

    _fabRotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabRot = Tween<double>(begin: 0.0, end: 0.625).animate(
      CurvedAnimation(parent: _fabRotCtrl, curve: Curves.easeInOut),
    );

    _popupCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _popupScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _popupCtrl, curve: Curves.easeOutBack),
    );
    _popupFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _popupCtrl, curve: Curves.easeIn),
    );
    _popupSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _popupCtrl, curve: Curves.easeOut));

    // Pesan sambutan dari bot
    _messages.add(_Msg(
      'Halo! 👋 Saya Trimbo Assistant.\n\nAda yang bisa saya bantu? Pilih pertanyaan di bawah atau ketik pesanmu! 😊',
      _Sender.bot,
    ));
  }

  @override
  void dispose() {
    _fabRotCtrl.dispose();
    _popupCtrl.dispose();
    _scrollCtrl.dispose();
    _inputCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isOpen = !_isOpen);
    if (_isOpen) {
      _fabRotCtrl.forward();
      _popupCtrl.forward();
    } else {
      _fabRotCtrl.reverse();
      _popupCtrl.reverse();
    }
  }

  void _handleSend(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    _inputCtrl.clear();

    setState(() {
      _messages.add(_Msg(trimmed, _Sender.user));
      _isBotTyping = true;
    });
    _scrollToBottom();

    // Cari jawaban dari FAQ
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      final qa = _faqs.firstWhere(
        (q) => q.question.toLowerCase() == trimmed.toLowerCase() ||
            trimmed.contains(
              q.question.replaceAll(RegExp(r'[^\w\s]', unicode: true), '').trim(),
            ),
        orElse: () => _QA(
          '🤔',
          trimmed,
          'Maaf, saya belum punya jawaban spesifik untuk pertanyaan itu.\n\nCoba pilih dari pertanyaan umum di bawah, atau hubungi guru/administrator sekolah ya! 🙏',
        ),
      );

      setState(() {
        _isBotTyping = false;
        _messages.add(_Msg(qa.answer, _Sender.bot));
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

    Future.delayed(const Duration(milliseconds: 700), () {
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
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Widget ini hanya sebesar FAB; popup keluar lewat clipBehavior.none
      width: 60.w,
      height: 60.h,
      child: Stack(
        clipBehavior: Clip.none, // ← KUNCI: popup boleh keluar dari batas Stack
        alignment: Alignment.bottomRight,
        children: [
          // ====== POPUP CHAT ======
          if (_isOpen)
            Positioned(
              bottom: 68.h, // tepat di atas FAB
              right: 0,
              child: AnimatedBuilder(
                animation: _popupCtrl,
                builder: (_, child) => FadeTransition(
                  opacity: _popupFade,
                  child: SlideTransition(
                    position: _popupSlide,
                    child: ScaleTransition(
                      scale: _popupScale,
                      alignment: Alignment.bottomRight,
                      child: child,
                    ),
                  ),
                ),
                child: _ChatPopup(
                  messages: _messages,
                  isBotTyping: _isBotTyping,
                  faqs: _faqs,
                  scrollCtrl: _scrollCtrl,
                  inputCtrl: _inputCtrl,
                  onFaqTap: _handleFaqTap,
                  onSend: _handleSend,
                  onClose: _toggle,
                ),
              ),
            ),

          // ====== FAB BUTTON ======
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _toggle,
              child: RotationTransition(
                turns: _fabRot,
                child: Container(
                  width: 56.w,
                  height: 56.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.45),
                        blurRadius: 16,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isOpen ? Icons.close_rounded : Icons.chat_bubble_rounded,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ========================
// POPUP WINDOW
// ========================

class _ChatPopup extends StatelessWidget {
  final List<_Msg> messages;
  final bool isBotTyping;
  final List<_QA> faqs;
  final ScrollController scrollCtrl;
  final TextEditingController inputCtrl;
  final ValueChanged<_QA> onFaqTap;
  final ValueChanged<String> onSend;
  final VoidCallback onClose;

  const _ChatPopup({
    required this.messages,
    required this.isBotTyping,
    required this.faqs,
    required this.scrollCtrl,
    required this.inputCtrl,
    required this.onFaqTap,
    required this.onSend,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 310.w,
        height: 460.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
            bottomLeft: Radius.circular(20.r),
            bottomRight: Radius.circular(4.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 28,
              spreadRadius: 2,
              offset: const Offset(-4, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
            bottomLeft: Radius.circular(20.r),
            bottomRight: Radius.circular(4.r),
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildMessageList()),
              _buildQuickReplies(),
              _buildInput(context),
            ],
          ),
        ),
      ),
    );
  }

  // -- Header --
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          // Avatar bot
          Container(
            width: 38.w,
            height: 38.h,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('🤖', style: TextStyle(fontSize: 20.sp)),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trimbo Assistant',
                  style: AppStyles.labelL.copyWith(
                    color: Colors.white,
                    fontSize: 13.sp,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 7.w,
                      height: 7.h,
                      decoration: const BoxDecoration(
                        color: Color(0xFF34D399),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Online — siap membantu',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Close button
          GestureDetector(
            onTap: onClose,
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded, color: Colors.white, size: 16.sp),
            ),
          ),
        ],
      ),
    );
  }

  // -- Daftar pesan --
  Widget _buildMessageList() {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: ListView.builder(
        controller: scrollCtrl,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        itemCount: messages.length + (isBotTyping ? 1 : 0),
        itemBuilder: (context, index) {
          // Indikator "sedang mengetik"
          if (isBotTyping && index == messages.length) {
            return _TypingIndicator();
          }
          final msg = messages[index];
          final isBot = msg.sender == _Sender.bot;
          return _Bubble(msg: msg, isBot: isBot);
        },
      ),
    );
  }

  // -- Quick replies --
  Widget _buildQuickReplies() {
    return Container(
      constraints: BoxConstraints(maxHeight: 86.h),
      padding: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Pertanyaan cepat:',
            style: TextStyle(
              fontSize: 9.5.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5.h),
          SizedBox(
            height: 60.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: faqs.length,
              separatorBuilder: (_, __) => SizedBox(width: 6.w),
              itemBuilder: (_, i) {
                final qa = faqs[i];
                return GestureDetector(
                  onTap: () => onFaqTap(qa),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.08),
                          AppColors.secondary.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.25),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(qa.icon, style: TextStyle(fontSize: 14.sp)),
                        SizedBox(height: 2.h),
                        Text(
                          qa.question,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 9.5.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // -- Input teks --
  Widget _buildInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: inputCtrl,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Ketik pertanyaanmu...',
                hintStyle: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textTertiary,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.r),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.r),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.r),
                  borderSide:
                      BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
              onSubmitted: onSend,
              textInputAction: TextInputAction.send,
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => onSend(inputCtrl.text),
            child: Container(
              width: 38.w,
              height: 38.h,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 18.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ========================
// CHAT BUBBLE
// ========================

class _Bubble extends StatelessWidget {
  final _Msg msg;
  final bool isBot;
  const _Bubble({required this.msg, required this.isBot});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          // Avatar bot (kiri)
          if (isBot) ...[
            Container(
              width: 28.w,
              height: 28.h,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('🤖', style: TextStyle(fontSize: 13.sp)),
              ),
            ),
            SizedBox(width: 6.w),
          ],

          // Bubble teks
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
              decoration: BoxDecoration(
                color: isBot ? Colors.white : AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: Radius.circular(isBot ? 4.r : 16.r),
                  bottomRight: Radius.circular(isBot ? 16.r : 4.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: isBot
                    ? Border.all(color: AppColors.border, width: 1)
                    : null,
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  color: isBot ? AppColors.textPrimary : Colors.white,
                  fontSize: 12.sp,
                  height: 1.5,
                ),
              ),
            ),
          ),

          if (!isBot) SizedBox(width: 6.w),
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
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _dots = List.generate(3, (i) {
      return Tween<double>(begin: 0, end: -5.0).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(i * 0.2, 0.6 + i * 0.2, curve: Curves.easeInOut),
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
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28.w,
            height: 28.h,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('🤖', style: TextStyle(fontSize: 13.sp)),
            ),
          ),
          SizedBox(width: 6.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
                bottomRight: Radius.circular(16.r),
                bottomLeft: Radius.circular(4.r),
              ),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  return Transform.translate(
                    offset: Offset(0, _dots[i].value),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Container(
                        width: 6.w,
                        height: 6.h,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
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
