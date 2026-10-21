import 'package:flutter/material.dart';

import '../models/shift.dart';

/// Cause icon with a corner badge: FULL, or "N left" when few places remain.
class ShiftAvatar extends StatelessWidget {
  const ShiftAvatar({super.key, required this.shift});

  final Shift shift;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = shift.cause.color(scheme);
    final (:taken, :free) = shift.places;

    return Semantics(
      label: '${shift.cause.label}, $taken taken',
      child: SizedBox.square(
        dimension: 56,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withValues(alpha: 0.16),
              child: Icon(shift.cause.icon, color: color),
            ),
            if (shift.isFull)
              _Badge(
                text: 'FULL',
                background: scheme.error,
                foreground: scheme.onError,
              )
            else if (free <= 5)
              _Badge(
                text: '$free left',
                background: scheme.tertiaryContainer,
                foreground: scheme.onTertiaryContainer,
              ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.text,
    required this.background,
    required this.foreground,
  });

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: -8,
      bottom: -4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: foreground),
        ),
      ),
    );
  }
}
