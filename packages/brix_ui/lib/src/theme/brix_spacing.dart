import 'dart:ui' show lerpDouble;

import 'brix_window_size.dart';

/// The spacing steps of the app and how far content stays from the window
/// edges. Use the steps instead of loose numbers, so screens line up.
///
/// ```dart
/// SizedBox(height: context.brix.spacing.l)
/// ```
class BrixSpacing {
  const BrixSpacing({
    this.xs = 4,
    this.s = 8,
    this.m = 12,
    this.l = 16,
    this.xl = 24,
    this.xxl = 32,
    this.pageCompact = 16,
    this.pageMedium = 24,
    this.pageExpanded = 32,
    this.maxContentWidth = 640,
  });

  final double xs;
  final double s;
  final double m;
  final double l;
  final double xl;
  final double xxl;

  /// Side padding of a page on phones.
  final double pageCompact;

  /// Side padding of a page on medium windows.
  final double pageMedium;

  /// Side padding of a page on expanded and wider windows.
  final double pageExpanded;

  /// The widest a column of content (a form, a list) grows, so it stays
  /// easy to read on tablets and desktops.
  final double maxContentWidth;

  /// Side padding of a page for a window [size].
  double page(BrixWindowSize size) {
    if (size.isAtLeast(BrixWindowSize.expanded)) return pageExpanded;
    if (size.isMedium) return pageMedium;
    return pageCompact;
  }

  BrixSpacing copyWith({
    double? xs,
    double? s,
    double? m,
    double? l,
    double? xl,
    double? xxl,
    double? pageCompact,
    double? pageMedium,
    double? pageExpanded,
    double? maxContentWidth,
  }) {
    return BrixSpacing(
      xs: xs ?? this.xs,
      s: s ?? this.s,
      m: m ?? this.m,
      l: l ?? this.l,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      pageCompact: pageCompact ?? this.pageCompact,
      pageMedium: pageMedium ?? this.pageMedium,
      pageExpanded: pageExpanded ?? this.pageExpanded,
      maxContentWidth: maxContentWidth ?? this.maxContentWidth,
    );
  }

  /// Blends from this to [other] while the theme animates.
  BrixSpacing lerp(BrixSpacing other, double t) {
    double mix(double a, double b) => lerpDouble(a, b, t)!;
    return BrixSpacing(
      xs: mix(xs, other.xs),
      s: mix(s, other.s),
      m: mix(m, other.m),
      l: mix(l, other.l),
      xl: mix(xl, other.xl),
      xxl: mix(xxl, other.xxl),
      pageCompact: mix(pageCompact, other.pageCompact),
      pageMedium: mix(pageMedium, other.pageMedium),
      pageExpanded: mix(pageExpanded, other.pageExpanded),
      maxContentWidth: mix(maxContentWidth, other.maxContentWidth),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BrixSpacing &&
      other.xs == xs &&
      other.s == s &&
      other.m == m &&
      other.l == l &&
      other.xl == xl &&
      other.xxl == xxl &&
      other.pageCompact == pageCompact &&
      other.pageMedium == pageMedium &&
      other.pageExpanded == pageExpanded &&
      other.maxContentWidth == maxContentWidth;

  @override
  int get hashCode => Object.hash(
    xs,
    s,
    m,
    l,
    xl,
    xxl,
    pageCompact,
    pageMedium,
    pageExpanded,
    maxContentWidth,
  );
}
