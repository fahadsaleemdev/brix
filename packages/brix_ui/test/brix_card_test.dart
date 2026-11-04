import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Widget card, {BrixTheme? theme}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: (theme ?? BrixTheme.light()).toThemeData(),
      home: Scaffold(body: Center(child: card)),
    ),
  );
}

BoxDecoration _decoration(WidgetTester tester) =>
    tester
            .widget<DecoratedBox>(
              find
                  .descendant(
                    of: find.byType(BrixCard),
                    matching: find.byType(DecoratedBox),
                  )
                  .first,
            )
            .decoration
        as BoxDecoration;

double _scale(WidgetTester tester) =>
    tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;

void main() {
  testWidgets('uses the theme surface, radius and spacing', (tester) async {
    await _pump(tester, const BrixCard(child: Text('Hello')));
    final theme = BrixTheme.light();
    final box = _decoration(tester);
    expect(box.color, theme.colors.surface);
    expect(box.borderRadius, BorderRadius.circular(theme.shape.radius));
    expect(box.boxShadow, isNotEmpty);
    final padding = tester.widget<Padding>(
      find
          .ancestor(of: find.text('Hello'), matching: find.byType(Padding))
          .first,
    );
    expect(padding.padding, EdgeInsets.all(theme.spacing.l));
    expect(find.byType(AnimatedScale), findsNothing); // not tappable
  });

  testWidgets('a tappable card shrinks while held and calls onTap', (
    tester,
  ) async {
    var taps = 0;
    await _pump(
      tester,
      BrixCard(onTap: () => taps++, child: const Text('Open')),
    );
    expect(_scale(tester), 1);
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Open')),
    );
    await tester.pump();
    expect(_scale(tester), 0.98);
    await gesture.up();
    await tester.pump();
    expect(_scale(tester), 1);
    expect(taps, 1);
  });

  testWidgets('a tappable card is a button for screen readers', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pump(
      tester,
      BrixCard(
        onTap: () {},
        semanticLabel: 'Order 42',
        child: const Text('Order 42'),
      ),
    );
    final node = tester.getSemantics(find.byType(BrixCard));
    expect(node.label, 'Order 42');
    expect(node.flagsCollection.isButton, isTrue);
    semantics.dispose();
  });

  testWidgets('accentColor draws a strip on the leading edge', (tester) async {
    await _pump(
      tester,
      const BrixCard(
        accentColor: Colors.green,
        style: BrixCardStyle(accentWidth: 6),
        child: Text('Paid'),
      ),
    );
    final strip = tester.widget<ColoredBox>(
      find.descendant(
        of: find.byType(BrixCard),
        matching: find.byType(ColoredBox),
      ),
    );
    expect(strip.color, Colors.green);
    expect(tester.getSize(find.byWidget(strip)).width, 6);
  });

  testWidgets('an accent card lays out a LayoutBuilder child (no '
      'intrinsic sizes asked)', (tester) async {
    await _pump(
      tester,
      BrixCard(
        accentColor: Colors.green,
        // Like a network image that sizes itself from its constraints.
        child: LayoutBuilder(
          builder: (_, constraints) =>
              SizedBox(height: 80, child: Text('w ${constraints.maxWidth}')),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final strip = find.descendant(
      of: find.byType(BrixCard),
      matching: find.byType(ColoredBox),
    );
    // The strip runs the full height of the content.
    expect(tester.getSize(strip).height, greaterThanOrEqualTo(80));
  });

  testWidgets('the accent strip sits on the leading edge in RTL too', (
    tester,
  ) async {
    await _pump(
      tester,
      const Directionality(
        textDirection: TextDirection.rtl,
        child: BrixCard(accentColor: Colors.green, child: Text('Paid')),
      ),
    );
    final card = tester.getRect(find.byType(BrixCard));
    final strip = tester.getRect(
      find.descendant(
        of: find.byType(BrixCard),
        matching: find.byType(ColoredBox),
      ),
    );
    expect(strip.right, closeTo(card.right, 1.5));
  });

  testWidgets('theme card style, then the card style on top', (tester) async {
    await _pump(
      tester,
      const BrixCard(style: BrixCardStyle(radius: 4), child: Text('Hi')),
      theme: BrixTheme.light(
        card: const BrixCardStyle(
          color: Colors.amber,
          radius: 20,
          shadow: [],
          borderWidth: 0,
        ),
      ),
    );
    final box = _decoration(tester);
    expect(box.color, Colors.amber);
    expect(box.borderRadius, BorderRadius.circular(4));
    expect(box.boxShadow, isEmpty);
    expect(box.border, isNull);
  });

  testWidgets('pressedScale 1 turns the press effect off', (tester) async {
    await _pump(
      tester,
      BrixCard(
        onTap: () {},
        style: const BrixCardStyle(pressedScale: 1),
        child: const Text('Still'),
      ),
    );
    await tester.startGesture(tester.getCenter(find.text('Still')));
    await tester.pump();
    expect(_scale(tester), 1);
  });

  testWidgets('a builder draws the card; brix keeps tap and pressed state', (
    tester,
  ) async {
    final seen = <bool>[];
    var taps = 0;
    await _pump(
      tester,
      BrixCard(
        onTap: () => taps++,
        accentColor: Colors.red,
        builder: (context, card) {
          seen.add(card.pressed);
          expect(card.tappable, isTrue);
          expect(card.accentColor, Colors.red);
          return ColoredBox(color: Colors.black, child: card.child);
        },
        child: const Text('Own'),
      ),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Own')),
    );
    await tester.pump();
    await gesture.up();
    await tester.pump();
    expect(seen, containsAllInOrder([false, true, false]));
    expect(taps, 1);
  });

  testWidgets('theme cardBuilder is used; a card builder wins', (tester) async {
    final theme = BrixTheme.light(
      cardBuilder: (context, card) => Container(key: const Key('theme')),
    );
    await _pump(tester, const BrixCard(child: Text('x')), theme: theme);
    expect(find.byKey(const Key('theme')), findsOneWidget);

    await _pump(
      tester,
      BrixCard(
        builder: (context, card) => Container(key: const Key('own')),
        child: const Text('x'),
      ),
      theme: theme,
    );
    expect(find.byKey(const Key('own')), findsOneWidget);
    expect(find.byKey(const Key('theme')), findsNothing);
  });

  test('BrixCardStyle merge, lerp and equality', () {
    const a = BrixCardStyle(radius: 8, color: Color(0xFF000000));
    const b = BrixCardStyle(radius: 16);
    expect(a.merge(b).radius, 16);
    expect(a.merge(b).color, const Color(0xFF000000));
    expect(a.merge(null), a);
    expect(a.lerp(b, 0.5).radius, 12);
    expect(
      const BrixCardStyle(shadow: [BoxShadow(blurRadius: 2)]),
      const BrixCardStyle(shadow: [BoxShadow(blurRadius: 2)]),
    );
    expect(a, isNot(b));
  });

  test('BrixTheme carries the card style through copyWith and lerp', () {
    final theme = BrixTheme.light();
    expect(theme.card, const BrixCardStyle());
    final round = theme.copyWith(card: const BrixCardStyle(radius: 24));
    expect(round.card.radius, 24);
    expect(round, isNot(theme));
    expect(theme.lerp(round, 1).card.radius, 24);
  });
}
