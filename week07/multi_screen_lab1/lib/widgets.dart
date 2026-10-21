import 'package:flutter/material.dart';

import 'models.dart';
import 'utils/format.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onToggleFavourite,
  });

  final CampusEvent event;
  final VoidCallback onTap;
  final VoidCallback onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final TextTheme text = theme.textTheme;
    final String? badge = event.isFull
        ? 'FULL'
        : (event.freePlaces <= 5 ? '${event.freePlaces} left' : null);

    return Opacity(
      opacity: event.isPast ? 0.6 : 1,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: event.category.color(scheme),
                      foregroundColor: event.category.onColor(scheme),
                      child: Icon(event.category.icon),
                    ),
                    if (badge != null)
                      Positioned(
                        bottom: -10,
                        left: -8,
                        right: -8,
                        child: Center(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: event.isFull
                                  ? scheme.error
                                  : scheme.inverseSurface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              child: Text(
                                badge,
                                style: text.labelSmall?.copyWith(
                                  color: event.isFull
                                      ? scheme.onError
                                      : scheme.onInverseSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${formatDateTime(event.startsAt)} · ${event.location}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Favourite',
                  onPressed: onToggleFavourite,
                  icon: Icon(
                    event.favourite ? Icons.favorite : Icons.favorite_border,
                  ),
                  color: event.favourite ? scheme.error : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.buttonLabel,
    this.onPressed,
  });

  final IconData icon;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? label = buttonLabel;
    final VoidCallback? action = onPressed;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            if (label != null && action != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(onPressed: action, child: Text(label)),
            ],
          ],
        ),
      ),
    );
  }
}
