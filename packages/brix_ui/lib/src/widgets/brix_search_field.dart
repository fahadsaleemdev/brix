import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/brix_theme_context.dart';
import 'brix_loader.dart';
import 'brix_option.dart';
import 'brix_select_style.dart';
import 'brix_text_field.dart';
import 'brix_text_field_style.dart';

/// A text field that suggests options under it while you type, like a
/// search box. The options come from a list you already have ([options]) or
/// from your backend ([search], e.g. through `BrixOfflineCache` so it also
/// works offline).
///
/// ```dart
/// BrixSearchField<Inverter>(
///   label: 'Inverter model',
///   search: (text) => repository.searchInverters(text),
///   onSelected: (inverter) => setState(() => model = inverter),
///   onFreeText: (text) => setState(() => customModel = text),
/// )
/// ```
///
/// With [onFreeText], text that matches no option can be used too: a
/// "Use ..." row appears under the options. What the app shows next (extra
/// fields, a note) is up to the app; brix shows nothing more.
class BrixSearchField<T> extends StatefulWidget {
  const BrixSearchField({
    super.key,
    this.options,
    this.search,
    this.onSelected,
    this.onFreeText,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.label,
    this.hint,
    this.isRequired = false,
    this.requiredMessage,
    this.validator,
    this.errorText,
    this.enabled = true,
    this.minLength = 1,
    this.debounce = const Duration(milliseconds: 300),
    this.maxListHeight = 280,
    this.fieldStyle,
    this.style,
  }) : assert(
         options != null || search != null,
         'Give options (a list you have) or search (your backend).',
       );

  /// Options you already have; they are filtered on the device by label.
  final List<BrixOption<T>>? options;

  /// Options from your backend for the typed text. Called after the user
  /// stops typing for [debounce]; an older answer never replaces a newer
  /// one, and an error shows a short message instead of crashing.
  final Future<List<BrixOption<T>>> Function(String text)? search;

  /// Called with the value of the option the user picked.
  final ValueChanged<T>? onSelected;

  /// When given, typed text that matches no option can be used: the user
  /// taps the "Use ..." row or presses done on the keyboard.
  final ValueChanged<String>? onFreeText;

  /// The typed text. Give one to set a starting text or read it later.
  final TextEditingController? controller;

  /// The starting text when no [controller] is given, e.g. a value saved
  /// earlier. Rebuilding with a new value replaces the text while the field
  /// is not being edited.
  final String? initialValue;

  final FocusNode? focusNode;

  /// Shown above the field.
  final String? label;

  /// Shown while the field is empty. Default: the theme's `searchHint`.
  final String? hint;

  /// Adds the required marker and, without a [validator], a check that
  /// something is typed.
  final bool isRequired;

  final String? requiredMessage;
  final FormFieldValidator<String>? validator;

  /// An error from outside the form (e.g. the backend).
  final String? errorText;

  final bool enabled;

  /// How many characters before options show.
  final int minLength;

  /// How long typing must pause before [search] runs.
  final Duration debounce;

  /// The tallest the list under the field grows; it scrolls after that.
  final double maxListHeight;

  /// This field's look, on top of `BrixTheme.textField`.
  final BrixTextFieldStyle? fieldStyle;

  /// The list's look, on top of `BrixTheme.select`.
  final BrixSelectStyle? style;

  @override
  State<BrixSearchField<T>> createState() => _BrixSearchFieldState<T>();
}

class _BrixSearchFieldState<T> extends State<BrixSearchField<T>> {
  final _link = LayerLink();
  final _portal = OverlayPortalController();
  TextEditingController? _ownController;
  FocusNode? _ownFocus;
  Timer? _timer;
  int _request = 0;

  List<BrixOption<T>> _results = const [];
  bool _loading = false;
  bool _failed = false;
  bool _searched = false;
  double _width = 0;

