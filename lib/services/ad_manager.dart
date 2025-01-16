import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  static String get rewardedAdUnitId {
    return 'ca-app-pub-6355564828045606~8622973930';
  }

  static RewardedAd? _rewardedAd;
  static bool _isAdLoading = false;

  static Future<void> loadRewardedAd() async {
    if (_rewardedAd != null || _isAdLoading) return;
    _isAdLoading = true;

    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isAdLoading = false;
        },
        onAdFailedToLoad: (error) {
          _isAdLoading = false;
        },
      ),
    );
  }

  static Future<bool> showRewardedAd() async {
    if (_rewardedAd == null) {
      await loadRewardedAd();
      if (_rewardedAd == null) return false;
    }

    final completer = Completer<bool>();
    
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd(); // 다음 광고 미리 로드
        completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        completer.complete(false);
      },
    );

    _rewardedAd!.show(onUserEarnedReward: (_, __) {});
    return completer.future;
  }

  static void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
} 