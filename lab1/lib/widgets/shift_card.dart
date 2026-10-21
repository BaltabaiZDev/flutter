import 'package:flutter/material.dart';

import '../models/shift.dart';
import '../utils/format.dart';
import 'shift_avatar.dart';

/// The one card used by every list and grid of shifts.
class ShiftCard extends StatelessWidget {
  const ShiftCard({
    super.key,
    required this.shift,
    required this.onTap,
    required this.onToggleFavourite,
  });

  final Shift shift;
  final VoidCallback onTap;
  final VoidCallback onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
          child: Row(
            children: [
              ShiftAvatar(shift: shift),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shift.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shift.isPast
                          ? '${formatDateTime(shift.startsAt)} · ended'
                          : formatDateTime(shift.startsAt),
                      style: muted,
                    ),
                    Row(
                      children: [
                        Icon(
                          shift.isRemote ? Icons.videocam : Icons.place,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            shift.isRemote ? 'Online' : shift.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: shift.favourite
                    ? 'Remove from favourites'
                    : 'Add to favourites',
                onPressed: onToggleFavourite,
                icon: Icon(
                  shift.favourite ? Icons.favorite : Icons.favorite_border,
                  color: shift.favourite ? theme.colorScheme.primary : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
