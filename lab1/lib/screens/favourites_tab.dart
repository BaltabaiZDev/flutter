import 'package:flutter/material.dart';

import '../models/shift.dart';
import '../widgets/empty_state.dart';
import '../widgets/shift_collection.dart';

/// Tab 2: the shifts marked with a heart, soonest first.
class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.shifts,
    required this.onOpen,
    required this.onToggleFavourite,
    required this.onBrowse,
  });

  final List<Shift> shifts;
  final ValueChanged<Shift> onOpen;
  final ValueChanged<Shift> onToggleFavourite;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    if (!shifts.any((s) => s.favourite)) {
      return EmptyState(
        icon: Icons.favorite_border,
        message:
            'No favourites yet.\nTap the heart on a shift to keep it here.',
        actionLabel: 'Browse shifts',
        onAction: onBrowse,
      );
    }
    final favourites = shifts.where((s) => s.favourite).toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return ShiftCollection(
      shifts: favourites,
      onOpen: onOpen,
      onToggleFavourite: onToggleFavourite,
    );
  }
}
