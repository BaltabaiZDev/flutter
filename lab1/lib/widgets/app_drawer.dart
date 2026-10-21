import 'package:flutter/material.dart';

import 'icon_row.dart';

/// The drawer only closes itself; the dialogs are shown by the shell, whose
/// context is still alive after the drawer is gone.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.onAbout, required this.onReset});

  final VoidCallback onAbout;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.volunteer_activism,
                  size: 40,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(height: 8),
                Text(
                  'Helping Hands',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          IconRow(
            icon: const Icon(Icons.info_outline),
            title: 'About',
            onTap: () {
              Navigator.pop(context);
              onAbout();
            },
          ),
          IconRow(
            icon: const Icon(Icons.restore),
            title: 'Reset data',
            onTap: () {
              Navigator.pop(context);
              onReset();
            },
          ),
        ],
      ),
    );
  }
}
