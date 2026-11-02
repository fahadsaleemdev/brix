import 'package:flutter/material.dart';

import 'brix_icon.dart';

/// Every icon brix_ui shows on its own. Material icons by default; pass
/// your own (`BrixIcon(CupertinoIcons....)`, `BrixIcon.custom(svg)`).
class BrixUiIcons {
  const BrixUiIcons({
    this.warning = const BrixIcon(Icons.warning_amber_rounded),
    this.error = const BrixIcon(Icons.error_outline_rounded),
    this.success = const BrixIcon(Icons.check_circle_rounded),
    this.showPassword = const BrixIcon(Icons.visibility_outlined),
    this.hidePassword = const BrixIcon(Icons.visibility_off_outlined),
    this.selectChevron = const BrixIcon(Icons.unfold_more_rounded),
    this.selected = const BrixIcon(Icons.check_rounded),
    this.search = const BrixIcon(Icons.search_rounded),
    this.freeText = const BrixIcon(Icons.add_rounded),
  });

  /// `BrixDialog.warning`.
  final BrixIcon warning;

  /// `BrixDialog.error`.
  final BrixIcon error;

  /// `BrixToast.success`.
  final BrixIcon success;

  /// Password field button, while the text is hidden.
  final BrixIcon showPassword;

  /// Password field button, while the text is shown.
  final BrixIcon hidePassword;

  /// The end of a `BrixSelect` field.
  final BrixIcon selectChevron;

  /// Next to the chosen option in a `BrixSelect` menu or sheet.
  final BrixIcon selected;

  /// The search box of a searchable `BrixSelect` and `BrixSearchField`.
  final BrixIcon search;

  /// The "Use ..." row of `BrixSearchField`.
  final BrixIcon freeText;

  BrixUiIcons copyWith({
    BrixIcon? warning,
    BrixIcon? error,
    BrixIcon? success,
    BrixIcon? showPassword,
    BrixIcon? hidePassword,
    BrixIcon? selectChevron,
    BrixIcon? selected,
    BrixIcon? search,
    BrixIcon? freeText,
  }) {
    return BrixUiIcons(
      warning: warning ?? this.warning,
      error: error ?? this.error,
      success: success ?? this.success,
      showPassword: showPassword ?? this.showPassword,
      hidePassword: hidePassword ?? this.hidePassword,
      selectChevron: selectChevron ?? this.selectChevron,
      selected: selected ?? this.selected,
      search: search ?? this.search,
      freeText: freeText ?? this.freeText,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BrixUiIcons &&
      other.warning == warning &&
      other.error == error &&
      other.success == success &&
      other.showPassword == showPassword &&
      other.hidePassword == hidePassword &&
      other.selectChevron == selectChevron &&
      other.selected == selected &&
      other.search == search &&
      other.freeText == freeText;

  @override
  int get hashCode => Object.hash(
    warning,
    error,
    success,
    showPassword,
    hidePassword,
    selectChevron,
    selected,
    search,
    freeText,
  );
}
