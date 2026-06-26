import 'package:flutter/material.dart';
import 'package:fover/features/matches/presentation/pages/match_detail_page.dart';

class MatchDetailTabBar extends StatelessWidget {
  const MatchDetailTabBar({
    super.key,
    required this.selectedTab,
    required this.tabs,
    required this.onTabSelected,
  });

  final MatchDetailTab selectedTab;
  final List<MatchDetailTab> tabs;
  final ValueChanged<MatchDetailTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        child: Row(
          children: tabs.map((tab) {
            final active = tab == selectedTab;
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => onTabSelected(tab),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
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
                                    : FontWeight.w600,
                                fontSize: 14,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          height: 3,
                          width: active ? 28 : 0,
                          decoration: BoxDecoration(
                            color: active
                                ? const Color(0xFF00D1A0)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
