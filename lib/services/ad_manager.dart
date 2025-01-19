import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  static String get rewardedAdUnitId {
    return 'ca-app-pub-6355564828045606/7703879593'; // 여기에 실제 보상형 광고 단위 ID를 입력
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
          print('광고 로드 성공'); // 디버그 로그 추가
          _rewardedAd = ad;
          _isAdLoading = false;
        },
        onAdFailedToLoad: (error) {
          print('광고 로드 실패: ${error.message}'); // 에러 메시지 출력
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
