import 'dart:ui' show lerpDouble;

import 'package:flutter/painting.dart';

/// How `BrixCard`s look. Set it in `BrixTheme(card: ...)`; a card's own
/// `style` goes on top.
class BrixCardStyle {
  const BrixCardStyle({
    this.color,
    this.radius,
    this.padding,
    this.borderColor,
    this.borderWidth,
    this.shadow,
    this.accentWidth,
    this.pressedScale,
    this.haptics,
  });

  /// Default: `colors.surface`.
  final Color? color;

  /// Default: `shape.radius`.
  final double? radius;

  /// Space around the content. Default: `spacing.l` on every side.
  final EdgeInsetsGeometry? padding;

  /// Default: `colors.border` at a quarter strength.
  final Color? borderColor;

  /// Default: 1. Zero draws no border.
  final double? borderWidth;

  /// Default: one soft shadow. An empty list draws none.
  final List<BoxShadow>? shadow;

  /// Width of the coloured strip on the leading edge when the card has an
  /// `accentColor`. Default: 4.
  final double? accentWidth;

  /// Size while a tappable card is held down. Default: 0.98; 1 turns it off.
  final double? pressedScale;

  /// A light tap feel on tappable cards. Default: on.
  final bool? haptics;

  /// This style with [other]'s set values on top.
  BrixCardStyle merge(BrixCardStyle? other) {
    if (other == null) return this;
    return BrixCardStyle(
      color: other.color ?? color,
      radius: other.radius ?? radius,
      padding: other.padding ?? padding,
      borderColor: other.borderColor ?? borderColor,
      borderWidth: other.borderWidth ?? borderWidth,
      shadow: other.shadow ?? shadow,
      accentWidth: other.accentWidth ?? accentWidth,
      pressedScale: other.pressedScale ?? pressedScale,
      haptics: other.haptics ?? haptics,
    );
  }

  /// Blends from this to [other] while the theme animates.
  BrixCardStyle lerp(BrixCardStyle other, double t) {
    double? mix(double? a, double? b) =>
        a == null || b == null ? (t < 0.5 ? a : b) : lerpDouble(a, b, t);
    return BrixCardStyle(
      color: Color.lerp(color, other.color, t),
      radius: mix(radius, other.radius),
      padding: EdgeInsetsGeometry.lerp(padding, other.padding, t),
      borderColor: Color.lerp(borderColor, other.borderColor, t),
      borderWidth: mix(borderWidth, other.borderWidth),
      shadow: t < 0.5 ? shadow : other.shadow,
      accentWidth: mix(accentWidth, other.accentWidth),
      pressedScale: mix(pressedScale, other.pressedScale),
      haptics: t < 0.5 ? haptics : other.haptics,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BrixCardStyle &&
      other.color == color &&
      other.radius == radius &&
      other.padding == padding &&
      other.borderColor == borderColor &&
      other.borderWidth == borderWidth &&
      _sameShadow(other.shadow, shadow) &&
      other.accentWidth == accentWidth &&
      other.pressedScale == pressedScale &&
      other.haptics == haptics;

  static bool _sameShadow(List<BoxShadow>? a, List<BoxShadow>? b) {
    if (a == null || b == null) return a == b;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    color,
    radius,
    padding,
    borderColor,
    borderWidth,
    shadow == null ? null : Object.hashAll(shadow!),
    accentWidth,
    pressedScale,
    haptics,
  );
}
