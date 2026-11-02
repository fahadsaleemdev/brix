import 'dart:ui' show lerpDouble;

import 'brix_window_size.dart';

/// Where one [BrixWindowSize] ends and the next starts, in logical pixels.
/// The defaults are the Material 3 window size classes.
///
/// ```dart
/// BrixTheme.light(breakpoints: const BrixBreakpoints(medium: 700))
/// ```
class BrixBreakpoints {
  const BrixBreakpoints({
    this.medium = 600,
    this.expanded = 840,
    this.large = 1200,
    this.extraLarge = 1600,
  });

  /// First width that counts as [BrixWindowSize.medium].
  final double medium;

  /// First width that counts as [BrixWindowSize.expanded].
  final double expanded;

  /// First width that counts as [BrixWindowSize.large].
  final double large;

  /// First width that counts as [BrixWindowSize.extraLarge].
  final double extraLarge;

  /// The size class for a window [width].
  BrixWindowSize sizeFor(double width) {
    if (width >= extraLarge) return BrixWindowSize.extraLarge;
    if (width >= large) return BrixWindowSize.large;
    if (width >= expanded) return BrixWindowSize.expanded;
    if (width >= medium) return BrixWindowSize.medium;
    return BrixWindowSize.compact;
  }

  BrixBreakpoints copyWith({
    double? medium,
    double? expanded,
    double? large,
    double? extraLarge,
  }) {
    return BrixBreakpoints(
      medium: medium ?? this.medium,
      expanded: expanded ?? this.expanded,
      large: large ?? this.large,
      extraLarge: extraLarge ?? this.extraLarge,
    );
  }

  /// Blends from this to [other] while the theme animates.
  BrixBreakpoints lerp(BrixBreakpoints other, double t) {
    return BrixBreakpoints(
      medium: lerpDouble(medium, other.medium, t)!,
      expanded: lerpDouble(expanded, other.expanded, t)!,
      large: lerpDouble(large, other.large, t)!,
      extraLarge: lerpDouble(extraLarge, other.extraLarge, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BrixBreakpoints &&
      other.medium == medium &&
      other.expanded == expanded &&
      other.large == large &&
      other.extraLarge == extraLarge;

  @override
  int get hashCode => Object.hash(medium, expanded, large, extraLarge);
}
