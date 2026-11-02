import 'package:flutter/widgets.dart';

import 'brix_theme.dart';
import 'brix_window_size.dart';

/// `context.brix.colors.primary`, short for [BrixTheme.of], and
/// `context.brixWindow` for the window size class.
extension BrixThemeContext on BuildContext {
  BrixTheme get brix => BrixTheme.of(this);

  /// The size class of the window, from its width and the theme's
  /// breakpoints. Rebuilds only when the window size changes.
  BrixWindowSize get brixWindow =>
      brix.breakpoints.sizeFor(MediaQuery.sizeOf(this).width);
}
