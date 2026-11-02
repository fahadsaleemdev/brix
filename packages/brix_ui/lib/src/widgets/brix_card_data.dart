import 'package:flutter/widgets.dart';

import 'brix_card_style.dart';

/// Draws every `BrixCard` with the app's own widget; brix keeps the tap,
/// the pressed state and the semantics.
typedef BrixCardBuilder = Widget Function(
  BuildContext context,
  BrixCardData card,
);

/// What a [BrixCardBuilder] gets.
class BrixCardData {
  const BrixCardData({
    required this.child,
    required this.style,
    required this.pressed,
    required this.tappable,
    this.accentColor,
  });

  /// The card's content.
  final Widget child;

  /// The resolved look: theme, then the card's own style, defaults filled in.
  final BrixCardStyle style;

  /// Whether the card is held down right now.
  final bool pressed;

  /// Whether the card reacts to taps.
  final bool tappable;

  /// The card's accent, e.g. a status colour.
  final Color? accentColor;
}
