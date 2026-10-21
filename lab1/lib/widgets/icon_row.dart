import 'package:flutter/material.dart';

/// An icon, a title, an optional subtitle and an optional trailing widget.
/// Used instead of ListTile so the project never needs a `leading` slot.
class IconRow extends StatelessWidget {
  const IconRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.highlighted = false,
    this.onTap,
  });

  final Widget icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool highlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sub = subtitle;
    final end = trailing;
    return Ink(
      color: highlighted ? scheme.secondaryContainer : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              IconTheme.merge(
                data: IconThemeData(
                  color: highlighted ? scheme.primary : scheme.onSurfaceVariant,
                ),
                child: icon,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: highlighted ? FontWeight.bold : null,
                      ),
                    ),
                    if (sub != null)
                      Text(
                        sub,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              ?end,
            ],
          ),
        ),
      ),
    );
  }
}
