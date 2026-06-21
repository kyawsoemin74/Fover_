import 'package:flutter/material.dart';

class TeamPlaceholderTab extends StatelessWidget {
  const TeamPlaceholderTab({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1220),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white60,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