  TextEditingController get _controller =>
      widget.controller ??
      (_ownController ??= TextEditingController(text: widget.initialValue));
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());
  String get _text => _controller.text.trim();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_focusChanged);
  }

  @override
  void didUpdateWidget(BrixSearchField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final text = widget.initialValue;
    if (widget.controller == null &&
        text != oldWidget.initialValue &&
        text != null) {
      // The field shows the app's new value from the next frame on.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_focus.hasFocus && _controller.text != text) {
          _controller.text = text;
        }
      });
    }
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownFocus)?.removeListener(_focusChanged);
      _focus.addListener(_focusChanged);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _focus.removeListener(_focusChanged);
    _ownController?.dispose();
    _ownFocus?.dispose();
    super.dispose();
  }

  void _focusChanged() {
    if (_focus.hasFocus && _text.length >= widget.minLength) {
      _changed(_controller.text);
    } else if (!_focus.hasFocus) {
      _portal.hide();
    }
  }

  void _changed(String _) {
    _timer?.cancel();
    final text = _text;
    if (text.length < widget.minLength) {
      setState(() {
        _results = const [];
        _loading = _failed = _searched = false;
      });
      _portal.hide();
      return;
    }
    final options = widget.options;
    if (options != null) {
      final query = text.toLowerCase();
      setState(() {
        _results = options
            .where((option) => option.label.toLowerCase().contains(query))
            .toList();
        _loading = _failed = false;
        _searched = true;
      });
      _portal.show();
      return;
    }
    setState(() {
      _loading = true;
      _failed = false;
    });
    _portal.show();
    final request = ++_request;
    _timer = Timer(widget.debounce, () async {
      try {
        final found = await widget.search!(text);
        if (!mounted || request != _request) return;
        setState(() {
          _results = found;
          _loading = _failed = false;
          _searched = true;
        });
      } catch (_) {
        if (!mounted || request != _request) return;
        setState(() {
          _results = const [];
          _loading = false;
          _failed = _searched = true;
        });
      }
    });
  }

  bool get _showFreeRow =>
      widget.onFreeText != null &&
      _text.isNotEmpty &&
      !_loading &&
      !_results.any(
        (option) => option.label.toLowerCase() == _text.toLowerCase(),
      );

  void _pick(BrixOption<T> option) {
    _controller.value = TextEditingValue(
      text: option.label,
      selection: TextSelection.collapsed(offset: option.label.length),
    );
    _close();
    widget.onSelected?.call(option.value);
  }

  void _useFreeText() {
    final text = _text;
    _close();
    widget.onFreeText?.call(text);
  }

  void _submit(String _) {
    final match = _results.where(
      (option) => option.label.toLowerCase() == _text.toLowerCase(),
    );
    if (match.isNotEmpty) {
      _pick(match.first);
    } else if (widget.onFreeText != null && _text.isNotEmpty) {
      _useFreeText();
    }
  }

  void _close() {
    _timer?.cancel();
    _request++;
    _portal.hide();
    _focus.unfocus();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final brix = context.brix;
    return LayoutBuilder(
      builder: (context, constraints) {
        _width = constraints.maxWidth;
        return OverlayPortal(
          controller: _portal,
          overlayChildBuilder: (_) => Positioned(
            width: _width,
            child: CompositedTransformFollower(
              link: _link,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomLeft,
              offset: const Offset(0, 6),
              // Taps on the list count as taps on the field, so the field
              // keeps its focus until an option is picked.
              child: TextFieldTapRegion(child: _list(context)),
            ),
          ),
          child: CompositedTransformTarget(
            link: _link,
            child: BrixTextField(
              controller: _controller,
              focusNode: _focus,
              label: widget.label,
              hint: widget.hint ?? brix.texts.searchHint,
              isRequired: widget.isRequired,
              requiredMessage: widget.requiredMessage,
              validator: widget.validator,
              errorText: widget.errorText,
              enabled: widget.enabled,
              prefixIcon: brix.icons.search.build(
                color: brix.colors.mutedText,
                size: 20,
              ),
              textInputAction: TextInputAction.search,
              onChanged: _changed,
              onSubmitted: _submit,
              style: widget.fieldStyle,
            ),
          ),
        );
      },
    );
  }

  Widget _list(BuildContext context) {
    final brix = context.brix;
    final style = brix.select.merge(widget.style);
    final rows = <Widget>[
      if (_loading)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: BrixLoader(),
        )
      else ...[
        for (final option in _results)
          _Row(
            label: option.label,
            leading: option.icon?.build(color: brix.colors.mutedText, size: 20),
            style: style,
            onTap: () => _pick(option),
          ),
        if (_results.isEmpty && _searched && !_showFreeRow)
          _Note(_failed ? brix.texts.errorTitle : brix.texts.noResults),
        if (_showFreeRow)
          _Row(
            label: brix.texts.useFreeText.replaceAll('{value}', _text),
            leading: brix.icons.freeText.build(
              color: style.selectedColor ?? brix.colors.primary,
              size: 20,
            ),
            color: style.selectedColor ?? brix.colors.primary,
            style: style,
            onTap: _useFreeText,
          ),
      ],
    ];
    return Material(
      color: style.menuColor ?? brix.colors.surface,
      elevation: 8,
      shadowColor: const Color(0x40000000),
      borderRadius: BorderRadius.circular(
        style.menuRadius ?? brix.shape.radius,
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: widget.maxListHeight),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 6),
          shrinkWrap: true,
          children: rows,
        ),
      ),
    );
  }
}

/// One row of the list: an option or the "Use ..." row.
class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.style,
    required this.onTap,
    this.leading,
    this.color,
  });

  final String label;
  final BrixSelectStyle style;
  final VoidCallback onTap;
  final Widget? leading;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final brix = context.brix;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
            style.optionPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: brix.typography.body
                    .copyWith(color: color ?? brix.colors.text)
                    .merge(style.optionStyle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A quiet line in the list: nothing found, or the search failed.
class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final brix = context.brix;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Text(
        text,
        style: brix.typography.body.copyWith(color: brix.colors.mutedText),
      ),
    );
  }
}
