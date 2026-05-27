import 'package:flutter/material.dart';

class EmptyFollowing extends StatelessWidget {
  const EmptyFollowing({
    super.key,
    required this.isExpanded,
    required this.onToggle,
  });

  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final title = isExpanded ? 'Following list is empty' : 'Following section hidden';
    final message = isExpanded
        ? 'Add teams and competitions to follow live score alerts, stats, and news in one feed.'
        : 'Tap the button to restore your followed items and keep live action in view.';

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onToggle,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              icon: Icon(isExpanded ? Icons.visibility_off : Icons.visibility),
              label: Text(isExpanded ? 'Hide Section' : 'Show Section'),
            ),
          ],
        ),
      ),
    );
  }
}
