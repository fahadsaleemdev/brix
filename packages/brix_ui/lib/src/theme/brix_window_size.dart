/// How much room the app has, from the window width: the window size
/// classes Flutter and Material 3 recommend for adaptive layouts.
///
/// ```dart
/// final window = context.brixWindow;
/// if (window.isCompact) return const PhoneLayout();
/// return const TabletLayout();
/// ```
///
/// A class, not an enum, so a new size can be added without breaking a
/// `switch` in your app.
final class BrixWindowSize {
  const BrixWindowSize._(this.name, this._rank);

  /// Phones in portrait (under 600 wide by default).
  static const compact = BrixWindowSize._('compact', 0);

  /// Large phones in landscape, small tablets, foldables (600 to 839).
  static const medium = BrixWindowSize._('medium', 1);

  /// Tablets in landscape, small desktop windows (840 to 1199).
  static const expanded = BrixWindowSize._('expanded', 2);

  /// Desktop windows (1200 to 1599).
  static const large = BrixWindowSize._('large', 3);

  /// Very wide desktop windows (1600 and wider).
  static const extraLarge = BrixWindowSize._('extraLarge', 4);

  /// Every size, from the smallest.
  static const values = [compact, medium, expanded, large, extraLarge];

  final String name;
  final int _rank;

  bool get isCompact => this == compact;
  bool get isMedium => this == medium;
  bool get isExpanded => this == expanded;

  /// Medium or wider: room for two panes or a side bar.
  bool get isAtLeastMedium => isAtLeast(medium);

  /// Whether this size is [other] or wider.
  bool isAtLeast(BrixWindowSize other) => _rank >= other._rank;

  @override
  String toString() => 'BrixWindowSize.$name';
}
