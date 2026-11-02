import 'package:flutter/painting.dart';

/// The text styles brix widgets and your screens use. Styles carry size,
/// weight and font only, the colour comes from [BrixColors], so the same
/// styles work in light and dark.
///
/// The scale follows iOS: [largeTitle], [title1], [title2], [title3],
/// [headline], [body], [callout], [subheadline], [footnote], [caption] and
/// [caption2], plus [label] and [button] for fields and buttons. Text grows
/// with the user's text size setting; it never grows with the screen width.
///
/// Pass your own font with [fontFamily], or whole styles (e.g. from
/// `google_fonts`):
///
/// ```dart
/// BrixTypography(fontFamily: 'Inter')
/// Text('Welcome', style: context.brix.typography.largeTitle)
/// ```
class BrixTypography {
  /// iOS-like sizes. [fontFamily] is applied to every style that has no font
  /// of its own. [title3] follows [title] unless you set it.
  BrixTypography({
    String? fontFamily,
    TextStyle? title,
    TextStyle? body,
    TextStyle? label,
    TextStyle? button,
    TextStyle? caption,
    TextStyle? largeTitle,
    TextStyle? title1,
    TextStyle? title2,
    TextStyle? title3,
    TextStyle? headline,
    TextStyle? callout,
    TextStyle? subheadline,
    TextStyle? footnote,
    TextStyle? caption2,
  }) : title = _withFont(title ?? _title, fontFamily),
       body = _withFont(
         body ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
         fontFamily,
       ),
       label = _withFont(
         label ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
         fontFamily,
       ),
       button = _withFont(
         button ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
         fontFamily,
       ),
       caption = _withFont(
         caption ?? const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
         fontFamily,
       ),
       largeTitle = _withFont(
         largeTitle ??
             const TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
         fontFamily,
       ),
       title1 = _withFont(
         title1 ?? const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
         fontFamily,
       ),
       title2 = _withFont(
         title2 ?? const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
         fontFamily,
       ),
       title3 = _withFont(title3 ?? title ?? _title, fontFamily),
       headline = _withFont(
         headline ?? const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
         fontFamily,
       ),
       callout = _withFont(
         callout ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
         fontFamily,
       ),
       subheadline = _withFont(
         subheadline ??
             const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
         fontFamily,
       ),
       footnote = _withFont(
         footnote ?? const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
         fontFamily,
       ),
       caption2 = _withFont(
         caption2 ?? const TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
         fontFamily,
       );

  const BrixTypography._({
    required this.title,
    required this.body,
    required this.label,
    required this.button,
    required this.caption,
    required this.largeTitle,
    required this.title1,
    required this.title2,
    required this.title3,
    required this.headline,
    required this.callout,
    required this.subheadline,
    required this.footnote,
    required this.caption2,
  });

  static const _title = TextStyle(fontSize: 20, fontWeight: FontWeight.w600);

  /// Dialog titles and headings (20). The same size as [title3].
  final TextStyle title;

  /// Field input, messages and running text (16).
  final TextStyle body;

  /// Field labels (14).
  final TextStyle label;

  /// Button text (16).
  final TextStyle button;

  /// Hints under fields, small notes (12).
  final TextStyle caption;

  /// The big title at the top of a screen (34).
  final TextStyle largeTitle;

  /// First level heading (28).
  final TextStyle title1;

  /// Second level heading (22).
  final TextStyle title2;

  /// Third level heading, e.g. a section (20).
  final TextStyle title3;

  /// The main line of a list row or card (17, semibold).
  final TextStyle headline;

  /// Notes and short explanations next to content (16).
  final TextStyle callout;

  /// The second line of a row or card (15).
  final TextStyle subheadline;

  /// Small print under content (13).
  final TextStyle footnote;

  /// The smallest text, e.g. a time stamp (11).
  final TextStyle caption2;

  static TextStyle _withFont(TextStyle style, String? fontFamily) =>
      fontFamily == null || style.fontFamily != null
      ? style
      : style.copyWith(fontFamily: fontFamily);

  BrixTypography copyWith({
    TextStyle? title,
    TextStyle? body,
    TextStyle? label,
    TextStyle? button,
    TextStyle? caption,
    TextStyle? largeTitle,
    TextStyle? title1,
    TextStyle? title2,
    TextStyle? title3,
    TextStyle? headline,
    TextStyle? callout,
    TextStyle? subheadline,
    TextStyle? footnote,
    TextStyle? caption2,
  }) {
    return BrixTypography._(
      title: title ?? this.title,
      body: body ?? this.body,
      label: label ?? this.label,
      button: button ?? this.button,
      caption: caption ?? this.caption,
      largeTitle: largeTitle ?? this.largeTitle,
      title1: title1 ?? this.title1,
      title2: title2 ?? this.title2,
      title3: title3 ?? this.title3,
      headline: headline ?? this.headline,
      callout: callout ?? this.callout,
      subheadline: subheadline ?? this.subheadline,
      footnote: footnote ?? this.footnote,
      caption2: caption2 ?? this.caption2,
    );
  }

  /// Blends from this to [other] while the theme animates.
  BrixTypography lerp(BrixTypography other, double t) {
    TextStyle mix(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t)!;
    return BrixTypography._(
      title: mix(title, other.title),
      body: mix(body, other.body),
      label: mix(label, other.label),
      button: mix(button, other.button),
      caption: mix(caption, other.caption),
      largeTitle: mix(largeTitle, other.largeTitle),
      title1: mix(title1, other.title1),
      title2: mix(title2, other.title2),
      title3: mix(title3, other.title3),
      headline: mix(headline, other.headline),
      callout: mix(callout, other.callout),
      subheadline: mix(subheadline, other.subheadline),
      footnote: mix(footnote, other.footnote),
      caption2: mix(caption2, other.caption2),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BrixTypography &&
      other.title == title &&
      other.body == body &&
      other.label == label &&
      other.button == button &&
      other.caption == caption &&
      other.largeTitle == largeTitle &&
      other.title1 == title1 &&
      other.title2 == title2 &&
      other.title3 == title3 &&
      other.headline == headline &&
      other.callout == callout &&
      other.subheadline == subheadline &&
      other.footnote == footnote &&
      other.caption2 == caption2;

  @override
  int get hashCode => Object.hash(
    title,
    body,
    label,
    button,
    caption,
    largeTitle,
    title1,
    title2,
    title3,
    headline,
    callout,
    subheadline,
    footnote,
    caption2,
  );
}
