import 'package:flutter/material.dart';

import 'models.dart';
import 'widgets.dart';

class EventsTab extends StatefulWidget {
  const EventsTab({
    super.key,
    required this.events,
    required this.onOpen,
    required this.onToggleFavourite,
    required this.onAdd,
  });

  final List<CampusEvent> events;
  final ValueChanged<CampusEvent> onOpen;
  final ValueChanged<CampusEvent> onToggleFavourite;
  final VoidCallback onAdd;

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  final TextEditingController _search = TextEditingController();

  EventCategory? _category;
  bool _showPast = false;

  @override
  void dispose() {
    _search.dispose();

    super.dispose();
  }

  void _resetFilters() {
    _search.clear();

    setState(() {
      _category = null;
      _showPast = false;
    });
  }

  Widget _card(CampusEvent event) => EventCard(
    event: event,
    onTap: () => widget.onOpen(event),
    onToggleFavourite: () => widget.onToggleFavourite(event),
  );

  @override
  Widget build(BuildContext context) {
    final List<CampusEvent> visible = sortedByDate(
      filterEvents(
        widget.events,
        query: _search.text,
        category: _category,
        showPast: _showPast,
      ),
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            controller: _search,
            textInputAction: TextInputAction.search,
            onChanged: (_) => setState(() {}),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            decoration: InputDecoration(
              hintText: 'Search events',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _search.clear();

                        setState(() {});
                      },
                    ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              for (final EventCategory? c in <EventCategory?>[
                null,
                ...EventCategory.values,
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c?.label ?? 'All'),
                    selected: _category == c,
                    onSelected: (_) => setState(() => _category = c),
                  ),
                ),
              FilterChip(
                label: const Text('Past'),
                selected: _showPast,
                onSelected: (value) => setState(() => _showPast = value),
              ),
            ],
          ),
        ),
        Expanded(
          child: widget.events.isEmpty
              ? EmptyState(
                  icon: Icons.event_busy,
                  message: 'No events yet',
                  buttonLabel: 'Add event',
                  onPressed: widget.onAdd,
                )
              : visible.isEmpty
              ? EmptyState(
                  icon: Icons.search_off,
                  message: 'No events match your filters',
                  buttonLabel: 'Reset filters',
                  onPressed: _resetFilters,
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth >= 600) {
                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 360,
                              mainAxisExtent: 112,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: visible.length,
                        itemBuilder: (context, index) => _card(visible[index]),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: visible.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) => _card(visible[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.events,
    required this.onOpen,
    required this.onToggleFavourite,
    required this.onBrowse,
  });

  final List<CampusEvent> events;
  final ValueChanged<CampusEvent> onOpen;
  final ValueChanged<CampusEvent> onToggleFavourite;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final List<CampusEvent> favourites = sortedByDate(favouritesOf(events));

    if (favourites.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border,
        message: 'No favourites yet',
        buttonLabel: 'Browse events',
        onPressed: onBrowse,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: favourites.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) => EventCard(
        event: favourites[index],
        onTap: () => onOpen(favourites[index]),
        onToggleFavourite: () => onToggleFavourite(favourites[index]),
      ),
    );
  }
}

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.events,
    required this.themeMode,
    required this.onProfileChanged,
    required this.onThemeModeChanged,
  });

  final Profile profile;
  final List<CampusEvent> events;
  final ThemeMode themeMode;
  final ValueChanged<Profile> onProfileChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  static final RegExp _groupPattern = RegExp(r'^[A-Z]{2,4}-\d{4}$');

  late final TextEditingController _name = TextEditingController(
    text: widget.profile.name,
  );
  late final TextEditingController _group = TextEditingController(
    text: widget.profile.group,
  );

  static String? _groupError(String? value) {
    final String group = (value ?? '').trim();

    if (group.isEmpty || _groupPattern.hasMatch(group)) return null;

    return 'Use the format IT-2301';
  }

  void _saveName() {
    widget.onProfileChanged(widget.profile.copyWith(name: _name.text.trim()));
  }

  void _saveGroup() {
    if (_groupError(_group.text) != null) return;

    widget.onProfileChanged(widget.profile.copyWith(group: _group.text.trim()));
  }

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.profile.name != oldWidget.profile.name) {
      _name.text = widget.profile.name;
    }

    if (widget.profile.group != oldWidget.profile.group) {
      _group.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _group.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final int lists = listsContaining(widget.events, widget.profile.name);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'You are on $lists ${lists == 1 ? 'list' : 'lists'}',
          style: text.titleMedium,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _name,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) {
            _saveName();

            FocusScope.of(context).nextFocus();
          },
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          decoration: const InputDecoration(
            labelText: 'Name',
            helperText: 'Press Next to save',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _group,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: _groupError,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _saveGroup(),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          decoration: const InputDecoration(
            labelText: 'Group',
            hintText: 'IT-2301',
            helperText: 'Press Done to save',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        Text('Theme', style: text.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final ThemeMode mode in ThemeMode.values)
              ChoiceChip(
                label: Text(switch (mode) {
                  ThemeMode.system => 'System',
                  ThemeMode.light => 'Light',
                  ThemeMode.dark => 'Dark',
                }),
                selected: widget.themeMode == mode,
                onSelected: (_) => widget.onThemeModeChanged(mode),
              ),
          ],
        ),
      ],
    );
  }
}
