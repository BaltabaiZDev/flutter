import 'package:flutter/material.dart';

import '../models/shift.dart';
import 'shift_card.dart';

/// A list on phones, a grid of cells up to 360 px wide from 600 px on.
class ShiftCollection extends StatelessWidget {
  const ShiftCollection({
    super.key,
    required this.shifts,
    required this.onOpen,
    required this.onToggleFavourite,
  });

  static const gridBreakpoint = 600.0;
  static const maxCellWidth = 360.0;

  final List<Shift> shifts;
  final ValueChanged<Shift> onOpen;
  final ValueChanged<Shift> onToggleFavourite;

  Widget _card(Shift shift) => ShiftCard(
    key: ValueKey(shift.id),
    shift: shift,
    onTap: () => onOpen(shift),
    onToggleFavourite: () => onToggleFavourite(shift),
  );

  @override
  Widget build(BuildContext context) {
    // 88 px at the bottom keeps the last card clear of the FAB.
    const padding = EdgeInsets.fromLTRB(12, 4, 12, 88);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= gridBreakpoint) {
          return GridView.builder(
            padding: padding,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: maxCellWidth,
              childAspectRatio: 2.4,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: shifts.length,
            itemBuilder: (context, i) => _card(shifts[i]),
          );
        }
        return ListView.separated(
          padding: padding,
          itemCount: shifts.length,
          separatorBuilder: (context, i) => const SizedBox(height: 4),
          itemBuilder: (context, i) => _card(shifts[i]),
        );
      },
    );
  }
}
