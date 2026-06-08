import 'package:flutter/material.dart';

class ProfileActionButton extends StatelessWidget {
  const ProfileActionButton({
    super.key,
    this.icon,
    this.child,
    required this.tooltip,
    this.onTap,
    this.iconSize = 20,
    this.size = 36,
  });

  final IconData? icon;
  final Widget? child;
  final String tooltip;
  final VoidCallback? onTap;
  final double iconSize;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.onSurface.withAlpha(10),
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onTap,
        icon: child ?? Icon(icon ?? Icons.person_outline, size: iconSize),
        tooltip: tooltip,
        splashRadius: 20,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints.tightFor(width: size, height: size),
        color: theme.colorScheme.onSurface,
      ),
    );
  }
}
