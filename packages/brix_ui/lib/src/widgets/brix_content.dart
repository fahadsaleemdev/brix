import 'package:flutter/widgets.dart';

import '../theme/brix_theme_context.dart';

/// Keeps a column of content readable on every window: centred, no wider
/// than `BrixTheme.spacing.maxContentWidth`, with the page padding of the
/// window size (16 on phones, 24 on medium, 32 on wider windows).
///
/// ```dart
/// Scaffold(body: BrixContent(child: LoginForm()))
/// ```
class BrixContent extends StatelessWidget {
  const BrixContent({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;

  /// Default: `BrixTheme.spacing.maxContentWidth`. `double.infinity` lets
  /// the content use the whole width.
  final double? maxWidth;

  /// Default: the page padding of the window size on the sides, none on top
  /// and bottom.
  final EdgeInsetsGeometry? padding;

  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final spacing = context.brix.spacing;
    final side = spacing.page(context.brixWindow);
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? spacing.maxContentWidth,
        ),
        // Full width up to the maximum, so forms and lists fill the column.
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: padding ?? EdgeInsets.symmetric(horizontal: side),
            child: child,
          ),
        ),
      ),
    );
  }
}
