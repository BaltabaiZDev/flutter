import 'package:flutter/material.dart';

/// What a volunteer shift helps with.
enum Cause {
  animals('Animals', Icons.pets),
  environment('Environment', Icons.park),
  education('Education', Icons.school),
  foodBank('Food bank', Icons.restaurant),
  health('Health', Icons.local_hospital);

  const Cause(this.label, this.icon);

  final String label;
  final IconData icon;

  /// Exhaustive: adding a value makes the compiler point here.
  Color color(ColorScheme scheme) => switch (this) {
    Cause.animals => scheme.tertiary,
    Cause.environment => scheme.primary,
    Cause.education => scheme.secondary,
    Cause.foodBank => scheme.error,
    Cause.health => scheme.inversePrimary,
  };
}
