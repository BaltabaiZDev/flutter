import 'package:flutter/material.dart';

import '../models/cause.dart';
import '../models/shift.dart';
import '../widgets/empty_state.dart';
import '../widgets/shift_collection.dart';

/// Tab 1: search, cause chips, a past filter and the list itself.
/// The shifts come from the shell; only the filter state lives here.
class ShiftsTab extends StatefulWidget {
  const ShiftsTab({
    super.key,
    required this.shifts,
    required this.onOpen,
    required this.onToggleFavourite,
  });

  final List<Shift> shifts;
  final ValueChanged<Shift> onOpen;
  final ValueChanged<Shift> onToggleFavourite;

  @override
  State<ShiftsTab> createState() => _ShiftsTabState();
}

class _ShiftsTabState extends State<ShiftsTab> {
  final _search = TextEditingController();
  Cause? _cause;
  bool _showPast = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matches(Shift s) {
    final query = _search.text.trim().toLowerCase();
    return (query.isEmpty || s.title.toLowerCase().contains(query)) &&
        (_cause == null || s.cause == _cause) &&
        (_showPast || !s.isPast);
  }

  /// Upcoming first by date, past ones last. Sorts a copy, never the state.
  List<Shift> get _visible =>
      widget.shifts.where(_matches).toList()..sort((a, b) {
        if (a.isPast != b.isPast) return a.isPast ? 1 : -1;
        return a.startsAt.compareTo(b.startsAt);
      });

  void _clearSearch() {
    setState(() => _search.clear());
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search shifts',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              FilterChip(
                label: const Text('Past'),
                avatar: const Icon(Icons.history),
                selected: _showPast,
                onSelected: (v) => setState(() => _showPast = v),
              ),
              const SizedBox(width: 12),
              ChoiceChip(
                label: const Text('All'),
                selected: _cause == null,
                onSelected: (_) => setState(() => _cause = null),
              ),
              for (final cause in Cause.values) ...[
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: Icon(cause.icon),
                  label: Text(cause.label),
                  selected: _cause == cause,
                  onSelected: (_) => setState(() => _cause = cause),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? EmptyState(
                  icon: Icons.search_off,
                  message: 'No shifts match your search.',
                  actionLabel: _search.text.isEmpty ? null : 'Clear search',
                  onAction: _clearSearch,
                )
              : ShiftCollection(
                  shifts: visible,
                  onOpen: widget.onOpen,
                  onToggleFavourite: widget.onToggleFavourite,
                ),
        ),
      ],
    );
  }
}
