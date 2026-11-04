import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/brix_theme_context.dart';
import 'brix_card_data.dart';
import 'brix_card_style.dart';

/// A surface for your own content: the theme's colour, corners, a soft
/// shadow and padding. What goes inside is yours; brix only gives the frame.
/// Like Flutter's `Card` it is as wide as its content; a `ListView` or a
/// `Column(crossAxisAlignment: CrossAxisAlignment.stretch)` makes it full width.
///
/// ```dart
/// BrixCard(child: Text('3 new orders today'))
///
/// BrixCard(
///   accentColor: Colors.green,           // e.g. a status
///   onTap: () => open(order),             // press effect and a light tap feel
///   child: OrderSummary(order),
/// )
/// ```
///
/// Change every card with `BrixTheme(card: BrixCardStyle(...))`, one card
/// with [style], or draw your own card with [builder] (or
/// `BrixTheme.cardBuilder`) while brix keeps the tap and the pressed state.
class BrixCard extends StatefulWidget {
  const BrixCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.accentColor,
    this.semanticLabel,
    this.style,
    this.builder,
  });

  final Widget child;

  /// Makes the card tappable: it shrinks a little while held down.
  final VoidCallback? onTap;

  final VoidCallback? onLongPress;

  /// A coloured strip on the leading edge, e.g. a status colour.
  final Color? accentColor;

  /// What screen readers say for a tappable card, in place of its content.
  final String? semanticLabel;

  /// This card's look, on top of `BrixTheme.card`.
  final BrixCardStyle? style;

  /// Draws this card instead of brix (wins over `BrixTheme.cardBuilder`).
  final BrixCardBuilder? builder;

  @override
  State<BrixCard> createState() => _BrixCardState();
}

class _BrixCardState extends State<BrixCard> {
  bool _pressed = false;

  bool get _tappable => widget.onTap != null || widget.onLongPress != null;

  void _press(bool pressed) {
    if (_pressed != pressed) setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    final brix = context.brix;
    final style = BrixCardStyle(
      color: brix.colors.surface,
      radius: brix.shape.radius,
      padding: EdgeInsets.all(brix.spacing.l),
      borderColor: brix.colors.border.withValues(alpha: 0.25),
      borderWidth: 1,
      shadow: const [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 16,
          offset: Offset(0, 6),
        ),
      ],
      accentWidth: 4,
      pressedScale: 0.98,
      haptics: true,
    ).merge(brix.card).merge(widget.style);

    final data = BrixCardData(
      child: widget.child,
      style: style,
      pressed: _pressed,
      tappable: _tappable,
      accentColor: widget.accentColor,
    );
    final custom = widget.builder ?? brix.cardBuilder;
    final card = custom != null ? custom(context, data) : _DefaultCard(data);

    if (!_tappable) return card;
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      excludeSemantics: widget.semanticLabel != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _press(true),
        onTapUp: (_) => _press(false),
        onTapCancel: () => _press(false),
        onTap: widget.onTap == null
            ? null
            : () {
                if (style.haptics ?? true) HapticFeedback.lightImpact();
                widget.onTap!();
              },
        onLongPress: widget.onLongPress,
        child: AnimatedScale(
          scale: _pressed ? style.pressedScale ?? 0.98 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: card,
        ),
      ),
    );
  }
}

/// The brix card: surface, corners, border, shadow and the accent strip.
class _DefaultCard extends StatelessWidget {
  const _DefaultCard(this.data);

  final BrixCardData data;

  @override
  Widget build(BuildContext context) {
    final style = data.style;
    final radius = BorderRadius.circular(style.radius ?? 12);
    final width = style.borderWidth ?? 1;
    final accent = data.accentColor;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.color,
        borderRadius: radius,
        border: width > 0
            ? Border.all(color: style.borderColor!, width: width)
            : null,
        boxShadow: style.shadow,
      ),
      child: ClipRRect(
        borderRadius: radius,
        // A Stack, not IntrinsicHeight + Row: the strip takes the card's
        // height without asking the content for intrinsic sizes, which a
        // LayoutBuilder inside (network images, adaptive layouts) cannot
        // give.
        child: accent == null
            ? Padding(padding: style.padding!, child: data.child)
            : Stack(
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: style.accentWidth ?? 4,
                    ),
                    child: Padding(padding: style.padding!, child: data.child),
                  ),
                  PositionedDirectional(
                    start: 0,
                    top: 0,
                    bottom: 0,
                    width: style.accentWidth ?? 4,
                    child: ColoredBox(color: accent),
                  ),
                ],
              ),
      ),
    );
  }
}
