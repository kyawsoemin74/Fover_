class AdsConfigModel {
  const AdsConfigModel({
    required this.isEnabled,
    required this.bannerAndroid,
    required this.interstitialAndroid,
    required this.rewardedAndroid,
    required this.bannerIos,
    required this.interstitialIos,
    required this.rewardedIos,
  });

  final bool isEnabled;
  final String bannerAndroid;
  final String interstitialAndroid;
  final String rewardedAndroid;
  final String bannerIos;
  final String interstitialIos;
  final String rewardedIos;

  factory AdsConfigModel.fromJson(Map<String, dynamic> json) {
    return AdsConfigModel(
      isEnabled: json['is_enabled'] as bool? ?? false,
      bannerAndroid: json['banner_android']?.toString() ?? '',
      interstitialAndroid: json['interstitial_android']?.toString() ?? '',
      rewardedAndroid: json['rewarded_android']?.toString() ?? '',
      bannerIos: json['banner_ios']?.toString() ?? '',
      interstitialIos: json['interstitial_ios']?.toString() ?? '',
      rewardedIos: json['rewarded_ios']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_enabled': isEnabled,
      'banner_android': bannerAndroid,
      'interstitial_android': interstitialAndroid,
      'rewarded_android': rewardedAndroid,
      'banner_ios': bannerIos,
      'interstitial_ios': interstitialIos,
      'rewarded_ios': rewardedIos,
    };
  }
}
