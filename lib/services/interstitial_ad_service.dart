import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdService {
  static final InterstitialAdService _instance = InterstitialAdService._internal();
  factory InterstitialAdService() => _instance;
  InterstitialAdService._internal();

  InterstitialAd? _interstitialAd;
  bool _isAdLoading = false;

  void loadAd() {
    if (_interstitialAd != null || _isAdLoading) return;
    _isAdLoading = true;

    // Menggunakan Test Ad Unit ID untuk Interstitial Ad
    final String adUnitId = Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/1033173712'  // Test ID Android
        : 'ca-app-pub-3940256099942544/4411468910'; // Test ID iOS

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          debugPrint('InterstitialAd was loaded.');
          _interstitialAd = ad;
          _isAdLoading = false;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('Ad failed to load with error: $error');
          _isAdLoading = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  void showAd({required VoidCallback onAdDismissed}) {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          debugPrint('Ad showed full screen content.');
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          debugPrint('Ad failed to show full screen content with error: $err');
          ad.dispose();
          _interstitialAd = null;
          onAdDismissed();
        },
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('Ad was dismissed.');
          ad.dispose();
          _interstitialAd = null;
          loadAd(); // Muat ulang iklan untuk penggunaan selanjutnya
          onAdDismissed();
        },
        onAdImpression: (ad) {
          debugPrint('Ad recorded an impression.');
        },
        onAdClicked: (ad) {
          debugPrint('Ad was clicked.');
        },
      );
      _interstitialAd!.show();
    } else {
      // Jika iklan belum siap, langsung lanjutkan aksi dan coba muat ulang
      onAdDismissed();
      loadAd();
    }
  }
}
