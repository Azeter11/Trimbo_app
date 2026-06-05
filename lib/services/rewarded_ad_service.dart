import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/constants/app_colors.dart';

class RewardedAdService {
  static final RewardedAdService _instance = RewardedAdService._internal();
  factory RewardedAdService() => _instance;
  RewardedAdService._internal();

  RewardedAd? _rewardedAd;
  bool _isAdLoading = false;

  void loadAd() {
    if (_rewardedAd != null || _isAdLoading) return;
    _isAdLoading = true;

    // Menggunakan Test Ad Unit ID untuk Rewarded Ad (Safe untuk Development & Testing)
    // Ganti dengan Ad Unit ID asli Anda hanya saat akan rilis ke production
    final String adUnitId = Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/5224354917'  // Test ID Android
        : 'ca-app-pub-3940256099942544/1712485313'; // Test ID iOS

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          debugPrint('RewardedAd was loaded.');
          // ServerSideVerificationOptions _options = ServerSideVerificationOptions(
          //   customData: 'SAMPLE_CUSTOM_DATA_STRING',
          // );
          // ad.setServerSideOptions(_options);
          
          _rewardedAd = ad;
          _isAdLoading = false;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              debugPrint('Ad showed full screen content.');
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              debugPrint('Ad failed to show full screen content with error: $err');
              ad.dispose();
              _rewardedAd = null;
            },
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('Ad was dismissed.');
              ad.dispose();
              _rewardedAd = null;
              loadAd(); // Muat ulang iklan setelah selesai ditonton
            },
            onAdImpression: (ad) {
              debugPrint('Ad recorded an impression.');
            },
            onAdClicked: (ad) {
              debugPrint('Ad was clicked.');
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('Ad failed to load with error: $error');
          _isAdLoading = false;
          _rewardedAd = null;
        },
      ),
    );
  }

  void showAdConfirmationDialog({
    required VoidCallback onRewardEarned,
  }) {
    Get.dialog(
      AlertDialog(
        title: const Text('Ekspor Nilai'),
        content: const Text('Tonton iklan untuk melanjutkan ekspor dokumen.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Get.back(); // Tutup dialog konfirmasi
              _showAd(onRewardEarned);
            },
            child: const Text('Tonton Iklan'),
          ),
        ],
      ),
    );
  }

  void _showAd(VoidCallback onRewardEarned) {
    if (_rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
          debugPrint('Reward amount: ${rewardItem.amount}');
          // Panggil fungsi ekspor ketika reward didapatkan
          onRewardEarned();
        },
      );
    } else {
      // Jika iklan gagal dimuat atau belum siap, lanjutkan ekspor langsung 
      // (Bisa juga menampilkan pesan error jika wajib menonton iklan)
      Get.snackbar(
        'Info',
        'Iklan belum siap, melanjutkan ekspor...',
        backgroundColor: Colors.black54,
        colorText: Colors.white,
      );
      onRewardEarned();
      loadAd(); // Coba muat ulang
    }
  }
}
