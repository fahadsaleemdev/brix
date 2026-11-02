import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BrixTypography scale', () {
    test('has the iOS sizes and keeps the old five styles as they were', () {
      final type = BrixTypography();
      expect(
        [
          type.largeTitle,
          type.title1,
          type.title2,
          type.title3,
          type.headline,
          type.body,
          type.callout,
          type.subheadline,
          type.footnote,
          type.caption,
          type.caption2,
        ].map((style) => style.fontSize),
        [34, 28, 22, 20, 17, 16, 16, 15, 13, 12, 11],
      );
      expect(type.title.fontSize, 20);
      expect(type.label.fontSize, 14);
      expect(type.button.fontSize, 16);
      expect(type.headline.fontWeight, FontWeight.w600);
    });

    test('fontFamily reaches every style that has no font of its own', () {
      final type = BrixTypography(
        fontFamily: 'Inter',
        footnote: const TextStyle(fontSize: 13, fontFamily: 'Mono'),
      );
      expect(type.largeTitle.fontFamily, 'Inter');
      expect(type.caption2.fontFamily, 'Inter');
      expect(type.footnote.fontFamily, 'Mono');
    });

    test('title3 follows a custom title unless it is set', () {
      const custom = TextStyle(fontSize: 21);
      expect(BrixTypography(title: custom).title3.fontSize, 21);
      expect(
        BrixTypography(
          title: custom,
          title3: const TextStyle(fontSize: 19),
        ).title3.fontSize,
        19,
      );
    });

    test('copyWith, lerp and equality cover the new styles', () {
      final a = BrixTypography();
      final b = a.copyWith(headline: const TextStyle(fontSize: 21));
      expect(b.headline.fontSize, 21);
      expect(b, isNot(a));
      expect(a, BrixTypography());
      expect(a.hashCode, BrixTypography().hashCode);
      expect(a.lerp(b, 0.5).headline.fontSize, 19);
    });
  });

  group('BrixBreakpoints and BrixWindowSize', () {
    test('size classes start at the Material 3 widths', () {
      const points = BrixBreakpoints();
      expect(points.sizeFor(0), BrixWindowSize.compact);
      expect(points.sizeFor(599.9), BrixWindowSize.compact);
      expect(points.sizeFor(600), BrixWindowSize.medium);
      expect(points.sizeFor(839), BrixWindowSize.medium);
      expect(points.sizeFor(840), BrixWindowSize.expanded);
      expect(points.sizeFor(1200), BrixWindowSize.large);
      expect(points.sizeFor(1600), BrixWindowSize.extraLarge);
    });

    test('custom breakpoints move the classes', () {
      expect(
        const BrixBreakpoints(medium: 700).sizeFor(650),
        BrixWindowSize.compact,
      );
    });

    test('isAtLeast compares sizes', () {
      expect(BrixWindowSize.expanded.isAtLeast(BrixWindowSize.medium), isTrue);
      expect(BrixWindowSize.compact.isAtLeastMedium, isFalse);
      expect(BrixWindowSize.medium.isAtLeastMedium, isTrue);
      expect(BrixWindowSize.values.first, BrixWindowSize.compact);
    });
  });

  group('BrixSpacing', () {
    test('page padding grows with the window', () {
      const spacing = BrixSpacing();
      expect(spacing.page(BrixWindowSize.compact), 16);
      expect(spacing.page(BrixWindowSize.medium), 24);
      expect(spacing.page(BrixWindowSize.expanded), 32);
      expect(spacing.page(BrixWindowSize.extraLarge), 32);
    });

    test('copyWith, lerp and equality', () {
      const a = BrixSpacing();
      final b = a.copyWith(l: 20);
      expect(b.l, 20);
      expect(a.lerp(b, 0.5).l, 18);
      expect(a, const BrixSpacing());
      expect(b, isNot(a));
    });
  });

  group('BrixTheme', () {
    test('carries spacing and breakpoints with defaults', () {
      final theme = BrixTheme.light();
      expect(theme.spacing, const BrixSpacing());
      expect(theme.breakpoints, const BrixBreakpoints());
      final changed = theme.copyWith(spacing: const BrixSpacing(l: 20));
      expect(changed.spacing.l, 20);
      expect(changed, isNot(theme));
      expect(theme.lerp(changed, 1).spacing.l, 20);
    });
  });

  group('context.brixWindow and BrixContent', () {
    Future<void> pump(
      WidgetTester tester,
      double width,
      Widget child, {
      BrixTheme? theme,
    }) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: (theme ?? BrixTheme.light()).toThemeData(),
          home: Scaffold(body: child),
        ),
      );
    }

    testWidgets('brixWindow follows the window width', (tester) async {
      late BrixWindowSize size;
      final probe = Builder(
        builder: (context) {
          size = context.brixWindow;
          return const SizedBox();
        },
      );
      await pump(tester, 390, probe);
      expect(size, BrixWindowSize.compact);
      await pump(tester, 900, probe);
      expect(size, BrixWindowSize.expanded);
    });

    testWidgets('BrixContent uses the page padding of the window', (
      tester,
    ) async {
      const key = Key('content');
      await pump(
        tester,
        390,
        const BrixContent(child: SizedBox(key: key, height: 10)),
      );
      expect(tester.getSize(find.byKey(key)).width, 390 - 32);
    });

    testWidgets('BrixContent stops at the max width on wide windows', (
      tester,
    ) async {
      const key = Key('content');
      await pump(
        tester,
        1300,
        const BrixContent(child: SizedBox(key: key, height: 10)),
      );
      expect(tester.getSize(find.byKey(key)).width, 640 - 64);
      expect(tester.getCenter(find.byKey(key)).dx, 650);
    });

    testWidgets('BrixContent takes its own max width and padding', (
      tester,
    ) async {
      const key = Key('content');
      await pump(
        tester,
        1300,
        const BrixContent(
          maxWidth: 400,
          padding: EdgeInsets.zero,
          child: SizedBox(key: key, height: 10),
        ),
      );
      expect(tester.getSize(find.byKey(key)).width, 400);
    });
  });
}
