import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:fover/features/ads/providers/ads_runtime_provider.dart';

enum BannerPlacement {
  home,
  matchDetail,
  leagueDetail,
  teamDetail,
  newsDetail,
}

class BannerAdSlot extends ConsumerWidget {
  const BannerAdSlot({super.key, this.placement = BannerPlacement.home});

  final BannerPlacement placement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adsRuntimeProvider);
    final sharedService = ref.read(adsRuntimeProvider.notifier).sharedBannerService;

    if (state.status == AdsRuntimeStatus.initial || state.status == AdsRuntimeStatus.loading || state.isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(12),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: Center(
            child: Container(
              width: 120,
              height: 12,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      );
    }

    if (sharedService?.bannerAd == null || !state.isBannerAvailable) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: AdWidget(ad: sharedService!.bannerAd!),
      ),
    );
  }
}
