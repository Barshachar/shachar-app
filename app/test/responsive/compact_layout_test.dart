import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_utils/offline_supabase.dart';

import '../smoke/smoke_fixture.dart';
import '../test_utils/tester_view_compat.dart';

Future<void> _prepareCompactSurface(WidgetTester tester) async {
  await tester.setDevicePixelRatio(1.0);
  await tester.setSurfaceSize(const Size(320, 568));
}

Future<void> _pumpScenario(WidgetTester tester, Widget widget) async {
  await _prepareCompactSurface(tester);
  await tester.pumpWidget(widget);
  await tester.pumpAndSettle();
}

Future<void> _clearSurface(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    await ensureSupabaseForTests();
    Intl.defaultLocale = 'en_US';
  });

  testWidgets('core flows render without overflow on compact surface',
      (WidgetTester tester) async {
    final SmokeFixture fixture = SmokeFixture();

    // Checkout dropdowns
    await _pumpScenario(tester, fixture.buildCheckoutScenario());
    expect(tester.takeException(), isNull);
    final checkoutDropdowns = tester.allWidgets
        .whereType<DropdownButtonFormField<dynamic>>()
        .toList();
    expect(checkoutDropdowns.length, greaterThanOrEqualTo(2),
        reason: 'dropdown count=${checkoutDropdowns.length}');
    expect(
      tester.getSize(find.byWidget(checkoutDropdowns.first)).width,
      lessThanOrEqualTo(320),
    );
    await _clearSurface(tester);

    // Cart totals row
    await _pumpScenario(tester, fixture.buildCartScenario());
    expect(tester.takeException(), isNull);
    expect(find.textContaining('Subtotal:'), findsWidgets);
    await _clearSurface(tester);

    // Quick order filters
    await _pumpScenario(tester, fixture.buildQuickOrderScenario());
    expect(tester.takeException(), isNull);
    final quickOrderDropdowns = tester.allWidgets
        .whereType<DropdownButtonFormField<dynamic>>()
        .toList();
    expect(quickOrderDropdowns.isNotEmpty, isTrue,
        reason: 'dropdown count=${quickOrderDropdowns.length}');
    expect(
      tester.getSize(find.byWidget(quickOrderDropdowns.first)).width,
      lessThanOrEqualTo(320),
    );
    await _clearSurface(tester);

    // Catalog add-to-cart button
    await _pumpScenario(tester, fixture.buildCatalogScenario());
    expect(tester.takeException(), isNull);
    expect(
      tester.allWidgets.any(
        (Widget widget) =>
            widget.key == const ValueKey('catalog_add_btn_variant-green'),
      ),
      isTrue,
      reason: 'catalog button missing',
    );
    await _clearSurface(tester);
  });
}
