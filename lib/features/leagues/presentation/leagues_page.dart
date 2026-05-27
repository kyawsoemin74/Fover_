import 'package:flutter/material.dart';
import 'package:fover/shared/widgets/custom_appbar.dart';

class LeaguesPage extends StatelessWidget {
  const LeaguesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomAppBar(
            title: 'Leagues',
          ),
          const SizedBox(height: 14),
          Text(
            'Browse competitions, standings, and upcoming match schedules.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 26),
          Expanded(
            child: Center(
              child: Text(
                'League overview will be integrated here.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
