import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../models/shift.dart';

/// Tab 3: who you are and how the app looks.
class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.shifts,
    required this.onProfileChanged,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final Profile profile;
  final List<Shift> shifts;
  final ValueChanged<Profile> onProfileChanged;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  /// Two to four capital letters, a dash and two to four digits: SE-2203.
  static final _groupPattern = RegExp(r'^[A-Z]{2,4}-\d{2,4}$');

  final _nameKey = GlobalKey<FormFieldState<String>>();
  final _groupKey = GlobalKey<FormFieldState<String>>();
  late final TextEditingController _name;
  late final TextEditingController _group;
  final _groupFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.name);
    _group = TextEditingController(text: widget.profile.group);
  }

  @override
  void dispose() {
    _name.dispose();
    _group.dispose();
    _groupFocus.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter your name';
    if (v.length < 2) return 'At least 2 characters';
    return null;
  }

  String? _validateGroup(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    return _groupPattern.hasMatch(v) ? null : 'Format: SE-2203';
  }

  void _saveName(String value) {
    if (_nameKey.currentState?.validate() ?? false) {
      widget.onProfileChanged(widget.profile.copyWith(name: value.trim()));
    }
    _groupFocus.requestFocus();
  }

  void _saveGroup(String value) {
    if (_groupKey.currentState?.validate() ?? false) {
      widget.onProfileChanged(widget.profile.copyWith(group: value.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = widget.profile.name;
    final lists = widget.profile.hasName
        ? widget.shifts.fold(0, (n, s) => s.contains(name) ? n + 1 : n)
        : 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CircleAvatar(
          radius: 40,
          child: Text(
            widget.profile.hasName ? name.characters.first.toUpperCase() : '?',
            style: theme.textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'You are on $lists ${lists == 1 ? 'list' : 'lists'}',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 24),
        TextFormField(
          key: _nameKey,
          controller: _name,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: _validateName,
          onFieldSubmitted: _saveName,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Name',
            helperText: 'Press Enter to save',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          key: _groupKey,
          controller: _group,
          focusNode: _groupFocus,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: _validateGroup,
          onFieldSubmitted: _saveGroup,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Group',
            hintText: 'SE-2203',
            helperText: 'Press Enter to save',
            prefixIcon: Icon(Icons.groups),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        Text('Theme', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final (mode, label, icon) in const [
              (ThemeMode.system, 'System', Icons.brightness_auto),
              (ThemeMode.light, 'Light', Icons.light_mode),
              (ThemeMode.dark, 'Dark', Icons.dark_mode),
            ])
              ChoiceChip(
                avatar: Icon(icon),
                label: Text(label),
                selected: widget.themeMode == mode,
                onSelected: (_) => widget.onThemeModeChanged(mode),
              ),
          ],
        ),
      ],
    );
  }
}
