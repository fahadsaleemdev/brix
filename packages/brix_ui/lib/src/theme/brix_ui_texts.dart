/// Every text brix_ui shows on its own. English by default; pass your own
/// for another language or wording.
///
/// ```dart
/// BrixTheme.light(texts: const BrixUiTexts(ok: 'ٹھیک ہے'))
/// ```
class BrixUiTexts {
  const BrixUiTexts({
    this.ok = 'OK',
    this.warningTitle = 'Please check',
    this.errorTitle = 'Something went wrong',
    this.showPassword = 'Show password',
    this.hidePassword = 'Hide password',
    this.requiredField = 'This field is required.',
    this.selectHint = 'Choose',
    this.searchHint = 'Search',
    this.noResults = 'No results',
    this.useFreeText = 'Use "{value}"',
  });

  /// The button that closes a dialog.
  final String ok;

  /// Title of `BrixDialog.warning` when none is given.
  final String warningTitle;

  /// Title of `BrixDialog.error` when none is given.
  final String errorTitle;

  /// Password field button, while the text is hidden.
  final String showPassword;

  /// Password field button, while the text is shown.
  final String hidePassword;

  /// Error of a required `BrixTextField` left empty.
  final String requiredField;

  /// Shown in an empty `BrixSelect`.
  final String selectHint;

  /// The search box of a searchable `BrixSelect` sheet.
  final String searchHint;

  /// Shown when a search finds nothing.
  final String noResults;

  /// The row that takes typed text that matches no option in
  /// `BrixSearchField`; `{value}` is replaced with the text.
  final String useFreeText;

  BrixUiTexts copyWith({
    String? ok,
    String? warningTitle,
    String? errorTitle,
    String? showPassword,
    String? hidePassword,
    String? requiredField,
    String? selectHint,
    String? searchHint,
    String? noResults,
    String? useFreeText,
  }) {
    return BrixUiTexts(
      ok: ok ?? this.ok,
      warningTitle: warningTitle ?? this.warningTitle,
      errorTitle: errorTitle ?? this.errorTitle,
      showPassword: showPassword ?? this.showPassword,
      hidePassword: hidePassword ?? this.hidePassword,
      requiredField: requiredField ?? this.requiredField,
      selectHint: selectHint ?? this.selectHint,
      searchHint: searchHint ?? this.searchHint,
      noResults: noResults ?? this.noResults,
      useFreeText: useFreeText ?? this.useFreeText,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BrixUiTexts &&
      other.ok == ok &&
      other.warningTitle == warningTitle &&
      other.errorTitle == errorTitle &&
      other.showPassword == showPassword &&
      other.hidePassword == hidePassword &&
      other.requiredField == requiredField &&
      other.selectHint == selectHint &&
      other.searchHint == searchHint &&
      other.noResults == noResults &&
      other.useFreeText == useFreeText;

  @override
  int get hashCode => Object.hash(
    ok,
    warningTitle,
    errorTitle,
    showPassword,
    hidePassword,
    requiredField,
    selectHint,
    searchHint,
    noResults,
    useFreeText,
  );
}
