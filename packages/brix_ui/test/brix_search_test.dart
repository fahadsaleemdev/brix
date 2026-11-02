import 'dart:async';

import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _inverters = [
  BrixOption(value: 'sun5', label: 'SUN2000-5KTL'),
  BrixOption(value: 'sun10', label: 'SUN2000-10KTL'),
  BrixOption(value: 'sg10', label: 'SG 10 RT'),
];

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: BrixTheme.light().toThemeData(),
      home: Scaffold(
        body: Form(
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    ),
  );
}

Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField).first, text);
  await tester.pump();
}

void main() {
  group('BrixSelect searchable', () {
    testWidgets('opens a sheet with a search box that narrows the options', (
      tester,
    ) async {
      String? chosen;
      await _pump(
        tester,
        BrixSelect<String>(
          label: 'Inverter',
          searchable: true,
          options: _inverters,
          onChanged: (value) => chosen = value,
        ),
      );
      await tester.tap(find.byType(BrixSelect<String>));
      await tester.pumpAndSettle();
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('SG 10 RT'), findsOneWidget);

      await tester.enterText(find.byType(TextField).last, 'sun');
      await tester.pump();
      expect(find.text('SG 10 RT'), findsNothing);
      expect(find.text('SUN2000-10KTL'), findsOneWidget);

      await tester.tap(find.text('SUN2000-10KTL'));
      await tester.pumpAndSettle();
      expect(chosen, 'sun10');
    });

    testWidgets('shows No results when nothing matches', (tester) async {
      await _pump(
        tester,
        BrixSelect<String>(searchable: true, options: _inverters),
      );
      await tester.tap(find.byType(BrixSelect<String>));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'xyz');
      await tester.pump();
      expect(find.text('No results'), findsOneWidget);
    });
  });

  group('BrixSearchField with a list', () {
    testWidgets('filters by label and picks an option', (tester) async {
      String? picked;
      await _pump(
        tester,
        BrixSearchField<String>(
          label: 'Model',
          options: _inverters,
          onSelected: (value) => picked = value,
        ),
      );
      await _type(tester, '10');
      expect(find.text('SUN2000-10KTL'), findsOneWidget);
      expect(find.text('SG 10 RT'), findsOneWidget);
      expect(find.text('SUN2000-5KTL'), findsNothing);

      await tester.tap(find.text('SG 10 RT'));
      await tester.pump();
      expect(picked, 'sg10');
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'SG 10 RT',
      );
      expect(find.text('SUN2000-10KTL'), findsNothing); // list closed
    });

    testWidgets('waits for minLength', (tester) async {
      await _pump(
        tester,
        BrixSearchField<String>(options: _inverters, minLength: 3),
      );
      await _type(tester, 'su');
      expect(find.text('SUN2000-5KTL'), findsNothing);
      await _type(tester, 'sun');
      expect(find.text('SUN2000-5KTL'), findsOneWidget);
    });

    testWidgets('offers the typed text when nothing matches', (tester) async {
      String? free;
      await _pump(
        tester,
        BrixSearchField<String>(
          options: _inverters,
          onFreeText: (text) => free = text,
        ),
      );
      await _type(tester, 'My Custom 7K');
      expect(find.text('Use "My Custom 7K"'), findsOneWidget);
      expect(find.text('No results'), findsNothing);
      await tester.tap(find.text('Use "My Custom 7K"'));
      await tester.pump();
      expect(free, 'My Custom 7K');
    });

    testWidgets('no Use row for an exact match or without onFreeText', (
      tester,
    ) async {
      await _pump(
        tester,
        BrixSearchField<String>(options: _inverters, onFreeText: (_) {}),
      );
      await _type(tester, 'sg 10 rt');
      expect(find.textContaining('Use "'), findsNothing);

      await _pump(tester, BrixSearchField<String>(options: _inverters));
      await _type(tester, 'xyz');
      expect(find.textContaining('Use "'), findsNothing);
      expect(find.text('No results'), findsOneWidget);
    });

    testWidgets('done on the keyboard picks an exact match or the free text', (
      tester,
    ) async {
      String? picked;
      String? free;
      await _pump(
        tester,
        BrixSearchField<String>(
          options: _inverters,
          onSelected: (value) => picked = value,
          onFreeText: (text) => free = text,
        ),
      );
      await _type(tester, 'sg 10 rt');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      expect(picked, 'sg10');

      await _type(tester, 'Other 3K');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      expect(free, 'Other 3K');
    });

    testWidgets('a required field checks that something is typed', (
      tester,
    ) async {
      await _pump(
        tester,
        BrixSearchField<String>(options: _inverters, isRequired: true),
      );
      final form = tester.state<FormState>(find.byType(Form));
      expect(form.validate(), isFalse);
      await tester.pump();
      expect(find.text('This field is required.'), findsOneWidget);
    });
  });

  group('BrixSearchField with a backend', () {
    testWidgets('waits for the pause, shows a loader, then the answer', (
      tester,
    ) async {
      final calls = <String>[];
      final answer = Completer<List<BrixOption<String>>>();
      await _pump(
        tester,
        BrixSearchField<String>(
          search: (text) {
            calls.add(text);
            return answer.future;
          },
        ),
      );
      await _type(tester, 's');
      await _type(tester, 'su');
      await _type(tester, 'sun');
      expect(find.byType(BrixLoader), findsOneWidget);
      expect(calls, isEmpty);

      await tester.pump(const Duration(milliseconds: 300));
      expect(calls, ['sun']); // one call after typing stops

      answer.complete(_inverters.take(2).toList());
      await tester.pump();
      expect(find.byType(BrixLoader), findsNothing);
      expect(find.text('SUN2000-5KTL'), findsOneWidget);
    });

    testWidgets('an older answer never replaces a newer one', (tester) async {
      final answers = <String, Completer<List<BrixOption<String>>>>{};
      await _pump(
        tester,
        BrixSearchField<String>(
          search: (text) => (answers[text] = Completer()).future,
        ),
      );
      await _type(tester, 'sun');
      await tester.pump(const Duration(milliseconds: 300));
      await _type(tester, 'sg');
      await tester.pump(const Duration(milliseconds: 300));

      answers['sg']!.complete([_inverters[2]]);
      await tester.pump();
      answers['sun']!.complete(_inverters.take(2).toList());
      await tester.pump();
      expect(find.text('SG 10 RT'), findsOneWidget);
      expect(find.text('SUN2000-5KTL'), findsNothing);
    });

    testWidgets('an error shows a short message, not a crash', (tester) async {
      await _pump(
        tester,
        BrixSearchField<String>(
          search: (_) async => throw StateError('offline'),
        ),
      );
      await _type(tester, 'sun');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      expect(find.text('Something went wrong'), findsOneWidget);
    });
  });

  test('texts and icons for search have defaults', () {
    const texts = BrixUiTexts();
    expect(texts.searchHint, 'Search');
    expect(texts.noResults, 'No results');
    expect(texts.useFreeText, 'Use "{value}"');
    expect(texts.copyWith(noResults: 'Kuch nahi mila'), isNot(texts));
    const icons = BrixUiIcons();
    expect(icons.copyWith(search: icons.freeText).search, icons.freeText);
  });
}
