import 'package:flutter/material.dart';

class TeamProfileTabs extends StatelessWidget {
  const TeamProfileTabs({super.key, required this.tabs});

  final List<String> tabs;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelPadding: const EdgeInsets.only(right: 8),
      padding: EdgeInsets.zero,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: BoxDecoration(
        color: const Color(0xFF1C2B44),
        borderRadius: BorderRadius.circular(14),
      ),
      dividerColor: Colors.transparent,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white60,
      labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
      unselectedLabelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      tabs: tabs
          .map(
            (tab) => Tab(
              height: 38,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(tab),
              ),
            ),
          )
          .toList(),
    );
  }
}
