import 'package:flutter/material.dart';
import 'package:fover/features/matches/presentation/pages/match_detail_page.dart';

class MatchDetailTabBar extends StatelessWidget {
  const MatchDetailTabBar({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  final MatchDetailTab selectedTab;
  final ValueChanged<MatchDetailTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 48),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: MatchDetailTab.values.map((tab) {
              final active = tab == selectedTab;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => onTabSelected(tab),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xFF132B3D)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tab.title,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: active ? Colors.white : Colors.white60,
                                fontWeight: active
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 13,
                              ),
                        ),
                        const SizedBox(height: 5),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          height: 2.5,
                          width: active ? 20 : 0,
                          decoration: BoxDecoration(
                            color: active
                                ? const Color(0xFF10B981)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
