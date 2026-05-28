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
    return SizedBox(
      height: 48,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        child: Row(
          children: MatchDetailTab.values.map((tab) {
            final active = tab == selectedTab;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onTabSelected(tab),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFF161E32) : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    border: active ? Border.all(color: Colors.white12) : null,
                  ),
                  child: Text(
                    tab.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: active ? Colors.white : Colors.white60,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
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
