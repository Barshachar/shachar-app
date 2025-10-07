import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_utils/offline_supabase.dart';

import '../test_utils/tester_view_compat.dart';
import 'smoke_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    await ensureSupabaseForTests();
  });

  testWidgets(
    'core customer/vendor screens render without overflow on iPhone SE',
    (WidgetTester tester) async {
      Intl.defaultLocale = 'en_US';
      await tester.setDevicePixelRatio(1.0);
      await tester.setSurfaceSize(const Size(320, 568));

      final SmokeFixture fixture = SmokeFixture();

      final List<SmokeScenario> scenarios = <SmokeScenario>[
        SmokeScenario('CatalogPage', () => fixture.buildCatalogScenario()),
        SmokeScenario('ProductPage', () => fixture.buildProductScenario()),
        SmokeScenario(
            'QuickOrderPage', () => fixture.buildQuickOrderScenario()),
        SmokeScenario('CartPage', () => fixture.buildCartScenario()),
        SmokeScenario('CheckoutPage', () => fixture.buildCheckoutScenario()),
        SmokeScenario(
            'OrderDetailPage', () => fixture.buildOrderDetailScenario()),
        SmokeScenario('OrdersPage', () => fixture.buildOrdersScenario()),
        SmokeScenario(
          'VendorShipmentsPage',
          () => fixture.buildVendorShipmentsScenario(),
        ),
        SmokeScenario(
          'CustomerRfqsPage',
          () => fixture.buildCustomerRfqsScenario(),
        ),
        SmokeScenario(
            'VendorRfqsPage', () => fixture.buildVendorRfqsScenario()),
      ];

      for (final SmokeScenario scenario in scenarios) {
        await tester.pumpWidget(scenario.build());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        expect(
          tester.takeException(),
          isNull,
          reason: 'No overflow on SE for ${scenario.name}',
        );
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
      }
    },
  );
}
