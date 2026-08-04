import 'package:flutter_test/flutter_test.dart';
import 'package:fover/features/ads/config/ads_config_model.dart';

void main() {
  group('AdsConfigModel', () {
    test('parses backend config payload into a strongly typed model', () {
      final json = {
        'is_enabled': true,
        'banner_android': 'banner_android_id',
        'interstitial_android': 'interstitial_android_id',
        'rewarded_android': 'rewarded_android_id',
        'banner_ios': 'banner_ios_id',
        'interstitial_ios': 'interstitial_ios_id',
        'rewarded_ios': 'rewarded_ios_id',
      };

      final config = AdsConfigModel.fromJson(json);

      expect(config.isEnabled, isTrue);
      expect(config.bannerAndroid, 'banner_android_id');
      expect(config.interstitialAndroid, 'interstitial_android_id');
      expect(config.rewardedAndroid, 'rewarded_android_id');
      expect(config.bannerIos, 'banner_ios_id');
      expect(config.interstitialIos, 'interstitial_ios_id');
      expect(config.rewardedIos, 'rewarded_ios_id');
    });
  });
}
