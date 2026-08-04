import 'package:flutter/material.dart';
import 'package:fover/features/team/presentation/team_profile_header_layout.dart';

class TeamProfileTabs extends StatelessWidget {
  const TeamProfileTabs({super.key, required this.tabs});

  final List<String> tabs;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelPadding: const EdgeInsets.symmetric(horizontal: 12),
      padding: EdgeInsets.zero,
      indicatorSize: TabBarIndicatorSize.label,
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(
          width: 2,
          color: Color(0xFF32D583),
        ),
      ),
      dividerColor: Colors.transparent,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white60,
      indicatorColor: const Color(0xFF32D583),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return Colors.white10;
        }
        return Colors.transparent;
      }),
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
              height: TeamProfileHeaderLayout.tabBarHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(tab),
              ),
            ),
          )
          .toList(),
    );
  }
}
