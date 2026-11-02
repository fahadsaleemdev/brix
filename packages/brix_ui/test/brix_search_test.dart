import 'dart:async';

import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _cities = [
  BrixOption(value: 'lon', label: 'London'),
  BrixOption(value: 'lis', label: 'Lisbon'),
  BrixOption(value: 'par', label: 'Paris'),
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
          label: 'City',
          searchable: true,
          options: _cities,
          onChanged: (value) => chosen = value,
        ),
      );
      await tester.tap(find.byType(BrixSelect<String>));
      await tester.pumpAndSettle();
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Paris'), findsOneWidget);

      await tester.enterText(find.byType(TextField).last, 'l');
      await tester.pump();
      expect(find.text('Paris'), findsNothing);
      expect(find.text('Lisbon'), findsOneWidget);

      await tester.tap(find.text('Lisbon'));
      await tester.pumpAndSettle();
      expect(chosen, 'lis');
    });

    testWidgets('shows No results when nothing matches', (tester) async {
      await _pump(
        tester,
        BrixSelect<String>(searchable: true, options: _cities),
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
          label: 'City',
          options: _cities,
          onSelected: (value) => picked = value,
        ),
      );
      await _type(tester, 'on');
      expect(find.text('London'), findsOneWidget);
      expect(find.text('Lisbon'), findsOneWidget);
      expect(find.text('Paris'), findsNothing);

      await tester.tap(find.text('Lisbon'));
      await tester.pump();
      expect(picked, 'lis');
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Lisbon',
      );
      expect(find.text('London'), findsNothing); // list closed
    });

    testWidgets('waits for minLength', (tester) async {
      await _pump(
        tester,
        BrixSearchField<String>(options: _cities, minLength: 3),
      );
      await _type(tester, 'lo');
      expect(find.text('London'), findsNothing);
      await _type(tester, 'lon');
      expect(find.text('London'), findsOneWidget);
    });

    testWidgets('offers the typed text when nothing matches', (tester) async {
      String? free;
      await _pump(
        tester,
        BrixSearchField<String>(
          options: _cities,
          onFreeText: (text) => free = text,
        ),
      );
      await _type(tester, 'Springfield');
      expect(find.text('Use "Springfield"'), findsOneWidget);
      expect(find.text('No results'), findsNothing);
      await tester.tap(find.text('Use "Springfield"'));
      await tester.pump();
      expect(free, 'Springfield');
    });

    testWidgets('no Use row for an exact match or without onFreeText', (
      tester,
    ) async {
      await _pump(
        tester,
        BrixSearchField<String>(options: _cities, onFreeText: (_) {}),
      );
      await _type(tester, 'paris');
      expect(find.textContaining('Use "'), findsNothing);

      await _pump(tester, BrixSearchField<String>(options: _cities));
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
          options: _cities,
          onSelected: (value) => picked = value,
          onFreeText: (text) => free = text,
        ),
      );
      await _type(tester, 'paris');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      expect(picked, 'par');

      await _type(tester, 'Old Town');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      expect(free, 'Old Town');
    });

    testWidgets('a required field checks that something is typed', (
      tester,
    ) async {
      await _pump(
        tester,
        BrixSearchField<String>(options: _cities, isRequired: true),
      );
      final form = tester.state<FormState>(find.byType(Form));
      expect(form.validate(), isFalse);
      await tester.pump();
      expect(find.text('This field is required.'), findsOneWidget);
    });
  });

  testWidgets('initialValue fills the field and follows a new value', (
    tester,
  ) async {
    Widget field(String value) =>
        BrixSearchField<String>(options: _cities, initialValue: value);
    await _pump(tester, field('Paris'));
    TextEditingController text() =>
        tester.widget<TextField>(find.byType(TextField)).controller!;
    expect(text().text, 'Paris');
    await _pump(tester, field('London'));
    await tester.pump();
    expect(text().text, 'London');
    expect(find.text('Lisbon'), findsNothing); // no list while idle
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
      await _type(tester, 'l');
      await _type(tester, 'lo');
      await _type(tester, 'lon');
      expect(find.byType(BrixLoader), findsOneWidget);
      expect(calls, isEmpty);

      await tester.pump(const Duration(milliseconds: 300));
      expect(calls, ['lon']); // one call after typing stops

      answer.complete(_cities.take(2).toList());
      await tester.pump();
      expect(find.byType(BrixLoader), findsNothing);
      expect(find.text('London'), findsOneWidget);
    });

    testWidgets('an older answer never replaces a newer one', (tester) async {
      final answers = <String, Completer<List<BrixOption<String>>>>{};
      await _pump(
        tester,
        BrixSearchField<String>(
          search: (text) => (answers[text] = Completer()).future,
        ),
      );
      await _type(tester, 'lon');
      await tester.pump(const Duration(milliseconds: 300));
      await _type(tester, 'par');
      await tester.pump(const Duration(milliseconds: 300));

      answers['par']!.complete([_cities[2]]);
      await tester.pump();
      answers['lon']!.complete(_cities.take(2).toList());
      await tester.pump();
      expect(find.text('Paris'), findsOneWidget);
      expect(find.text('London'), findsNothing);
    });

    testWidgets('an error shows a short message, not a crash', (tester) async {
      await _pump(
        tester,
        BrixSearchField<String>(
          search: (_) async => throw StateError('offline'),
        ),
      );
      await _type(tester, 'lon');
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
